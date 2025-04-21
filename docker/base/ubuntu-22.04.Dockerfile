FROM ubuntu:22.04

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
    software-properties-common \
    tcl \
    && rm -rf /var/lib/apt/lists/*

# Install GHCup for Haskell toolchain management
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Add GHCup to PATH
ENV PATH="/root/.ghcup/bin:$PATH"

# Label the image
LABEL org.opencontainers.image.source=https://github.com/B-Lang-org/bsc
LABEL org.opencontainers.image.description="Base image for BSC on Ubuntu 22.04"
LABEL org.opencontainers.image.licenses=BSD-3-Clause 