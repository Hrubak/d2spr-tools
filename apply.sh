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

repo start auto device/samsung/d2-common
echo "d2: audio: Fix routing for BT voicedial feature"
cdv device/samsung/d2-common
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_d2-common refs/changes/95/33195/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto packages/apps/Settings
#echo "Settings: add battery bar (1/2)"
#cdv packages/apps/Settings
#git reset --hard
#git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Settings refs/changes/13/31913/3 && git cherry-pick FETCH_HEAD
#cdb

#repo start auto frameworks/base
#echo "Framework: add battery bar (2/2)"
#cdv frameworks/base
#git reset --hard
#git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/12/31912/2 && git cherry-pick FETCH_HEAD
#cdb

repo start auto packages/apps/Camera
echo "Add storage selection (1/2)"
cdv packages/apps/Camera
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Camera refs/changes/53/29153/6 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Gallery2
echo "Add storage selection (2/2)"
cdv packages/apps/Gallery2
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Gallery2 refs/changes/54/29154/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto packages/apps/Mms
#echo "Add quick emoji button next to text input"
#cdv packages/apps/Mms
#git reset --hard
#git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Mms refs/changes/55/32455/1 && git cherry-pick FETCH_HEAD
#cdb

##### SUCCESS ####
SUCCESS=true
exit 0
