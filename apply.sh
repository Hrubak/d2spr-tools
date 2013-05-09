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

#repo start auto frameworks/base
#echo "REVERT: Revert GPS changes for now until issues are resolved."
#cdv frameworks/base
#git reset --hard
#git revert -n ddbadd0e3e37d37f6e3e657950b3f317228d5808 
#cdb

repo start auto kernel/samsung/d2
echo "ARM: 7467/1: mutex: use generic xchg-based implementation for ARMv6+"
cdv kernel/samsung/d2
git reset --hard
git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_kernel_samsung_d2 refs/changes/21/37221/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto vendor/samsung
#echo "d2-common: bcmdhd: update firmware to latest (VRBMB1)"
#cdv vendor/samsung
#git reset --hard
#git cherry-pick a3ba4ada070cd346905fc00b39aaab994b4cb745 --no-edit
#cdb

##### SUCCESS ####
SUCCESS=true
exit 0
