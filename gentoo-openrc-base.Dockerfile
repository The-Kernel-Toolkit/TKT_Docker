FROM gentoo/stage3:latest AS root

# Copy our files
COPY distro-files/gentoo-openrc/etc/environment /etc/evironment
COPY distro-files/profile /etc/profile
COPY distro-files/shells /etc/shells
COPY distro-files/resolv.conf /etc/resolv.conf
COPY distro-files/gentoo-openrc/etc/portage/make.conf /etc/portage/make.conf
COPY distro-files/gentoo-openrc/etc/portage/package.accept_keywords/tkt /etc/portage/package.accept_keywords/tkt
COPY distro-files/gentoo-openrc/etc/portage/package.use/tkt /etc/portage/package.use/tkt

# Binhost gpg key fetch
RUN getuto

# Sync tree and set profile
RUN emerge-webrsync && emerge --sync
RUN eselect profile set 1

# Cleanup perl
RUN perl-cleaner --all

# Update portage
RUN emerge --oneshot portage

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
      sys-process/tini \
      app-portage/gentoolkit && \
     etc-update --automode -5 || true

# Update remaining packages
RUN emerge --quiet --verbose --getbinpkg --usepkg --buildpkg --binpkg-respect-use=y --autounmask=y --autounmask-continue -uDN @world && \
    etc-update --automode -5 || true

# Set home variables for root
ENV HOME=/root \
    USER=root
USER root

# Copy TKT GHCI configs
COPY distro-files/GHCI.cfg /GHCI.cfg.base
COPY distro-files/gentoo-openrc/GHCI.cfg /GHCI.cfg.distro
RUN cat /GHCI.cfg.distro /GHCI.cfg.base >> /GHCI.cfg

# Cleanup to shrink image
RUN emerge --depclean && \
    revdep-rebuild

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
