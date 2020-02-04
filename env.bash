#############################
# Author
# Technexion
#############################

TOP="${PWD}"
PATH_KERNEL="${PWD}/kernel_imx"
PATH_UBOOT="${PWD}/bootable/bootloader/uboot-imx"

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


if [[ "$CPU_TYPE" == "imx6" ]]; then
    if [[ "$CPU_MODULE" == "edm1cf-sd" ]]; then
        if [[ "$BASEBOARD" == "wandboard" ]]; then
            UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='wandboard_android_defconfig'
            DTB_TARGET='imx6q-wandboard-revc1.dtb imx6dl-wandboard-revc1.dtb imx6q-wandboard-revb1.dtb imx6dl-wandboard-revb1.dtb'
            TARGET_DEVICE=wandboard
        fi
    elif [[ "$CPU_MODULE" == "edm1cf-sd-pmic" ]]; then
        if [[ "$BASEBOARD" == "wandboard" ]]; then
            UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='wandboard_android_defconfig'
            DTB_TARGET='imx6qp-wandboard-revd1.dtb imx6q-wandboard-revd1.dtb imx6dl-wandboard-revd1.dtb imx6dl-wandboard-revc1.dtb imx6q-wandboard-revc1.dtb'
            TARGET_DEVICE=wandboard_pmic
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
		DTB_TARGET='imx6q-pico_dwarf_lvds.dtb imx6dl-pico_dwarf_lvds.dtb imx6q-pico_dwarf.dtb imx6dl-pico_dwarf.dtb imx6q-pico_hobbit.dtb imx6dl-pico_hobbit.dtb imx6q-pico_nymph.dtb imx6dl-pico_nymph.dtb imx6q-pico_pi.dtb imx6dl-pico_pi.dtb'
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
#           TARGET_DEVICE=wandboard_pmic
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
			KERNEL_CONFIG='tn_imx7_android_defconfig'
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
            cd "${TMP_PWD}"
            source build/envsetup.sh
            cd ${PATH_UBOOT} && heat "$@" || return $?
            cd ${PATH_KERNEL} && heat "$@" || return $?
            cd "${TMP_PWD}"
            lunch "$TARGET_DEVICE"-user
            make "$@" || return $?
#           make "$@" PRODUCT-"$TARGET_DEVICE"-user dist || return $?
            ;;
        "${PATH_KERNEL}"*)
#           export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
            cd "${PATH_KERNEL}"
#           make "$@" $KERNEL_IMAGE LOADADDR=0x10008000 $KERNEL_CFLAGS || return $?
#           make "$@" $KERNEL_CFLAGS || return $?
            make "$@" $KERNEL_IMAGE || return $?
            make "$@" modules || return $?
            make "$@" $DTB_TARGET || return $?
            ;;
        "${PATH_UBOOT}"*)
#           export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
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
            source build/envsetup.sh
            cd ${PATH_UBOOT} && cook "$@" || return $?
            cd ${PATH_KERNEL} && cook "$@" || return $?
            cd "${TMP_PWD}"
            lunch "$TARGET_DEVICE"-user
            make "$@" || return $?
            ;;
        "${PATH_KERNEL}"*)
#            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
            cd "${PATH_KERNEL}"
            make "$@" $KERNEL_CONFIG || return $?
            heat "$@" || return $?
            ;;
        "${PATH_UBOOT}"*)
#            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
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
    cd "${TOP}"
    sudo ./device/fsl/common/tools/fsl-sdcard-partition.sh ${dev_node}
    sync
    sudo hdparm -z ${dev_node}
    sync
    sudo mkfs.vfat -F 32 ${dev_node}1 -n boot;sync

	mkdir $IMX_PATH
    sudo mount ${dev_node}1 $IMX_PATH;
    sudo cp $PATH_UBOOT/u-boot.img $IMX_PATH/; sync
    sudo cp $PATH_KERNEL/arch/arm/boot/zImage $IMX_PATH/zImage; sync

    if [[ "$TARGET_DEVICE" == "edm1cf_6dq" || "$TARGET_DEVICE" == "edm1cf_pmic_6dq"  ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf_"$BASEBOARD".dtb $IMX_PATH/imx6q-edm1-cf_"$BASEBOARD".dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf_"$BASEBOARD".dtb $IMX_PATH/imx6dl-edm1-cf_"$BASEBOARD".dtb;sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf-pmic_"$BASEBOARD".dtb $IMX_PATH/imx6q-edm1-cf-pmic_"$BASEBOARD".dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf-pmic_"$BASEBOARD".dtb $IMX_PATH/imx6dl-edm1-cf-pmic_"$BASEBOARD".dtb;sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6qp-edm1-cf-pmic_"$BASEBOARD".dtb $IMX_PATH/imx6qp-edm1-cf-pmic_"$BASEBOARD".dtb; sync
		if [[ "$OUTPUT_DISPLAY" == "tc0700" ]]; then
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6q-edm1-cf_"$OUTPUT_DISPLAY".dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6dl-edm1-cf_"$OUTPUT_DISPLAY".dtb;sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6q-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6dl-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb;sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6qp-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6qp-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf-pmic_tc1000.dtb $IMX_PATH/imx6q-edm1-cf-pmic_tc1000.dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf-pmic_tc1000.dtb $IMX_PATH/imx6dl-edm1-cf-pmic_tc1000.dtb;sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6qp-edm1-cf-pmic_tc1000.dtb $IMX_PATH/imx6qp-edm1-cf-pmic_tc1000.dtb; sync
		fi
    elif [[ "$TARGET_DEVICE" == "pico_6dq" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-pico_*.dtb $IMX_PATH/.; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-pico_*.dtb $IMX_PATH/.; sync
    elif [[ "$TARGET_DEVICE" == "tek3_6dq" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tek3.dtb $IMX_PATH/imx6q-tek3.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tek3.dtb $IMX_PATH/imx6dl-tek3.dtb;sync
    elif [[ "$TARGET_DEVICE" == "tep5_6dq" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tep5.dtb $IMX_PATH/imx6q-tep5.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tep5.dtb $IMX_PATH/imx6dl-tep5.dtb;sync
    elif [[ "$TARGET_DEVICE" == "wandboard" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-wandboard-revc1.dtb $IMX_PATH/imx6q-wandboard-revc1.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard-revc1.dtb $IMX_PATH/imx6dl-wandboard-revc1.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-wandboard-revb1.dtb $IMX_PATH/imx6q-wandboard-revb1.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard-revb1.dtb $IMX_PATH/imx6dl-wandboard-revb1.dtb; sync
    elif [[ "$TARGET_DEVICE" == "wandboard_pmic" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6*-wandboard-revd1.dtb $IMX_PATH/; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6*-wandboard-revc1.dtb $IMX_PATH/; sync
        #sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard-revd1.dtb $IMX_PATH/wandboard-revd1.dtb; sync
    elif [[ "$TARGET_DEVICE" == "pico_7d" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_dwarf.dtb $IMX_PATH/imx7d-pico_dwarf.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_hobbit.dtb $IMX_PATH/imx7d-pico_hobbit.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_nymph.dtb $IMX_PATH/imx7d-pico_nymph.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_pi.dtb $IMX_PATH/imx7d-pico_pi.dtb; sync
    elif [[ "$TARGET_DEVICE" == "tep1_7d" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-tep1.dtb $IMX_PATH/imx7d-tep1.dtb; sync
    fi

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
        sudo cp ./out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    else
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp ./out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    fi

    # download the android system
    echo == download the system ==
    sudo dd if=./out/target/product/$TARGET_DEVICE/system_raw.img of=${dev_node}5 bs=1M oflag=dsync status=progress
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
	sudo dd if=$PATH_UBOOT/SPL of="$@" bs=1k seek=1 oflag=dsync
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
    sudo cp $PATH_UBOOT/u-boot.img $IMX_PATH/; sync
    sudo cp $PATH_KERNEL/arch/arm/boot/zImage $IMX_PATH/zImage; sync

    if [[ "$TARGET_DEVICE" == "edm1cf_6dq" || "$TARGET_DEVICE" == "edm1cf_pmic_6dq"  ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf_"$BASEBOARD".dtb $IMX_PATH/imx6q-edm1-cf_"$BASEBOARD".dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf_"$BASEBOARD".dtb $IMX_PATH/imx6dl-edm1-cf_"$BASEBOARD".dtb;sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf-pmic_"$BASEBOARD".dtb $IMX_PATH/imx6q-edm1-cf-pmic_"$BASEBOARD".dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf-pmic_"$BASEBOARD".dtb $IMX_PATH/imx6dl-edm1-cf-pmic_"$BASEBOARD".dtb;sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6qp-edm1-cf-pmic_"$BASEBOARD".dtb $IMX_PATH/imx6qp-edm1-cf-pmic_"$BASEBOARD".dtb; sync
		if [[ "$OUTPUT_DISPLAY" == "tc0700" ]]; then
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6q-edm1-cf_"$OUTPUT_DISPLAY".dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6dl-edm1-cf_"$OUTPUT_DISPLAY".dtb;sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6q-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6dl-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb;sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6qp-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb $IMX_PATH/imx6qp-edm1-cf-pmic_"$OUTPUT_DISPLAY".dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf-pmic_tc1000.dtb $IMX_PATH/imx6q-edm1-cf-pmic_tc1000.dtb; sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf-pmic_tc1000.dtb $IMX_PATH/imx6dl-edm1-cf-pmic_tc1000.dtb;sync
			sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6qp-edm1-cf-pmic_tc1000.dtb $IMX_PATH/imx6qp-edm1-cf-pmic_tc1000.dtb; sync
		fi
    elif [[ "$TARGET_DEVICE" == "pico_6dq" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-pico_*.dtb $IMX_PATH/.; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-pico_*.dtb $IMX_PATH/.; sync
    elif [[ "$TARGET_DEVICE" == "tek3_6dq" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tek3.dtb $IMX_PATH/imx6q-tek3.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tek3.dtb $IMX_PATH/imx6dl-tek3.dtb;sync
    elif [[ "$TARGET_DEVICE" == "tep5_6dq" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tep5.dtb $IMX_PATH/imx6q-tep5.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tep5.dtb $IMX_PATH/imx6dl-tep5.dtb;sync
    elif [[ "$TARGET_DEVICE" == "wandboard" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-wandboard-revc1.dtb $IMX_PATH/imx6q-wandboard-revc1.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard-revc1.dtb $IMX_PATH/imx6dl-wandboard-revc1.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-wandboard-revb1.dtb $IMX_PATH/imx6q-wandboard-revb1.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard-revb1.dtb $IMX_PATH/imx6dl-wandboard-revb1.dtb; sync
    elif [[ "$TARGET_DEVICE" == "wandboard_pmic" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6*-wandboard-revd1.dtb $IMX_PATH/; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6*-wandboard-revc1.dtb $IMX_PATH/; sync
        #sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard-revd1.dtb $IMX_PATH/wandboard-revd1.dtb; sync
    elif [[ "$TARGET_DEVICE" == "pico_7d" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_dwarf.dtb $IMX_PATH/imx7d-pico_dwarf.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_hobbit.dtb $IMX_PATH/imx7d-pico_hobbit.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_nymph.dtb $IMX_PATH/imx7d-pico_nymph.dtb; sync
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-pico_pi.dtb $IMX_PATH/imx7d-pico_pi.dtb; sync
    elif [[ "$TARGET_DEVICE" == "tep1_7d" ]]; then
        sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx7d-tep1.dtb $IMX_PATH/imx7d-tep1.dtb; sync
    fi

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
        sudo cp ./out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    else
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp ./out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    fi

    # download the android system
    echo == download the system ==
    sudo dd if=./out/target/product/$TARGET_DEVICE/system_raw.img of=${dev_node}5 bs=1M oflag=dsync status=progress
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
	sudo dd if=$PATH_UBOOT/SPL of="$@" bs=1k seek=1 oflag=dsync
	sleep 1

    sudo umount ${dev_node}*
    sudo rm -rf $IMX_PATH
    sync
    sleep 1

    echo "Flash Done!!!"

    cd "${TMP_PWD}"
}

gen_mp_images() {
  rm -rf auto_test
  sync

  mkdir -p auto_test/device/fsl/common/tools
  mkdir -p auto_test/device/fsl/"$TARGET_DEVICE"/uenv
  mkdir -p auto_test/kernel_imx/arch/arm/boot
  mkdir -p auto_test/kernel_imx/arch/arm/boot/dts
  mkdir -p auto_test/bootable/bootloader/uboot-imx
  mkdir -p auto_test/out/target/product/"${TARGET_DEVICE}"

  cp -rv device/fsl/common/tools/* auto_test/device/fsl/common/tools/
  cp -rv $PATH_UBOOT/u-boot.img auto_test/bootable/bootloader/uboot-imx/
  cp -rv $PATH_UBOOT/SPL auto_test/bootable/bootloader/uboot-imx/
  cp -rv $PATH_KERNEL/arch/arm/boot/zImage auto_test/kernel_imx/arch/arm/boot/zImage
  cp -rv out/target/product/"${TARGET_DEVICE}"/u-boot.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/obj/KERNEL_OBJ/arch/arm/boot/zImage auto_test/out/target/product/"${TARGET_DEVICE}"/obj/KERNEL_OBJ/arch/arm/boot/
  cp -rv $PATH_KERNEL/arch/arm/boot/dts/*.dtb auto_test/kernel_imx/arch/arm/boot/dts/
  cp -rv device/fsl/"$TARGET_DEVICE"/uenv/. auto_test/device/fsl/"$TARGET_DEVICE"/uenv/
  cp -rv out/target/product/"${TARGET_DEVICE}"/ramdisk.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/uramdisk.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/system_raw.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv device/fsl/"${TARGET_DEVICE}"/audio_policy_hdmi.conf auto_test/device/fsl/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/recovery*.img auto_test/out/target/product/"${TARGET_DEVICE}"/

  cp -rv cookers auto_test/
  rm -rf auto_test/cookers/.git

  sync
}
