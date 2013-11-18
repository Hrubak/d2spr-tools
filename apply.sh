#!/bin/bash

unset SUCCESS
on_exit() {
  if [ -z "$SUCCESS" ]; then
    echo "ERROR: $0 failed.  Please fix the above error."
    exit 1
  else
    echo "SUCCESS: $0 has completed."
    exit 0
  fi
}
trap on_exit EXIT

http_patch() {
  PATCHNAME=$(basename $1)
  curl -L -o $PATCHNAME -O -L $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

# Change directory verbose
cdv() {
  echo
  echo "*****************************"
  echo "Current Directory: $1"
  echo "*****************************"
  cd $BASEDIR/$1
}

# Change back to base directory
cdb() {
  cd $BASEDIR
}

# Sanity check
if [ -d ../.repo ]; then
  cd ..
fi
if [ ! -d .repo ]; then
  echo "ERROR: Must run this script from the base of the repo."
  SUCCESS=true
  exit 255
fi

# Save Base Directory
BASEDIR=$(pwd)

# Abandon auto topic branch
set -e
. build/envsetup.sh

################ Apply Patches Below ####################

repopick -b 53075 53131 53194 53195 53196 53302 53309 53376 53377 53356 53445 53528 53409 53411 53413 53414 53595 53603 53604 53637 53619 53964 54106 53648 53544 53724 54137 54139


##### SUCCESS ####
SUCCESS=true
exit 0
