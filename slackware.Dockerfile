FROM aclemons/slackware:current AS root

# Copy our files
COPY distro-files/slackware/etc/environment /etc/evironment
COPY distro-files/slackware/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/slackware/etc/slackpkg/mirrors /etc/slackpkg/mirrors
COPY distro-files/slackware/GHCI.cfg /GHCI.cfg

# Fix ca-certificates the Slackware way
RUN wget --no-check-certificate "http://mirrors.unixsol.org/slackware/slackware64-current/slackware64/n/ca-certificates-$(date +%Y%m%d).txz" -O /tmp/ca-certificates.txz || true && \
    installpkg /tmp/ca-certificates.txz || true && \
    slackpkg update gpg && \
    slackpkg update

# Install build deps
RUN yes | slackpkg -batch=on -default_answer=y install \
    bash bc binutils bison brotli ccache clang cmake cpio curl cyrus-sasl diffutils dwarves elfutils fakeroot fakeroot-ng file flex gc gcc \
    gcc-g++ gcc-gcobol gcc-gdc gcc-gfortran gcc-gm2 gcc-gnat gcc-go gcc-objc gcc-rust git glibc guile gzip kernel-headers kmod libedit libelf \
    libxml2 lld llvm lz4 lzop m4 make ncurses nghttp2 nghttp3 openssl patchutils perl python3 python3-pip rsync schedtool spirv-llvm-translator \
    sudo tar time wget xxHash xz zstd

# ldconfig because Slacklyfe
RUN ldconfig

# Download and install tini manually (Slackware doesn't have it by default)
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static-amd64 /sbin/tini
RUN chmod +x /sbin/tini

# Clean up cache
RUN rm -rf /var/cache/*

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
