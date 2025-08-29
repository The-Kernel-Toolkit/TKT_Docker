# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-suse-dev:latest AS root

# Update container
RUN zypper update -y

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
