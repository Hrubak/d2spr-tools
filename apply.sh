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
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/85/30385/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto device/samsung/msm8960-common
#echo "### add Storage Settings"
#cdv device/samsung/msm8960-common
#git reset --hard
#git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_msm8960-common refs/changes/30/27230/1 && git cherry-pick FETCH_HEAD
#cdb
##### SUCCESS ####
SUCCESS=true
exit 0
