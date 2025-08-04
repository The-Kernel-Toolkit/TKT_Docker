FROM fedora:latest AS root

# Copy our files
COPY distro-files/fedora/etc/environment /etc/evironment
COPY distro-files/fedora/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/fedora/GHCI.cfg /GHCI.cfg

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/fedora/etc/passwd /etc/passwd
COPY distro-files/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/fedora/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Update dnf and get tools
RUN dnf upgrade --assumeyes
RUN dnf install -y --skip-unavailable \
      bash bc bison ccache cmake cpio curl flex git kmod lz4 make patchutils perl python3 python3-pip rsync \
      sudo tar time wget zstd clang clang-tools-extra lld llvm dwarves gcc-gcc gcc-c++ gawk hostname ncurses-devel libdw-devel libelf-devel \
      libnuma-devel libopenssl-devel libudev-devel openssl openssl-devel python3-devel rpm-build rpmdevtools xz zstd \
      elfutils-devel fedora-packager fedpkg pesign numactl-devel openssl-devel-engine perl-devel perl-generators \
      qt5-qtbase-devel

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Clean up
RUN dnf clean all

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

CMD ["/bin/bash"]
