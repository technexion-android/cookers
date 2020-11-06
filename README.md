# Technexion Android 10 BSP for i.MX8 Platforms


## Support Hardware

|System-On-Module|Baseboard|
|---|---|
|EDM-G-IMX8M-PLUS|WANDBOARD|

****
## Contents
* [Download-The-Source-Code](#Download-The-Source-Code)
* [Compiling-Environment-Setup](#Compiling-Environment-Setup)
* [Starting-Compile-The-Source-Code](#Starting-Compile-The-Source-Code)
* [Flashing-The-Output-Images](#Flashing-The-Output-Images)
    * uuu way
    * big image way
* [Enabling-WiFi/BT-function](#Enabling-WiFi_BT-function)
    * WiFi part
    * Bluetooth part
* [Features](#Features)
    * LIBGPIOD JNI APIs

****
## Download-The-Source-Code

Github way (Prepare repo command first is recommended)

Install repo first:

    $ sudo apt-get install repo

Download the source code:

    $ repo init -u https://github.com/technexion-android/manifest -b tn-android-10.0.0-2.5.0_8m-next
    $ repo sync -j<N> (N is up to cors numbers on your host PC)

    Latest update (20201106):
    1. [EDM-G-IMX8MP] First release

****
## Compiling-Environment-Setup

There are two different methods you can use to set up the build environment. One is to install the required packages onto your host filesystem. 
Another is to use a docker container, where the installation of the required packages is automated for you.

General Packages Installation ( Ubuntu 16.04 or above, note that some packages are different name with Ubuntu 20.04 )

    $ sudo apt-get install uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop \
    git-core curl u-boot-tools mtd-utils android-tools-fsutils device-tree-compiler gdisk \
    gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib \
    libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip sshpass ssh-askpass zip xz-utils kpartx vim screen sudo wget \
    bc locales openjdk-8-jdk rsync docker.io python3 kmod cgpt bsdmainutils lzip hdparm libssl-dev cpio

Or adapt Docker Container based compile environment (Optional)

    $ cd cookers
    $ docker build -t build_droid10 .
    $ sudo docker run --privileged=true --name mx8_build  -v /home/<user name>/<source folder>:/home/mnt -t -i build_droid10 bash
    (first time)

    $ sudo docker ps -a
    $ sudo docker start <your container id>
    $ sudo docker exec -it mx8_build bash (after first time)

****
## Starting-Compile-The-Source-Code

Source the compile relative commands:

    For EDM-G-IMX8MP + WANDBOARD (HDMI with 1080p)

    $ source cookers/env.bash.imx8.edm-g-imx8mp.wandboard.hdmi


Get the NXP restricted extra packages (recommended):

    $ merge_restricted_extras
    sometimes could be stocking on the waiting github response, please try again.
    Note that it will showing up a EULA message before merge packages, please type 'yes' to continue the process as follows:

    Could you agree this EULA and keep install packages?yes

For a full build:

    $ cook -j<N> (N is up to cors numbers on your host PC)

For clean the all compiled files:

    $ throw

## Flashing-The-Output-Images

Output relative image files of path:

    $ ls <source>/out/target/product/<target board>/ (edm_g_imx8mp or others)

#### uuu way (recommended)
Step 1. Download uuu tool first:
* [NXP uuu release](https://github.com/NXPmicro/mfgtools/releases)
* Technexion uuu release: ftp://ftp.technexion.net/development_resources/development_tools/installer/imx-mfg-uuu-tool_20200629.zip

About Technexion uuu Detial:
* [HERE](https://github.com/TechNexion/u-boot-edm/wiki/Use-mfgtool-%22uuu%22-to-flash-eMMC)

Step 2. Then install uuu to different environment:

* [Refer Q&A item 3 of Chapter 5 on User Manual](https://github.com/technexion-android/Documents/blob/android-9/pdf/Android-Pie_User-Manual_20191220.pdf)

Step 3. Quick way for flashing to board (adapt uuu based flash script):

    Ubuntu host:
    $ cd <source>/out/target/product/<target board>/
    $ sudo ./uuu_imx_android_flash.sh -f <platform_name> -a -e -c <eMMC_size> -D .
    (platform_name is up to your SoC platform of device, such as imx8mp, imx8mm, imx8mq, imx8mn)
    (eMMC_size is up to your eMMC size, 16GB: eMMC_size=13, 32GB: eMMC_size=28, minimal 9GB size for demo: eMMC_size=9)

    Example:
    $ sudo ./uuu_imx_android_flash.sh -f imx8mp -a -e -c 28 -D .

    Windows example:
    $ uuu_imx_android_flash.bat -f <platform_name> -a -e -c <eMMC_size> -D .

Note: Steps for boot mode change when flash the image:
Firstly, the user must be change the boot mode to serial download mode and connect a OTG cable from board to host PC. Then, running the uuu commands as above post. In the end, 
change back the boot mode to eMMC boot mode, that's it.

#### big image way (easier but spend much time for image flashing)

Step 1. Source the compile relative commands first.
Step 2. issue command to auto generate a local image for flashing

    $ gen_local_images <image_size>
    (eMMC_size is up to your eMMC size, 16GB: image_size=13, 32GB: image_size=28, minimal 9GB size for demo: image_size=9)

Step 3. You'll see a test.img in <source>/out/target/product/<target board>/
Step 4. You can use flash this image to eMMC using uuu tool, ums or other classic ways.
Note: users need change to serial download mode if adapt uuu tool, and ums just keep eMMC boot mode is enough.

## Enabling-WiFi_BT-function

Prepare WiFi/BT firmware

This SDK is supporting Qualcomm(QCA) WLAN module - QCA9377 as default configuration, Because of the license restriction, please contact TechNexion FAE or Sales to get licensed firmware files, default is disabled.

    Contact Window: sales@technexion.com

#### WiFi part

After getting the firmware binary: .. Decompress the tarball and put all the firmware files into a created 'wifi-firmware' folder such as

    <source folder>/device/fsl/imx8m/edm_g_imx8mp/wifi-firmware/

Then take the qca9377 and wlan folder to the specific path such as:

    $ cp -rv qca9377/ <source folder>/device/fsl/edm_g_imx8mp/wifi-firmware/
    $ cp -rv wlan/ <source folder>/device/fsl/edm_g_imx8mp/wifi-firmware/qca9377/

#### Bluetooth part

After getting the firmware binary: .. Decompress the tarball and put all the firmware files to specific path such as:

    $ cp -rv qca/ <source folder>/device/fsl/edm_g_imx8mp/bluetooth/

Issue the command cook again as previous Chapter "Compiling Environment Setup", WiFi/BT function will be packaged in output image!

## Features

#### LIBGPIOD JNI APIs

Technexion provide a demo app about libgpiod JNI Test, specific source code as following:
* [source code](https://github.com/technexion-android/packages_apps_GpiodJniTest.git)

Users can implement own GUI using our INPUT/OUTPUT APIs

    Setting GPIO as output with specific value:
    public native String  setGpioInfo(int gpiobank,int gpioline, int value)

    Setting GPIO as input and get a value:
    public native String  getGpioInfo(int gpiobank,int gpioline);
