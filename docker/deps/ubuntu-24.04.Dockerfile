ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

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
    cmake \
    bison \
    flex \
    libgmp-dev \
    autoconf \
    gperf \
    # Documentation dependencies
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    && rm -rf /var/lib/apt/lists/*

# Create cache directories
RUN mkdir -p /ccache

# Add scripts
COPY docker/deps/check_code.sh /usr/local/bin/check_code.sh
COPY docker/deps/fix_confdir.sh /usr/local/bin/fix_confdir.sh
RUN chmod +x /usr/local/bin/check_code.sh /usr/local/bin/fix_confdir.sh

# Label the image
LABEL org.opencontainers.image.source=https://github.com/B-Lang-org/bsc
LABEL org.opencontainers.image.description="BSC dependencies for Ubuntu 24.04"
LABEL org.opencontainers.image.licenses=BSD-3-Clause 