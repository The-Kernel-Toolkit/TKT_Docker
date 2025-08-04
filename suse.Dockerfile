FROM opensuse/tumbleweed:latest AS root

# Copy our files
COPY distro-files/suse/etc/environment /etc/evironment
COPY distro-files/suse/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/suse/GHCI.cfg /GHCI.cfg

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/suse/etc/passwd /etc/passwd
COPY distro-files/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/suse/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Refresh + dist-upgrade for latest packages
RUN zypper --non-interactive refresh && \
    zypper --non-interactive dup

# Install build + kernel dev toolchain
RUN zypper --non-interactive install --no-recommends \
    bash bc bison ccache clang clang-tools cmake cpio curl dwarves flex gawk gcc-c++ git \
    hostname kernel-source kernel-syms kmod libdw-devel libelf-devel libnuma-devel \
    libopenssl-devel libqt5-qtbase-devel libudev-devel lld llvm lz4 make ncurses-devel \
    openssl-devel patchutils perl perl-ExtUtils-MakeMaker python311 python311-devel \
    python311-pip rpm-build rpmdevtools rsync sudo tar time wget xz zstd awk
RUN zypper --non-interactive addrepo --refresh https://download.opensuse.org/repositories/devel:languages:python/openSUSE_Tumbleweed/devel:languages:python.repo
RUN rpm --import https://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Tumbleweed/repodata/repomd.xml.key
RUN zypper --gpg-auto-import-keys refresh

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Clean up cache to reduce layers
RUN zypper clean -a

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

CMD ["/usr/bin/bash"]
