#!/usr/bin/env bash

set -e

function retry() {
    END=$(($(date +%s) + 600))

    while (($(date +%s) < END)); do
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
    docker compose -f "${DOCKER_CONF_LOCATION}/${ENVIRONMENT}/docker-compose.yml" "$@"
}

function check_hadoop() {
    environment_compose exec hadoop-master hive -e 'select 1;' >/dev/null 2>&1
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
        test $(environment_compose exec hadoop-master hdfs dfs -ls /user/hive/warehouse/bucketed_table |
            tee /dev/stderr | grep /bucketed_table/ | wc -l) -ge 4 &&
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

function check_spark() {
    environment_compose exec spark curl -f http://localhost:10213
}

function run_spark_tests() {
    environment_compose exec spark beeline -u jdbc:hive2://localhost:10213 -e 'SELECT 1;' &&
        environment_compose exec spark beeline -u jdbc:hive2://localhost:10213 -e 'SHOW DATABASES;' &&
        true
}

function check_health() {
    if ! list=$(environment_compose ps --format json); then
        echo >&2 "Error getting Docker containers status: $list"
        return 1
    fi
    if ! status=$(jq -er '.Health' <<<"$list"); then
        echo >&2 "Error getting health for $service: $status"
        return 1
    fi
    test "$status" == "healthy"
}

function run_kerberos_tests() {
    sleep 60
    environment_compose exec kerberos create_principal -o -p tola -k tola.keytab
    environment_compose exec kerberos kinit -kt ala.keytab ala@STARBURSTDATA.COM
}

function check_openldap() {
    environment_compose exec openldap /usr/bin/wait-for-slapd.sh
}

function stop_all_containers() {
    local ENVIRONMENT
    for ENVIRONMENT in $(getAvailableEnvironments); do
        stop_docker_compose_containers ${ENVIRONMENT}
    done
}

function stop_docker_compose_containers() {
    local ENVIRONMENT=$1
    RUNNING_CONTAINERS=$(environment_compose ps -q)

    if [[ -n ${RUNNING_CONTAINERS} ]]; then
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
    if [[ -n ${LOGS_PID} ]]; then
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
    for i in $(ls -d $DOCKER_CONF_LOCATION/*/); do echo ${i%%/}; done |
        grep -v files | grep -v common | xargs -n1 basename
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=bin/lib.sh
source "$SCRIPT_DIR/lib.sh"
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
docker compose version
docker version

stop_all_containers

# catch terminate signals
trap terminate INT TERM EXIT

if [ -n "${PLATFORMS:-}" ]; then
    IFS=, read -ra platforms <<<"$PLATFORMS"
    platforms=("${platforms[@]//\//-}")
    platforms=("${platforms[@]/#/-}")
else
    platforms=("")
fi
export ARCH
for ARCH in "${platforms[@]}"; do

    environment_compose up -d

    # start docker logs for the external services
    environment_compose logs --no-color -f &

    LOGS_PID=$!

    if [[ ${ENVIRONMENT} == *"accumulo"* ]]; then
        retry check_health
    elif [[ ${ENVIRONMENT} == "kerberos" ]]; then
        run_kerberos_tests
    elif [[ ${ENVIRONMENT} == *"hive"* ]]; then
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
    elif [[ ${ENVIRONMENT} == *"openldap"* ]]; then
        retry check_openldap
    elif [[ ${ENVIRONMENT} == *"spark"* ]]; then
        # wait until Spark is started
        retry check_spark

        # run tests
        set -x
        set +e
        sleep 10
        run_spark_tests
    else
        echo >&2 "ERROR: no test defined for ${ENVIRONMENT}"
        cleanup
        exit 2
    fi

    EXIT_CODE=$?
    set -e

    cleanup
done

# execution finished successfully
# disable trap
trap - INT TERM EXIT

exit ${EXIT_CODE}
