#!/usr/bin/env bash

set -xeu

timeout=30

while ((timeout > 0)); do
  if supervisorctl status slapd | grep -q RUNNING; then
    echo "Slapd is running... Exiting"
    exit 0
  fi

  sleep 1
  ((timeout -= 1))
done

echo "Slapd startup timed out"
exit 1
