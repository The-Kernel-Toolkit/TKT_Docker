FROM alpine:3.22 AS verify

RUN apk add --no-cache curl tar zstd tini
RUN curl -sOJL "https://gitlab.archlinux.org/api/v4/projects/10185/packages/generic/rootfs/20250720.0.386825/base-devel-20250720.0.386825.tar.zst"
RUN echo "8ed2fd0af1b9506f8695352557407598b23fb73ac50d944f306e67b5cfd781fa  base-devel-20250720.0.386825.tar.zst" > /tmp/sha256sums.txt
RUN sha256sum -c /tmp/sha256sums.txt
RUN mkdir /rootfs
RUN tar -C /rootfs --extract --file base-devel-20250720.0.386825.tar.zst

FROM scratch AS root
LABEL maintainer="ETJAKEOC@gmail.com"
COPY --from=verify /rootfs /

RUN rm -rf /etc/pacman.d/mirrorlist
RUN echo "Server = rsync://mirrors.kernel.org/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
RUN echo "Server = http://arch.mirror.constant.com/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

RUN ldconfig && \
    sed -i '/BUILD_ID/a VERSION_ID=20250720.0.386825' /etc/os-release

ENV LANG=C.UTF-8

RUN pacman -Syy --needed --noconfirm \
aria2 curl reflector rsync wget
RUN reflector --fastest 10 --verbose --protocol rsync,https,http --latest 10 --age 1 --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --needed --noconfirm \
    base-devel bc bison clang coreutils cpio docbook-xsl flex gcc git \
    graphviz imagemagick inetutils initramfs kmod libelf lld llvm mkinitcpio pahole \
    patchutils perl python-sphinx python-sphinx_rtd_theme schedtool sudo \
    tar xmlto xz

FROM root AS final
LABEL maintainer="ETJAKEOC@gmail.com"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
