FROM debian:sid AS root

# Create TKT user
RUN useradd -m -U -s /bin/bash TKT
RUN mkdir -p /home/TKT/.config
RUN chown -R TKT:TKT /home/TKT

# Copy our files
COPY distro-files/debian/etc/environment /etc/evironment
COPY distro-files/debian/etc/profile /etc/profile
COPY distro-files/debian/etc/shells /etc/shells
COPY distro-files/debian/etc/apt/sources.list.d/tkt.list /etc/apt/sources.list.d/tkt.list
COPY distro-files/arch/etc/passwd /etc/passwd
COPY distro-files/arch/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/debian/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/arch/usr/bin/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Base system & dev tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    adwaita-icon-theme libdrm-common libjsoncpp26 libsharpyuv0 libxcomposite1 \
    at-spi2-common libdrm-intel1 liblcms2-2 libsm6 libxcursor1 \
    at-spi2-core libdrm2 liblerc4 libsystemd-shared libxdamage1 \
    cmake-data libegl-dev libmd4c0 libthai-data libxdmcp-dev \
    dbus libegl-mesa0 libmtdev1t64 libthai0 libxdmcp6 \
    dbus-bin libegl1 libnss-systemd libtiff6 libxext-dev \
    dbus-daemon libepoxy0 libopengl-dev libuv1t64 libxext6 \
    dbus-session-bus-common libevdev2 libopengl0 libvulkan-dev libxfixes3 \
    dbus-system-bus-common libfmt10 libpam-systemd libvulkan1 libxi6 \
    dbus-user-session libfontconfig1 libpango-1.0-0 libwacom-common libxinerama1 \
    dconf-gsettings-backend libfreetype6 libpangocairo-1.0-0 libwacom9 libxkbcommon-x11-0 \
    dconf-service libfribidi0 libpangoft2-1.0-0 libwayland-client0 libxkbcommon0 \
    dmsetup libgbm1 libpciaccess0 libwayland-cursor0 libxrandr2 \
    fontconfig libgdk-pixbuf-2.0-0 libpcre2-16-0 libwayland-egl1 libxrender1 \
    fontconfig-config libgdk-pixbuf2.0-bin libpixman-1-0 libwayland-server0 libxshmfence1 \
    fonts-dejavu-core libgdk-pixbuf2.0-common libpng16-16t64 libwebp7 libxtst6 \
    fonts-dejavu-mono libgl-dev libproc2-0 libx11-6 libxxf86vm1 \
    gsettings-desktop-schemas libgl1 libqt5concurrent5t64 libx11-data linux-sysctl-defaults \
    gtk-update-icon-cache libgl1-mesa-dri libqt5core5t64 libx11-dev mesa-libgallium \
    hicolor-icon-theme libglib2.0-0t64 libqt5dbus5t64 libx11-xcb1 mesa-vulkan-drivers \
    libarchive13t64 libglib2.0-data libqt5gui5t64 libxau-dev procps \
    libatk-bridge2.0-0t64 libglu1-mesa libqt5network5t64 libxau6 psmisc \
    libatk1.0-0t64 libglu1-mesa-dev libqt5opengl5-dev libxcb-dri3-0 qt5-gtk-platformtheme \
    libatspi2.0-0t64 libglvnd0 libqt5opengl5t64 libxcb-glx0 qt5-qmake \
    libavahi-client3 libglx-dev libqt5printsupport5t64 libxcb-icccm4 qt5-qmake-bin \
    libavahi-common-data libglx-mesa0 libqt5qml5 libxcb-image0 qtbase5-dev-tools \
    libavahi-common3 libglx0 libqt5qmlmodels5 libxcb-keysyms1 qtchooser \
    libcairo-gobject2 libgraphite2-3 libqt5quick5 libxcb-present0 qttranslations5-l10n \
    libcairo2 libgtk-3-0t64 libqt5sql5-sqlite libxcb-randr0 qtwayland5 \
    libcloudproviders0 libgtk-3-bin libqt5sql5t64 libxcb-render-util0 shared-mime-info \
    libcolord2 libgtk-3-common libqt5svg5 libxcb-render0 systemd \
    libcryptsetup12 libgudev-1.0-0 libqt5test5t64 libxcb-shape0 systemd-cryptsetup \
    libcups2t64 libharfbuzz0b libqt5waylandclient5 libxcb-shm0 systemd-sysv \
    libdatrie1 libhiredis1.1.0 libqt5waylandcompositor5 libxcb-sync1 systemd-timesyncd \
    libdav1d7 libice6 libqt5widgets5t64 libxcb-util1 x11-common \
    libdbus-1-3 libicu76 libqt5xml5t64 libxcb-xfixes0 x11proto-dev \
    libdconf1 libinput-bin librhash1 libxcb-xinerama0 xdg-user-dirs \
    libdeflate0 libinput10 librsvg2-2 libxcb-xinput0 xkb-data \
    libdevmapper1.02.1 libjbig0 librsvg2-common libxcb-xkb1 xorg-sgml-doctools \
    libdouble-conversion3 libjpeg62-turbo libsensors-config libxcb1 xtrans-dev \
    libdrm-amdgpu1 libjson-c5 libsensors5 libxcb1-dev ccache cmake ninja-build nano \
    bash bc bison binutils binutils-dev binutils-gold build-essential clang clang-format clang-tidy clang-tools \
    cpio curl debhelper device-tree-compiler dpkg-dev dwarves fakeroot flex g++ g++-multilib gcc gcc-multilib git \
    gnupg kmod libc6-dev libc6-dev-i386 libdw-dev libelf-dev libncurses-dev libnuma-dev libperl-dev libssl-dev \
    libstdc++-14-dev libudev-dev lld llvm lz4 make patchutils perl python3 python3-pip python3-setuptools rsync \
    schedtool sudo tar time tini wget xz-utils zstd


# Symlink clang-cpp if needed (older LLVM versions sometimes miss this)
RUN ln -s /usr/bin/clang /usr/bin/clang-cpp || true

# Clean APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables for TKT
ENV HOME=/home/TKT \
    USER=TKT

# Set working directory to user's home
WORKDIR /home/TKT

# Use the TKT user from this point on
USER TKT

# Setup the TKT repo ahead of time to save a little time
RUN /home/TKT/init-tkt.sh

# Set working directory to the TKT repo
WORKDIR /home/TKT/TKT

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
