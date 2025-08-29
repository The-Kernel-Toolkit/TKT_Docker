FROM archlinux:base-devel AS root

# Copy our base files
COPY distro-files/arch/etc/environment /etc/environment
COPY distro-files/profile /etc/profile
COPY distro-files/shells /etc/shells
COPY distro-files/resolv.conf /etc/resolv.conf
COPY distro-files/arch/etc/pacman.conf /etc/pacman.conf
COPY distro-files/arch/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
COPY distro-files/arch/etc/makepkg.conf /etc/makepkg.conf
COPY distro-files/arch/usr/bin/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Run reflector to speed up repos
RUN pacman -Syy --needed --noconfirm --asexplicit aria2 curl reflector wget
#RUN reflector --fastest 5 --verbose --protocol https,http --latest 5 --age 1 --sort rate --save /etc/pacman.d/mirrorlist

# Update and install base-devel and other needed packages
RUN pacman -Su --needed --noconfirm --asexplicit \
        base-devel bash bc bison bzip2 ccache clang coreutils cpio dialog docbook-xsl flex gcc gettext git graphviz \
        imagemagick inetutils kmod libbpf libelf lld llvm linux-firmware lz4 lzo mkinitcpio nano ncurses openssl \
        patchutils perl python python-sphinx python-sphinx_rtd_theme python-yaml rsync rust rust-bindgen rust-src schedtool \
        scx-scheds sudo tar texlive-latexextra time wget wireless-regdb xmlto xz zstd

# Create TKT user
RUN useradd --badname -U -m TKT && \
    chown -R TKT:TKT /home/TKT && \
    mkdir -p /home/TKT/.config
COPY distro-files/arch/etc/passwd /etc/passwd
COPY distro-files/sudoers.d/TKT /etc/sudoers.d/TKT
COPY distro-files/GHCI.cfg /GHCI.cfg.base
COPY distro-files/arch/GHCI.cfg /GHCI.cfg.distro
RUN cat /GHCI.cfg.distro /GHCI.cfg.base >> /GHCI.cfg

# Final command (login shell)
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-i"]
