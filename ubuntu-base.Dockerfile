# Pull latest Ubuntu container
FROM ubuntu:latest AS root

# Copy over our files
COPY distro-files/ubuntu/etc/environment /etc/evironment
COPY distro-files/profile /etc/profile
COPY distro-files/shells /etc/shells
COPY distro-files/resolv.conf /etc/resolv.conf
COPY distro-files/ubuntu/etc/apt/sources.list.d/plucky.list /etc/apt/sources.list.d/plucky.list

# Copy TKT GHCI configs
COPY distro-files/GHCI.cfg /TKT.cfg.base
COPY distro-files/ubuntu/GHCI.cfg /TKT.cfg.distro
RUN cat /TKT.cfg.distro /TKT.cfg.base >> /GHCI.cfg
RUN rm /TKT.cfg.distro /TKT.cfg.base

# Update the repo database and upgrade packages
RUN apt-get update && yes '' | apt-get -y dist-upgrade

# Install depends
RUN apt-get install -y --no-install-recommends --no-install-suggests \
      adduser appstream apt bash bc binutils bison build-essential bzip2 ccache \
      clang clang-format clang-tidy clang-tools cmake cpp cpio curl dbus \
      dbus-bin dbus-daemon dbus-session-bus-common dbus-system-bus-common \
      dbus-user-session dirmngr distro-info-data dmsetup dpkg-dev debhelper dwarves \
      fakeroot flex g++ gcc gir1.2-girepository-2.0 gir1.2-glib-2.0 \
      gir1.2-packagekitglib-1.0 git gnupg gnupg-l10n gnupg-utils gpg gpg-agent \
      gpg-wks-client gpgconf gpgsm iso-codes keyboxd kmod libalgorithm-diff-perl \
      libalgorithm-diff-xs-perl libalgorithm-merge-perl libappstream5 \
      libapt-pkg7.0 libassuan9 libcap2-bin libcryptsetup12 libdbus-1-3 \
      libdevmapper1.02.1 libdpkg-perl libduktape207 libfakeroot libelf-dev \
      libfile-fcntllock-perl libgirepository-1.0-1 libglib2.0-0t64 \
      libglib2.0-bin libglib2.0-data libgstreamer1.0-0 libjson-c5 libksba8 \
      liblocale-gettext-perl liblz4-dev libnss-systemd libpackagekit-glib2-18 \
      libpam-cap libpam-systemd libpolkit-agent-1-0 libpolkit-gobject-1-0 libssl-dev \
      libstdc++-15-dev libstemmer0d libsystemd-shared libtext-charwidth-perl \
      libtext-wrapi18n-perl libxmlb2 libxxhash-dev linux-sysctl-defaults lld \
      lto-disabled-list llvm lsb-release make networkd-dispatcher packagekit \
      packagekit-tools patch patchutils perl pinentry-curses polkitd \
      python-apt-common python3 python3-apt python3-autocommand python3-bcrypt \
      python3-blinker python3-cffi-backend python3-cryptography python3-dbus \
      python3-distro python3-distro-info python3-gi python3-httplib2 \
      python3-inflect python3-jaraco.context python3-jaraco.functools \
      python3-jwt python3-launchpadlib python3-lazr.restfulclient \
      python3-lazr.uri python3-more-itertools python3-oauthlib python3-pip \
      python3-pkg-resources python3-pyparsing python3-software-properties \
      python3-typeguard python3-typing-extensions python3-wadllib rsync \
      sgml-base shared-mime-info software-properties-common sudo systemd \
      systemd-cryptsetup systemd-resolved systemd-sysv systemd-timesyncd tar \
      time tini ucf unattended-upgrades wget xdg-user-dirs xml-core zstd \
      autoconf autopoint automake bsdextrautils dh-autoreconf dh-strip-nondeterminism \
      file gettext gettext-base groff-base intltool-debian libarchive-zip-perl \
      libarchive-cpio-perl libdebhelper-perl libdw-dev libdw1t64 libfile-stripnondeterminism-perl \
      liblzma-dev libltdl-dev libltdl7 libmagic-mgc libmagic1t64 libmail-sendmail-perl \
      libpipeline1 libsys-hostname-long-perl libtool libuchardet0 libzstd-dev zlib1g-dev \
      po-debconf lzop

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Finish image
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/bash"]
