FROM ghcr.io/the-kernel-toolkit/tkt-ubuntu-dev:latest AS root

# Copy our files
COPY distro-files/popos/etc/environment /etc/evironment
COPY distro-files/popos/etc/profile /etc/profile
COPY distro-files/popos/etc/os-release /etc/os-release

# Copy TKT GHCI configs
COPY distro-files/GHCI.cfg /TKT.cfg.base
COPY distro-files/popos/GHCI.cfg /TKT.cfg.distro
RUN cat /TKT.cfg.distro /TKT.cfg.base >> /GHCI.cfg
RUN rm /TKT.cfg.distro /TKT.cfg.base

# Install Pop!_OS keys + base packages + dev tools
COPY distro-files/popos/etc/apt/sources.list.d/tkt.list /etc/apt/sources.list.d/tkt.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 63C46DF0140D738961429F4E204DD8AEC33A7AFF
RUN apt-get update

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
