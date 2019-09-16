#############################
# Author
# Technexion
#############################

TOP="${PWD}"
PATH_KERNEL="${PWD}/vendor/nxp-opensource/kernel_imx"
PATH_UBOOT="${PWD}/vendor/nxp-opensource/uboot-imx"
PATH_OUT_DRIVERS="${PWD}/vendor/nxp-opensource/out-of-tree_drivers"

export PATH="${PATH_UBOOT}/tools:${PATH}"
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
CLASSPATH=".:$JAVA_HOME/lib:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
PATH="$JAVA_HOME/bin:${PATH}"
export DISPLAY=:0

export ARCH=arm
export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
export USER=$(whoami)

export MY_ANDROID=$TOP
export LC_ALL=C
export DRAM_SIZE_1G=false
export AUDIOHAT_ACTIVE=false
export EXPORT_BASEBOARD_NAME="PI"


# TARGET support: pico-imx8m, pico-imx8mm
IMX_PATH="./mnt"
SYS_PATH="./tmp"
MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
CPU_MODULE=$(echo $MODULE | awk -F. '{print $4}')
BASEBOARD=$(echo $MODULE | awk -F. '{print $5}')
OUTPUT_DISPLAY=$(echo $MODULE | awk -F. '{print $6}')
KERNEL_CFLAGS='KCFLAGS=-mno-android'

PATH_TOOLS="${TOP}/device/fsl/common/tools"

if [[ "$CPU_TYPE" == "imx6q" || "$CPU_TYPE" == "imx6dl" ]]; then
  if [[ "$CPU_MODULE" == "pico-imx6" ]]; then
    init_rc_file="${TOP}/device/fsl/imx6dq/pico_imx6/init.rc"
    KERNEL_IMAGE='Image'
    KERNEL_CONFIG='tn_android_defconfig'
    UBOOT_CONFIG='pico-imx6_android_spl_defconfig'
    TARGET_DEVICE=pico_imx6
    TARGET_DEVICE_NAME="${CPU_TYPE}"
    DTB_TARGET='imx6q-pico-qca_pi.dtb imx6dl-pico-qca_pi.dtb imx6q-pico-qca_dwarf.dtb imx6dl-pico-qca_dwarf.dtb imx6q-pico-qca_nymph.dtb imx6dl-pico-qca_nymph.dtb imx6q-pico-qca_hobbit.dtb imx6dl-pico-qca_hobbit.dtb'
    if [[ "$BASEBOARD" == "pi" ]]; then
      export EXPORT_BASEBOARD_NAME="PI"
    elif [[ "$BASEBOARD" == "dwarf" ]]; then
      export EXPORT_BASEBOARD_NAME="DWARF"
    elif [[ "$BASEBOARD" == "hobbit" ]]; then
      export EXPORT_BASEBOARD_NAME="HOBBIT"
    elif [[ "$BASEBOARD" == "nymph" ]]; then
      export EXPORT_BASEBOARD_NAME="NYMPH"
    elif [[ "$BASEBOARD" == "hobbit" ]]; then
      export EXPORT_BASEBOARD_NAME="HOBBIT"
    fi
    if [ -f "$init_rc_file" ]; then
      # echo "$init_rc_file exist"
      if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
        export DISPLAY_TARGET="DISP_HDMI"
        sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
      elif [[ "$OUTPUT_DISPLAY" == "lcd-5-inch" ]]; then
        export DISPLAY_TARGET="DISP_LCD_5INCH"
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
        sed -i 's/		# setprop hw.backlight.dev "backlight_lcd"/		setprop hw.backlight.dev "backlight_lcd"/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
        sed -i 's/		setprop hw.backlight.dev "backlight_lvds"/		# setprop hw.backlight.dev "backlight_lvds"/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
      elif [[ "$OUTPUT_DISPLAY" == "lvds-7-inch" ]]; then
        export DISPLAY_TARGET="DISP_LVDS_7INCH"
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
        sed -i 's/		setprop hw.backlight.dev "backlight_lcd"/		# setprop hw.backlight.dev "backlight_lcd"/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
        sed -i 's/		# setprop hw.backlight.dev "backlight_lvds"/		setprop hw.backlight.dev "backlight_lvds"/' ${TOP}/device/fsl/imx6dq/pico_imx6/init.rc
      fi
    fi
  fi
elif [[ "$CPU_TYPE" == "imx7d" ]]; then
  if [[ "$CPU_MODULE" == "pico-imx7" ]]; then
    KERNEL_IMAGE='Image'
    KERNEL_CONFIG='tn_android_defconfig'
    UBOOT_CONFIG='pico-imx7d_android_spl_defconfig'
    DTB_TARGET='imx7d-pico-qca_pi.dtb imx7d-pico-qca_dwarf.dtb imx7d-pico-qca_nymph.dtb imx7d-pico-qca_hobbit.dtb'
    TARGET_DEVICE=pico_imx7
    TARGET_DEVICE_NAME="${CPU_TYPE}"
    if [[ "$BASEBOARD" == "pi" ]]; then
      export EXPORT_BASEBOARD_NAME="PI"
    elif [[ "$BASEBOARD" == "dwarf" ]]; then
      export EXPORT_BASEBOARD_NAME="DWARF"
    elif [[ "$BASEBOARD" == "hobbit" ]]; then
      export EXPORT_BASEBOARD_NAME="HOBBIT"
    elif [[ "$BASEBOARD" == "nymph" ]]; then
      export EXPORT_BASEBOARD_NAME="NYMPH"
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
            source build/envsetup.sh
            lunch "$TARGET_DEVICE"-userdebug
            make "$@" || return $?

            if [ "${AUDIOHAT_ACTIVE}" = true ] ; then
              echo 'Compile Audio-Hat relative drivers...'
              cd "${PATH_OUT_DRIVERS}"/tfa98xx/
              KDIR="${TOP}"/out/target/product/"$TARGET_DEVICE"/obj/KERNEL_OBJ make clean
              KDIR="${TOP}"/out/target/product/"$TARGET_DEVICE"/obj/KERNEL_OBJ make
              KDIR="${TOP}"/out/target/product/"$TARGET_DEVICE"/obj/KERNEL_OBJ make modules_install
              cd -
              make "$@" || return $?
            fi
            ;;
        "${PATH_KERNEL}"*)
            cd "${PATH_KERNEL}"
            rm -rf ./modules/lib
            make "$@" $KERNEL_CFLAGS || return $?
            make "$@" modules_install INSTALL_MOD_PATH=./modules || return $?
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
    echo "$TMP_PWD"

    case "${PWD}" in
        "${TOP}")
            cd "${TMP_PWD}"
            source build/envsetup.sh
            lunch "$TARGET_DEVICE"-userdebug
            make "$@" || return $?

            if [ "${AUDIOHAT_ACTIVE}" = true ] ; then
              echo 'Compile Audio-Hat relative drivers...'
              cd "${PATH_OUT_DRIVERS}"/tfa98xx/
              KDIR="${TOP}"/out/target/product/"$TARGET_DEVICE"/obj/KERNEL_OBJ make clean
              KDIR="${TOP}"/out/target/product/"$TARGET_DEVICE"/obj/KERNEL_OBJ make
              KDIR="${TOP}"/out/target/product/"$TARGET_DEVICE"/obj/KERNEL_OBJ make modules_install
              cd -
              make "$@" || return $?
            fi
            cd ${PATH_UBOOT} && cook "$@" || return $?
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
  dev_node="$1"
  card_size="$2"
  echo "$dev_node start"
  sudo cp -rv ${TMP_PWD}/device/fsl/common/tools/gpt_partition_move ${PATH_OUT}/
  cd "${PATH_OUT}"
  sudo ./fsl-sdcard-partition.sh -f ${TARGET_DEVICE_NAME} -c ${card_size} ${dev_node}
  sync

  sudo ./gpt_partition_move -d ${dev_node} -s 4096
  SPL_IMAGE=$(ls u-boot-*.SPL)
  UBOOT_RAW_IMAGE=$(ls u-boot-*.img)
  sudo dd if=${SPL_IMAGE} of=${dev_node} bs=1k seek=1 conv=sync

  if [[ "$TARGET_DEVICE" == "pico_imx6" ]]; then
    sudo dd if=${UBOOT_RAW_IMAGE} of=${dev_node} bs=512 seek=92 oflag=dsync
  elif [[ "$TARGET_DEVICE" == "pico_imx7" ]]; then
    sudo dd if=${UBOOT_RAW_IMAGE} of=${dev_node} bs=512 seek=120 oflag=dsync
  fi

  sync
  echo "Flash Done!!!"
  cd "${TMP_PWD}"
}

merge_restricted_extras() {
  wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/technexion-android/android_restricted_extra/raw/master/imx6_7-p9-2.2.tar.gz
  tar zxvf imx6_7-p9-2.2.tar.gz
  cp -rv imx-p9.0.0_2.2.0-ga/vendor/nxp/* vendor/nxp/
  cp -rv imx-p9.0.0_2.2.0-ga/EULA.txt .
  cp -rv imx-p9.0.0_2.2.0-ga/SCR* .
  rm -rf imx6_7-p9-2.2.tar.gz imx-p9.0.0_2.2.0-ga
  sync
}

gen_mp_images() {
  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"

  mkdir -p auto_test

  cp -rv "${PATH_OUT}"/boot.img auto_test/
  cp -rv "${PATH_OUT}"/dtbo-*.img auto_test/
  cp -rv "${PATH_OUT}"/partition-table-*.img auto_test/
  cp -rv "${PATH_OUT}"/partition-table.img auto_test/
  cp -rv "${PATH_OUT}"/vbmeta-*.img auto_test/
  cp -rv "${PATH_OUT}"/vendor.img auto_test/
  cp -rv "${PATH_OUT}"/system.img auto_test/
  cp -rv "${PATH_OUT}"/recovery*.img auto_test/
  cp -rv "${PATH_OUT}"/u-boot-*.SPL auto_test/
  cp -rv "${PATH_OUT}"/u-boot-*.img auto_test/

  cp -rv device/fsl/common/tools/gpt_partition_move auto_test/
  cp -rv device/fsl/common/tools/fsl-sdcard-partition.sh auto_test/
  cp -rv device/fsl/common/tools/fsl-sdcard-partition-virtual-image.sh auto_test/

  chmod -R 777 auto_test/

  sync
}

gen_virtual_images() {

  partition_size="$@"

  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"

  cd "${TMP_PWD}"

  cd "${PATH_OUT}"
  sudo dd if=/dev/zero of=test.img bs=1M count=3400
  sudo kpartx -av test.img
  loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c 3 "${loop_dev}"
  sudo kpartx -d test.img
  sync
  sudo kpartx -av test.img
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c 3 "${loop_dev}"
  sync

  sudo ./gpt_partition_move -d ${loop_dev} -s 4096
  SPL_IMAGE=$(ls u-boot-*.SPL)
  UBOOT_RAW_IMAGE=$(ls u-boot-*.img)
  sudo dd if=${SPL_IMAGE} of=${loop_dev} bs=1k seek=1 conv=sync

  if [[ "$TARGET_DEVICE" == "pico_imx6" ]]; then
    sudo dd if=${UBOOT_RAW_IMAGE} of=${loop_dev} bs=512 seek=92 oflag=dsync
  elif [[ "$TARGET_DEVICE" == "pico_imx7" ]]; then
    sudo dd if=${UBOOT_RAW_IMAGE} of=${loop_dev} bs=512 seek=120 oflag=dsync
  fi

  sync
  sudo kpartx -d test.img
  sync
  cd "${TMP_PWD}"
}
