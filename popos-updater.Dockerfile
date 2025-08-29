FROM ghcr.io/the-kernel-toolkit/tkt-popos-dev:latest AS root

# Update container
RUN apt-get update && apt-get upgrade -y

# Final shell
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
