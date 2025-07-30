FROM nixos/nix AS root

RUN echo "experimental-features = flakes nix-command" >> /etc/nix/nix.conf
RUN nix profile install nixpkgs#cachix

CMD    ["/bin/sh"]
