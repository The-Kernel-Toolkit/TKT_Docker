FROM ubuntu:oracular

# Update + install all build deps at build time
RUN rm -rf /etc/apt/sources.list* && mkdir /etc/apt/sources.list.d
RUN echo "deb [trusted=yes] http://mirror.mit.edu/ubuntu oracular main universe multiverse restricted" | tee /etc/apt/sources.list.d/mit.edu.list
RUN echo "deb [trusted=yes] http://mirror.mit.edu/ubuntu oracular-backports main universe multiverse restricted" | tee /etc/apt/sources.list.d/mit.edu.list
RUN echo "deb [trusted=yes] http://mirror.mit.edu/ubuntu oracular-proposed main universe multiverse restricted" | tee /etc/apt/sources.list.d/mit.edu.list
RUN echo "deb [trusted=yes] http://mirror.mit.edu/ubuntu oracular-security main universe multiverse restricted" | tee /etc/apt/sources.list.d/mit.edu.list
RUN echo "deb [trusted=yes] http://mirror.mit.edu/ubuntu oracular-updates main universe multiverse restricted" | tee /etc/apt/sources.list.d/mit.edu.list
RUN apt-get install -y --no-install-recommends \
      build-essential bc bison flex libssl-dev libelf-dev dwarves \
      git curl wget clang lld llvm clang-tools clang-format clang-tidy \
      bash ccache cmake cpio kmod lz4 make patchutils python3 python3-pip \
      rsync sudo tar time tini zstd liblz4-dev libxxhash-dev

# Ensure clang-cpp is resolved (redundant but safe fallback)
RUN ln -sf /usr/bin/clang /usr/bin/clang-cpp || true

# Clean cache for smaller image
RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/bash"]
