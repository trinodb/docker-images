#!/bin/sh

BROKEN_LINKS=$( find . -type l -exec sh -c "file -b {} | grep -q ^broken" \; -print )

if [ ! "${BROKEN_LINKS}" = '' ]; then
  echo "The following symlinks are broken:"
  printf '%s\n' "${BROKEN_LINKS}"
  exit 1
fi
