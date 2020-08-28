#!/bin/bash
#
# Stock kernel for LG Electronics msm8996 devices build script by jcadduono
# -modified by stendro
#
################### BEFORE STARTING ################
#
# download a working toolchain and extract it somewhere and configure this
# file to point to the toolchain's root directory.
#
# once you've set up the config section how you like it, you can simply run
# ./build.sh [VARIANT]
#
# optional: specify "twrp" after [VARIANT] to enable TWRP config options.
##################### VARIANTS #####################
#
# H850		= International (Global)
#		LGH850   (LG G5)
#
# H830		= T-Mobile (US)
#		LGH830   (LG G5)
#
# RS988		= Unlocked (US)
#		LGRS988  (LG G5)
#
#   *************************
#
# H910		= AT&T (US)
#		LGH910   (LG V20)
#
# H915		= Canada (CA)
#		LGH915   (LG V20)
#
# H918		= T-Mobile (US)
#		LGH918   (LG V20)
#
# US996		= US Cellular & Unlocked (US)
#		LGUS996  (LG V20)
#
# US996Santa	= US Cellular & Unlocked (US)
#		LGUS996  (LG V20) (Unlocked with Engineering Bootloader)
#
# VS995		= Verizon (US)
#		LGVS995  (LG V20)
#
# H990DS	= International (Global)
#		LGH990   (LG V20)
#
# H990TR	= Turkey (TR)
#		LGH990   (LG V20)
#
# LS997		= Sprint (US)
#		LGLS997  (LG V20)
#
# F800K/L/S	= Korea (KR)
#		LGF800   (LG V20)
#
#   *************************
#
# H870		= International (Global)
#		LGH870   (LG G6)
#
# US997		= US Cellular & Unlocked (US)
#		US997    (LG G6)
#
# H872		= T-Mobile (US)
#		LGH872   (LG G6)
#
###################### CONFIG ######################

# root directory of this kernel (this script's location)
gaming=$2
isg5=$3
isoc=$4
isclear=$5

RDIR=$(pwd)

if [ "$isoc" = "1" ]; then
cp -r ../oc/msm8996-v3.dtsi arch/arm/boot/dts/qcom/msm8996-v3.dtsi
cp -r ../oc/msm8996-regulator.dtsi arch/arm/boot/dts/qcom/msm8996-regulator.dtsi
cp -r ../oc/cpr3-hmss-regulator.c drivers/regulator/cpr3-hmss-regulator.c 
else
cp -r ../stock/msm8996-v3.dtsi arch/arm/boot/dts/qcom/msm8996-v3.dtsi
cp -r ../stock/msm8996-regulator.dtsi arch/arm/boot/dts/qcom/msm8996-regulator.dtsi
cp -r ../stock/cpr3-hmss-regulator.c drivers/regulator/cpr3-hmss-regulator.c 
fi

if [ "$isg5" != "1" ]; then
isg5=0
fi

# build dir
if [ "$gaming" = "1" ]; then
    echo is GAMING
	BDIR=build_1$isg5
  else
    echo is not GAMING
	BDIR=build$isg5
fi

# enable ccache ?
USE_CCACHE=yes

# version number
VER=$(cat "$RDIR/VERSION")

# compiler options. ld.gold, graphite ?
# requires proper cross-comiler support
MK_LINKER=ld
USE_GRAPHITE=no
if [ "$USE_GRAPHITE" = "yes" ]; then
MK_FLAGS="-fgraphite-identity \
 -ftree-loop-distribution \
 -floop-nest-optimize \
 -floop-interchange"
fi

# MK_FLAGS="-Wno-attribute-alias"
MK_VDSO=yes
# select cpu threads
THREADS=$(grep -c "processor" /proc/cpuinfo)

# get build date, month day year
BDATE=$(LC_ALL='en_US.utf8' date '+%b %d %Y')

# directory containing cross-compiler
GCC_COMP=$HOME/92/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
# directory containing 32bit cross-compiler (COMPAT_VDSO)
GCC_COMP_32=$HOME/92/gcc-arm-9.2-2019.12-x86_64-arm-none-eabi/bin/arm-none-eabi-

# compiler version
# gnu gcc (non-linaro)
if $(${GCC_COMP}gcc --version | grep -q '(GCC)'); then
GCC_STRING=$(${GCC_COMP}gcc --version | head -n1 | cut -f2 -d')')
GCC_VER="GCC$GCC_STRING"
else # linaro gcc
GCC_VER="$(${GCC_COMP}gcc --version | head -n1 | cut -f1 -d')' | \
	cut -f2 -d'(')"
if $(echo $GCC_VER | grep -q '~dev'); then
  GCC_VER="$(echo $GCC_VER | cut -f1 -d'~')+"
fi
fi

############## SCARY NO-TOUCHY STUFF ###############

# color codes
COLOR_N="\033[0m"
COLOR_R="\033[0;31m"
COLOR_G="\033[1;32m"
COLOR_P="\033[1;35m"

# twrp configuration
[ "$2" = "twrp" ] && MK_TWRP=yes

ABORT() {
	echo -e $COLOR_R"Error: $*"
	exit 1
}

# MK_NAME, KBUILD_COMPILER_STRING
# and KBUILD_BUILD_TIMESTAMP causes
# 'kernel version' to not display
# in android settings. Not a problem really.
export MK_FLAGS
export MK_LINKER
export ARCH=arm64
export KBUILD_COMPILER_STRING=$GCC_VER
export KBUILD_BUILD_TIMESTAMP=$BDATE
export KBUILD_BUILD_USER=lybxlpsv
export KBUILD_BUILD_HOST=github
export MK_NAME="mk2000 ${VER}"
if [ "$USE_CCACHE" = "yes" ]; then
  export CROSS_COMPILE="ccache $GCC_COMP"
  export CROSS_COMPILE_ARM32="ccache $GCC_COMP_32"
else
  export CROSS_COMPILE=$GCC_COMP
  export CROSS_COMPILE_ARM32=$GCC_COMP_32
fi

# selected device
[ "$1" ] && DEVICE=$1
[ "$DEVICE" ] || ABORT "No device specified!"

lineageos="lineageos_"
defconfig="_defconfig"
oxavelar="_oxavelar"

# link device name to lg config files
if [ "$DEVICE" = "H990DS" ]; then
  if [ "$gaming" = "1" ]; then
	DEVICE_DEFCONFIG=lineageos_h990_oxavelar_defconfig
  else
	DEVICE_DEFCONFIG=lineageos_h990_defconfig
  fi
else
  if [ "$gaming" = "1" ]; then
	DEVICE_DEFCONFIG=$lineageos$DEVICE$oxavelar$defconfig
  else
	DEVICE_DEFCONFIG=$lineageos$DEVICE$defconfig
  fi
fi

# check for stuff
[ -f "$RDIR/arch/$ARCH/configs/${DEVICE_DEFCONFIG}" ] \
	|| ABORT "$DEVICE_DEFCONFIG not found in $ARCH configs!"

[ -x "${GCC_COMP}gcc" ] \
	|| ABORT "Cross-compiler not found at: ${GCC_COMP}gcc"

[ -x "${GCC_COMP_32}gcc" ] && MK_VDSO=yes \
	|| echo -e $COLOR_R"32-bit compiler not found, COMPAT_VDSO disabled."

if [ "$USE_CCACHE" = "yes" ]; then
	command -v ccache >/dev/null 2>&1 \
	|| ABORT "Do you have ccache installed?"
fi

[ "$GCC_VER" ] || ABORT "Couldn't get GCC version."

# build commands
CLEAN_BUILD() {
	echo -e $COLOR_G"Cleaning build folder..."$COLOR_N
	rm -rf $BDIR && sleep 5
}

SETUP_BUILD() {
	echo -e $COLOR_G"Creating kernel config..."$COLOR_N
	mkdir -p $BDIR
	make -C "$RDIR" O=$BDIR "$DEVICE_DEFCONFIG" \
		|| ABORT "Failed to set up build."
	if [ "$MK_LINKER" = "ld.gold" ]; then
	  echo "CONFIG_THIN_ARCHIVES=y" >> $BDIR/.config
	fi
	if [ "$MK_VDSO" = "yes" ]; then
	  echo "CONFIG_COMPAT_VDSO=y" >> $BDIR/.config
	fi
	if [ "$MK_TWRP" = "yes" ]; then
	  echo "include mk2000_twrp_conf" >> $BDIR/.config
	fi
}

BUILD_KERNEL() {
	echo -e $COLOR_G"Compiling kernel..."$COLOR_N
	TIMESTAMP1=$(date +%s)
	while ! make -C "$RDIR" O=$BDIR -j2; do
		read -rp "Build failed. Retry? " do_retry
		case $do_retry in
			Y|y) continue ;;
			*) ABORT "Compilation discontinued." ;;
		esac
	done
	TIMESTAMP2=$(date +%s)
	BSEC=$((TIMESTAMP2-TIMESTAMP1))
	BTIME=$(printf '%02dm:%02ds' $(($BSEC/60)) $(($BSEC%60)))
}

INSTALL_MODULES() {
	grep -q 'CONFIG_MODULES=y' $BDIR/.config || return 0
	echo -e $COLOR_G"Installing kernel modules..."$COLOR_N
	make -C "$RDIR" O=$BDIR \
		INSTALL_MOD_PATH="." \
		INSTALL_MOD_STRIP=1 \
		modules_install
	rm $BDIR/lib/modules/*/build $BDIR/lib/modules/*/source
}

PREPARE_NEXT() {
	echo "$DEVICE" > $BDIR/DEVICE \
		|| echo -e $COLOR_R"Failed to reflect device!"
	if grep -q 'KERNEL_COMPRESSION_LZ4=y' $BDIR/.config; then
	  echo lz4 > $BDIR/COMPRESSION \
		|| echo -e $COLOR_R"Failed to reflect compression method!"
	else
	  echo gz > $BDIR/COMPRESSION \
		|| echo -e $COLOR_R"Failed to reflect compression method!"
	fi
	git log --oneline -50 > $BDIR/GITCOMMITS \
		|| echo -e $COLOR_R"Failed to reflect commit log!"
}

cd "$RDIR" || ABORT "Failed to enter $RDIR!"
if [ "$MK_TWRP" = "yes" ]; then
  echo -e $COLOR_P"TWRP configuration selected."
fi
echo -e $COLOR_G"Building ${DEVICE} ${VER}..."
echo -e $COLOR_P"Using $GCC_VER..."
if [ "$USE_CCACHE" = "yes" ]; then
  echo -e $COLOR_P"Using CCACHE..."
fi

if [ "$isclear" = "1" ]; then
CLEAN_BUILD &&
SETUP_BUILD &&
BUILD_KERNEL &&
INSTALL_MODULES &&
PREPARE_NEXT &&
echo -e $COLOR_G"Finished building ${DEVICE} ${VER} -- Kernel compilation took"$COLOR_R $BTIME
echo -e $COLOR_P"Run ./copy_finished.sh to create AnyKernel zip."
else
SETUP_BUILD &&
BUILD_KERNEL &&
INSTALL_MODULES &&
PREPARE_NEXT &&
echo -e $COLOR_G"Finished building ${DEVICE} ${VER} -- Kernel compilation took"$COLOR_R $BTIME
echo -e $COLOR_P"Run ./copy_finished.sh to create AnyKernel zip."
fi

