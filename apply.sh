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
repo start auto frameworks/opt/telephony
echo "### patch Bleks stuff"
cdv frameworks/opt/telephony
git reset --hard
http_patch https://www.dropbox.com/s/n5xtm402x3x8jaf/blek.patch
cdb
#echo "Re-enable standalone power collapse on d2 and apex devices"
#repopick 46950

#echo "Framework: Development setting to enable navbar (1 of 2)"
#repopick 46928

#echo "Settings: Development setting to enable navbar (2 of 2)"
#repopick 46927

#echo "Revert DcTracker: ensure subscription is from NV before calling onRecordsLoaded"
#repopick 48873

##### SUCCESS ####
SUCCESS=true
exit 0
