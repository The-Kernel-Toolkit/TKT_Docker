FROM linuxmintd/mint21-amd64 AS root

# Copy our base files
COPY distro-files/mint/etc/environment /etc/evironment
COPY distro-files/profile /etc/profile
COPY distro-files/shells /etc/shells
COPY distro-files/resolv.conf /etc/resolv.conf

# Copy TKT GHCI configs
COPY distro-files/GHCI.cfg /TKT.cfg.base
COPY distro-files/mint/GHCI.cfg /TKT.cfg.distro
RUN cat /TKT.cfg.distro /TKT.cfg.base >> /GHCI.cfg
RUN rm /TKT.cfg.distro /TKT.cfg.base

# Add Mint repo + keyring
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y wget gnupg lsb-release apt-utils tzdata dialog
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6616109451BBBF2

# Install Mint base bits + build tools
RUN apt-get install -y \
    build-essential bc bison flex libssl-dev libelf-dev dwarves \
    git curl wget clang lld python3 perl \
    bash ccache cmake cpio curl git kmod lz4 lzop make patchutils perl python3 python3-pip rsync sudo tar time wget zstd \
    clang lld llvm clang-format clang-tidy clang-tools \
    liblz4-dev libxxhash-dev software-properties-common tini

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Clean up
RUN apt-get clean

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
