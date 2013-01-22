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

repo start auto hardware/qcom/audio-caf
echo "disable support for LPA playback on bluetooth"
cdv hardware/qcom/audio-caf
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_qcom_audio-caf refs/changes/13/30213/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base
echo "GPS commits from CodeAurora"
cdv frameworks/base
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/49/29349/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/opt/telephony
echo "PhoneProxy: On v6 or greater RIL, when LTE_ON_CDMA is TRUE"
cdv frameworks/opt/telephony
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/95/28195/2 && git checkout FETCH_HEAD
cdb

repo start auto device/samsung/qcom-common
echo "REVERT: qcom-common: Enable CAF audio variant"
cdv device/samsung/qcom-common
git reset --hard
git revert -n 22a9c684bf73187f07b740955a4d2c362e74f943
cdb

repo start auto device/samsung/d2-common
echo "REVERT:d2: Update audio policy for new driver / More audio use case enhacements"
cdv device/samsung/d2-common
git reset --hard
git revert -n e7ecaaac0b74dbb80a535f1d931c487b5989d1f6
git revert -n 3f96e9b15b179981fdab6a26f032494b89313df9
cdb


##### SUCCESS ####
SUCCESS=true
exit 0
