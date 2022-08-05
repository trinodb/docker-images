#!/usr/bin/env bash

set -xeu

timeout=30
while ((timeout > 0)); do
  # -LLL would print responses in LDIF format without comments and version
  # An invalid filter is applied to avoid actual response which spams the build process.
  if ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config -LLL "(emptyAttribute=emptyValue)"; then
    echo "Slapd is running... Exiting"
    exit 0
  fi

  sleep 1
  ((timeout -= 1))
done

echo "Slapd startup timed out"
exit 1
