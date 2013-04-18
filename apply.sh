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

repo start auto external/bluetooth/bluedroid
echo "REVERT: Bluetooth: Change Sampling Frequency to 48 kHz ."
cdv external/bluetooth/bluedroid
git reset --hard
git revert -n 69f86c8d0f1f2d1adfd04f94bfd4580a3bc61d4c 
cdb

#repo start auto packages/apps/Trebuchet
#echo "Workspace and AppList Icon Tap/Touch"
#cdv packages/apps/Trebuchet
#git reset --hard
#git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Trebuchet refs/changes/73/32873/1 && git cherry-pick FETCH_HEAD
#cdb

#repo start auto device/samsung/msm8960-common
#echo "msm8960-common: Add haptic feedback control prefs"
#cdv device/samsung/msm8960-common
#git reset --hard
#git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_device_samsung_msm8960-common refs/changes/81/35981/3 && git cherry-pick FETCH_HEAD
#cdb

##### SUCCESS ####
SUCCESS=true
exit 0
