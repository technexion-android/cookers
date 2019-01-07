# Technexion Android 8 SDK for i.MX8 Platforms
## Download The Source code

Github way (Prepare repo command first is recommended)

    $ repo init https://github.com/technexion-android/manifest -b tn-o8.1.0_1.3.0_8m-ga
    $ repo sync -j<N> (N is up to cors numbers on your host PC)

## Compiling Environment Setup

General Packages Installation ( Ubuntu 16.04 or above)

    $ sudo apt-get install uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop \
    git-core curl u-boot-tools mtd-utils android-tools-fsutils device-tree-compiler gdisk \
    gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib \
    libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip sshpass ssh-askpass zip xz-utils kpartx vim screen sudo wget \
    bc locales openjdk-8-jdk rsync docker.io

Technexion Docker Image Production

    $ cd cookers
    $ docker build -t build_droid8 .
    $ sudo docker run --name mx8_build  -v /home/<user name>/<source folder>:/home/mnt -t -i build_droid8 bash
    (first time)

    $ sudo docker ps -a
    $ sudo docker start <your container id>
    $ sudo docker exec -it mx8_build bash
    (after first time)


## Starting Compile The Source Code
 
Source the compile relative commands:

    For PICO-i.MX8 HDMI

    $ source cookers/env.bash.imx8.pico-8m.pi.hdmi

    For PICO-i.MX8 5-inch LCD (1280x720 resolution via MIPI-DSI interface)

    $ source cookers/env.bash.imx8.pico-8m.pi.lcd


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

## Enabling Wifi/BT function

Prepare WIFI/BT firmware

This SDK is supporting Qualcomm(QCA) WLAN module - QCA9377 as default configuration, Because of the license restriction, please contact TechNexion FAE or Sales to get licensed firmware files.

    Contact Window: sales@technexion.com

After getting the firmware binary: .. Decompress the tarball and put all the firmware files into 

    <source folder>/device/fsl/pico_8m/wifi-firmware/

Then take the QCA9377 folder as target path such as: 

    <source folder>/device/fsl/pico_8m/wifi-firmware/QCA9377

Issue the command cook/heat again as previous Chapter "Compiling Environment Setup", WiFi/BT function will be working! Enjoy!
