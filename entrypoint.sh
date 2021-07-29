#!/bin/sh

set -euo pipefail

# initialize the serverdir if that hasn't happened before
if [ ! -f "${DEVPISERVER_SERVERDIR}/.nodeinfo" ] \
      || [ ! -f "${DEVPISERVER_SERVERDIR}/.sqlite" ]; then
  devpi-init
fi

if [ -z "${SECRETFILE_CONTENTS}" ]; then
  if [ ! -s "${DEVPISERVER_SECRETFILE}" ]; then
    # generate a new random secretfile
    echo "Generating random secretfile"
    # if we don't have permissions to the dir that secretfile is in,
    # we will write to /tmp, then copy its contents into secretfile

    # create a subdirectory in /tmp
    TEMP_DIR=$(mktemp -d)
    TEMP_SECRETFILE="${TEMP_DIR}/secretfile"

    # create a secretfile in that subdirectory
    devpi-gen-secret --secretfile "${TEMP_SECRETFILE}"

    # read the temp file's contents into the existing secretfile
    # This is necessary when we have permissions to the file,
    # but lack permissions to the parent directory (i.e. /secretfile)
    <"${TEMP_SECRETFILE}" dd status=none of="${DEVPISERVER_SECRETFILE}"
    rm -rf "${TEMP_DIR}" || true
  fi

else
  # check that our SECRETFILE_CONTENTS match what is in the secretfile
  if [ "$(<${DEVPISERVER_SECRETFILE} tee)" != "${SECRETFILE_CONTENTS}" ]; then
      echo "Writing the given secret string to ${DEVPISERVER_SECRETFILE}"
      printf "%s" "${SECRETFILE_CONTENTS}" > "${DEVPISERVER_SECRETFILE}"
  fi
fi


exec "$@"
