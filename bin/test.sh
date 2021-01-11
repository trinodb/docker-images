#!/bin/bash

set -e

function retry() {
  END=$(($(date +%s) + 600))

  while (( $(date +%s) < $END )); do
    set +e
    "$@"
    EXIT_CODE=$?
    set -e

    if [[ ${EXIT_CODE} == 0 ]]; then
      break
    fi
    sleep 5
  done

  return ${EXIT_CODE}
}

function environment_compose() {
  docker-compose -f "${DOCKER_CONF_LOCATION}/${ENVIRONMENT}/docker-compose.yml" "$@"
}

function check_hadoop() {
  environment_compose exec hadoop-master hive -e 'select 1;' > /dev/null 2>&1
}

function run_hadoop_tests() {
  environment_compose exec hadoop-master hive -e 'SELECT 1' &&
  environment_compose exec hadoop-master hive -e 'CREATE TABLE foo (a INT);' &&
  environment_compose exec hadoop-master hive -e 'INSERT INTO foo VALUES (54);' &&
  # SELECT with WHERE to make sure that map-reduce job is scheduled
  environment_compose exec hadoop-master hive -e 'SELECT a FROM foo WHERE a > 0;' &&
  # Test table bucketing
  environment_compose exec hadoop-master hive -e '
    CREATE TABLE bucketed_table(a INT) CLUSTERED BY(a) INTO 32 BUCKETS;
    SET hive.enforce.bucketing = true;
    INSERT INTO bucketed_table VALUES (1), (2), (3), (4);
  ' &&
  test $(environment_compose exec hadoop-master hdfs dfs -ls /user/hive/warehouse/bucketed_table \
    | tee /dev/stderr | grep /bucketed_table/ | wc -l) -ge 4 &&
  true
}

function run_hive_transactional_tests() {
    environment_compose exec hadoop-master hive -e "
      CREATE TABLE transactional_table (x int) STORED AS orc TBLPROPERTIES ('transactional'='true');
      INSERT INTO transactional_table VALUES (1), (2), (3), (4);
    " &&
    environment_compose exec hadoop-master hive -e 'SELECT x FROM transactional_table WHERE x > 0;' &&
    environment_compose exec hadoop-master hive -e 'DELETE FROM transactional_table WHERE x = 2;' &&
    environment_compose exec hadoop-master hive -e 'UPDATE transactional_table SET x = 14 WHERE x = 4;' &&
    environment_compose exec hadoop-master hive -e 'SELECT x FROM transactional_table WHERE x > 0;' &&
    true
}

function check_gpdb() {
  environment_compose exec gpdb su gpadmin -l -c "pg_isready"
}

function run_gpdb_tests() {
    environment_compose exec gpdb su gpadmin -l -c "psql -c 'CREATE TABLE foo (a INT) DISTRIBUTED RANDOMLY'" &&
    environment_compose exec gpdb su gpadmin -l -c "psql -c 'INSERT INTO foo VALUES (54)'" &&
    environment_compose exec gpdb su gpadmin -l -c "psql -c 'SELECT a FROM foo'" &&
    true
}

function stop_all_containers() {
  local ENVIRONMENT
  for ENVIRONMENT in $(getAvailableEnvironments)
  do
     stop_docker_compose_containers ${ENVIRONMENT}
  done
}

function stop_docker_compose_containers() {
  local ENVIRONMENT=$1
  RUNNING_CONTAINERS=$(environment_compose ps -q)

  if [[ ! -z ${RUNNING_CONTAINERS} ]]; then
    # stop containers started with "up", removing their volumes
    # Some containers (SQL Server) fail to stop on Travis after running the tests. We don't have an easy way to
    # reproduce this locally. Since all the tests complete successfully, we ignore this failure.
    environment_compose down -v || true
  fi

  echo "Docker compose containers stopped: [$ENVIRONMENT]"
}

function cleanup() {
  stop_docker_compose_containers ${ENVIRONMENT}

  # Ensure that the logs processes are terminated.
  # In most cases after the docker containers are stopped, logs processes must be terminated.
  if [[ ! -z ${LOGS_PID} ]]; then
    kill ${LOGS_PID} 2>/dev/null || true
  fi

  # docker logs processes are being terminated as soon as docker container are stopped
  # wait for docker logs termination
  wait 2>/dev/null || true
}

function terminate() {
  trap - INT TERM EXIT
  set +e
  cleanup
  exit 130
}

function getAvailableEnvironments() {
  for i in $(ls -d $DOCKER_CONF_LOCATION/*/); do echo ${i%%/}; done \
     | grep -v files | grep -v common | xargs -n1 basename
}

SCRIPT_DIR=${BASH_SOURCE%/*}
PROJECT_ROOT="${SCRIPT_DIR}/.."
DOCKER_CONF_LOCATION="${PROJECT_ROOT}/etc/compose"

ENVIRONMENT=$1

# Get the list of valid environments
if [[ ! -f "$DOCKER_CONF_LOCATION/$ENVIRONMENT/docker-compose.yml" ]]; then
   echo "Usage: run_on_docker.sh <$(getAvailableEnvironments | tr '\n' '|')>"
   exit 1
fi

shift 1

# check docker and docker compose installation
docker-compose version
docker version

stop_all_containers

# catch terminate signals
trap terminate INT TERM EXIT

environment_compose up -d

# start docker logs for the external services
environment_compose logs --no-color -f &

LOGS_PID=$!

if [[ ${ENVIRONMENT} == *"gpdb"* ]]; then
    # wait until gpdb process is started
    retry check_gpdb

    # run tests
    set -x
    set +e
    sleep 10
    run_gpdb_tests
else
    # wait until hadoop processes is started
    retry check_hadoop

    # run tests
    set -x
    set +e
    sleep 10
    run_hadoop_tests
    if [[ ${ENVIRONMENT} == *"3.1-hive" ]]; then
      run_hive_transactional_tests
    fi
fi

EXIT_CODE=$?
set -e

# execution finished successfully
# disable trap, run cleanup manually
trap - INT TERM EXIT
cleanup

exit ${EXIT_CODE}
