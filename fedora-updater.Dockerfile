# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-fedora-dev:latest AS root

# Update container
RUN dnf upgrade -y

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
