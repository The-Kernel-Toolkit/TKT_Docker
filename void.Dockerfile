FROM voidlinux/voidlinux:latest AS root

# Copy our files
COPY distro-files/void/etc/environment /etc/evironment
COPY distro-files/void/etc/profile /etc/profile
COPY distro-files/etc/shells /etc/shells
COPY distro-files/etc/resolv.conf /etc/resolv.conf
COPY distro-files/void//etc/xbps.d/00-repository-main.conf /etc/xbps.d/00-repository-main.conf
COPY distro-files/void/GHCI.cfg /GHCI.cfg

# Create TKT user in an unconventional way, because Void
RUN useradd --badnames TKT && \
    mkdir -p /home/TKT/.config && \
    chown -R TKT:TKT /home/TKT

COPY distro-files/void/etc/passwd /etc/passwd
COPY distro-files/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/void/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Sync base system and certs
RUN xbps-install -Suy xbps && \
    xbps-install -Sy ca-certificates

# Install core + compiler + packaging tools
RUN xbps-install -y \
  bash bc bison ccache clang clang-tools-extra cmake cpio curl flex git kmod lz4 make patchutils perl \
  python3 python3-pip rsync sudo tar time wget zstd \
  base-devel docbook-xsl elfutils-devel fakeroot gcc gnupg graphviz liblz4-devel lz4 lzop m4 \
  ncurses openssl-devel pahole patch pkg-config schedtool xtools xmlto xz

# Clean up
RUN xbps-remove -O && rm -rf /var/cache/xbps

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

CMD ["/bin/bash"]
