# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-void-dev:latest AS root

# Update container
RUN xbps-install -Suy && xbps-remove -O

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
