FROM ubuntu:20.04
MAINTAINER Ray Chang <ray.chang@technexion.com> Po Cheng <po.cheng@technexion.com> Richard Hu <richard.hu@technexion.com> Wig Cheng(wig.cheng@technexion.com)

ENV DEBIAN_FRONTEND=noninteractive

# Install a basic SSH server
RUN apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    apt -q update && apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

# Install JRE 21 LTS
RUN apt -q update && apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-21-jre-headless

# Installing Yocto required packages
RUN apt -q update && apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
	gawk wget git-core git-lfs diffstat unzip texinfo gcc-multilib g++-multilib build-essential \
	chrpath socat cpio python python3 python3-pip python3-pexpect python-dev \
	xz-utils debianutils iputils-ping libsdl1.2-dev xterm \
	language-pack-en coreutils texi2html file docbook-utils \
	python-pysqlite2 help2man desktop-file-utils \
	libgl1-mesa-dev libglu1-mesa-dev mercurial autoconf automake \
	groff curl lzop asciidoc u-boot-tools libreoffice-writer \
	sshpass ssh-askpass zip xz-utils kpartx qemu bison flex device-tree-compiler bc rsync \
	cmake libusb-1.0.0-dev libzip-dev libbz2-dev pkg-config libssl-dev manpages-posix-dev bash \
	vim screen sudo libncurses5 zstd liblz4-tool

# Installing android relative packages
RUN apt -q update && apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
	uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop git-core curl u-boot-tools mtd-utils android-tools-adb \
	device-tree-compiler gdisk gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib \
	libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip software-properties-common \
	sshpass ssh-askpass zip xz-utils kpartx vim screen sudo wget bc locales openjdk-8-jdk rsync python3 kmod cgpt bsdmainutils lzip hdparm libssl-dev cpio libncurses5

RUN apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Change default shell to bash. Make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo && \
    chmod a+x /usr/bin/repo

# Set user $USR to the image
ENV USR jenkins
ENV USR_HOME /home/jenkins
RUN useradd -m -d $USR_HOME -s /bin/sh $USR &&\
    echo "$USR:$USR" | chpasswd

RUN echo "root:root" | chpasswd
RUN usermod -a -Gsudo $USR

# Setup repo
RUN mkdir $USR_HOME/bin &&\
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $USR_HOME/bin/repo &&\
    chmod a+x $USR_HOME/bin/repo &&\
    chown -R "$USR:$USR" $USR_HOME/bin

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

RUN chown $USR:$USR $USR_HOME/.ssh
RUN chown $USR:$USR $USR_HOME/.ssh/id_rsa
RUN chown $USR:$USR $USR_HOME/.ssh/known_hosts

# Fix build error "/bin/sh: Argument list too long"
RUN echo "ulimit -s 20480" >> $USR_HOME/.bashrc

RUN ln -sf python3.8 /usr/bin/python

# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]
