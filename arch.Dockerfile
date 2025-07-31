FROM archlinux:base-devel AS root

# Copy our base files
COPY distro-files/arch/etc/environment /etc/environment
COPY distro-files/arch/etc/profile /etc/profile
COPY distro-files/arch/etc/shells /etc/shells
COPY distro-files/arch/etc/pacman.conf /etc/pacman.conf
COPY distro-files/arch/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
COPY distro-files/arch/etc/makepkg.conf /etc/makepkg.conf
COPY distro-files/arch/usr/bin/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Create TKT user
COPY distro-files/gen-TKT-user.sh /gen-TKT-user.sh
RUN chmod +x /gen-TKT-user.sh && /gen-TKT-user.sh && rm /gen-TKT-user.sh
COPY distro-files/arch/etc/passwd /etc/passwd
COPY distro-files/arch/etc/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /home/TKT/.config/TKT.cfg.base
COPY distro-files/arch/GHCI.cfg /home/TKT/.config/TKT.cfg.distro
RUN cat /home/TKT/.config/TKT.cfg.distro /home/TKT/.config/TKT.cfg.base >> /home/TKT/.config/TKT.cfg
COPY distro-files/init-tkt.sh /home/TKT/init-tkt.sh
RUN chmod +x /home/TKT/init-tkt.sh

# Run reflector to speed up repos
RUN pacman -Syy --needed --noconfirm --asexplicit aria2 curl reflector rsync wget
RUN reflector --fastest 5 --verbose --protocol rsync,https,http --latest 5 --age 1 --sort rate --save /etc/pacman.d/mirrorlist

# Update and install base-devel and other needed packages
RUN pacman -Syu --needed --noconfirm --asexplicit \
        base-devel bash bc bison ccache clang coreutils cpio docbook-xsl flex gcc gettext git graphviz imagemagick \
        inetutils initramfs kmod libelf linux-firmware lld llvm mkinitcpio nano pahole patchutils perl python \
        python-sphinx python-sphinx_rtd_theme python-yaml rust rust-bindgen rust-src schedtool scx-scheds sudo \
        tar texlive-latexextra time wireless-regdb xmlto xz

# Set environment variables for TKT
ENV HOME=/home/TKT \
    USER=TKT

# Set working directory to user's home
WORKDIR /home/TKT

# Use the TKT user from this point on
USER TKT

# Setup the TKT repo ahead of time to save a little time
RUN /home/TKT/init-tkt.sh && rm /home/TKT/init-tkt.sh

# Set working directory to the TKT repo
WORKDIR /home/TKT/TKT

# Echo mirrorlist for debug purposes
RUN cat /etc/pacman.d/mirrorlist

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
