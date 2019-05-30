# Technexion Android 8 SDK for i.MX8 Platforms
## Download The Source code

Github way (Prepare repo command first is recommended)

    $ repo init -u https://github.com/technexion-android/manifest -b tn-o8.1.0_1.3.0_8m-ga
    $ repo sync -j<N> (N is up to cors numbers on your host PC)

## Compiling Environment Setup

General packages installation ( Ubuntu 16.04 or above)

    $ sudo apt-get install uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop \
    git-core curl u-boot-tools mtd-utils android-tools-fsutils device-tree-compiler gdisk \
    gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib \
    libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip sshpass ssh-askpass zip xz-utils kpartx vim screen sudo wget \
    bc locales openjdk-8-jdk rsync docker.io

Technexion Docker image generation

    $ cd cookers
    $ docker build -t build_droid8 .
    $ sudo docker run --privileged=true --name mx8_build  -v /home/<user name>/<source folder>:/home/mnt -t -i build_droid8 bash
    (first time)

    $ sudo docker ps -a
    $ sudo docker start <your container id>
    $ sudo docker exec -it mx8_build bash
    (after first time)


## Starting Compile The Source Code
 
Source the compile relative commands:

    For PICO-IMX8 HDMI

    $ source cookers/env.bash.imx8.pico-8m.pi.hdmi

    For PICO-IMX8 5-inch LCD (1280x720 resolution via MIPI-DSI interface)

    $ source cookers/env.bash.imx8.pico-8m.pi.lcd

    For PICO-IMX8 Dual Display: HDMI and MIPI-to-LVDS 7-inch Panel with 1024x600 resolution (Demo Stage)

    $ source cookers/env.bash.imx8.pico-8m.pi.dual-sn65dsi84

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

## Enabling WiFi/BT Function

Prepare WiFi/BT firmware

This SDK is supporting Qualcomm(QCA) WLAN module - QCA9377 as default configuration, Because of the license restriction, please contact TechNexion FAE or Sales to get licensed firmware files.

    Contact Window: sales@technexion.com

After getting the WiFi firmware binary: .. Decompress the tarball and put all the WiFi firmware files into 

    <source folder>/device/fsl/pico_8m/wifi-firmware/

Then take the QCA9377 folder as target path such as:

    <source folder>/device/fsl/pico_8m/wifi-firmware/QCA9377

After getting the BT firmware binary: .. Decompress the tarball and put all the BT(Bluetooth) firmware files into 

    <source folder>/device/fsl/pico_8m/bluetooth/nvm_tlv_3.2.bin
    <source folder>/device/fsl/pico_8m/bluetooth/rampatch_tlv_3.2.tlv

Issue the command cook/heat again as previous Chapter "Compiling Environment Setup", WiFi/BT function will be working! Enjoy!
