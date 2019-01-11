#############################
# Author
# Technexion
#############################

TOP="${PWD}"
PATH_KERNEL="${PWD}/vendor/nxp-opensource/kernel_imx"
PATH_UBOOT="${PWD}/vendor/nxp-opensource/uboot-imx"

export PATH="${PATH_UBOOT}/tools:${PATH}"
#export ARCH=arm
#export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
#export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
#export CROSS_COMPILE=/opt/gcc-5.1-2015.08-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
CLASSPATH=".:$JAVA_HOME/lib:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
#PATH="$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
PATH="$JAVA_HOME/bin:${PATH}"
export DISPLAY=:0
#export PATH=$PATH:/opt/gcc-5.1-2015.08-x86_64_arm-linux-gnueabihf/bin
#export CROSS_COMPILE=/opt/gcc-5.1-2015.08-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
#export PATH=$PATH:"${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin"
#export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
#sudo apt-get install gcc-aarch64-linux-gnu
#sudo apt-get install gcc-arm-linux-gnueabi

export ARCH=arm64
export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export CROSS32CC=arm-linux-gnueabi-gcc
export USER=$(whoami)

export MY_ANDROID=$TOP
export LC_ALL=C

# TARGET support: wandboard,edm1cf,picosom,edm1cf_6sx
IMX_PATH="./mnt"
SYS_PATH="./tmp"
MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
CPU_MODULE=$(echo $MODULE | awk -F. '{print $4}')
BASEBOARD=$(echo $MODULE | awk -F. '{print $5}')
OUTPUT_DISPLAY=$(echo $MODULE | awk -F. '{print $6}')
KERNEL_CFLAGS='KCFLAGS=-mno-android'

PATH_TOOLS="${TOP}/device/fsl/common/tools"

if [[ "$CPU_TYPE" == "imx8" ]]; then
    if [[ "$CPU_MODULE" == "pico-8m" ]]; then
        if [[ "$BASEBOARD" == "pi" ]]; then

            KERNEL_IMAGE='Image'
            KERNEL_CONFIG='android_defconfig'
			if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
				UBOOT_CONFIG='pico_8m_android_defconfig'
				TARGET_DEVICE=pico_8m
				TARGET_DEVICE_NAME=imxpico_8m
				DTB_TARGET='pico_8m.dtb'
			elif [[ "$OUTPUT_DISPLAY" == "lcd" ]]; then
				UBOOT_CONFIG='pico_8m_lcd_android_defconfig'
				TARGET_DEVICE=pico_8m_lcd
				TARGET_DEVICE_NAME=imxpico_8m_lcd
				DTB_TARGET='pico_8m_lcd.dtb'
			fi
        elif [[ "$BASEBOARD" == "wanboard" ]]; then
            UBOOT_CONFIG='mx8mq_evk_android_defconfig'
            KERNEL_IMAGE='Image'
            KERNEL_CONFIG='android_defconfig'
            DTB_TARGET='fsl-imx8mq-evk.dtb'
            TARGET_DEVICE=evk_8mq
            TARGET_DEVICE_NAME=imx8mq
        fi
	elif [[ "$CPU_MODULE" == "evk_8mq" ]]; then
            UBOOT_CONFIG='mx8mq_evk_android_defconfig'
            KERNEL_IMAGE='Image'
            KERNEL_CONFIG='android_defconfig'
            DTB_TARGET='fsl-imx8mq-evk.dtb'
            TARGET_DEVICE=evk_8mq
            TARGET_DEVICE_NAME=imx8mq
	fi
fi

recipe() {
    local TMP_PWD="${PWD}"

    case "${PWD}" in
        "${PATH_KERNEL}"*)
            cd "${PATH_KERNEL}"
            make "$@" menuconfig || return $?
            ;;
        *)
            echo -e "Error: outside the project" >&2
            return 1
            ;;
    esac

    cd "${TMP_PWD}"
}

heat() {
    local TMP_PWD="${PWD}"
    case "${PWD}" in
        "${TOP}")
            # cd "${TMP_PWD}"'
            cd ${PATH_UBOOT} && heat "$@" || return $?
            cd ${PATH_KERNEL} && heat "$@" || return $?
            cd "${TMP_PWD}"
            source build/envsetup.sh
            lunch "$TARGET_DEVICE"-user
            make "$@" || return $?
#           make "$@" PRODUCT-"$TARGET_DEVICE"-user dist || return $?
            ;;
        "${PATH_KERNEL}"*)
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
            cd "${PATH_KERNEL}"
			rm "${TOP}"/device/fsl/"${TARGET_DEVICE}"/wifi-firmware/wlan.ko
			rm -rf ../modules/lib
            make "$@" $KERNEL_CFLAGS || return $?
            make "$@" || return $?
            make "$@" modules_install INSTALL_MOD_PATH=../modules || return $?
			cd drivers/net/wireless/qcacld-2.0
            make "$@" clean || return $?
            make "$@" || return $?
            KERNEL_SRC=../../../../../kernel_imx make "$@" modules_install INSTALL_MOD_PATH=../modules || return $?
            cd "${PATH_KERNEL}"
			cp ../modules/lib/modules/4.9.78*/extra/wlan.ko "${TOP}"/device/fsl/"${TARGET_DEVICE}"/wifi-firmware/
            ;;
        "${PATH_UBOOT}"*)
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-gnu/bin/aarch64-linux-gnu-"
            cd "${PATH_UBOOT}"
            make "$@" || return $?
            ;;
        *)
            echo -e "Error: outside the project" >&2
            return 1
            ;;
    esac

    cd "${TMP_PWD}"
}

cook() {
    local TMP_PWD="${PWD}"
    echo "$TMP_PWD"

    case "${PWD}" in
        "${TOP}")
            cd ${PATH_UBOOT} && cook "$@" || return $?
            cd ${PATH_KERNEL} && cook "$@" || return $?
            cd "${TMP_PWD}"
            source build/envsetup.sh
            lunch "$TARGET_DEVICE"-userdebug
            make "$@" || return $?
            ;;
        "${PATH_KERNEL}"*)
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
            cd "${PATH_KERNEL}"
            make "$@" $KERNEL_CONFIG || return $?
            heat "$@" || return $?
            ;;
        "${PATH_UBOOT}"*)
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-gnu/bin/aarch64-linux-gnu-"
            cd "${PATH_UBOOT}"
            make "$@" $UBOOT_CONFIG || return $?
            heat "$@" || return $?
            ;;
        *)
            echo -e "Error: outside the project" >&2
            return 1
            ;;
    esac

    cd "${TMP_PWD}"
}

throw() {
    local TMP_PWD="${PWD}"

    case "${PWD}" in
        "${TOP}")
            rm -rf out
            cd ${PATH_UBOOT} && throw "$@" || return $?
            cd ${PATH_KERNEL} && throw "$@" || return $?
            ;;
        "${PATH_KERNEL}"*)
            cd "${PATH_KERNEL}"
#           make "$@" $KERNEL_CONFIG || return $?
#           make "$@" $KERNEL_CFLAGS || return $?
            make "$@" distclean || return $?
            ;;
        "${PATH_UBOOT}"*)
            cd "${PATH_UBOOT}"
#           make "$@" $UBOOT_CONFIG || return $?
            make "$@" distclean || return $?
            ;;
        *)
            echo -e "Error: outside the project" >&2
            return 1
            ;;
    esac

    cd "${TMP_PWD}"
}

flashcard() {
  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
  dev_node="$@"
  echo "$dev_node start"
  cd "${PATH_OUT}"
  sudo $TOP/device/fsl/common/tools/tn-sdcard-partition.sh -f ${TARGET_DEVICE_NAME} -c 7 ${dev_node}
  sync
  echo "Flash Done!!!"
  cd "${TMP_PWD}"
}

flashuboot() {
    local TMP_PWD="${PWD}"
	PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
    dev_node="$@"
    sudo hdparm -z ${dev_node}
    sync

    echo == download the android boot ==
    sudo dd if=${PATH_OUT}/u-boot-${TARGET_DEVICE_NAME}.imx of=${dev_node}1 bs=1M oflag=dsync
    sleep 1

    echo == download the android recovery ==
    sudo dd if=${PATH_OUT}/u-boot-${TARGET_DEVICE_NAME}.imx of=${dev_node}2 bs=1M oflag=dsync
    sleep 1

	echo == Erase the environment variables ==
	sudo dd if=/dev/zero of=${dev_node} bs=1k seek=1 count=1023 oflag=dsync
	sleep 1
	sudo dd if=/dev/zero of=${dev_node} bs=1M seek=1 count=3 oflag=dsync
	sleep 1

    echo == download the boot loader ==
    sudo dd if=${PATH_OUT}/u-boot-${TARGET_DEVICE_NAME}.imx of=${dev_node} bs=1k seek=33 oflag=dsync
    sleep 1

	sync
    echo "Flash Done!!!"

}

flashemmc() {
    local TMP_PWD="${PWD}"
	PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
    dev_node="$@"
    echo "$dev_node start"
	cd "${PATH_OUT}"
	sudo $TOP/device/fsl/common/tools/fsl-sdcard-partition-source.sh -f ${TARGET_DEVICE} -c 7 ${dev_node}
	sync
    sleep 1
	sudo $TOP/device/fsl/common/tools/gpt_partition_move -d ${dev_node} -s 8192
    sync
    sleep 1

	echo == Erase the environment variables ==
	sudo dd if=/dev/zero of=${dev_node} bs=1k seek=1 count=1023 oflag=dsync
	sleep 1
	sudo dd if=/dev/zero of=${dev_node} bs=1M seek=1 count=3 oflag=dsync
	sleep 1

    cd "${TOP}"
    sudo hdparm -z ${dev_node}
    sync

    echo == download the boot loader ==
    # sudo dd if=${PATH_OUT}/u-boot-${TARGET_DEVICE_NAME}_defconfig.imx of=${dev_node} bs=1k seek=33 oflag=dsync
    sudo dd if=${PATH_OUT}/obj/BOOTLOADER_OBJ/SPL of=${dev_node} bs=1k seek=33 oflag=dsync
    sleep 1

    sudo mkfs.vfat -F 32 ${dev_node}1 -n boot;sync

	mkdir $IMX_PATH
    sudo mount ${dev_node}1 $IMX_PATH;
    sudo cp ${PATH_OUT}/obj/BOOTLOADER_OBJ/u-boot.img $IMX_PATH/; sync
    sudo cp ${PATH_OUT}/obj/KERNEL_OBJ/arch/arm64/boot/Image $IMX_PATH/Image; sync

    # donwload the environment settings
    echo == download the environment - Display: "$OUTPUT_DISPLAY" ==
		sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/KERNEL_OBJ/*.dtb $IMX_PATH/.; sync
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/chmodel.sh $IMX_PATH/chmodel.sh; sync
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.*.* $IMX_PATH/.; sync
		sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$BASEBOARD"."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync

    # download the ramdisk
    if [[ "$CPU_TYPE" == "imx8" ]]; then
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x43800000 -n "Android Root Filesystem" -d ${PATH_OUT}/ramdisk.img ${PATH_OUT}/uramdisk.img
        sudo cp ${PATH_OUT}/uramdisk.img $IMX_PATH/;sync
	elif [[ "$CPU_TYPE" == "imx7" ]]; then
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x83800000 -n "Android Root Filesystem" -d ${PATH_OUT}/ramdisk.img ${PATH_OUT}/uramdisk.img
        sudo cp ${PATH_OUT}/uramdisk.img $IMX_PATH/;sync
	elif [[ "$CPU_TYPE" == "imx6" ]]; then
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ${PATH_OUT}/ramdisk.img ${PATH_OUT}/uramdisk.img
        sudo cp ${PATH_OUT}/uramdisk.img $IMX_PATH/;sync
    fi

    echo == download the android recovery ==
    sudo dd if=${PATH_OUT}/boot.img of=${dev_node}2 bs=1M oflag=dsync
    sleep 1

    echo == download the android system ==
    sudo dd if=${PATH_OUT}/system_raw.img of=${dev_node}3 bs=1M oflag=dsync
    sleep 1

    echo == download the vendor ==
    sudo dd if=${PATH_OUT}/vendor_raw.img of=${dev_node}8 bs=1M oflag=dsync
    sleep 1

    echo == download the vbmeta ==
    sudo dd if=${PATH_OUT}/vbmeta-${TARGET_DEVICE_NAME}.dtb.img of=${dev_node}12 bs=1M oflag=dsync
    sleep 1

    sudo umount ${dev_node}*
    sudo rm -rf $IMX_PATH
	sudo rm ${PATH_OUT}/uramdisk.img
    sync
    sleep 1
    echo "Flash Done!!!"
    cd "${TMP_PWD}"
}

merge_restricted_extras() {
  wget https://github.com/technexion-android/android_restricted_extra/raw/master/imx8-o8.tar.gz
  tar zxvf imx8-o8.tar.gz
  cp -rv imx-o8.1.0_1.3.0_8m/vendor/nxp/* vendor/nxp/
  cp -rv imx-o8.1.0_1.3.0_8m/EULA.txt .
  cp -rv imx-o8.1.0_1.3.0_8m/SCR* .
  rm -rf imx8-o8.tar.gz imx-o8.1.0_1.3.0_8m
  sync
}


gen_mp_images() {

  mkdir -p auto_test/device/fsl/common/tools
  cp -rv device/fsl/common/tools/* auto_test/device/fsl/common/tools/

  mkdir -p auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/boot-*.img auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/partition-table-*.bpt auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/partition-table-*.img auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/partition-table.bpt auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/partition-table.img auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/ramdisk-recovery.img auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/u-boot-*.imx auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/vbmeta-*.img auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/vendor.img auto_test/out/target/product/pico_8m/
  cp -rv out/target/product/pico_8m/system.img auto_test/out/target/product/pico_8m/


  cp -rv cookers auto_test/
  rm -rf auto_test/cookers/.git

}
