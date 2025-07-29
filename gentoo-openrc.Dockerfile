FROM gentoo/stage3:latest

# Modern Gentoo wants /etc/portage/package.use as a dir, not a file
RUN mkdir -p /etc/portage/package.use /etc/portage/package.accept_keywords

# Set USE flags
RUN echo 'sys-kernel/installkernel dracut' >> /etc/portage/package.use/installkernel
RUN echo 'dev-libs/openssl ~amd64' >> /etc/portage/package.accept_keywords/tkt
RUN echo "media-libs/libglvnd X" > /etc/portage/package.use/libglvnd
RUN echo "x11-libs/libxkbcommon X" >> /etc/portage/package.use/libxkbcommon

RUN echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf
RUN echo 'USE="-cxx minimal"' >> /etc/portage/make.conf

# Enable binpkg fetch, ccache
ENV FEATURES="ccache getbinpkg"

# Binhost
ENV PORTAGE_BINHOST="https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64"
RUN getuto

# Sync tree and set profile
RUN emerge-webrsync
RUN eselect profile set 1

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
      dev-util/patchutils

CMD ["/bin/bash"]
