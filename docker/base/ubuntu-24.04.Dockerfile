FROM ubuntu:24.04 AS stp-builder

# Install STP build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Build STP
WORKDIR /build
RUN git clone --depth 1 https://github.com/stp/stp.git && \
    cd stp && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

FROM ubuntu:24.04 AS yices-builder

# Install Yices build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    autoconf \
    git \
    && rm -rf /var/lib/apt/lists/*

# Build Yices
WORKDIR /build
RUN git clone --depth 1 https://github.com/SRI-CSL/yices2.git && \
    cd yices2 && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install

FROM ubuntu:24.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ccache \
    curl \
    git \
    libelf-dev \
    pkg-config \
    python3 \
    python3-pip \
    python3-yaml \
    software-properties-common \
    tcl \
    && rm -rf /var/lib/apt/lists/*

# Create cache directories
RUN mkdir -p /ccache

# Copy built artifacts from builders
COPY --from=stp-builder /usr/local/include/stp /usr/local/include/stp
COPY --from=stp-builder /usr/local/lib/lib*stp* /usr/local/lib/
COPY --from=stp-builder /usr/local/bin/stp* /usr/local/bin/

COPY --from=yices-builder /usr/local/include/yices* /usr/local/include/
COPY --from=yices-builder /usr/local/lib/libyices* /usr/local/lib/
COPY --from=yices-builder /usr/local/bin/yices* /usr/local/bin/

# Update library cache
RUN ldconfig

# Install GHCup for Haskell toolchain management
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Add GHCup to PATH
ENV PATH="/root/.ghcup/bin:$PATH"

# Label the image
LABEL org.opencontainers.image.source=https://github.com/B-Lang-org/bsc
LABEL org.opencontainers.image.description="Base image for BSC on Ubuntu 24.04"
LABEL org.opencontainers.image.licenses=BSD-3-Clause 