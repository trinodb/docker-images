#!/usr/bin/env bash

skip_if_needed() {
  SHOULD_RUN=true
  # Can't rely on exit codes here, as BATS will fail the test if any of the statements
  # returns non-zero exit code. `set +e` does not solve the problem.
  echo "${EXPECTED_CAPABILITIES}" | grep -q "$BATS_TEST_DESCRIPTION" || SHOULD_RUN=false
  if [[ "$SHOULD_RUN" == false ]]; then
    skip
  fi
}

assert_run() {
  run "$@"
  echo "Output of [$*]:"
  echo
  printf '%s\n' "${lines[@]}" | nl -v 0
  return ${status}
}

assert_output_contains() {
  printf '%s\n' "${lines[@]}" | grep -q $1
}

function exposes_hive {
  skip_if_needed
  assert_run dockerize -wait tcp://hadoop-master:10000 -timeout 90s
}

function allows_creating_a_table_in_hive {
  skip_if_needed
  assert_run beeline -n hdfs -u jdbc:hive2://hadoop-master:10000 -e 'create table test as select 42 id'
}

function allows_selecting_from_the_table {
  skip_if_needed
  assert_run beeline -n hdfs -u jdbc:hive2://hadoop-master:10000 -e 'select * from test'
  assert_output_contains 'test.id'
  assert_output_contains '42'
}

function exposes_socks_proxy {
  skip_if_needed
  PROXY_ADDRESS='hadoop-master:1180'
  assert_run dockerize -wait tcp://${PROXY_ADDRESS} -timeout 10s
  assert_run curl --socks5 ${PROXY_ADDRESS} google.com
}
