#!/bin/bash

BROKEN_LINKS="$(find -L . -type l)"

if [ ! "${BROKEN_LINKS}" = '' ]; then
  echo "The following symlinks are broken:"
  printf '%s\n' "${BROKEN_LINKS}"
  exit 1
fi
