FROM ubuntu:20.04
MAINTAINER Ray Chang <ray.chang@technexion.com> Richard Hu <richard.hu@technexion.com> Sean Xie <sean.xie@technexion.com>

ENV USR jenkins
ENV USR_HOME /home/jenkins
# Install a basic SSH server
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

# Install JRE 8
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends default-jre-headless &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Installing Yocto required packages
RUN apt-get -q update &&\
 DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
 gawk wget git-core git-lfs diffstat unzip texinfo gcc-multilib g++-multilib build-essential \
 chrpath socat cpio python python3 python3-pip python3-pexpect python-dev \
 xz-utils debianutils iputils-ping libsdl1.2-dev xterm \
 language-pack-en coreutils texi2html file docbook-utils \
 python-pysqlite2 help2man desktop-file-utils \
 libgl1-mesa-dev libglu1-mesa-dev mercurial autoconf automake \
 groff curl lzop asciidoc u-boot-tools libreoffice-writer \
 sshpass ssh-askpass zip xz-utils kpartx qemu bison flex device-tree-compiler bc rsync \
 cmake libusb-1.0.0-dev libzip-dev libbz2-dev pkg-config libssl-dev manpages-posix-dev \
 vim screen sudo libncurses5 &&\
 apt-get -q autoremove &&\
 apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Installing android relative packages
RUN apt-get -q update &&\
 DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
 tzdata git-core gnupg flex bison apt-utils build-essential zip curl zlib1g-dev liblz-dev gcc-multilib g++-multilib libc6-dev-i386\
 libncurses5 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip\
 fontconfig uuid uuid-dev liblzo2-2 liblzo2-dev lzop u-boot-tools mtd-utils android-sdk-libsparse-utils android-sdk-ext4-utils\
 device-tree-compiler gdisk m4 make libssl-dev libghc-gnutls-dev swig libdw-dev dwarves python bc cpio tar lz4 rsync ninja-build clang\
 android-tools-adb gperf software-properties-common sshpass ssh-askpass xz-utils kpartx vim screen sudo wget locales openjdk-8-jdk python3\
 kmod cgpt bsdmainutils lzip hdparm\
 && ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata\
 && apt-get -q autoremove
 && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo && \
 chmod a+x /usr/bin/repo


# Set user $USR to the image
RUN useradd -m -d $USR_HOME -s /bin/sh $USR &&\
    echo "$USR:$USR" | chpasswd

RUN echo "root:root" | chpasswd
RUN usermod -a -Gsudo $USR

# Setup repo
RUN mkdir $USR_HOME/bin &&\
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $USR_HOME/bin/repo &&\
    chmod a+x $USR_HOME/bin/repo

ENV LANG en_US.UTF-8
RUN locale-gen $LANG && update-locale

ENV HOME $USR_HOME
ENV PATH $USR_HOME/bin:$PATH
RUN env > /etc/environment

# Import ssh key
ARG SSH_KEY
ENV SSH_KEY=$SSH_KEY

RUN mkdir $USR_HOME/.ssh/
RUN echo "$SSH_KEY" > $USR_HOME/.ssh/id_rsa
RUN chmod 600 $USR_HOME/.ssh/id_rsa

RUN touch $USR_HOME/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> $USR_HOME/.ssh/known_hosts
RUN ssh-keyscan github.com >> $USR_HOME/.ssh/known_hosts
RUN ssh-keyscan gitlab.com >> $USR_HOME/.ssh/known_hosts
RUN ssh-keyscan 10.20.30.20 >> $USR_HOME/.ssh/known_hosts
RUN ssh-keyscan 10.88.88.8 >> $USR_HOME/.ssh/known_hosts

RUN chown $USR:$USR $USR_HOME/.ssh/id_rsa
RUN chown $USR:$USR $USR_HOME/.ssh/known_hosts
# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]
