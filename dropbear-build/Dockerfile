FROM debian:bookworm-slim

ARG DROPBEAR_VERSION=2026.94

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl bzip2 xz-utils make file && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN curl -fL --retry 3 \
        "https://github.com/cross-tools/musl-cross/releases/download/20260823/arm-unknown-linux-musleabi.tar.xz" \
        -o musl-toolchain.tar.xz && \
    echo "d9542873fbe7a2239418d1a2798ef3dece6f0679ba218721880b25a051e61cfd  musl-toolchain.tar.xz" | sha256sum -c - && \
    tar -xJf musl-toolchain.tar.xz && \
    curl -fL --retry 3 \
        "https://matt.ucc.asn.au/dropbear/releases/dropbear-${DROPBEAR_VERSION}.tar.bz2" \
        -o dropbear.tar.bz2 && \
    tar -xjf dropbear.tar.bz2 && \
    cd "dropbear-${DROPBEAR_VERSION}" && \
    PATH="/build/arm-unknown-linux-musleabi/bin:$PATH" \
    CFLAGS="-Os -fno-pie" LDFLAGS="-no-pie" ./configure \
        --host=arm-unknown-linux-musleabi \
        --disable-zlib \
        --disable-pam \
        --disable-utmp \
        --disable-utmpx \
        --disable-wtmp \
        --disable-wtmpx \
        --disable-lastlog && \
    sed -i 's/-fPIE//g; s/-Wl,-pie//g' Makefile libtomcrypt/Makefile libtommath/Makefile && \
    printf '%s\n' \
        '#define DROPBEAR_SVR_PASSWORD_AUTH 0' \
        '#define DROPBEAR_SVR_PAM_AUTH 0' \
        '#define DROPBEAR_SVR_PUBKEY_AUTH 1' \
        > localoptions.h && \
    PATH="/build/arm-unknown-linux-musleabi/bin:$PATH" \
    make -j"$(nproc)" PROGRAMS="dropbear dropbearkey" STATIC=1 && \
    /build/arm-unknown-linux-musleabi/bin/arm-unknown-linux-musleabi-strip dropbear dropbearkey && \
    mkdir -p /out && \
    cp dropbear dropbearkey /out/ && \
    file /out/dropbear /out/dropbearkey
