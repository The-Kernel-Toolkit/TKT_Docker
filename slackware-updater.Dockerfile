# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-slackware-dev:latest AS root

# Update container
RUN echo "YES" | slackpkg update

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
