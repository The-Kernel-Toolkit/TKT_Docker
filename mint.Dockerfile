FROM linuxmintd/mint21-amd64 AS root

# Copy our base files
COPY distro-files/mint/etc/environment /etc/evironment
COPY distro-files/mint/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/mint/etc/passwd /etc/passwd
COPY distro-files/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/mint/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

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

# Time to fix Mint's broken ass distro
RUN userdel -rf ubuntu || true
RUN chown -R TKT:TKT /home/TKT
RUN ln -s /usr/bin/clang /usr/bin/clang-cpp

# Clean up
RUN apt-get clean

# Set environment variables for TKT
ENV HOME=/home/TKT \
    USER=TKT

# Use the TKT user from this point on
USER TKT

# Setup the TKT repo ahead of time to save a little time
RUN /home/TKT/init-tkt.sh

# Set working directory to user's home
WORKDIR /home/TKT/TKT

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
