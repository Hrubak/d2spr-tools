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

repo start auto packages/apps/Bluetooth
echo "Revert BT MAP 1/3"
cdv packages/apps/Bluetooth
git reset --hard
git revert -n 5d54e372e49ebfd7049a896b20e81c51af81d409
git revert -n ae002e254c80def23897af49414e4ee0ab11deb2
git revert -n 0aab1b683358baffa8e98e7009693e7a696243b8
git revert -n 8e80a44984cc88983aa996a036ab4edb1f391ef0
git revert -n a7c5b31fdbc9d61d2d35d7ddce932ec1bac1719f
git revert -n 078e032940c11e9a63800ce192caa501426d6e9f
git revert -n bffc5d0a4d74b2cf7670fef9c7d86d5d248cba71
git revert -n e7f60fef58f755788cd61aea8acbd9051f914214
cdb

repo start auto packages/apps/Settings
echo "Revert BT MAP 2/3"
cdv packages/apps/Settings
git reset --hard
git revert -n 408854a8c4e99c6c9c801fc107119deb25677d48
cdb

repo start auto frameworks/base
echo "Revert BT MAP 3/3"
cdv frameworks/base
git reset --hard
git revert -n f4d8b457f6bd83bd9d043ed3b1463fdb588b3cfa
cdb

repo start auto kernel/samsung/d2
echo "Fix:wpa/wpa2 tethering"
cdv kernel/samsung/d2
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_kernel_samsung_d2 refs/changes/56/31356/1 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
