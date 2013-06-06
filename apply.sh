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

repo start auto frameworks/base
echo "REVERT: Revert GPS changes for now until issues are resolved."
cdv frameworks/base
git reset --hard
git revert -n ddbadd0e3e37d37f6e3e657950b3f317228d5808 
cdb

repo start auto frameworks/opt/telephony
echo "SamsungQualcommRIL: fix errors and replaces it with known values"
cdv frameworks/opt/telephony
git reset --hard
git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/76/43476/18 && git cherry-pick FETCH_HEAD
cdb

repo start auto kernel/samsung/d2
echo "d2: Squashed revert of msm_serial_hs.c updates"
cdv kernel/samsung/d2
git reset --hard
git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_kernel_samsung_d2 refs/changes/30/43830/1 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
