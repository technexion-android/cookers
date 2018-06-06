#############################
# Author
# Technexion
#############################

TOP="${PWD}"
PATH_KERNEL="${PWD}/vendor/nxp-opensource/kernel_imx"
PATH_UBOOT="${PWD}/vendor/nxp-opensource/uboot-imx"

export PATH="${PATH_UBOOT}/tools:${PATH}"
export ARCH=arm
#export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
#export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
CLASSPATH=".:$JAVA_HOME/lib:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
#PATH="$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
PATH="$JAVA_HOME/bin:${PATH}"
export DISPLAY=:0
export PATH=$PATH:/opt/gcc-5.1-2015.08-x86_64_arm-linux-gnueabihf/bin
export CROSS_COMPILE=/opt/gcc-5.1-2015.08-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
export MY_ANDROID=$TOP
export LC_ALL=C
source build/envsetup.sh

# TARGET support: wandboard,edm1cf,picosom,edm1cf_6sx
IMX_PATH="./mnt"
SYS_PATH="./tmp"
MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
CPU_MODULE=$(echo $MODULE | awk -F. '{print $4}')
BASEBOARD=$(echo $MODULE | awk -F. '{print $5}')
OUTPUT_DISPLAY=$(echo $MODULE | awk -F. '{print $6}')
KERNEL_CFLAGS='KCFLAGS=-mno-android'

PATH_OUT="${TOP}/out/target/product/${BASEBOARD}"
PATH_TOOLS="${TOP}/device/fsl/common/tools"

if [[ "$CPU_TYPE" == "imx6" ]]; then
    if [[ "$CPU_MODULE" == "edm1-sd" ]]; then
        if [[ "$BASEBOARD" == "fairy" ]]; then
            UBOOT_CONFIG='edm-cf-imx6_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='imx_v7_android_defconfig'
            DTB_TARGET='imx6dl-edm1_fairy.dtb imx6q-edm1_fairy.dtb imx6qp-edm1_fairy.dtb'
            TARGET_DEVICE=edm1_6dq
        elif [[ "$BASEBOARD" == "wandboard" ]]; then
            UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000 KCFLAGS=-mno-android'
            KERNEL_CONFIG='wandboard_android_defconfig'
			DTB_TARGET='imx6q-wandboard-revb1.dtb imx6q-wandboard-revd1.dtb imx6dl-wandboard-revb1.dtb imx6dl-wandboard-revd1.dtb imx6qp-wandboard-revd1.dtb'
            TARGET_DEVICE=wandboard
        fi
    elif [[ "$CPU_MODULE" == "edm1cf-sd-pmic" ]]; then
        if [[ "$BASEBOARD" == "wandboard" ]]; then
            UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000 KCFLAGS=-mno-android'
            KERNEL_CONFIG='wandboard_android_defconfig'
            # KERNEL_CONFIG='tn_imx_android_defconfig'
            # DTB_TARGET='imx6dl-wandboard.dtb imx6dl-wandboard-revb1.dtb imx6q-wandboard.dtb imx6q-wandboard-revb1.dtb imx6qp-wandboard-revd1.dtb'
			DTB_TARGET='imx6q-wandboard-revb1.dtb imx6q-wandboard-revd1.dtb imx6dl-wandboard-revb1.dtb imx6dl-wandboard-revd1.dtb imx6qp-wandboard-revd1.dtb'
            TARGET_DEVICE=wandboard
        elif [[ "$BASEBOARD" == "fairy" ]]; then
			UBOOT_CONFIG='edm-cf-imx6_defconfig'
			KERNEL_IMAGE='zImage'
			KERNEL_CONFIG='tn_imx_android_defconfig'
        	if [[ "$OUTPUT_DISPLAY" == "tc0700" ]]; then
	            DTB_TARGET='imx6q-edm1-cf_tc0700.dtb imx6dl-edm1-cf_tc0700.dtb imx6q-edm1-cf-pmic_tc0700.dtb imx6dl-edm1-cf-pmic_tc0700.dtb imx6qp-edm1-cf-pmic_tc0700.dtb'
        	else
				DTB_TARGET='imx6q-edm1-cf_fairy.dtb imx6dl-edm1-cf_fairy.dtb imx6q-edm1-cf-pmic_fairy.dtb imx6dl-edm1-cf-pmic_fairy.dtb imx6qp-edm1-cf-pmic_fairy.dtb'
			fi
			TARGET_DEVICE=edm1cf_pmic_6dq
        fi
    elif [[ "$CPU_MODULE" == "tek3" ]]; then
		UBOOT_CONFIG='tek-imx6_defconfig'
		KERNEL_CONFIG='tn_imx_android_defconfig'
		KERNEL_IMAGE='uImage LOADADDR=0x10008000'
		DTB_TARGET='imx6q-tek3.dtb imx6dl-tek3.dtb'
		TARGET_DEVICE=tek3_6dq   	
    elif [[ "$CPU_MODULE" == "tep5" ]]; then
		UBOOT_CONFIG='tek-imx6_defconfig'
		KERNEL_CONFIG='tn_imx_android_defconfig'
		KERNEL_IMAGE='uImage LOADADDR=0x10008000'
		DTB_TARGET='imx6q-tep5.dtb imx6dl-tep5.dtb'
		TARGET_DEVICE=tep5_6dq	    	
    elif [[ "$CPU_MODULE" == "pico-sd" ]]; then
		UBOOT_CONFIG='pico-imx6_defconfig'
		KERNEL_CONFIG='tn_imx_android_defconfig'
#		KERNEL_IMAGE='uImage LOADADDR=0x10008000'
		KERNEL_IMAGE='zImage'
		DTB_TARGET='imx6q-pico_dwarf.dtb imx6dl-pico_dwarf.dtb imx6q-pico_hobbit.dtb imx6dl-pico_hobbit.dtb imx6q-pico_nymph.dtb imx6dl-pico_nymph.dtb imx6q-pico_pi.dtb imx6dl-pico_pi.dtb'
		TARGET_DEVICE=pico_6dq
    elif [[ "$CPU_MODULE" == "edm1cf-nand-pmic" ]]; then
        if [[ "$BASEBOARD" == "fairy" ]]; then
            UBOOT_CONFIG='edm-cf-imx6_defconfig'
#           UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000'
            KERNEL_CONFIG='tn_imx_android_defconfig'
#           KERNEL_CONFIG='wandboard_android_defconfig'
        	if [[ "$OUTPUT_DISPLAY" == "tc0700" ]]; then
	            DTB_TARGET='imx6q-edm1-cf_tc0700.dtb imx6dl-edm1-cf_tc0700.dtb imx6q-edm1-cf-pmic_tc0700.dtb imx6dl-edm1-cf-pmic_tc0700.dtb imx6qp-edm1-cf-pmic_tc0700.dtb imx6q-edm1-cf-pmic_tc1000.dtb imx6dl-edm1-cf-pmic_tc1000.dtb imx6qp-edm1-cf-pmic_tc1000.dtb'
        	else
				DTB_TARGET='imx6q-edm1-cf_fairy.dtb imx6dl-edm1-cf_fairy.dtb imx6q-edm1-cf-pmic_fairy.dtb imx6dl-edm1-cf-pmic_fairy.dtb imx6qp-edm1-cf-pmic_fairy.dtb'
			fi
#           DTB_TARGET='imx6qp-wandboard-revd1.dtb imx6q-wandboard-revd1.dtb imx6dl-wandboard-revd1.dtb imx6dl-wandboard-revc1.dtb imx6q-wandboard-revc1.dtb'
            TARGET_DEVICE=edm1cf_pmic_6dq
#           TARGET_DEVICE=wandboard
        fi
    fi
	elif [[ "$CPU_TYPE" == "imx7" ]]; then
	    if [[ "$CPU_MODULE" == "pico-sd" ]]; then
			UBOOT_CONFIG='pico-imx7d_spl_defconfig'
			KERNEL_IMAGE='uImage LOADADDR=0x10008000'
			DTB_TARGET='imx7d-pico_dwarf.dtb imx7d-pico_hobbit.dtb imx7d-pico_nymph.dtb imx7d-pico_pi.dtb'
#			KERNEL_CONFIG='tn_pico_7d_android_defconfig'
			KERNEL_CONFIG='tn_imx_android_defconfig'
			TARGET_DEVICE=pico_7d	
	    elif [[ "$CPU_MODULE" == "tep1" ]]; then
			UBOOT_CONFIG='tep1-imx7d_spl_defconfig'
			KERNEL_IMAGE='uImage LOADADDR=0x10008000'
			DTB_TARGET='imx7d-tep1.dtb'
			KERNEL_CONFIG='tn_imx_android_defconfig'
			TARGET_DEVICE=tep1_7d	    	
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
            # cd "${TMP_PWD}"
            cd ${PATH_UBOOT} && heat "$@" || return $?
            cd ${PATH_KERNEL} && heat "$@" || return $?
            cd "${TMP_PWD}"
            lunch "$TARGET_DEVICE"-user
            make "$@" || return $?
#           make "$@" PRODUCT-"$TARGET_DEVICE"-user dist || return $?
            ;;
        "${PATH_KERNEL}"*)
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
            cd "${PATH_KERNEL}"
#           make "$@" $KERNEL_IMAGE LOADADDR=0x10008000 $KERNEL_CFLAGS || return $?
            make "$@" $KERNEL_CFLAGS || return $?
            make "$@" $KERNEL_IMAGE || return $?
            make "$@" modules || return $?
            make "$@" $DTB_TARGET || return $?
            ;;
        "${PATH_UBOOT}"*)
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
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
            lunch "$TARGET_DEVICE"-user
            make "$@" || return $?
            ;;
        "${PATH_KERNEL}"*)
            # export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
            cd "${PATH_KERNEL}"
            make "$@" $KERNEL_CONFIG || return $?
            heat "$@" || return $?
            ;;
        "${PATH_UBOOT}"*)
            # export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
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

    dev_node="$@"
    echo "$dev_node start"
	cd "${PATH_OUT}"
	sudo $TOP/device/fsl/common/tools/fsl-sdcard-partition-source.sh -f ${TARGET_DEVICE} ${dev_node}
	sync
    sleep 1
	sudo $TOP/device/fsl/common/tools/gpt_partition_move -d ${dev_node} -s 8192
    sync
    sleep 1
    cd "${TOP}"
    sudo hdparm -z ${dev_node}
    sync
    sudo mkfs.vfat -F 32 ${dev_node}1 -n boot;sync

	mkdir $IMX_PATH
    sudo mount ${dev_node}1 $IMX_PATH;
    sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/BOOTLOADER_OBJ/u-boot.img $IMX_PATH/; sync
    sudo cp $TOP/out/target/product/wandboard/obj/KERNEL_OBJ/arch/arm/boot/zImage $IMX_PATH/zImage; sync

	sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/KERNEL_OBJ/imx6*-wandboard*.dtb $IMX_PATH/.; sync

    # donwload the environment settings
    echo == download the environment - Display: "$OUTPUT_DISPLAY" ==
    if [[ "$TARGET_DEVICE" == "pico_6dq" || "$TARGET_DEVICE" == "pico_7d" || "$OUTPUT_DISPLAY" == "tc0700" || "$TARGET_DEVICE" == "tep5_6dq" || "$TARGET_DEVICE" == "tek3_6dq" ]]; then
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/chmodel.sh $IMX_PATH/chmodel.sh; sync
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.*.* $IMX_PATH/.; sync
		sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$BASEBOARD"."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync
    else
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/chmodel.sh $IMX_PATH/chmodel.sh; sync
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.* $IMX_PATH/.; sync
    fi
    # download the ramdisk
    if [[ "$CPU_TYPE" == "imx7" ]]; then
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x83800000 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    else
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    fi
    # download the android system
    echo == download the system ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/system_raw.img of=${dev_node}3 bs=1M oflag=dsync
    sleep 1
    echo == download the vendor ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/vendor_raw.img of=${dev_node}9 bs=1M oflag=dsync
    sleep 1
    echo == download the recovery ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/recovery.img of=${dev_node}2 bs=1M oflag=dsync
    sleep 1
	echo == Erase the environment variables ==
	sudo dd if=/dev/zero of="$@" bs=1k seek=1 count=1023 oflag=dsync
	sleep 1
	sudo dd if=/dev/zero of="$@" bs=1M seek=1 count=3 oflag=dsync
	sleep 1
	echo == flash the SPL ==
	sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/obj/BOOTLOADER_OBJ/SPL of="$@" bs=1k seek=1 oflag=dsync
	sleep 1

    sudo umount ${dev_node}*
    sudo rm -rf $IMX_PATH
	sudo rm $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img
    sync
    sleep 1

    echo "Flash Done!!!"

    cd "${TMP_PWD}"
}

flashmbr() {
    local TMP_PWD="${PWD}"

    dev_node="$@"
    echo "$dev_node start"
    cd "${TOP}"
    sudo ./device/fsl/common/tools/fsl-sdcard-partition.sh ${dev_node}
    sync
    sudo hdparm -z ${dev_node}
    sync
    sudo mkfs.vfat -F 32 ${dev_node}1 -n boot;sync

	mkdir $IMX_PATH
    sudo mount ${dev_node}1 $IMX_PATH;
    sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/BOOTLOADER_OBJ/u-boot.img $IMX_PATH/; sync
    sudo cp $TOP/out/target/product/wandboard/obj/KERNEL_OBJ/arch/arm/boot/zImage $IMX_PATH/zImage; sync

	sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/KERNEL_OBJ/imx6*-wandboard*.dtb $IMX_PATH/.; sync

    # donwload the environment settings
    echo == download the environment - Display: "$OUTPUT_DISPLAY" ==
    if [[ "$TARGET_DEVICE" == "pico_6dq" || "$TARGET_DEVICE" == "pico_7d" || "$OUTPUT_DISPLAY" == "tc0700" || "$TARGET_DEVICE" == "tep5_6dq" || "$TARGET_DEVICE" == "tek3_6dq" ]]; then
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/chmodel.sh $IMX_PATH/chmodel.sh; sync
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.*.* $IMX_PATH/.; sync
		sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$BASEBOARD"."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync
    else
        sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync
    fi
    # download the ramdisk
    if [[ "$CPU_TYPE" == "imx7" ]]; then
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x83800000 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    else
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    fi

    # download the android system
    echo == download the system ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/system_raw.img of=${dev_node}3 bs=1M oflag=dsync
    sleep 1
    # donwload the audio settings
    # if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
    # echo == download the audio setting for "$OUTPUT_DISPLAY" ==
    #  mkdir $SYS_PATH
    #  sudo mount ${dev_node}3 $SYS_PATH;
    #  sudo cp $TOP/device/fsl/"$TARGET_DEVICE"/audio_policy_hdmi.conf $SYS_PATH/etc/audio_policy.conf; sync
    #  sudo umount ${dev_node}3
    #  sudo rm -rf $SYS_PATH
    # fi
    echo == download the vendor ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/vendor_raw.img of=${dev_node}10 bs=1M oflag=dsync
    sleep 1
    echo == download the recovery ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/recovery.img of=${dev_node}2 bs=1M oflag=dsync
    sleep 1
	echo == Erase the environment variables ==
	sudo dd if=/dev/zero of="$@" bs=1k seek=1 count=1023 oflag=dsync
	sleep 1
	sudo dd if=/dev/zero of="$@" bs=1M seek=1 count=3 oflag=dsync
	sleep 1
	echo == flash the SPL ==
	sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/obj/BOOTLOADER_OBJ/SPL of="$@" bs=1k seek=1 oflag=dsync
	sleep 1

    sudo umount ${dev_node}*
    sudo rm -rf $IMX_PATH
    sync
    sleep 1

    echo "Flash Done!!!"

    cd "${TMP_PWD}"
}

flashemmc() {
    local TMP_PWD="${PWD}"

    dev_node="$@"
    echo "$dev_node start"
    cd "${TOP}"
    sudo ./device/fsl/common/tools/fsl-sdcard-partition-3.5G.sh ${dev_node}
    sync
    sudo hdparm -z ${dev_node}
    sync
    sudo mkfs.vfat -F 32 ${dev_node}1 -n boot;sync

	mkdir $IMX_PATH
    sudo mount ${dev_node}1 $IMX_PATH;
    sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/BOOTLOADER_OBJ/u-boot.img $IMX_PATH/; sync
    sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/KERNEL_OBJ/arch/arm/boot/zImage $IMX_PATH/.; sync

	sudo cp $TOP/out/target/product/$TARGET_DEVICE/obj/KERNEL_OBJ/imx6*-wandboard*.dtb $IMX_PATH/.; sync

    # donwload the environment settings
    echo == download the environment - Display: "$OUTPUT_DISPLAY" ==
	sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync

    # download the ramdisk
    if [[ "$CPU_TYPE" == "imx7" ]]; then
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x83800000 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/.;sync
    else
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp $TOP/out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/.;sync
    fi

    # download the android system
    echo == download the system ==
    sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/system_raw.img of=${dev_node}5 bs=1M oflag=dsync
    sleep 1
    # donwload the audio settings
    if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
    echo == download the audio setting for "$OUTPUT_DISPLAY" ==
      mkdir $SYS_PATH
      sudo mount ${dev_node}5 $SYS_PATH;
      sudo cp ./device/fsl/"$TARGET_DEVICE"/audio_policy_hdmi.conf $SYS_PATH/etc/audio_policy.conf; sync
      sudo umount ${dev_node}5
      sudo rm -rf $SYS_PATH
    fi

    echo == download the recovery ==
    sudo dd if=./out/target/product/$TARGET_DEVICE/recovery.img of=${dev_node}2 bs=1M oflag=dsync
    sleep 1
	echo == Erase the environment variables ==
	sudo dd if=/dev/zero of="$@" bs=1k seek=1 count=1023 oflag=dsync
	sleep 1
	sudo dd if=/dev/zero of="$@" bs=1M seek=1 count=3 oflag=dsync
	sleep 1
	echo == flash the SPL ==
	sudo dd if=$TOP/out/target/product/$TARGET_DEVICE/obj/BOOTLOADER_OBJ/SPL of="$@" bs=1k seek=1 oflag=dsync
	sleep 1

    sudo umount ${dev_node}*
    sudo rm -rf $IMX_PATH
    sync
    sleep 1

    echo "Flash Done!!!"

    cd "${TMP_PWD}"
}
