FROM gentoo/stage3:systemd AS root

# Copy our files
COPY distro-files/gentoo-systemd/etc/environment /etc/environment
COPY distro-files/gentoo-systemd/etc/profile /etc/profile
COPY distro-files/gentoo-systemd/etc/shells /etc/shells
COPY distro-files/gentoo-systemd/etc/portage/make.conf /etc/portage/make.conf
COPY distro-files/gentoo-systemd/etc/portage/package.accept_keywords/tkt /etc/portage/package.accept_keywords/tkt
COPY distro-files/gentoo-systemd/etc/portage/package.use/tkt /etc/portage/package.use/tkt

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/gentoo-systemd/etc/passwd /etc/passwd
COPY distro-files/gentoo-systemd/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/gentoo-systemd/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Binhost gpg key fetch
RUN getuto

# Sync tree and set profile
RUN emerge-webrsync
RUN eselect profile set 2

RUN perl-cleaner --all

# Update portage and emerge packages
RUN emerge --oneshot portage
RUN FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox" emerge --verbose --getbinpkg --usepkg --buildpkg --binpkg-respect-use=y --autounmask=y --autounmask-continue \
      sys-kernel/gentoo-kernel-bin \
      llvm-core/llvm \
      llvm-core/clang \
      llvm-core/lld \
      dev-util/ccache \
      dev-build/cmake \
      dev-vcs/git \
      app-arch/lz4 \
      dev-python/pip \
      net-misc/curl \
      sys-process/time \
      app-admin/sudo \
      dev-util/patchutils \
      sys-process/tini

CMD ["/bin/bash"]
