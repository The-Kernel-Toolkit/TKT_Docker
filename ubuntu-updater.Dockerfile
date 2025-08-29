# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-ubuntu-dev:latest AS root

# Update container
RUN apt update && apt upgrade -y

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
