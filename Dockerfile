# -- build stage --
FROM --platform=$TARGETPLATFORM debian:bookworm-slim AS builder

ARG MOTION_VERSION=release-4.7.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    autoconf \
    automake \
    autopoint \
    pkgconf \
    gettext \
    libtool \
    build-essential \
    libcamera-dev \
    libopencv-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libwebp-dev \
    libmicrohttpd-dev \
    libmariadb-dev \
    libasound2-dev \
    libpulse-dev \
    libfftw3-dev \
    libsqlite3-dev \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --depth 1 --branch ${MOTION_VERSION} https://github.com/Motion-Project/motion.git .

RUN autoreconf -fiv && \
    ./configure && \
    make -j"$(nproc)" && \
    make install DESTDIR=/install

# -- runtime stage --
FROM --platform=$TARGETPLATFORM debian:bookworm-slim

# Install the same dev packages — guaranteed to exist in Bookworm —
# then strip headers/pkgconfig/manpages to keep the image lean.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcamera-dev \
    libopencv-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libwebp-dev \
    libmicrohttpd-dev \
    libmariadb-dev \
    libasound2-dev \
    libpulse-dev \
    libfftw3-dev \
    libsqlite3-dev \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/include /usr/lib/*/pkgconfig /usr/share/man /usr/share/doc

COPY --from=builder /install/usr/local /usr/local

# create a non-root user for running motion
RUN useradd --system --create-home --shell /bin/false motion

RUN mkdir -p /var/lib/motion /var/log/motion && \
    chown -R motion:motion /var/lib/motion /var/log/motion

USER motion
WORKDIR /var/lib/motion

EXPOSE 8080 8081

ENTRYPOINT ["motion"]
