FROM ubuntu:oracular AS root

# Copy our files
COPY distro-files/popos/etc/environment /etc/evironment
COPY distro-files/popos/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/popos/etc/os-release /etc/os-release
COPY distro-files/popos/GHCI.cfg /GHCI.cfg

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/popos/etc/passwd /etc/passwd
COPY distro-files/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/popos/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh && chown -R TKT:TKT /home/TKT

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
RUN userdel -rf ubuntu || true
RUN ln -s /usr/bin/clang /usr/bin/clang-cpp

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

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

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
