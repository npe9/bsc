# Dockerfile for building BSC with GHC 9.6.6 and Cabal 3.10.1.0
# Updated to include build process in workflow
FROM ubuntu:24.04

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libgmp-dev \
    libffi-dev \
    libncurses5-dev \
    zlib1g-dev \
    libtinfo-dev \
    ghc \
    cabal-install \
    ccache \
    dnsutils \
    iputils-ping \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ghc --version

# Set DNS environment variables
ENV HOSTALIASES=/etc/host.aliases
RUN echo "hackage.haskell.org 8.8.8.8" > /etc/host.aliases

# Create and configure Cabal
RUN mkdir -p /root/.cabal && \
    echo "repository hackage.haskell.org" > /root/.cabal/config && \
    echo "  url: https://hackage.haskell.org/" >> /root/.cabal/config && \
    echo "  secure: True" >> /root/.cabal/config && \
    echo "  root-keys: fe331502606802feac15e514d9b9ea83fee8b6ffef71335479a2e68d84adc6b0" >> /root/.cabal/config && \
    echo "            1ea9ba32c526d1cc91ab5e5bd364ec5e9e8cb67179a471872f6e26f0ae773d42" >> /root/.cabal/config && \
    echo "            51f0161b906011b52c6613376b1ae937670da69322113a246a09f807c62f6921" >> /root/.cabal/config && \
    echo "  key-threshold: 2" >> /root/.cabal/config

# Test network connectivity and DNS resolution
RUN echo "Testing network connectivity and DNS resolution..." && \
    ping -c 4 hackage.haskell.org && \
    dig hackage.haskell.org && \
    curl -v https://hackage.haskell.org/

# Update Cabal package list and install syb
RUN cabal update && \
    cabal install --lib syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["/bin/bash"]
