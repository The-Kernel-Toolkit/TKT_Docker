# Pull latest Ubuntu container
FROM ubuntu:oracular AS root

# Copy over our files
COPY distro-files/ubuntu/etc/environment /etc/environment
COPY distro-files/ubuntu/etc/profile /etc/profile
COPY distro-files/ubuntu/etc/shells /etc/shells
COPY distro-files/ubuntu/etc/apt/sources.list.d/plucky.list /etc/apt/sources.list.d/plucky.list
COPY distro-files/ubuntu/etc/apt/sources.list.d/oracular.list /etc/apt/sources.list.d/oracular.list

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

# Finish image
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/bash"]
