FROM ubuntu:oracular AS root

# Copy our files
COPY distro-files/popos/etc/environment /etc/evironment
COPY distro-files/popos/etc/profile /etc/profile
COPY distro-files/popos/etc/shells /etc/shells
COPY distro-files/popos/etc/os-release /etc/os-release
COPY distro-files/popos/GHCI.cfg /GHCI.cfg

# Add System76 repo + key
RUN apt-get update && \
    apt-get install -y wget gnupg curl

# Install Pop!_OS keys + base packages + dev tools
COPY distro-files/popos/etc/apt/sources.list.d/tkt.list /etc/apt/sources.list.d/tkt.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 63C46DF0140D738961429F4E204DD8AEC33A7AFF
RUN apt-get update && apt-get install -y \
    build-essential bc bison flex libssl-dev libelf-dev dwarves \
    clang lld llvm git curl wget python3 perl tini

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/clang /usr/bin/clang-cpp

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
