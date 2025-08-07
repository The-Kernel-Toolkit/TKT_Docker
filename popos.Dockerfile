FROM ubuntu:oracular AS root

# Copy our files
COPY distro-files/popos/etc/environment /etc/evironment
COPY distro-files/popos/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/popos/etc/os-release /etc/os-release

# Create TKT user
RUN mkdir -p /github/home/.config
ENV HOME=/github/home
COPY distro-files/GHCI.cfg /github/home/.config/TKT.cfg.base
COPY distro-files/popos/GHCI.cfg /github/home/.config/TKT.cfg.distro
RUN cat /github/home/.config/TKT.cfg.distro /github/home/.config/TKT.cfg.base >> /github/home/.config/TKT.cfg

# Add System76 repo + key
RUN apt-get update && \
    apt-get install -y wget gnupg curl

# Install Pop!_OS keys + base packages + dev tools
COPY distro-files/popos/etc/apt/sources.list.d/tkt.list /etc/apt/sources.list.d/tkt.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 63C46DF0140D738961429F4E204DD8AEC33A7AFF
RUN apt-get update && apt-get install -y \
    build-essential bc bison flex libssl-dev libelf-dev dwarves \
    clang lld llvm git curl wget python3 perl tini

# Time to fix the fuck up called PopOS
RUN ln -s /usr/bin/clang /usr/bin/clang-cpp

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
