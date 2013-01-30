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
echo "AOKP cherrypicks"
cdv hardware/qcom/audio-caf
git reset --hard
git fetch http://gerrit.sudoservers.com/AOKP/android_hardware_qcom_audio-caf refs/changes/90/5290/1 && git cherry-pick FETCH_HEAD
git fetch http://gerrit.sudoservers.com/AOKP/android_hardware_qcom_audio-caf refs/changes/91/5291/1 && git cherry-pick FETCH_HEAD
git fetch http://gerrit.sudoservers.com/AOKP/android_hardware_qcom_audio-caf refs/changes/95/5295/1 && git cherry-pick FETCH_HEAD

repo start auto frameworks/base
echo "GPS commits from CodeAurora"
cdv frameworks/base
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/49/29349/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto frameworks/opt/telephony
#echo "PhoneProxy: On v6 or greater RIL, when LTE_ON_CDMA is TRUE"
#cdv frameworks/opt/telephony
#git reset --hard
#git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/95/28195/2 && git cherry-pick FETCH_HEAD
#cdb

repo start auto device/samsung/d2-common
echo "enable a2dp no delay for d2 devices"
cdv device/samsung/d2-common
git reset --hard
git fetch http://gerrit.sudoservers.com/AOKP/android_device_samsung_d2-common refs/changes/03/5303/1 && git cherry-pick FETCH_HEAD
git fetch http://gerrit.sudoservers.com/AOKP/android_device_samsung_d2-common refs/changes/01/5301/1 && git cherry-pick FETCH_HEAD
git fetch http://gerrit.sudoservers.com/AOKP/android_device_samsung_d2-common refs/changes/02/5302/1 && git cherry-pick FETCH_HEAD
git revert -n 1a7763691ee07f42e1fcb6d7824617a0381db6b8
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
