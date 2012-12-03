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

repo start auto device/samsung/msm8960-common
echo "### Add Storage settings in GalaxyS3Settings"
cdv device/samsung/msm8960-common
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_msm8960-common refs/changes/30/27230/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto device/samsung/d2-common
echo "### d2: Enable Bluetooth"
cdv pdevice/samsung/d2-common
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/16/27516/1 && git cherry-pick FETCH_HEAD
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/15/27515/1 && git cherry-pick FETCH_HEAD
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/14/27514/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto vendor/cm
echo "### cm: apns-conf.xml: (eHRPD/LTE handoff) Change pdp type for default/mms APNs"
cdv vendor/cm
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_vendor_cm refs/changes/05/27505/1 && git cherry-pick FETCH_HEAD
cdb
##### SUCCESS ####
SUCCESS=true
exit 0
