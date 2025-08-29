# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-gentoo-openrc-dev:latest AS root

# Update container
RUN emerge --sync && \
    emerge -uDN @world && \
    etc-update --automode -5 || true

# Optional cleanup to shrink image
RUN emerge --depclean && \
    revdep-rebuild

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
