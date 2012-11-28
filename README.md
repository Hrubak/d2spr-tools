L710/d2spr Build Instructions
=======================
```
mkdir -p android/CM10
cd android/CM10
repo init -u git://github.com/CyanogenMod/android.git -b jellybean
```

Modify your `.repo/local_manifest.xml` as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
  <manifest>
    <project name="Hrubak/d2spr-tools.git" path="d2spr-tools" remote="github" revision="jellybean" />
    <project name="CyanogenMod/android_device_samsung_d2spr" path="device/samsung/d2spr" remote="github" revision="smdk" />
    <project name="CyanogenMod/android_hardware_samsung" path="hardware/samsung" remote="github" revision="jellybean" />
    <project name="CyanogenMod/android_device_samsung_qcom-common" path="device/samsung/qcom-common" remote="github" revision="jellybean" />
    <project name="CyanogenMod/android_device_samsung_msm8960-common" path="device/samsung/msm8960-common" remote="github" revision="jellybean" />
    <project name="CyanogenMod/android_device_samsung_d2-common" path="device/samsung/d2-common" remote="github" revision="jellybean" />
    <project name="CyanogenMod/android_kernel_samsung_d2" path="kernel/samsung/d2" remote="github" revision="jellybean" />

  </manifest>
```

```
repo sync
vendor/cm/get-prebuilts
```

Auto Apply Patches
==================
This script will remove any topic branches named auto, then apply all patches under topic branch auto.

```
d2spr-tools/apply.sh
```

Build
=====
```
. build/envsetup.sh && brunch d2spr
```
