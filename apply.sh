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
repo start auto packages/apps/Gallery2
echo "Camera: Bring Samsung camera fixes and features to 4.3"
cdv packages/apps/Gallery2
git reset --hard
git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_packages_apps_Gallery2 refs/changes/87/46287/9 && git cherry-pick FETCH_HEAD
cdb

repo start auto device/samsung/d2-common
echo "d2-common:  Move Camera overlay settings to Gallery2"
cdv device/samsung/d2-common
git reset --hard
git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/72/46772/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto hardware/qcom/display-caf
echo "libgralloc: Allow ionFlags for GRALLOC_USAGE_PRIVATE_MM_HEAP case"
cdv  hardware/qcom/display-caf
git reset --hard
git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_hardware_qcom_display-caf refs/changes/21/46521/5 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
