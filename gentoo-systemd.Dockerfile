FROM gentoo/stage3:systemd AS root

# Copy our files
COPY distro-files/gentoo-systemd/etc/environment /etc/evironment
COPY distro-files/profile /etc/profile
COPY distro-files/shells /etc/shells
COPY distro-files/resolv.conf /etc/resolv.conf
COPY distro-files/gentoo-systemd/etc/portage/make.conf /etc/portage/make.conf
COPY distro-files/gentoo-systemd/etc/portage/package.accept_keywords/tkt /etc/portage/package.accept_keywords/tkt
COPY distro-files/gentoo-systemd/etc/portage/package.use/tkt /etc/portage/package.use/tkt

# Binhost gpg key fetch
RUN getuto

# Sync tree and set profile
RUN emerge-webrsync
RUN eselect profile set 2

RUN perl-cleaner --all

# Update portage and emerge packages
RUN emerge --oneshot portage

# Echo the make.conf for debug purposes
RUN cat /etc/portage/make.conf

RUN emerge --quiet --verbose --getbinpkg --usepkg --buildpkg --binpkg-respect-use=y --autounmask=y --autounmask-continue \
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

# Set home variables for root
ENV HOME=/root \
    USER=root
USER root

# Copy distro-specific config files
COPY distro-files/GHCI.cfg /GHCI.cfg.base
COPY distro-files/gentoo-systemd/GHCI.cfg /GHCI.cfg.distro
RUN cat /GHCI.cfg.distro /GHCI.cfg.base >> /GHCI.cfg

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
