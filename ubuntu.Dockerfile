# Pull latest Ubuntu container
FROM ubuntu:oracular AS root

# Copy over our files
COPY distro-files/ubuntu/etc/environment /etc/environment
COPY distro-files/ubuntu/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/ubuntu/etc/apt/sources.list.d/plucky.list /etc/apt/sources.list.d/plucky.list
COPY distro-files/ubuntu/etc/apt/sources.list.d/oracular.list /etc/apt/sources.list.d/oracular.list
COPY distro-files/ubuntu/GHCI.cfg /GHCI.cfg

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/ubuntu/etc/passwd /etc/passwd
COPY distro-files/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/ubuntu/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Update the repo database and upgrade packages
RUN apt-get update
RUN yes '' | apt-get upgrade

# Install depends
RUN apt-get install -y --no-install-recommends --no-install-suggests \
      bash build-essential bc bison flex libssl-dev libelf-dev dwarves \
      git curl wget clang lld llvm clang-tools clang-format clang-tidy \
      bash ccache cmake kmod lz4 make patchutils python3 python3-pip \
      rsync sudo tar time tini zstd liblz4-dev libxxhash-dev nano

# Ensure clang-cpp is resolved (redundant but safe fallback)
RUN ln -sf /usr/bin/clang /usr/bin/clang-cpp || true

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

# Finish image
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/bash"]
