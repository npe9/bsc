ARG REPOSITORY
FROM ghcr.io/${REPOSITORY}-tools:ubuntu-24.04 AS tools

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

# Copy built artifacts from tools image
COPY --from=tools /usr/local/include/minisat /usr/local/include/minisat
COPY --from=tools /usr/local/lib/libminisat.* /usr/local/lib/
COPY --from=tools /usr/local/bin/minisat /usr/local/bin/

COPY --from=tools /usr/local/include/stp /usr/local/include/stp
COPY --from=tools /usr/local/lib/libstp.* /usr/local/lib/
COPY --from=tools /usr/local/bin/stp /usr/local/bin/

COPY --from=tools /usr/local/include/yices* /usr/local/include/
COPY --from=tools /usr/local/lib/libyices* /usr/local/lib/
COPY --from=tools /usr/local/bin/yices* /usr/local/bin/

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