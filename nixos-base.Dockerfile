# Use official Nix image
FROM nixos/nix:latest AS root

# Copy DNS config
COPY distro-files/resolv.conf /etc/resolv.conf

# Setup the ENV
ENV NIX_REMOTE=daemon
ENV NIX_CONF_DIR=/etc/nix
ENV NIXPKGS_ALLOW_UNFREE=1
ENV NIX_NONINTERACTIVE=1
ENV NIX_CACHIX_AUTH_TOKEN=W511kfAgRPaUzA3Igf4ahN181qFRl745blhvfQOBio
ENV USER=root
ENV NIX_REMOTE=local

# Enable experimental features and configure cachix non-interactively
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
RUN echo "extra-substituters = https://tkt-cache.cachix.org" >> /etc/nix/nix.conf
RUN echo "extra-trusted-public-keys = tkt-cache.cachix.org-1:/W511kfAgRPaUzA3Igf4ahN181qFRl745blhvfQOBio=" >> /etc/nix/nix.conf

# Install basic kernel build dependencies via nix profile
RUN nix-env -iA \
      nixpkgs.gcc \
      nixpkgs.gnumake \
      nixpkgs.bc \
      nixpkgs.perl \
      nixpkgs.elfutils \
      nixpkgs.ncurses \
      nixpkgs.xz \
      nixpkgs.bzip2 \
      nixpkgs.cachix \
      nixpkgs.tini \
      nixpkgs.lzop

# Default command: drop into shell
ENV PATH=/root/.nix-profile/bin:$PATH
ENTRYPOINT ["tini", "--"]
CMD ["bash"]
