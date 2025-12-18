# Use official Nix image
FROM nixos/nix:latest AS root

# Copy DNS config
COPY distro-files/resolv.conf /etc/resolv.conf

# Enable experimental Nix features
RUN echo "experimental-features = flakes nix-command" >> /etc/nix/nix.conf

# Install basic kernel build dependencies via nix profile
RUN nix profile add \
      nixpkgs#gcc \
      nixpkgs#gnumake \
      nixpkgs#bc \
      nixpkgs#perl \
      nixpkgs#elfutils \
      nixpkgs#ncurses \
      nixpkgs#xz \
      nixpkgs#bzip2 \
      nixpkgs#cachix \
      nixpkgs#tini

# Default command: drop into shell
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh"]
