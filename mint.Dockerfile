FROM linuxmintd/mint21-amd64 AS root

# Copy our base files
COPY distro-files/mint/etc/environment /etc/evironment
COPY distro-files/mint/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf

# Copy TKT GHCI configs
COPY distro-files/GHCI.cfg /root/.config/TKT.cfg.base
COPY distro-files/mint/GHCI.cfg /root/.config/TKT.cfg.distro
RUN cat /root/.config/TKT.cfg.distro /root/.config/TKT.cfg.base >> /root/.config/TKT.cfg

# Add Mint repo + keyring
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y wget gnupg lsb-release apt-utils tzdata dialog
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6616109451BBBF2

# Install Mint base bits + build tools
RUN apt-get install -y \
    build-essential bc bison flex libssl-dev libelf-dev dwarves \
    git curl wget clang lld python3 perl \
    bash ccache cmake cpio curl git kmod lz4 make patchutils perl python3 python3-pip rsync sudo tar time wget zstd \
    clang lld llvm clang-format clang-tidy clang-tools \
    liblz4-dev libxxhash-dev software-properties-common tini

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Clean up
RUN apt-get clean

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
