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
. build/envsetup.sh

################ Apply Patches Below ####################

echo "cm: Add CMAccount to the build"
repopick 48599

#repo start auto frameworks/opt/telephony
#echo "Fix 1x/evdo data call for NV based subscription."
#cdv frameworks/opt/telephony
#git reset --hard
#git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/98/48198/1 && git cherry-pick FETCH_HEAD
#cdb

#repo start auto frameworks/opt/telephony
#echo "Telephony: Query SignalStrength when there is a RAT change."
#cdv frameworks/opt/telephony
#git reset --hard
#git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_frameworks_opt_telephony refs/changes/00/48200/1 && git cherry-pick FETCH_HEAD
#cdb

#repo start auto kernel/samsung/d2
#echo "Re-enable standalone power collapse on d2 and apex devices"
#cdv  kernel/samsung/d2
#git reset --hard
#git fetch http://Hrubak@review.cyanogenmod.org/CyanogenMod/android_kernel_samsung_d2 refs/changes/50/46950/3 && git cherry-pick FETCH_HEAD
#cdb

##### SUCCESS ####
SUCCESS=true
exit 0
