FROM voidlinux/voidlinux:latest AS root

# Copy our files
COPY distro-files/void/etc/environment /etc/evironment
COPY distro-files/profile /etc/profile
COPY distro-files/shells /etc/shells
COPY distro-files/resolv.conf /etc/resolv.conf
COPY distro-files/void/etc/xbps.d/00-repository-main.conf /etc/xbps.d/00-repository-main.conf

# Copy TKT GHCI configs
COPY distro-files/GHCI.cfg /TKT.cfg.base
COPY distro-files/void/GHCI.cfg /TKT.cfg.distro
RUN cat /TKT.cfg.distro /TKT.cfg.base >> /GHCI.cfg
RUN rm /TKT.cfg.distro /TKT.cfg.base

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

CMD ["/bin/bash"]
