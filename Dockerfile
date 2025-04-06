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
    libtinfo5 \
    ghc \
    cabal-install \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Create Cabal config directory and initialize config
RUN mkdir -p /root/.cabal && \
    echo "repository hackage.haskell.org\n  url: http://hackage.haskell.org/\n  secure: True\n  root-keys: 0a5c7ea47cd1b15f800f7289e56d51643c87d179\n  key-threshold: 3" > /root/.cabal/config

# Update Cabal package list and install dependencies
RUN cabal update && \
    cabal install --lib syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["cabal", "build"]
