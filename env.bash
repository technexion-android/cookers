#############################
# Author
# Wig Cheng@TW
#############################

TOP="${PWD}"
PATH_KERNEL="${PWD}/kernel_imx"
PATH_UBOOT="${PWD}/bootable/bootloader/uboot-imx"

export PATH="${PATH_UBOOT}/tools:${PATH}"
export ARCH=arm
#export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"

# TARGET support: wandboard,edm1cf,picosom,edm1cf_6sx
IMX_PATH="./mnt"
SYS_PATH="./tmp"
MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
CPU_MODULE=$(echo $MODULE | awk -F. '{print $4}')
BASEBOARD=$(echo $MODULE | awk -F. '{print $5}')
OUTPUT_DISPLAY=$(echo $MODULE | awk -F. '{print $6}')
KERNEL_CFLAGS='KCFLAGS=-mno-android'
KERNEL_CONFIG='tn_imx_android_defconfig'

if [[ "$CPU_TYPE" == "imx6" ]]; then
    if [[ "$CPU_MODULE" == "edm1cf-sd" ]]; then
        if [[ "$BASEBOARD" == "wandboard" ]]; then
            UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='wandboard_android_defconfig'
            DTB_TARGET='imx6q-wandboard-revc1.dtb imx6dl-wandboard-revc1.dtb imx6q-wandboard-revb1.dtb imx6dl-wandboard-revb1.dtb'
            TARGET_DEVICE=wandboard
        fi

    elif [[ "$CPU_MODULE" == "edm1cf-nand" ]]; then
        if [[ "$BASEBOARD" == "fairy" ]]; then
            UBOOT_CONFIG='edm-cf-imx6_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000'
            DTB_TARGET='imx6q-edm1-cf_fairy.dtb imx6dl-edm1-cf_fairy.dtb imx6q-edm1-cf-pmic_fairy.dtb imx6dl-edm1-cf-pmic_fairy.dtb imx6qp-edm1-cf-pmic_fairy.dtb'
            TARGET_DEVICE=edm1cf_6dq
        elif [[ "$BASEBOARD" == "tc0700" ]]; then
            UBOOT_CONFIG='edm-cf-imx6-no-console_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000'
            DTB_TARGET='imx6q-edm1-cf_tc0700.dtb imx6dl-edm1-cf_tc0700.dtb imx6q-edm1-cf-pmic_tc0700.dtb imx6dl-edm1-cf-pmic_tc0700.dtb imx6qp-edm1-cf-pmic_tc0700.dtb'
            TARGET_DEVICE=edm1cf_6dq
        fi

    elif [[ "$CPU_MODULE" == "edm1cf-nand-pmic" ]]; then
        if [[ "$BASEBOARD" == "fairy" ]]; then
            UBOOT_CONFIG='edm-cf-imx6_defconfig'
        elif [[ "$BASEBOARD" == "tc0700" ]]; then
            UBOOT_CONFIG='edm-cf-imx6-no-console_defconfig'
        fi
        KERNEL_IMAGE='uImage LOADADDR=0x10008000'
        DTB_TARGET='imx6q-edm1-cf_fairy.dtb imx6dl-edm1-cf_fairy.dtb imx6q-edm1-cf-pmic_fairy.dtb imx6dl-edm1-cf-pmic_fairy.dtb imx6qp-edm1-cf-pmic_fairy.dtb'
        TARGET_DEVICE=edm1cf_pmic_6dq


    elif [[ "$CPU_MODULE" == "pico-sd" ]]; then
            UBOOT_CONFIG='pico-imx6_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000'
            DTB_TARGET='imx6q-pico_dwarf.dtb imx6dl-pico_dwarf.dtb imx6q-pico_hobbit.dtb imx6dl-pico_hobbit.dtb imx6q-pico_nymph.dtb imx6dl-pico_nymph.dtb'
            TARGET_DEVICE=pico_6dq

    elif [[ "$CPU_MODULE" == "tek3" || "$CPU_MODULE" == "tep" ]]; then
            UBOOT_CONFIG='tek-imx6_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x10008000'
            DTB_TARGET='imx6q-tek3.dtb imx6dl-tek3.dtb imx6q-tep5.dtb imx6dl-tep5.dtb'
            TARGET_DEVICE=tek3_6dq
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
            cd ${PATH_UBOOT} && heat "$@" || return $?
            cd ${PATH_KERNEL} && heat "$@" || return $?
            cd "${TMP_PWD}"
            source build/envsetup.sh
            lunch "$TARGET_DEVICE"-eng
            make "$@" || return $?
            ;;
        "${PATH_KERNEL}"*)
#            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
            cd "${PATH_KERNEL}"
#            make "$@" $KERNEL_IMAGE LOADADDR=0x10008000 $KERNEL_CFLAGS || return $?
            make "$@" $KERNEL_IMAGE LOADADDR=0x10008000 || return $?
            make "$@" modules || return $?
            make "$@" $DTB_TARGET || return $?
            ;;
        "${PATH_UBOOT}"*)
#            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
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
            lunch "$TARGET_DEVICE"-eng
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
            make "$@" distclean || return $?
            ;;
        "${PATH_UBOOT}"*)
            cd "${PATH_UBOOT}"
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

    if [[ "$CPU_TYPE" == "imx7" ]]; then
        sudo dd if=./out/target/product/$TARGET_DEVICE/boot.img of=${dev_node}1; sync
        sleep 1
    else
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
        elif [[ "$TARGET_DEVICE" == "pico_6dq" ]]; then
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-pico_"$BASEBOARD".dtb $IMX_PATH/imx6q-pico_"$BASEBOARD".dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-pico_"$BASEBOARD".dtb $IMX_PATH/imx6dl-pico_"$BASEBOARD".dtb; sync
        elif [[ "$TARGET_DEVICE" == "tek3_6dq" ]]; then
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tek3.dtb $IMX_PATH/imx6q-tek3.dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tek3.dtb $IMX_PATH/imx6dl-tek3.dtb;sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tep5.dtb $IMX_PATH/imx6q-tep5.dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tep5.dtb $IMX_PATH/imx6dl-tep5.dtb;sync
       fi

        # donwload the environment settings
        echo == download the environment - Display: "$OUTPUT_DISPLAY" ==
        if [[ "$TARGET_DEVICE" == "pico_6dq" ]]; then
             sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$BASEBOARD"."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync
        else
            sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt."$OUTPUT_DISPLAY" $IMX_PATH/uEnv.txt; sync
        fi
        # download the ramdisk
        echo == download the ramdisk ==
        sudo mkimage -A arm -O linux -T ramdisk -C none -a 0x10800800 -n "Android Root Filesystem" -d ./out/target/product/$TARGET_DEVICE/ramdisk.img ./out/target/product/$TARGET_DEVICE/uramdisk.img
        sudo cp ./out/target/product/$TARGET_DEVICE/uramdisk.img $IMX_PATH/;sync
    fi
    # download the android system
    echo == download the system ==
    sudo dd if=./out/target/product/$TARGET_DEVICE/system_raw.img of=${dev_node}5;sync
    sleep 1
    # donwload the audio settings
    if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
    echo == download the audio setting for "$OUTPUT_DISPLAY" ==
      mkdir $SYS_PATH
      sudo mount ${dev_node}5 $SYS_PATH;
      sudo cp ./device/fsl/"$TARGET_DEVICE"/audio_policy_"$OUTPUT_DISPLAY".conf $SYS_PATH/etc/audio_policy.conf; sync
      sudo umount ${dev_node}5
      sudo rm -rf $SYS_PATH
    fi

    echo == download the recovery ==
    sudo dd if=./out/target/product/$TARGET_DEVICE/recovery.img of=${dev_node}2; sync
    sleep 1

    sudo umount ${dev_node}*
    sudo rm -rf $IMX_PATH
    sync
    sleep 1

    if [[ "$CPU_TYPE" == "imx7" ]]; then
        sudo dd if=$PATH_UBOOT/u-boot.imx of="$@" bs=512 seek=2; sync
        echo == flash the u-boot.imx finish ==
        sleep 1
    else
        sudo dd if=$PATH_UBOOT/SPL of="$@" bs=1k seek=1; sync
        echo == flash the spl finish ==
        sleep 1
    fi

    echo "Flash Done!!!"

    cd "${TMP_PWD}"
}

