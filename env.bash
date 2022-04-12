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

export GLOBAL_CPU_TYPE=$(echo $CPU_TYPE | tr "[:lower:]" "[:upper:]")

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
  elif [[ "$CPU_MODULE" == "edm1-imx6" ]]; then
    TARGET_DEVICE=edm1_imx6
    init_rc_file="${TOP}/device/fsl/imx6dq/${TARGET_DEVICE}/init.rc"
    KERNEL_IMAGE='Image'
    KERNEL_CONFIG='tn_android_defconfig'
    UBOOT_CONFIG='edm-imx6_android_spl_defconfig'
    TARGET_DEVICE_NAME="${CPU_TYPE}"
    export EXPORT_BASEBOARD_NAME="FAIRY"
    DTB_TARGET='imx6dl-edm1-fairy-qca.dtb imx6q-edm1-fairy-qca.dtb imx6qp-edm1-fairy-qca.dtb'
    if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
      export DISPLAY_TARGET="DISP_HDMI"
    elif [[ "$OUTPUT_DISPLAY" == "lcd-5-inch" ]]; then
      export DISPLAY_TARGET="DISP_LCD_5INCH"
    elif [[ "$OUTPUT_DISPLAY" == "tc0700" ]]; then
      export DISPLAY_TARGET="DISP_LVDS_7INCH"
      export EXPORT_BASEBOARD_NAME="TC0700"
      DTB_TARGET='imx6dl-edm1-tc0700-qca.dtb imx6q-edm1-tc0700-qca.dtb imx6qp-edm1-tc0700-qca.dtb'
    elif [[ "$OUTPUT_DISPLAY" == "tc1000" ]]; then
      export DISPLAY_TARGET="DISP_LVDS_10INCH"
      export EXPORT_BASEBOARD_NAME="TC1000"
      DTB_TARGET='imx6dl-edm1-tc1000-qca.dtb imx6q-edm1-tc1000-qca.dtb imx6qp-edm1-tc1000-qca.dtb'
    fi
    if [ -f "$init_rc_file" ]; then
      # echo "$init_rc_file exist"
      if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
        sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${init_rc_file}
      elif [[ "$OUTPUT_DISPLAY" == "lcd-5-inch" ]]; then
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${init_rc_file}
        sed -i 's/		# setprop hw.backlight.dev "backlight_lcd"/		setprop hw.backlight.dev "backlight_lcd"/' ${init_rc_file}
        sed -i 's/		setprop hw.backlight.dev "backlight_lvds"/		# setprop hw.backlight.dev "backlight_lvds"/' ${init_rc_file}
      elif [[ "$OUTPUT_DISPLAY" == "lvds-7-inch" || "$OUTPUT_DISPLAY" == "tc0700" ]]; then
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${init_rc_file}
        sed -i 's/		setprop hw.backlight.dev "backlight_lcd"/		# setprop hw.backlight.dev "backlight_lcd"/' ${init_rc_file}
        sed -i 's/		# setprop hw.backlight.dev "backlight_lvds"/		setprop hw.backlight.dev "backlight_lvds"/' ${init_rc_file}
      elif [[ "$OUTPUT_DISPLAY" == "tc1000" ]]; then
        sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${init_rc_file}
        sed -i 's/		setprop hw.backlight.dev "backlight_lcd"/		# setprop hw.backlight.dev "backlight_lcd"/' ${init_rc_file}
        sed -i 's/		# setprop hw.backlight.dev "backlight_lvds"/		setprop hw.backlight.dev "backlight_lvds"/' ${init_rc_file}
      fi
    fi
  elif [[ "$CPU_MODULE" == "hmi" ]]; then
    TARGET_DEVICE=tep5_imx6
    init_rc_file="${TOP}/device/fsl/imx6dq/${TARGET_DEVICE}/init.rc"
    KERNEL_IMAGE='Image'
    KERNEL_CONFIG='tn_android_defconfig'
    UBOOT_CONFIG='tek-imx6_android_spl_defconfig'
    TARGET_DEVICE_NAME="${CPU_TYPE}"
    export EXPORT_BASEBOARD_NAME="TEP5"
    if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
      export DISPLAY_TARGET="DISP_HDMI"
    elif [[ "$OUTPUT_DISPLAY" == "lvds-10-inch" ]]; then
      export DISPLAY_TARGET="DISP_LVDS_10INCH"
      DTB_TARGET='imx6dl-tep5.dtb imx6q-tep5.dtb'
    elif [[ "$OUTPUT_DISPLAY" == "lvds-15-inch" ]]; then
      export DISPLAY_TARGET="DISP_LVDS_15INCH"
      DTB_TARGET='imx6dl-tep5-15.dtb imx6q-tep5-15.dtb'
    fi
    if [ -f "$init_rc_file" ]; then
      # echo "$init_rc_file exist"
      if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
        sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${init_rc_file}
      elif [[ "$OUTPUT_DISPLAY" == "lvds-10-inch" || "$OUTPUT_DISPLAY" == "lvds-15-inch" ]]; then
        sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${init_rc_file}
        sed -i 's/		setprop hw.backlight.dev "backlight_lcd"/		# setprop hw.backlight.dev "backlight_lcd"/' ${init_rc_file}
        sed -i 's/		# setprop hw.backlight.dev "backlight_lvds"/		setprop hw.backlight.dev "backlight_lvds"/' ${init_rc_file}
      fi
    fi
  fi
elif [[ "$CPU_TYPE" == "imx7d" ]]; then
  if [[ "$CPU_MODULE" == "pico-imx7" ]]; then
    KERNEL_IMAGE='Image'
    KERNEL_CONFIG='tn_android_defconfig'
    UBOOT_CONFIG='pico-imx7d_android_spl_defconfig'
    DTB_TARGET='imx7d-pico-qca_pi.dtb imx7d-pico-qca_pi-voicehat.dtb imx7d-pico-qca_dwarf.dtb imx7d-pico-qca_nymph.dtb imx7d-pico-qca_hobbit.dtb'
    TARGET_DEVICE=pico_imx7
    TARGET_DEVICE_NAME="${CPU_TYPE}"
    if [[ "$BASEBOARD" == "pi" ]]; then
      export EXPORT_BASEBOARD_NAME="PI"
      if [[ "$OUTPUT_DISPLAY" == "lcd-5-inch-voicehat" ]]; then
        export AUDIOHAT_ACTIVE=true
      fi
    elif [[ "$BASEBOARD" == "dwarf" ]]; then
      export EXPORT_BASEBOARD_NAME="DWARF"
    elif [[ "$BASEBOARD" == "hobbit" ]]; then
      export EXPORT_BASEBOARD_NAME="HOBBIT"
    elif [[ "$BASEBOARD" == "nymph" ]]; then
      export EXPORT_BASEBOARD_NAME="NYMPH"
    fi
  elif [[ "$CPU_MODULE" == "hmi" ]]; then
    KERNEL_IMAGE='Image'
    KERNEL_CONFIG='tn_android_defconfig'
    UBOOT_CONFIG='tep1-imx7d_android_spl_defconfig'
    DTB_TARGET='imx7d-tep1.dtb imx7d-tep1-a2.dtb'
    TARGET_DEVICE=tep1_imx7
    TARGET_DEVICE_NAME="${CPU_TYPE}"
    export EXPORT_BASEBOARD_NAME="TEP1"
    export DISPLAY_TARGET="DISP_LCD_5INCH"
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
            if [[ $(cat /etc/issue | grep "20.04") ]]; then
              cd "${PATH_KERNEL}"
              cp -rv "${TOP}"/cookers/patches/selinux-use-kernel-definition-of-PF_MAX-in-scripts.diff .
              git apply selinux-use-kernel-definition-of-PF_MAX-in-scripts.diff
              rm selinux-use-kernel-definition-of-PF_MAX-in-scripts.diff
              cd "${TOP}"
            fi

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
            if [[ $(cat /etc/issue | grep "20.04") ]]; then
              cd "${PATH_KERNEL}"
              cp -rv "${TOP}"/cookers/patches/selinux-use-kernel-definition-of-PF_MAX-in-scripts.diff .
              git apply selinux-use-kernel-definition-of-PF_MAX-in-scripts.diff
              rm selinux-use-kernel-definition-of-PF_MAX-in-scripts.diff
              cd "${TOP}"
            fi

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

            if [ "$BASEBOARD" == "tep1-imx7" ] ; then
              echo 'Packaging Bluetooth USB library...'
              cd "${TOP}"/out/target/product/"$TARGET_DEVICE"/vendor/lib/hw/
              sudo ln -sn android.hardware.bluetooth@1.0-usb_impl.so android.hardware.bluetooth@1.0-impl.so
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

  if [ -z "$card_size" ];then
    card_size=7
  fi

  echo "$dev_node start"
  sudo cp -rv ${TMP_PWD}/device/fsl/common/tools/gpt_partition_move ${PATH_OUT}/
  cd "${PATH_OUT}"
  sudo ./fsl-sdcard-partition.sh -f ${TARGET_DEVICE_NAME} -c ${card_size} ${dev_node}
  sync

  sudo ./gpt_partition_move -d ${dev_node} -s 4096
  SPL_IMAGE=$(ls u-boot-*.SPL)
  UBOOT_RAW_IMAGE=$(ls u-boot-*.img)
  sudo dd if=${SPL_IMAGE} of=${dev_node} bs=1k seek=1 conv=sync
  if [[ "$CPU_TYPE" == "imx6q" || "$CPU_TYPE" == "imx6dl" ]]; then
    echo "flash_partition: ${UBOOT_RAW_IMAGE} ---> ${dev_node}"
    sudo dd if=${UBOOT_RAW_IMAGE} of=${dev_node} bs=512 seek=92 oflag=dsync
  elif [[ "$CPU_TYPE" == "imx7d" ]]; then
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
  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"

  img_size="$@"

  virtual_image_file="${PATH_OUT}/fsl-sdcard-partition-virtual-image.sh"

  sudo cp -rv ${TOP}/device/fsl/common/tools/gpt_partition_move ${PATH_OUT}/

  if [ -f "$virtual_image_file" ]; then
    echo "Find ${virtual_image_file}"
  else
    cp -rv device/fsl/common/tools/fsl-sdcard-partition-virtual-image.sh ${virtual_image_file}
  fi

  cd "${TMP_PWD}"

  if [[ "$img_size" == "" ]];then
    img_size=3
  fi

  cd "${PATH_OUT}"
  echo "Create an empty image with size $img_size:"
  sudo dd if=/dev/zero of=test.img bs="$img_size"M count=1024

  echo "Attach the image to a loop device:"
  sudo kpartx -av test.img
  loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
  echo "Image was attached on $loop_dev"

  echo Partition with:\
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c "$img_size" "${loop_dev}"
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c "$img_size" "${loop_dev}"
  sync

  echo "Detach the loop dev $loop_dev and reattach it"
  sudo kpartx -d test.img
  sudo kpartx -d "${loop_dev}"
  sudo losetup -d "${loop_dev}"
  sync

  sudo kpartx -av test.img
  loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
  echo "Image was reattached on $loop_dev"

  echo Partition it again with:\
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c "$img_size" "${loop_dev}"
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c "$img_size" "${loop_dev}"
  sync

  echo "Detach the loop dev $loop_dev and reattach it"
  sudo kpartx -d test.img
  sudo kpartx -d "${loop_dev}"
  sudo losetup -d "${loop_dev}"
  sync

  sudo kpartx -av test.img
  loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
  echo "Image was reattached on $loop_dev"

  echo Move the GPT partition header to make room for SPL and Bootloader:\
  sudo ./gpt_partition_move -d ${loop_dev} -s 4096
  sudo ./gpt_partition_move -d ${loop_dev} -s 4096
  sync

  echo Write SPL and Bootloader into the now empty space before the header:
  SPL_IMAGE=$(ls u-boot-*.SPL)
  UBOOT_RAW_IMAGE=$(ls u-boot-*.img)
  echo - sudo dd if=${SPL_IMAGE} of=${loop_dev} bs=1k seek=1 conv=sync
  sudo dd if=${SPL_IMAGE} of=${loop_dev} bs=1k seek=1 conv=sync

  if [[ "$CPU_TYPE" == "imx6q" || "$CPU_TYPE" == "imx6dl" ]]; then
    echo - sudo dd if=${UBOOT_RAW_IMAGE} of=${loop_dev} bs=512 seek=92 oflag=dsync
    sudo dd if=${UBOOT_RAW_IMAGE} of=${loop_dev} bs=512 seek=92 oflag=dsync
  elif [[ "$CPU_TYPE" == "imx7d" ]]; then
    echo - sudo dd if=${UBOOT_RAW_IMAGE} of=${loop_dev} bs=512 seek=120 oflag=dsync
    sudo dd if=${UBOOT_RAW_IMAGE} of=${loop_dev} bs=512 seek=120 oflag=dsync
  fi
  sync

  echo Detach the loop dev $loop_dev with the image for the last time:
  sudo kpartx -d test.img
  sudo kpartx -d "${loop_dev}"
  sudo losetup -d "${loop_dev}"
  sync

  echo Clean up loop devices # Technically not needed if everything went OK
  for i in $(losetup |grep 'test.img' |awk '{print $1}') ; do
    echo - sudo kpartx -d "${loop_dev}"
    sudo kpartx -d "${loop_dev}"
    echo - sudo losetup -d "$i"
    sudo losetup -d "$i"
  done

  cd "${TMP_PWD}"
  echo Done
}
