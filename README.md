# Technexion Android 8 SDK for i.MX6/i.MX7 Platforms
## Download The Source code

Github way (Prepare repo command first is recommended)

    $ repo init https://github.com/technexion-android/manifest -b tn-o8.0.0_1.0.0-ga
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
    $ sudo docker run --privileged=true --name mx8_build  -v /home/<user name>/<source folder>:/home/mnt -t -i build_droid8 bash
    (first time)

    $ sudo docker ps -a
    $ sudo docker start <your container id>
    $ sudo docker exec -it mx8_build bash
    (after first time)


## Starting Compile The Source Code
 
Source the compile relative commands:

    SD boot for EDM1-i.MX6 with PMIC onto FAIRY: HDMI

    $ source cookers/env.bash.imx6.edm1cf-sd-pmic.fairy.hdmi

    SD boot for EDM1-i.MX6 with PMIC onto FAIRY: 7-inch LCD (800x480 resolution via LVDS interface)

    $ source cookers/env.bash.imx6.edm1cf-sd-pmic.fairy.lcd

    SD boot for TC0700 (7-inch Panel PC)

    $ source cookers/env.bash.imx6.edm1cf-sd-pmic.fairy.tc0700

    SD boot for PCIO-i.MX6 onto DWARF: HDMI

    $ source cookers/env.bash.imx6.pico-sd.dwarf.hdmi

    SD boot for PCIO-i.MX6 onto DWARF: 7-inch LCD (800x480 resolution via LVDS interface)

    $ source cookers/env.bash.imx6.pico-sd.dwarf.lcd

    SD boot for PCIO-i.MX6 onto HOBBIT: 7-inch LCD (800x480 resolution via LVDS interface)

    $ source cookers/env.bash.imx6.pico-sd.hobbit.lcd

    SD boot for PCIO-i.MX6 onto NYMPH: HDMI

    $ source cookers/env.bash.imx6.pico-sd.nymph.hdmi

    SD boot for PCIO-i.MX6 onto PI: 7-inch LCD (800x480 resolution via LVDS interface)

    $ source cookers/env.bash.imx6.pico-sd.pi.lcd

    SD boot for PCIO-i.MX7 onto PI: 7-inch LCD (800x480 resolution via LVDS interface)

    $ source cookers/env.bash.imx7.pico-sd.pi.lcd

    TEP1 SERIES (5-inch Panel PC)

    $ source cookers/env.bash.imx7.tep1.tep1.lcd


## Work In Process, Coming Soon
