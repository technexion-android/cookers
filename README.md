# Technexion Android 9 SDK for i.MX8 Platforms
## Download The Source code

Github way (Prepare repo command first is recommended)

    $ repo init -u https://github.com/technexion-android/manifest -b tn-p9.0.0_1.0.0_8m-ga
    $ repo sync -j<N> (N is up to cors numbers on your host PC)

## Compiling Environment Setup

General Packages Installation ( Ubuntu 16.04 or above)

    $ sudo apt-get install uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop \
    git-core curl u-boot-tools mtd-utils android-tools-fsutils device-tree-compiler gdisk \
    gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib \
    libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip sshpass ssh-askpass zip xz-utils kpartx vim screen sudo wget \
    bc locales openjdk-8-jdk rsync docker.io python3 kmod cgpt bsdmainutils lzip

Technexion Docker Image Production

    $ cd cookers
    $ docker build -t build_droid9 .
    $ sudo docker run --privileged=true --name mx8_build  -v /home/<user name>/<source folder>:/home/mnt -t -i build_droid9 bash
    (first time)

    $ sudo docker ps -a
    $ sudo docker start <your container id>
    $ sudo docker exec -it mx8_build bash
    (after first time)


## Starting Compile The Source Code

Source the compile relative commands:

    For PICO-IMX8M HDMI

    $ source cookers/env.bash.imx8.pico-imx8m.pi.hdmi

    For PICO-IMX8M 5-inch LCD (1280x720 resolution via MIPI-DSI interface)

    $ source cookers/env.bash.imx8.pico-imx8m.pi.mipi-dsi_ili9881c

    For PICO-IMX8M HDMI with Audio-HAT

    $ source cookers/env.bash.imx8.pico-imx8m.pi.hdmi-audiohat

    For PICO-IMX8M-Mini HDMI (will be released soon)


Get the NXP restricted extra packages (recommended):

    $ merge_restricted_extras
    (sometimes could be stocking on the waiting github response, please try again)

For a full clean build:

    $ cook -j<N> (N is up to cors numbers on your host PC)

For an incremental build:

    $ heat -j<N> (N is up to cors numbers on your host PC)

For clean the all build files:

    $ throw

To Configuration in Linux Kernel part:

    $ cd vendor/nxp-opensource/kernel_imx/
    $ recipe (or make menuconfig)


## Flashing The Output Images

Output relative image files of path:

    $ ls <source>/out/target/product/pico_8m/

Quick way for flashing to board:

    $ flashcard /dev/sd<x> (x is up to your device node)

About how to mount your board as mass storage, please refer:
* [HERE](https://github.com/TechNexion/u-boot-edm/wiki/Use-mfgtool-to-flash-eMMC)

## Enabling WiFi/BT function

Prepare WiFi/BT firmware

This SDK is supporting Qualcomm(QCA) WLAN module - QCA9377 as default configuration, Because of the license restriction, please contact TechNexion FAE or Sales to get licensed firmware files, default is disabled.

    Contact Window: sales@technexion.com

After getting the firmware binary: .. Decompress the tarball and put all the firmware files into 

    <source folder>/device/fsl/pico_8m/wifi-firmware/

Then take the QCA9377 folder as target path such as:

    <source folder>/device/fsl/pico_8m/wifi-firmware/QCA9377

Issue the command cook/heat again as previous Chapter "Compiling Environment Setup", WiFi/BT function will be working! Enjoy!

## OTA Upgrade

###Generating an incremental upgradabled OTA package:

Backup your OTA package of current system revision, compile manually if the zip file is no exist:

    make otapackage -j4

    path: <source folder>/out/target/product/pico_imx8m/obj/PACKAGING/target_files_intermediates/pico_imx8m-target_files-eng.root.zip

When you're done the modified part for latest system revision, editing "<source>imx8m/pico_imx8m/build_id.mk" and modify the BUILD_ID to latest revision.

Note that the BUILD_ID must be newer than your current system revision.

Correct the IP address, port and path from target OTA server to ota.conf

    path: <source folder>device/fsl/imx8m/etc/ota.conf

Re-compile source code again and generate the new  pico_imx8m-target_files-eng.root.zip

old zip file rename to old.zip, and new zip file rename to new.zip, issue the command to generate the incremental update package:

    cd <source folodr>

    ./build/tools/releasetools/ota_from_target_files -i old.zip new.zip incremental_ota_update.zip

###Setup an OTA server:

You can setup OTA server using any simple REST base http server such as LineageOTA:

    https://github.com/julianxhokaxhiu/LineageOTA

move upgrade relative files to OTA server:

    cp ${old_build.prop} ${server_ota_folder}/old_build.prop

    cp ${MY_ANDROID}/out/target/product/evk_8mm/system/build.prop ${server_ota_folder}/build_diff.prop

    mkdir ${server_ota_folder}/diff_ota

    cp ${MY_ANDROID}/incremental_ota_update.zip ${server_ota_folder}/diff_ota

    cd ${server_ota_folder}/diff_ota

    unzip incremental_ota_update.zip

    mv payload.bin payload_diff.bin

    mv payload_properties.txt payload_properties_diff.txt

    mv payload_diff.bin payload_properties_diff.txt ${server_ota_folder}

    cd ${server_ota_folder}

    echo -n "base." >> build_diff.prop

    grep "ro.build.date.utc" old_build.prop >> build_diff.prop

## Change the Display Rotation Angle When Boot

You can modify the boot argument in device/fsl/imx8m/pico_imx8m/BoardConfig.mk

    modify the argument in BOARD_KERNEL_CMDLINE argument:

    androidboot.hwrotation=0 (No change, Default is landscape mode)

    androidboot.hwrotation=90 (rotate 90 degree)

    androidboot.hwrotation=180 (rotate 180 degree)

    androidboot.hwrotation=270 (rotate 270 degree)

## Enabling Low Memory Size Support

You can modify the global variable in cookers/env.bash

    modify the argument DRAM_SIZE_1G

    - export DRAM_SIZE_1G=false
    to
    + export DRAM_SIZE_1G=true

    Re-source again and start compiling the new images
