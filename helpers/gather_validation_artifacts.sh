#!/bin/bash

cmd="help"

FULL_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
#echo "FULL_PATH_TO_SCRIPT: $FULL_PATH_TO_SCRIPT"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"
#echo "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY"

source $SCRIPT_DIRECTORY/rig_lib.sh

setup_rig

# collect stuff
mv run.txt output
sudo mount $STORAGE-part4 data
cp data/mender-validation-state.json output
cp data/validation.log output
sudo umount data
tar cvjf output.tar.bz2 output
ls -alh .
ls -alh output/*

exit 0