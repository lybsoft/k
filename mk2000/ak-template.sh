#!/bin/bash
# Generate AnyKernel2 Script

if [ "$DEVICE" = "H870" ] || [ "$DEVICE" = "US997" ] || [ "$DEVICE" = "H872" ]; then
  DEV_NAME=LUCYE
elif [ "$DEVICE" = "H850" ] || [ "$DEVICE" = "RS988" ] || [ "$DEVICE" = "H830" ]; then
  DEV_NAME=H1
elif [ "$DEVICE" = "US996Santa" ] || [ "$DEVICE" = "US996" ] || [ "$DEVICE" = "H918" ]; then
  DEV_NAME=ELSA
else
  DEV_NAME=ELSA
  DEV_ABOOT=US996
  ABOOT_LOW=us996
fi

if [ "$DEVICE" = "H990DS" ]; then
  H990_SIM=$(echo '
# Set simcount (H990)
patch_cmdline "lge.dsds=" "lge.dsds=dsds";
patch_cmdline "lge.sim_num=" "lge.sim_num=2";')$'\n'
elif [ "$DEVICE" = "H990SS" ]; then
  H990_SIM=$(echo '
# Set simcount (H990)
patch_cmdline "lge.dsds=" "lge.dsds=none";
patch_cmdline "lge.sim_num=" "lge.sim_num=1";')$'\n'
fi

if [ "$DEVICE" = "US996Santa" ]; then
  AK_DEV=US996
elif [[ "$DEVICE" = F800* ]]; then
  AK_DEV=F800
elif [[ "$DEVICE" = H990* ]]; then
  AK_DEV=H990
else
  AK_DEV=$DEVICE
fi

DEV_LOW=$(echo "$AK_DEV" | awk '{print tolower($0)}')
NAME_LOW=$(echo "$DEV_NAME" | awk '{print tolower($0)}')

cat << EOF
# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=$DEVICE Kernel by lybxlpsv
do.devicecheck=1
do.droidcheck=1
do.modules=0
do.ssdtrim=0
do.cleanup=1
do.cleanuponabort=0
device.name1=$AK_DEV
device.name2=$DEV_NAME
device.name3=$DEV_LOW
device.name4=$NAME_LOW
device.name5=$DEV_ABOOT
device.name6=$ABOOT_LOW
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 \$ramdisk/*;
set_perm_recursive 0 0 750 750 \$ramdisk/init* \$ramdisk/sbin;

## AnyKernel install
dump_boot;

write_boot;
## end install
EOF
