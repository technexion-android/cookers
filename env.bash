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
      UBOOT_CONFIG='pico-imx8m_android_defconfig'
      TARGET_DEVICE=pico_imx8m
      TARGET_DEVICE_NAME=imx8mq
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
        export DISPLAY_TARGET="DISP_HDMI"
      elif [[ "$OUTPUT_DISPLAY" == "mipi-dsi_ili9881c-voicehat" ]]; then
        DTB_TARGET='imx8mm-pico-pi-voicehat.dtb'
        export DISPLAY_TARGET="DISP_HDMI"
        export AUDIOHAT_ACTIVE=true
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

            cd ${PATH_UBOOT} && heat "$@" || return $?
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
  wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/technexion-android/android_restricted_extra/raw/master/imx8-p9.tar.gz
  tar zxvf imx8-p9.tar.gz
  cp -rv imx-p9.0.0_1.0.0-ga/vendor/nxp/* vendor/nxp/
  cp -rv imx-p9.0.0_1.0.0-ga/EULA.txt .
  cp -rv imx-p9.0.0_1.0.0-ga/SCR* .
  rm -rf imx8-p9.tar.gz imx-p9.0.0_1.0.0-ga
  sync
}


gen_mp_images() {
  mkdir -p auto_test/device/fsl/common/tools
  mkdir -p auto_test/vendor/nxp-opensource
  cp -rv device/fsl/common/tools/* auto_test/device/fsl/common/tools/

  mkdir -p auto_test/out/target/product/"${TARGET_DEVICE}"/
  sudo cp -rv device/fsl/common/tools/gpt_partition_move auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/boot*.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/dtbo*.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/partition-table-*.bpt auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/partition-table-*.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/partition-table.bpt auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/partition-table.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/ramdisk-recovery.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/vbmeta-*.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/vendor.img auto_test/out/target/product/"${TARGET_DEVICE}"/
  cp -rv out/target/product/"${TARGET_DEVICE}"/system.img auto_test/out/target/product/"${TARGET_DEVICE}"/

  cp -rv cookers auto_test/
  cp -rv vendor/nxp-opensource/uboot-imx auto_test/vendor/nxp-opensource/
  rm -rf auto_test/cookers/.git
  rm -rf auto_test/vendor/nxp-opensource/uboot-imx/.git
  chmod -R 777 auto_test/vendor/nxp-opensource/uboot-imx/

  mkdir -p auto_test/prebuilts/gcc/linux-x86/aarch64
  cp -rv prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 auto_test/prebuilts/gcc/linux-x86/aarch64/
  sync
}
