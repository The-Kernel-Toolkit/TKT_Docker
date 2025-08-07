# Pull latest Ubuntu container
FROM ubuntu:oracular AS root

# Copy over our files
COPY distro-files/ubuntu/etc/environment /etc/environment
COPY distro-files/ubuntu/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/ubuntu/etc/apt/sources.list.d/plucky.list /etc/apt/sources.list.d/plucky.list
COPY distro-files/ubuntu/etc/apt/sources.list.d/oracular.list /etc/apt/sources.list.d/oracular.list

# Copy TKT GHCI configs
RUN mkdir -p /github/home/.config
ENV HOME=/github/home
COPY distro-files/GHCI.cfg /TKT.cfg.base
COPY distro-files/ubuntu/GHCI.cfg /TKT.cfg.distro
RUN cat /TKT.cfg.distro /TKT.cfg.base >> /TKT.cfg
RUN rm /TKT.cfg.distro /TKT.cfg.base

# Update the repo database and upgrade packages
RUN apt-get update
RUN yes '' | apt-get upgrade

# Install depends
RUN apt-get install -y --no-install-recommends --no-install-suggests \
      bash build-essential bc bison flex libssl-dev libelf-dev dwarves \
      git curl wget clang lld llvm clang-tools clang-format clang-tidy \
      bash ccache cmake kmod lz4 make patchutils python3 python3-pip \
      rsync sudo tar time tini zstd liblz4-dev libxxhash-dev nano

# Wrap clang-cpp because some distros are retarded and ship broken clang stacks
RUN echo "/usr/bin/clang -E '$@'" >> /usr/bin/clang-cpp && chmod +x /usr/bin/clang-cpp

# Finish image
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/bash"]
