# Pull existing container
FROM ghcr.io/the-kernel-toolkit/tkt-gentoo-systemd-dev:latest AS root

# Update container
RUN emerge --sync && \
    emerge --quiet --verbose --getbinpkg --usepkg --buildpkg --binpkg-respect-use=y --autounmask=y --autounmask-continue -uDN @world && \
    etc-update --automode -5 || true

# Cleanup to shrink image
RUN emerge --depclean && \
    revdep-rebuild

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
