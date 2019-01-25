# Technexion Android 8 SDK for i.MX6/i.MX7 Platforms
## Download The Source code

Github way (prepare repo command first is recommended)

    $ repo init -u https://github.com/technexion-android/manifest -b tn-o8.0.0_1.0.0-ga
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

Source the compile relative commands (SoM product line):

    EDM1-IMX6 onto FAIRY: HDMI

    $ source cookers/env.bash.imx6.edm1cf-pmic.fairy.hdmi

    EDM1-IMX6 with PMIC onto FAIRY: 7-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx6.edm1cf-pmic.fairy.lcd

    PICO-IMX6 onto DWARF: HDMI

    $ source cookers/env.bash.imx6.pico.dwarf.hdmi

    PICO-IMX6 onto DWARF: 7-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx6.pico.dwarf.lcd

    PICO-IMX6 onto HOBBIT: 7-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx6.pico.hobbit.lcd

    PICO-IMX6 onto NYMPH: HDMI

    $ source cookers/env.bash.imx6.pico.nymph.hdmi

    PICO-IMX6 onto NYMPH: 7-inch LVDS (1024x600 resolution via LVDS interface)

    $ source cookers/env.bash.imx6.pico.nymph.lvds

    PICO-IMX6 onto NYMPH: VGA

    $ source cookers/env.bash.imx6.pico.nymph.vga

    PICO-IMX6 onto PI: 7-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx6.pico.pi.lcd

    PICO-IMX7 onto DWARF: 5-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx7.pico.dwarf.lcd

    PICO-IMX7 onto HOBBIT: 5-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx7.pico.hobbit.lcd

    PICO-IMX7 onto NYMPH: VGA

    $ source cookers/env.bash.imx7.pico.nymph.vga

    PICO-IMX7 onto PI: 5-inch LCD (800x480 resolution via LCD interface)

    $ source cookers/env.bash.imx7.pico.pi.lcd

Source the compile relative commands (HMI product line):

    i.MX6 TC0700 (7-inch 1024x600 resolution Panel PC)

    $ source cookers/env.bash.imx6.edm1cf-pmic.fairy.tc0700

    i.MX6 TC01000 (10-inch 1280x800 resolution Panel PC)

    $ source cookers/env.bash.imx6.edm1cf-pmic.fairy.tc1000

    i.MX7 TEP1 (5-inch 800x480 Panel PC)

    $ source cookers/env.bash.imx7.tep1.tep1.lcd

Get the NXP restricted extra packages (recommended):

    $ merge_restricted_extras
    (sometimes could be stocking on the waiting github response, please try again)

For a full clean build:

    $ cook -j<N> (N is up to cors numbers on your host PC)

For an incremental build:

    $ heat -j<N> (N is up to cors numbers on your host PC)

For clean the all build files:

    $ throw

To configuration in Linux Kernel part:

    $ cd vendor/nxp-opensource/kernel_imx/
    $ recipe (or make menuconfig)

## Flashing The Output Images

Output relative image files of path:

    $ ls <source>/out/target/product/<your target platform>/

Quick way for flashing to board:

    $ flashcard /dev/sd<x> (x is up to your device node)

About how to mount your board as mass storage, please refer:
* [HERE](https://github.com/TechNexion/u-boot-edm/wiki/Use-mfgtool-to-flash-eMMC)

## Enabling WiFi/BT function

Prepare WiFi/BT firmware

This SDK is supporting Qualcomm(QCA) WLAN module - QCA9377 as default configuration, Because of the license restriction, please contact TechNexion FAE or Sales to get licensed firmware files.

Contact Window: sales@technexion.com

After getting the firmware binary: .. Decompress the tarball and put all the firmware files into░

    <source folder>/device/fsl/<your target platform>/wifi-firmware/

Then take the QCA9377 folder as target path such as:

    <source folder>/device/fsl/<your target platform>/wifi-firmware/QCA9377

Enabling the WiFi function in Build file:

    i.MX6: path: <source folder>/device/fsl/imx6/<your target platform>.mk
    i.MX7: path: <source folder>/device/fsl/imx7/<your target platform>.mk

    - BOARD_HAS_QCA9377_WLAN_FIRMWARE := false
    to
    + BOARD_HAS_QCA9377_WLAN_FIRMWARE := true

Issue the command cook/heat again as previous Chapter "Compiling Environment Setup", WiFi/BT function will be working! Enjoy!
