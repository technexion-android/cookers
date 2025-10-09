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
	QSPI_SUPPORT="no"
	case ${CPU_MODULE} in
		'pico-imx8mq')
			TARGET_DEVICE_NAME=imx8mq
			TARGET_DEVICE="pico_${TARGET_DEVICE_NAME}"
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-pico-${BASEBOARD}_android"
			;;
		'pico-imx8mm')
			TARGET_DEVICE_NAME=imx8mm
			TARGET_DEVICE="pico_${TARGET_DEVICE_NAME}"
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-pico-${BASEBOARD}_android"
			;;
		'tek-imx8mp')
			TARGET_DEVICE_NAME=imx8mp
			TARGET_DEVICE="tek_${TARGET_DEVICE_NAME}"
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-tek_android"
			QSPI_SUPPORT="yes"
			;;
		'tep-imx8mp')
			TARGET_DEVICE_NAME=imx8mp
			TARGET_DEVICE="tep_${TARGET_DEVICE_NAME}"
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-tep_android"
			QSPI_SUPPORT="yes"
			;;
		'axon-imx8mp')
			TARGET_DEVICE_NAME=imx8mp
			TARGET_DEVICE="axon_${TARGET_DEVICE_NAME}"
			KERNEL_IMAGE="Image"
			KERNEL_CONFIG="tn_${CPU_TYPE}_android_defconfig"
			UBOOT_CONFIG="${CPU_MODULE}_android_defconfig"
			UBOOT_TARGET="${TARGET_DEVICE_NAME}-axon_android"
			;;
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
	local _toolchain_ver="12.3.rel1"
	local _toolchain_trg="${_trg_arch}-none-linux-gnu"
	local _kernel_ver="6.12"

	export ARM_TOOLCAIN="${TOP}/prebuilts/gcc/linux-x86/aarch64/arm-gnu-toolchain-${_toolchain_ver}-x86_64-${_toolchain_trg}"
	export AARCH64_GCC_CROSS_COMPILE="${ARM_TOOLCAIN}/bin/${_toolchain_trg}-"
	export KERNEL_PREBUILTS_PATH="/opt/android-kernel-prebuilts-${_kernel_ver}"

	local _toolchain32_trg="arm-none-eabi"
	export ARM32_TOOLCHAIN="${TOP}/prebuilts/gcc/linux-x86/aarch32/arm-gnu-toolchain-${_toolchain_ver}-x86_64-${_toolchain32_trg}"
	export AARCH32_GCC_CROSS_COMPILE="${ARM32_TOOLCHAIN}/bin/${_toolchain32_trg}-"

	unset _toolchain_ver _toolchain_trg _trg_arch _kernel_ver _toolchain32_trg
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
			export TARGET_RELEASE=nxp_stable
			build_build_var_cache
			lunch "$TARGET_DEVICE"-nxp_stable-userdebug
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
	local _android_ver="15.0"
	local _imx_android_ver="android-${_android_ver}.0_2.0.0"
	local _toolchain_ver="12.3.rel1"
	local _imx_rel_pkg="imx-${_imx_android_ver}"

	wget -c -t 0 --timeout=60 --waitretry=60 https://download.technexion.com/development_resources/NXP/android/${_android_ver}/proprietary-package/${_imx_rel_pkg}.tar.gz
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

	# arm64
	local _arm_toolchain="arm-gnu-toolchain-${_toolchain_ver}-x86_64-aarch64-none-linux-gnu"
	local _dest="${TOP}/prebuilts/gcc/linux-x86/aarch64"
	mkdir -p "${_dest}"
	# download toolchain
	local _arm_toolchain_url="https://developer.arm.com/-/media/Files/downloads/gnu/${_toolchain_ver}/binrel"
	wget -c -t 0 --timeout=60 --waitretry=60 -P ${_dest} ${_arm_toolchain_url}/${_arm_toolchain}.tar.xz
	tar -xf ${_dest}/${_arm_toolchain}.tar.xz -C "${_dest}" && sync
	rm -rf ${_dest}/${_arm_toolchain}.tar.xz

	# arm32
	local _arm_toolchain="arm-gnu-toolchain-${_toolchain_ver}-x86_64-arm-none-eabi"
	local _dest="${TOP}/prebuilts/gcc/linux-x86/aarch32"
	mkdir -p "${_dest}"
	wget -c -t 0 --timeout=60 --waitretry=60 -P ${_dest} ${_arm_toolchain_url}/${_arm_toolchain}.tar.xz
	tar -xf ${_dest}/${_arm_toolchain}.tar.xz -C "${_dest}" && sync
	rm -rf ${_dest}/${_arm_toolchain}.tar.xz
	unset _arm_toolchain_url

	# kernel 6.12 build tools
	local _kernel_ver="6.12"
	local _kernel_tool="android-kernel-prebuilts-${_kernel_ver}.tar.gz"
	wget -c -t 0 --timeout=60 --waitretry=60 https://download.technexion.com/development_resources/NXP/android/${_android_ver}/${_kernel_tool}
	sudo tar -zxf ${_kernel_tool} -C "/opt/" && sync
	rm -rf ${_kernel_tool}
	unset _kernel_ver _kernel_tool

	unset _imx_android_ver _toolchain_ver _arm_toolchain _dest

	# WA: IW612 fw
	local _iw612_fw="sduart_nw61x_v1.bin.se"
	wget -c -t 0 --timeout=60 --waitretry=60 https://download.technexion.com/development_resources/NXP/android/${_android_ver}/imx-firmware/${_iw612_fw}
	mv ${_iw612_fw} ${TOP}/vendor/nxp/imx-firmware/nxp/FwImage_IW612_SD/${_iw612_fw}
	unset _iw612_fw
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
	cp -r qca_firmware/qca9377 "${_tn_wifi_dir}/"
	cp -r qca_firmware/wlan "${_tn_wifi_dir}/"
	#cp -r qca_firmware/wlan/cfg.dat "${_tn_wifi_dir}/qca9377/wlan/"

	# BT
	local _tn_bt_dir="${_tn_fw_dir}/bt/qcom/firmware"
	mkdir -p "${_tn_bt_dir}"
	cp -r qca_firmware/qca "${_tn_bt_dir}/"
	sync

	rm -rf qca_firmware

	# Wifi - QCA9377-5 ath10k
	git clone https://git.codelinaro.org/clo/ath-firmware/ath10k-firmware.git
	local _tn_wifi_dir="${_tn_fw_dir}/wifi/qcom/firmware/ath10k/QCA9377/hw1.0"
	mkdir -p "${_tn_wifi_dir}"
	cp ath10k-firmware/QCA9377/hw1.0/board.bin "${_tn_wifi_dir}/"
	cp ath10k-firmware/QCA9377/hw1.0/board-2.bin "${_tn_wifi_dir}/"
	cp ath10k-firmware/QCA9377/hw1.0/CNSS.TF.1.0/firmware-5.bin_CNSS.TF.1.0-00267-QCATFSWPZ-1 "${_tn_wifi_dir}/firmware-5.bin"
	cp ath10k-firmware/LICENSE.qca_firmware "${_tn_wifi_dir}/"

	rm -rf ath10k-firmware

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
	cp ${_workdir}/partition-table.img ${_workdir}/partition-table-28GB.img
	cp ${_workdir}/partition-table-dual.img ${_workdir}/partition-table-28GB-dual.img
	cp -r "${PATH_OUT}"/vbmeta*.img ${_workdir}
	cp -r "${PATH_OUT}"/vendor*.img ${_workdir}
	cp -r "${PATH_OUT}"/system*.img ${_workdir}
	cp -r "${PATH_OUT}"/product.img ${_workdir}
	cp -r "${PATH_OUT}"/super*.img ${_workdir}
	cp -r "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}".imx ${_workdir}
	cp -r "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu.imx ${_workdir}
	if [[ "$QSPI_SUPPORT" == "yes" ]]; then
		cp -r "${PATH_OUT}"/u-boot-"${TARGET_DEVICE_NAME}"-evk-uuu-fspi.imx ${_workdir}
	fi

	cp -r ${TOP}/device/nxp/common/tools/uuu_imx_android_flash.sh ${_workdir}
	cp -r ${TOP}/device/nxp/common/tools/uuu_imx_android_flash.bat ${_workdir}
	cp -r ${TOP}/device/nxp/common/tools/imx-sdcard-partition.sh ${_workdir}

	cp -r ${TOP}/vendor/technexion/utils/gen_sd_image.sh ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/tn-imx-sdcard-partition.sh ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/mfgtools/uuu ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/mfgtools/uuu.exe ${_workdir}
	cp -r ${TOP}/vendor/technexion/utils/mfgtools/UUU-3.pdf ${_workdir}
	sync

	chmod a+x ${_workdir}/uuu

	unset _workdir
}

gen_sd_image() {
	local _workdir=${1:-"auto_test"}
	local _soc=${2:-${TARGET_DEVICE_NAME}}
	local _sd_size=${3:-"16"}

	[[ -d ${_workdir} ]] || { _error_msg "Directory ${_workdir} not found, maybe do gen_mp_images first."; return 1; }
	[[ -z ${_soc} ]] && { _error_msg "SOC name is required."; return 1; }
	[[ ${_sd_size} -eq 16 || ${_sd_size} -eq 32 ]] || { _error_msg "SD card size is 16 or 32."; return 1; }
	[[ -f "${_workdir}/dtbo-${_soc}.img" ]] || { _error_msg "Invalid SOC ${_soc}."; return 1; }

	cd ${_workdir}
	./gen_sd_image.sh ${_soc} ${_sd_size}
	cd - > /dev/null

	unset _workdir _soc _sd_size
}
