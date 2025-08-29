FROM nixos/nix AS root

COPY distro-files/resolv.conf /etc/resolv.conf

RUN echo "experimental-features = flakes nix-command" >> /etc/nix/nix.conf
RUN nix profile install nixpkgs#cachix

CMD    ["/bin/sh"]
