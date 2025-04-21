ARG BASE_IMAGE
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
    libgmpxx-dev \
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

# Add code check script
COPY docker/deps/check_code.sh /usr/local/bin/check_code.sh
RUN chmod +x /usr/local/bin/check_code.sh

# Label the image
LABEL org.opencontainers.image.source=https://github.com/B-Lang-org/bsc
LABEL org.opencontainers.image.description="BSC dependencies for Ubuntu 22.04"
LABEL org.opencontainers.image.licenses=BSD-3-Clause 