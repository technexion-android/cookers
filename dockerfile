FROM ubuntu:16.04
MAINTAINER Ray Chang <ray.chang@technexion.com> Po Cheng <po.cheng@technexion.com> Richard Hu <richard.hu@technexion.com> Wig Cheng(wig.cheng@technexion.com)

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

# Installing android relative packages
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
	uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop git-core curl u-boot-tools mtd-utils android-tools-fsutils \
	device-tree-compiler gdisk gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib \
	libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip software-properties-common \
	sshpass ssh-askpass zip xz-utils kpartx vim screen sudo wget bc locales openjdk-8-jdk rsync python3 kmod cgpt bsdmainutils lzip hdparm &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends default-jre-headless &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Set user jenkins to the image
RUN useradd -m -d /home/jenkins -s /bin/sh jenkins &&\
    echo "jenkins:jenkins" | chpasswd

RUN echo "root:root" | chpasswd
RUN usermod -a -Gsudo jenkins

# Setup repo
RUN mkdir /home/jenkins/bin &&\
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /home/jenkins/bin/repo &&\
    chmod a+x /home/jenkins/bin/repo

ENV LANG en_US.UTF-8
RUN locale-gen $LANG && update-locale

ENV HOME /home/jenkins
ENV PATH /home/jenkins/bin:$PATH
RUN env > /etc/environment

RUN echo | add-apt-repository ppa:deadsnakes/ppa
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends python3.9 &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN sed -i '1 s/\#\!\/usr\/bin\/env\ .*/\#\!\/usr\/bin\/env\ python3.9/' ~/bin/repo

# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]

