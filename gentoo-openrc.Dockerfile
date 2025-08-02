FROM gentoo/stage3:latest AS root

# Copy our files
COPY distro-files/gentoo-openrc/etc/environment /etc/environment
COPY distro-files/gentoo-openrc/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/gentoo-openrc/etc/portage/make.conf /etc/portage/make.conf
COPY distro-files/gentoo-openrc/etc/portage/package.accept_keywords/tkt /etc/portage/package.accept_keywords/tkt
COPY distro-files/gentoo-openrc/etc/portage/package.use/tkt /etc/portage/package.use/tkt

# Binhost gpg key fetch
RUN getuto

# Sync tree and set profile
RUN emerge-webrsync
RUN eselect profile set 1

RUN perl-cleaner --all

# Update portage and emerge packages
RUN emerge --oneshot portage

# Echo the make.conf for debug purposes
RUN cat /etc/portage/make.conf

RUN emerge --verbose --getbinpkg --usepkg --buildpkg --binpkg-respect-use=y --autounmask=y --autounmask-continue \
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

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/gentoo-openrc/etc/passwd /etc/passwd
COPY distro-files/gentoo-openrc/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/gentoo-openrc/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Set environment variables for TKT
ENV HOME=/home/TKT \
    USER=TKT

# Set working directory to user's home
WORKDIR /home/TKT

# Use the TKT user from this point on
USER TKT

# Setup the TKT repo ahead of time to save a little time
RUN /home/TKT/init-tkt.sh && rm /home/TKT/init-tkt.sh

# Set working directory to the TKT repo
WORKDIR /home/TKT/TKT

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
