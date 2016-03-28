TOP="${PWD}"
PATH_KERNEL="${PWD}/kernel_imx"
PATH_UBOOT="${PWD}/bootable/bootloader/uboot-imx"

export PATH="${PATH_UBOOT}/tools:${PATH}"
export ARCH=arm
export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi-"

# TARGET support: wandboard,edm1cf,picosom,edm1cf_6sx
IMX_PATH="./mnt"
MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
CPU_MODULE=$(echo $MODULE | awk -F. '{print $4}')
BASEBOARD=$(echo $MODULE | awk -F. '{print $5}')
OUTPUT_DISPLAY=$(echo $MODULE | awk -F. '{print $6}')

if [[ "$CPU_TYPE" == "imx6" ]]; then
    if [[ "$CPU_MODULE" == "edm1cf-sd" ]]; then
        if [[ "$BASEBOARD" == "wandboard" ]]; then
            UBOOT_CONFIG='wandboard_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='wandboard_defconfig'
            DTB_TARGET='imx6q-wandboard.dtb imx6dl-wandboard.dtb'
        fi

    elif [[ "$CPU_MODULE" == "edm1cf-nand" ]]; then
        if [[ "$BASEBOARD" == "fairy" ]]; then
            UBOOT_CONFIG='edm-cf-imx6-android_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='edm-cf-imx_android_defconfig'
            DTB_TARGET='imx6q-edm1-cf.dtb imx6dl-edm1-cf.dtb'
            TARGET_DEVICE=edm1cf_6qdl
        elif [[ "$BASEBOARD" == "tc0700" ]]; then
            UBOOT_CONFIG='edm-cf-imx6-android-no-console_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='edm-cf-imx_android_defconfig'
            DTB_TARGET='imx6q-edm1-cf.dtb imx6dl-edm1-cf.dtb'
            TARGET_DEVICE=edm1cf_6qdl
        elif [[ "$BASEBOARD" == "tek3" ]]; then
            UBOOT_CONFIG='edm-cf-imx6-android_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='edm-cf-imx_android_defconfig'
            DTB_TARGET='imx6q-tek3.dtb imx6dl-tek3.dtb'
            TARGET_DEVICE=tek3_6qdl
        fi

    elif [[ "$CPU_MODULE" == "picosom-sd" ]]; then
        if [[ "$BASEBOARD" == "dwarf" ]]; then
            UBOOT_CONFIG='picosom-imx6-android_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='picosom-imx6_android_defconfig'
            DTB_TARGET='imx6q-picosom.dtb imx6dl-picosom.dtb'
            TARGET_DEVICE=pico_6qdl
        fi
    fi

elif [[ "$CPU_TYPE" == "imx6sx" ]]; then
    if [[ "$CPU_MODULE" == "edm1cf-nand" ]]; then
        if [[ "$BASEBOARD" == "goblin_lvds" ]]; then
            UBOOT_CONFIG='edm1-cf-imx6sx_defconfig'
            KERNEL_IMAGE='zImage'
            KERNEL_CONFIG='edm-cf-imx_defconfig'
            DTB_TARGET='imx6sx-edm1-cf.dtb'
        fi
    fi

elif [[ "$CPU_TYPE" == "imx7" ]]; then
    if [[ "$CPU_MODULE" == "picosom-sd" ]]; then
        if [[ "$BASEBOARD" == "dwarf" ]]; then
            UBOOT_CONFIG='pico-imx7d_android_defconfig'
            KERNEL_IMAGE='uImage LOADADDR=0x80008000'
            KERNEL_CONFIG='picosom-imx6_android_defconfig'
            DTB_TARGET='imx7d-pico.dtb'
            TARGET_DEVICE=pico_7d
        fi
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
            cd "${PATH_KERNEL}"
            make "$@" $KERNEL_IMAGE || return $?
            make "$@" modules || return $?
            make "$@" $DTB_TARGET || return $?
            ;;
        "${PATH_UBOOT}"*)
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
            cd "${PATH_KERNEL}"
            make "$@" $KERNEL_CONFIG || return $?
            heat "$@" || return $?
            ;;
        "${PATH_UBOOT}"*)
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

        if [[ "$TARGET_DEVICE" == "edm1cf_6qdl" ]]; then
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-edm1-cf.dtb $IMX_PATH/imx6q-edm1-cf.dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-edm1-cf.dtb $IMX_PATH/imx6dl-edm1-cf.dtb;sync
        elif [[ "$TARGET_DEVICE" == "pico_6qdl" ]]; then
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-picosom.dtb $IMX_PATH/imx6q-picosom.dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-picosom.dtb $IMX_PATH/imx6dl-picosom.dtb; sync
        elif [[ "$TARGET" == "wandboard" ]]; then
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-wandboard.dtb $IMX_PATH/imx6q-wandboard.dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-wandboard.dtb $IMX_PATH/imx6dl-wandboard.dtb;sync
        elif [[ "$TARGET" == "tek3_6qdl" ]]; then
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6q-tek3.dtb $IMX_PATH/imx6q-tek3.dtb; sync
            sudo cp $PATH_KERNEL/arch/arm/boot/dts/imx6dl-tek3.dtb $IMX_PATH/imx6dl-tek3.dtb;sync
       fi

        # donwload the environment settings
        echo == download the environment ==i

        if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
            sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.hdmi $IMX_PATH/uEnv.txt; sync
        elif [[ "$OUTPUT_DISPLAY" == "lvds" ]]; then
            if [[ "$BASEBOARD" == "tc0700" ]]; then
                sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.tc0700 $IMX_PATH/uEnv.txt; sync
            else
                sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.lvds $IMX_PATH/uEnv.txt; sync
            fi
        else
            sudo cp ./device/fsl/"$TARGET_DEVICE"/uenv/uEnv.txt.hdmi $IMX_PATH/uEnv.txt; sync
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

git_check() {
    local TMP_PWD="${PWD}"

    if [[ "$TARGET" == "edm1cf_6sx" ]]; then
        cd ${PATH_UBOOT} && git checkout tn-mx6-patches-2014.04_3.10.53_1.1.0_ga
        cd "${TMP_PWD}"
        cd ./hardware/libhardware_legacy && git checkout master
        cd "${TMP_PWD}"
        cd ./hardware/broadcom/libbt && git checkout tn-mx6-3.10.53-1.1.0-lp.5.0.0-ga-edm1sx
        cd "${TMP_PWD}"
    elif [[ "$TARGET" == "picosom" ]]; then
        cd ${PATH_UBOOT} && git checkout tn-mx6-patches-2014.10_3.10.53_1.1.0_ga
        cd "${TMP_PWD}"
        cd ./hardware/libhardware_legacy && git checkout tn-mx6-3.10.53-1.1.0-lp.5.0.0-ga-pico
        cd "${TMP_PWD}"
        cd ./hardware/broadcom/libbt && git checkout tn-mx6-3.10.53-1.1.0-lp.5.0.0-ga-pico
        cd "${TMP_PWD}"
    else
        cd ${PATH_UBOOT} && git checkout tn-mx6-patches-2014.10_3.10.53_1.1.0_ga
        cd "${TMP_PWD}"
        cd ./hardware/libhardware_legacy && git checkout master
        cd "${TMP_PWD}"
        cd ./hardware/broadcom/libbt && git checkout master
        cd "${TMP_PWD}"
    fi

    cd "${TMP_PWD}"
}

