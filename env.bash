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

export ARCH=arm64
export CROSS_COMPILE="${PWD}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export CROSS32CC=arm-linux-gnueabi-gcc
export USER=$(whoami)

export MY_ANDROID=$TOP
export LC_ALL=C
export DRAM_SIZE_1G=false
export AUDIOHAT_ACTIVE=false
export NFC_ACTIVE=false
export WM8960_AUDIO_CODEC_ACTIVE=false

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

if [[ "$CPU_TYPE" == "imx8" ]]; then
  if [[ "$CPU_MODULE" == "pico-imx8m" ]]; then
    if [[ "$BASEBOARD" == "pi" ]]; then
      KERNEL_IMAGE='Image'
      KERNEL_CONFIG='tn_imx8_android_defconfig'
      UBOOT_CONFIG='pico-imx8mq_android_defconfig'
      TARGET_DEVICE=pico_imx8m
      TARGET_DEVICE_NAME=imx8mq
      sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${TOP}/device/fsl/imx8m/pico_imx8m/init.rc

      if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
        DTB_TARGET='imx8mq-pico-pi.dtb'
        export DISPLAY_TARGET="DISP_HDMI"
      elif [[ "$OUTPUT_DISPLAY" == "hdmi-voicehat" ]]; then
        DTB_TARGET='imx8mq-pico-pi-voicehat.dtb'
        export DISPLAY_TARGET="DISP_HDMI"
        export AUDIOHAT_ACTIVE=true
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c" ]]; then
        DTB_TARGET='imx8mq-pico-pi-dcss-ili9881c.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${TOP}/device/fsl/imx8m/pico_imx8m/init.rc
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c-voicehat" ]]; then
        DTB_TARGET='imx8mq-pico-pi-dcss-ili9881c-voicehat.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
        export AUDIOHAT_ACTIVE=true
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${TOP}/device/fsl/imx8m/pico_imx8m/init.rc
      fi
    fi
  elif [[ "$CPU_MODULE" == "pico-imx8m-mini" ]]; then
    if [[ "$BASEBOARD" == "pi" ]]; then
      KERNEL_IMAGE='Image'
      KERNEL_CONFIG='tn_imx8_android_defconfig'
      UBOOT_CONFIG='pico-imx8mm_android_defconfig'
      TARGET_DEVICE=pico_imx8mm
      TARGET_DEVICE_NAME=imx8mm
      if [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c" ]]; then
        DTB_TARGET='imx8mm-pico-pi-ili9881c.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c-voicehat" ]]; then
        DTB_TARGET='imx8mm-pico-pi-voicehat.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
        export AUDIOHAT_ACTIVE=true
      fi
    fi
  elif [[ "$CPU_MODULE" == "flex-imx8m-mini" ]]; then
    if [[ "$BASEBOARD" == "pi" ]]; then
      KERNEL_IMAGE='Image'
      KERNEL_CONFIG='tn_imx8_android_defconfig'
      UBOOT_CONFIG='flex-imx8mm_android_defconfig'
      TARGET_DEVICE=flex_imx8mm
      TARGET_DEVICE_NAME=imx8mm
      if [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c" ]]; then
        DTB_TARGET='imx8mm-flex-pi-ili9881c.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c-voicehat" ]]; then
        DTB_TARGET='imx8mm-flex-pi-ili9881c-voicehat.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
        export AUDIOHAT_ACTIVE=true
      fi
    fi
  elif [[ "$CPU_MODULE" == "edm-imx8m" ]]; then
    if [[ "$BASEBOARD" == "wizard" ]]; then
      KERNEL_IMAGE='Image'
      KERNEL_CONFIG='tn_imx8_android_defconfig'
      UBOOT_CONFIG='edm-imx8mq_android_defconfig'
      TARGET_DEVICE=edm_imx8m
      TARGET_DEVICE_NAME=imx8mq
      sed -i 's/ro.sf.lcd_density\ 160/ro.sf.lcd_density\ 213/' ${TOP}/device/fsl/imx8m/edm_imx8m/init.rc

      if [[ "$OUTPUT_DISPLAY" == "hdmi" ]]; then
        DTB_TARGET='imx8mq-edm-wizard.dtb'
        export DISPLAY_TARGET="DISP_HDMI"
      elif [[ "$OUTPUT_DISPLAY" == "hdmi-voicehat" ]]; then
        DTB_TARGET='imx8mq-edm-wizard-voicehat.dtb'
        export DISPLAY_TARGET="DISP_HDMI"
        export AUDIOHAT_ACTIVE=true
      elif [[ "$OUTPUT_DISPLAY" == "hdmi-wm8960" ]]; then
        DTB_TARGET='imx8mq-edm-wizard.dtb'
        export DISPLAY_TARGET="DISP_HDMI"
        export WM8960_AUDIO_CODEC_ACTIVE=true
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c" ]]; then
        DTB_TARGET='imx8mq-edm-wizard-dcss-ili9881c.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
        export WM8960_AUDIO_CODEC_ACTIVE=true
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${TOP}/device/fsl/imx8m/edm_imx8m/init.rc
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c-voicehat" ]]; then
        DTB_TARGET='imx8mq-edm-wizard-dcss-ili9881c-voicehat.dtb'
        export DISPLAY_TARGET="DISP_MIPI_ILI9881C"
        export AUDIOHAT_ACTIVE=true
        sed -i 's/ro.sf.lcd_density\ 213/ro.sf.lcd_density\ 160/' ${TOP}/device/fsl/imx8m/edm_imx8m/init.rc
      elif [[ "$OUTPUT_DISPLAY" == "dual-hdmi" ]]; then
        DTB_TARGET='imx8mq-edm-wizard-dual-display-adv7535.dtb'
        export DISPLAY_TARGET="DISP_DUAL_HDMI"
      fi
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
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
            cd "${PATH_KERNEL}"
            rm -rf ./modules/lib
            make "$@" $KERNEL_CFLAGS || return $?
            make "$@" modules_install INSTALL_MOD_PATH=./modules || return $?
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
            export CROSS_COMPILE="${TOP}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
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
            rm -rf firmware_imx8
            rm -rf imx-mkimage
            ;;
        *)
            echo -e "Error: outside the project" >&2
            return 1
            ;;
    esac

    cd "${TMP_PWD}"
}

uuu_flashcard() {

  partition_size="$@"

  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
  if [[ "$CPU_MODULE" == "pico-imx8m" ]]; then
  UBOOT_PLATFORM="imx8mq-pico-pi"
  elif [[ "$CPU_MODULE" == "pico-imx8m-mini" ]]; then
  UBOOT_PLATFORM="imx8mm-pico-pi"
  elif [[ "$CPU_MODULE" == "flex-imx8m-mini" ]]; then
  UBOOT_PLATFORM="imx8mm-flex-pi"
  elif [[ "$CPU_MODULE" == "edm-imx8m" ]]; then
  UBOOT_PLATFORM="imx8mq-edm-wizard"
  fi

  cd "${PATH_UBOOT}"
  yes | ./install_uboot_imx8.sh -b ${UBOOT_PLATFORM} -d /dev/loop0  > /dev/null
  cd -

  sudo cp -rv "${PATH_UBOOT}/imx-mkimage/iMX8M/flash.bin" "${PATH_OUT}/"
  cd "${PATH_OUT}"
  sudo cp -rv flash.bin u-boot-"${TARGET_DEVICE_NAME}".imx
  sudo cp -rv flash.bin u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu.imx
  #sudo tee < flash.bin u-boot-* > /dev/null
  sync
  sudo ./uuu_imx_android_flash.sh -c "${partition_size}" -f "${TARGET_DEVICE_NAME}" -e -D .
  echo "Flash Done!!!"
  cd "${TMP_PWD}"
}

flashcard() {
  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
  dev_node="$@"
  echo "$dev_node start"
  sudo cp -rv ${TMP_PWD}/device/fsl/common/tools/gpt_partition_move ${PATH_OUT}/
  cd "${PATH_OUT}"
  sudo $TOP/device/fsl/common/tools/tn-sd-emmc-partition.sh -f ${TARGET_DEVICE_NAME} -c 7 ${dev_node}
  sync
  cd "${PATH_UBOOT}"
  ./install_uboot_imx8.sh -b pico-imx8m -d ${dev_node}
  sync
  echo "Flash Done!!!"
  cd "${TMP_PWD}"
}

merge_restricted_extras() {
  wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/technexion-android/android_restricted_extra/raw/master/imx8-p9-2.0.tar.gz
  tar zxvf imx8-p9-2.0.tar.gz
  cp -rv imx-p9.0.0_2.0.0-ga/vendor/nxp/* vendor/nxp/
  cp -rv imx-p9.0.0_2.0.0-ga/EULA.txt .
  cp -rv imx-p9.0.0_2.0.0-ga/SCR* .
  rm -rf imx8-p9-2.0.tar.gz imx-p9.0.0_2.0.0-ga
  sync
}


gen_mp_images() {

  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
  if [[ "$CPU_MODULE" == "pico-imx8m" ]]; then
  UBOOT_PLATFORM="imx8mq-pico-pi"
  elif [[ "$CPU_MODULE" == "edm-imx8m" ]]; then
  UBOOT_PLATFORM="imx8mq-edm-wizard"
  elif [[ "$CPU_MODULE" == "pico-imx8m-mini" ]]; then
  UBOOT_PLATFORM="imx8mm-pico-pi"
  elif [[ "$CPU_MODULE" == "flex-imx8m-mini" ]]; then
  UBOOT_PLATFORM="imx8mm-flex-pi"
  fi

  cd "${PATH_UBOOT}"
  sed -i '250,253 s/^/#/' install_uboot_imx8.sh
  yes | ./install_uboot_imx8.sh -b ${UBOOT_PLATFORM} -d /dev/loop0  > /dev/null
  sed -i '250,253 s/#//' install_uboot_imx8.sh
  cd -

  sudo cp -rv "${PATH_UBOOT}/imx-mkimage/iMX8M/flash.bin" "${PATH_OUT}/"
  cd "${PATH_OUT}"
  sudo cp -rv flash.bin u-boot-"${TARGET_DEVICE_NAME}".imx
  sudo cp -rv flash.bin u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu.imx
  sync
  cd "${TMP_PWD}"

  mkdir -p auto_test
  cp -rv "${PATH_OUT}"/boot.img auto_test/
  cp -rv "${PATH_OUT}"/dtbo-"${TARGET_DEVICE_NAME}".img auto_test/
  cp -rv "${PATH_OUT}"/partition-table-*.img auto_test/
  cp -rv "${PATH_OUT}"/partition-table.img auto_test/
  cp -rv "${PATH_OUT}"/vbmeta-"${TARGET_DEVICE_NAME}".img auto_test/
  cp -rv "${PATH_OUT}"/vendor.img auto_test/
  cp -rv "${PATH_OUT}"/system.img auto_test/
  cp -rv "${PATH_OUT}"/flash.bin auto_test/
  cp -rv "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}".imx auto_test/
  cp -rv "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu.imx auto_test/

  cp -rv device/fsl/common/tools/uuu_imx_android_flash.sh auto_test/
  cp -rv device/fsl/common/tools/uuu_imx_android_flash.bat auto_test/
  cp -rv device/fsl/common/tools/fsl-sdcard-partition-virtual-image.sh auto_test/
  cp -rv device/fsl/common/tools/fsl-sdcard-partition.sh auto_test/

  sync
}

gen_virtual_images() {

  partition_size="$@"

  local TMP_PWD="${PWD}"
  PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
  if [[ "$CPU_MODULE" == "pico-imx8m" ]]; then
  UBOOT_PLATFORM="imx8mq-pico-pi"
  elif [[ "$CPU_MODULE" == "pico-imx8m-mini" ]]; then
  UBOOT_PLATFORM="imx8mm-pico-pi"
  elif [[ "$CPU_MODULE" == "flex-imx8m-mini" ]]; then
  UBOOT_PLATFORM="imx8mm-flex-pi"
  fi

  cd "${PATH_UBOOT}"
  sed -i '225,235 s/^/#/' install_uboot_imx8.sh
  yes | ./install_uboot_imx8.sh -b ${UBOOT_PLATFORM} -d /dev/loop0  > /dev/null
  sed -i '225,235 s/#//' install_uboot_imx8.sh
  cd -

  sudo cp -rv "${PATH_UBOOT}/imx-mkimage/iMX8M/flash.bin" "${PATH_OUT}/"
  cd "${PATH_OUT}"
  sudo cp -rv flash.bin u-boot-"${TARGET_DEVICE_NAME}".imx
  sudo cp -rv flash.bin u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu.imx
  sync
  cd "${TMP_PWD}"

  sudo cp -rv device/fsl/common/tools/fsl-sdcard-partition-virtual-image.sh "${PATH_OUT}/"

  cd "${PATH_OUT}"
  sudo dd if=/dev/zero of=test.img bs=7M count=1024
  sudo kpartx -av test.img
  loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c 7 "${loop_dev}"
  sudo kpartx -d test.img
  sync
  sudo kpartx -av test.img
  sudo ./fsl-sdcard-partition-virtual-image.sh -f "$TARGET_DEVICE_NAME" -c 7 "${loop_dev}"
  sudo kpartx -d test.img
  sync
  cd "${TMP_PWD}"
}
