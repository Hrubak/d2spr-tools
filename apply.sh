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
repo abandon auto
set -e

################ Apply Patches Below ####################

repo start auto device/samsung/d2-common/audio
echo "revert a2dp commit"
cdv device/samsung/d2-common/audio
git reset --hard
git revert -n 36f45f3a64738503e571427a9dcde8cfc7df4e5a
cdb

repo start auto device/samsung/d2-common/
echo "revert lowpower commit"
cdv device/samsung/d2-common/
git reset --hard
git revert -n e78398126b4387fbc55c3e9de7b9329bdb4ef30a
cdb

#repo start auto system/core
#echo "### storage"
#cdv system/core
#git reset --hard
#git fetch https://github.com/CyanogenMod/android_system_core refs/heads/jellybean
#git cherry-pick be5bb1d4aa98e066c44e5ee8a54a9bf92b17aa37
#http_patch http://chris41g.devphone.org/patches/steve.patch
#cdb
##### SUCCESS ####
SUCCESS=true
exit 0
