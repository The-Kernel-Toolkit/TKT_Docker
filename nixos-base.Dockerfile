# Use official Nix image
FROM nixos/nix:latest AS root

# Copy DNS config
COPY distro-files/resolv.conf /etc/resolv.conf

# Enable experimental Nix features
RUN echo "experimental-features = flakes nix-command" >> /etc/nix/nix.conf

# Install basic kernel build dependencies via nix profile
RUN nix profile install \
      nixpkgs#gcc \
      nixpkgs#make \
      nixpkgs#bc \
      nixpkgs#perl \
      nixpkgs#elfutils \
      nixpkgs#ncurses \
      nixpkgs#git \
      nixpkgs#wget \
      nixpkgs#xz \
      nixpkgs#bzip2 \
      nixpkgs#gzip

# Install cachix for caching builds
RUN nix profile install nixpkgs#cachix

# Default command: drop into shell
CMD ["/bin/sh"]
