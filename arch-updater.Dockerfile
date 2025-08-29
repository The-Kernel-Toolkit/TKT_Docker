# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-arch-dev:latest AS root

# Update container
RUN pacman -Syu --noconfirm

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
