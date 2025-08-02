FROM ubuntu:oracular AS root

# Copy our files
COPY distro-files/mint/etc/environment /etc/evironment
COPY distro-files/mint/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/mint/GHCI.cfg /GHCI.cfg

# Add Mint repo + keyring
RUN apt-get update
RUN apt-get install -y wget gnupg lsb-release
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6616109451BBBF2

# Copy our "Mint distro files"
COPY distro-files/mint/etc/lsb-release /etc/lsb-release
COPY distro-files/mint/etc/os-release /etc/os-release
COPY distro-files/mint/etc/apt/sources.list.d/tkt.list /etc/apt/sources.list.d/tkt.list

# Install Mint base bits + build tools
RUN apt-get install -y \
    build-essential bc bison flex libssl-dev libelf-dev dwarves \
    git curl wget clang lld python3 perl \
    bash ccache cmake cpio curl git kmod lz4 make patchutils perl python3 python3-pip rsync sudo tar time wget zstd \
    clang lld llvm clang-format clang-tidy clang-tools \
    liblz4-dev libxxhash-dev software-properties-common tini

RUN ln -s /usr/bin/clang /usr/bin/clang-cpp

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
