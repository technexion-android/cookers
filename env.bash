#############################
# Author
# Technexion
#############################

[[ -z ${BASH_SOURCE} ]] && { echo -e "\nPlase execute $0 with bash ....\n"; return 1; }

TOP="${PWD}"
PATH_KERNEL="${PWD}/vendor/nxp-opensource/kernel_imx"
PATH_UBOOT="${PWD}/vendor/nxp-opensource/uboot-imx"
PATH_OUT_DRIVERS="${PWD}/vendor/nxp-opensource/out-of-tree_drivers"

export PATH="${PATH_UBOOT}/tools:${PATH}"
export USER=$(whoami)
export USE_CCACHE=1

export MY_ANDROID=$TOP
export LC_ALL=C
export ARCH=arm64

# TARGET support
MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
CPU_MODULE=$(echo $MODULE | awk -F. '{print $4}')
BASEBOARD=$(echo $MODULE | awk -F. '{print $5}')
OUTPUT_DISPLAY=$(echo $MODULE | awk -F. '{print $6}')
export EXPORT_BASEBOARD_NAME=$(tr '[:lower:]' '[:upper:]' <<< ${BASEBOARD})

if [[ "$CPU_TYPE" == "imx8" ]]; then
	case ${CPU_MODULE} in
		'edm-g-imx8mp')
			TARGET_DEVICE_NAME=imx8mp
			TARGET_DEVICE="edm_g_${TARGET_DEVICE_NAME}"
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-edm-g_android"
			;;
		'edm-g-imx8mm')
			TARGET_DEVICE_NAME=imx8mm
			TARGET_DEVICE=edm_g_${TARGET_DEVICE_NAME}
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-edm-g_android"
			;;
		'evk-8mp')
			TARGET_DEVICE_NAME=imx8mp
			TARGET_DEVICE=evk_8mp
			KERNEL_IMAGE='Image'
			#KERNEL_CONFIG='gki_defconfig'
			KERNEL_CONFIG='imx_v8_android_defconfig'
			UBOOT_CONFIG='imx8mp_evk_android_defconfig'
			UBOOT_TARGET=evk_8mp
			;;
		'evk-8mm')
			TARGET_DEVICE_NAME=imx8mm
			TARGET_DEVICE=evk_8mm
			KERNEL_IMAGE='Image'
			#KERNEL_CONFIG='gki_defconfig'
			KERNEL_CONFIG='imx_v8_android_defconfig'
			UBOOT_CONFIG='imx8mm_evk_android_defconfig'
			UBOOT_TARGET=evk_8mm
			;;
		*)
			echo "ERROR: Unsupported ${CPU_MODULE}"
			exit 1
			;;
	esac
fi

PATH_UBOOT_OUTPUT="${PWD}/out/target/product/${TARGET_DEVICE}/obj/UBOOT_OBJ"
PATH_KERNEL_OUTPUT="${PWD}/out/target/product/${TARGET_DEVICE}/obj/KERNEL_OBJ"

_error_msg() {
	echo -e "\033[0;31mERROR: ${1}\033[0;0m"
}

recipe() {
	local TMP_PWD="${PWD}"

	case "${PWD}" in
		"${PATH_UBOOT_OUTPUT}"*)
			cd "${PATH_UBOOT_OUTPUT}"
			make "$@" menuconfig || return $?
			cd -
			;;
		"${PATH_KERNEL_OUTPUT}"*)
			cd "${PATH_KERNEL_OUTPUT}"
			make "$@" menuconfig || return $?
			cd -
			;;
		*)
			echo -e "Error: outside the project" >&2
			return 1
			;;
	esac

	cd "${TMP_PWD}"
}

toolchain_setup() {
	JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
	CLASSPATH=".:$JAVA_HOME/lib:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
	PATH="$JAVA_HOME/bin:${PATH}"

	local _trg_arch="aarch64"
	local _toolchain_ver="9.2-2019.12"
	local _toolchain_trg="${_trg_arch}-none-linux-gnu"

	ARM_TOOLCAIN="${TOP}/prebuilts/gcc/linux-x86/aarch64/gcc-arm-${_toolchain_ver}-x86_64-${_toolchain_trg}"
	export AARCH64_GCC_CROSS_COMPILE="${ARM_TOOLCAIN}/bin/${_toolchain_trg}-"
	export CLANG_PATH="${TOP}/prebuilts/clang/host/linux-x86"

	unset _toolchain_ver _toolchain_trg _trg_arch
}

gen_flash_bin() {
	local _prod_out_dir="${TOP}/out/target/product/${TARGET_DEVICE}"

	_uuu_imx="${_prod_out_dir}/u-boot-${TARGET_DEVICE_NAME}-evk-uuu.imx"
	if [[ -f ${_uuu_imx} ]]; then
		for _f in flash.bin u-boot.bin; do
			cp -rfv "${_uuu_imx}" "${_prod_out_dir}/${_f}"
		done
	else
		_error_msg "${_uuu_imx} not found"
		return 1
	fi
	unset _f _uuu_imx _prod_out_dir
}

build_uboot() {
	local _make_cmd="make $@"

	export CROSS_COMPILE=${AARCH64_GCC_CROSS_COMPILE}
	echo "PATH_UBOOT = ${PATH_UBOOT}"
	cd "${PATH_UBOOT}"
	${_make_cmd} $UBOOT_CONFIG || return $?
	${_make_cmd} || return $?

	gen_flash_bin

	unset _make_cmd
}

build_kernel() {
	${TOP}/imx-make.sh kernel "$@"
	return $?
}

cook() {
	local TMP_PWD="$(pwd)"

	toolchain_setup

	case "${PWD}" in
		"${TOP}")
			[[ -z ${TARGET_DEVICE} ]] && { _error_msg "Variable TARGET_DEVICE can not empty"; return 1; }
			cd ${PATH_UBOOT} && throw "$@" || return $?
			cd "${TOP}"
			source build/envsetup.sh
			lunch "$TARGET_DEVICE"-userdebug
			./imx-make.sh "$@" || return $?
			gen_flash_bin
			;;
		"${PATH_KERNEL}"*)
			build_kernel "$@" || { _error_msg "Build Kernel Fail"; return 1; }
			;;
		"${PATH_UBOOT}"*)
			build_uboot "$@" || { _error_msg "Build U-Boot Fail"; return 1; }
			;;
		*)
			echo -e "Error: outside the project" >&2
			return 1
			;;
	esac

	cd "${TMP_PWD}"

	unset _android_ver TMP_PWD
}

throw() {
	local TMP_PWD="${PWD}"

	case "${PWD}" in
		"${TOP}")
			rm -rf out
			cd ${PATH_UBOOT} && throw "$@" || return $?
			;;
		"${PATH_UBOOT}"*)
			cd "${PATH_UBOOT}"
			make "$@" distclean || return $?
			make "$@" mrproper  || return $?
			;;
		*)
			echo -e "Error: outside the project" >&2
			return 1
			;;
	esac

	cd "${TMP_PWD}"
}

merge_restricted_extras() {
	local _android_ver="13.0"
	local _imx_android_ver="android-${_android_ver}.0_1.2.0"
	local _toolchain_ver="9.2-2019.12"
	local _imx_rel_pkg="imx-${_imx_android_ver}"

	wget -c -t 0 --timeout=60 --waitretry=60 https://ftp.technexion.com/development_resources/NXP/android/${_android_ver}/proprietary-package/${_imx_rel_pkg}.tar.gz
	tar -zxf ${_imx_rel_pkg}.tar.gz && sync
	# prebuilt libraries
	cp -r ${_imx_rel_pkg}/EULA.txt ${TOP}
	cat EULA.txt

	while true; do
		read -p $'\e[31mCould you agree this EULA and keep install packages?\e[0m(yes/no) ' yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) rm -rf ${_imx_rel_pkg}.tar.gz ${_imx_rel_pkg}; sync; exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done

	cp -r ${_imx_rel_pkg}/vendor/nxp/* ${TOP}/vendor/nxp/
	cp -r ${_imx_rel_pkg}/SCR* ${TOP}
	sync
	rm -rf ${_imx_rel_pkg}.tar.gz ${_imx_rel_pkg}

	unset _imx_rel_pkg

	local _arm_toolchain="gcc-arm-${_toolchain_ver}-x86_64-aarch64-none-linux-gnu"
	local _dest="${TOP}/prebuilts/gcc/linux-x86/aarch64"
	mkdir -p "${_dest}"
	# download toolchain
	local _arm_toolchain_url="https://developer.arm.com/-/media/Files/downloads/gnu-a/${_toolchain_ver}/binrel"
	wget -c -t 0 --timeout=60 --waitretry=60 -P ${_dest} ${_arm_toolchain_url}/${_arm_toolchain}.tar.xz
	tar -xf ${_dest}/${_arm_toolchain}.tar.xz -C "${_dest}" && sync
	rm -rf ${_dest}/${_arm_toolchain}.tar.xz
	unset _arm_toolchain_url


	unset _imx_android_ver _toolchain_ver _arm_toolchain _dest
}

get_tn_firmware() {
	local _tn_fw_dir="${TOP}/vendor/technexion"

	git clone https://oauth2:SbtQ_mC4fvJRA88_9jB7@gitlab.com/technexion-imx/qca_firmware.git
	cd qca_firmware
	git checkout caf-wlan/CNSS.LEA.NRT_3.0
	cd -

	# WiFi
	local _tn_wifi_dir="${_tn_fw_dir}/wifi/qcom/firmware"
	mkdir -p "${_tn_wifi_dir}"
	cp -rv qca_firmware/qca9377 "${_tn_wifi_dir}/"
	cp -rv qca_firmware/wlan "${_tn_wifi_dir}/qca9377/"
	#cp -rv qca_firmware/wlan/cfg.dat "${_tn_wifi_dir}/qca9377/wlan/"

	# BT
	local _tn_bt_dir="${_tn_fw_dir}/bt/qcom/firmware"
	mkdir -p "${_tn_bt_dir}"
	cp -rv qca_firmware/qca "${_tn_bt_dir}/"
	sync

	rm -rf qca_firmware

	unset _tn_bt_dir _tn_wifi_dir _tn_fw_dir
}

gen_mp_images() {
	PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"
	local _workdir="auto_test/"

	mkdir -p ${_workdir}
	cp -r "${PATH_OUT}"/init_boot*.img ${_workdir}
	cp -r "${PATH_OUT}"/boot*.img ${_workdir}
	cp -r "${PATH_OUT}"/dtbo*.img ${_workdir}
	cp -r "${PATH_OUT}"/partition-table*.img ${_workdir}
	cp -r "${PATH_OUT}"/vbmeta*.img ${_workdir}
	cp -r "${PATH_OUT}"/vendor*.img ${_workdir}
	cp -r "${PATH_OUT}"/system*.img ${_workdir}
	cp -r "${PATH_OUT}"/product.img ${_workdir}
	cp -r "${PATH_OUT}"/super*.img ${_workdir}
	cp -r "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}".imx ${_workdir}
	cp -r "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu.imx ${_workdir}
	cp -r "${PATH_OUT}"/flash.bin ${_workdir}
	cp -r "${PATH_OUT}"/u-boot.bin ${_workdir}

	cp -r ${TOP}/device/nxp/common/tools/uuu_imx_android_flash.sh ${_workdir}
	cp -r ${TOP}/device/nxp/common/tools/uuu_imx_android_flash.bat ${_workdir}
	cp -r ${TOP}/device/nxp/common/tools/imx-sdcard-partition.sh ${_workdir}

	cp -r ${TOP}/vendor/technexion/utils/imx-sdcard-partition-gen_image.sh ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/mfgtools/uuu ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/mfgtools/uuu.exe ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/mfgtools/UUU-3.pdf ${_workdir}
	sync

	chmod a+x ${_workdir}/uuu

	unset _workdir
}

gen_local_images() {
	PATH_OUT="${TOP}/out/target/product/${TARGET_DEVICE}"

	img_size="$@"

	if [[ "$img_size" == "" ]];then
		img_size=13
	fi

	cd "${PATH_OUT}"
	sudo dd if=/dev/zero of=test.img bs="$img_size"M count=1024
	sudo kpartx -av test.img
	loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
	sudo ./imx-sdcard-partition-gen_image.sh -f "$TARGET_DEVICE_NAME" -c "$img_size" "${loop_dev}"
	sudo kpartx -d test.img
	sudo kpartx -d "${loop_dev}"
	sudo losetup -d "${loop_dev}"
	sync
	sudo kpartx -av test.img
	sudo ./imx-sdcard-partition-gen_image.sh -f "$TARGET_DEVICE_NAME" -c "$img_size" "${loop_dev}"
	sudo kpartx -d test.img
	sudo kpartx -d "${loop_dev}"
	sudo losetup -d "${loop_dev}"
	sync
#	cd "${TMP_PWD}"
}
