FROM fedora:latest AS root

# Copy our files
COPY distro-files/fedora/etc/environment /etc/evironment
COPY distro-files/fedora/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf

# Copy TKT GHCI configs
RUN mkdir -p /github/home/.config
ENV HOME=/github/home
COPY distro-files/GHCI.cfg /TKT.cfg.base
COPY distro-files/fedora/GHCI.cfg /TKT.cfg.distro
RUN cat /TKT.cfg.distro /TKT.cfg.base >> /GHCI.cfg
RUN rm /TKT.cfg.distro /TKT.cfg.base

# Update dnf and get tools
RUN dnf upgrade --assumeyes
RUN dnf install -y --skip-unavailable \
      bash bc bison ccache cmake cpio curl flex git kmod lz4 lzop make patchutils perl python3 python3-pip rsync \
      sudo tar time wget zstd clang clang-tools-extra lld llvm dwarves gcc-gcc gcc-c++ gawk hostname ncurses-devel libdw-devel libelf-devel \
      libnuma-devel libopenssl-devel libudev-devel openssl openssl-devel python3-devel rpm-build rpmdevtools xz zstd \
      elfutils-devel fedora-packager fedpkg pesign numactl-devel openssl-devel-engine perl-devel perl-generators \
      qt5-qtbase-devel

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Clean up
RUN dnf clean all

CMD ["/bin/bash"]
