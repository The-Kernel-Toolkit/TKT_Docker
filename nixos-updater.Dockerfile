# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-nixos-dev:latest AS root

# Update container
RUN nix-channel --update

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
