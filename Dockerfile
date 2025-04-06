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

# Set up Cabal configuration
RUN mkdir -p /root/.cabal && \
    echo "repository hackage.haskell.org\n\
    url: https://hackage.haskell.org/\n\
    secure: True\n\
    root-keys: 0a5c7ea47cd1b15f01f5f51a33adda7e655bc0f0b0615baa8e271f4c3351e21d\n\
    key-threshold: 3\n\
    remote-repo: hackage.haskell.org:http://hackage.haskell.org/" > /root/.cabal/config

# Update Cabal and install dependencies
RUN cabal update && \
    cabal install syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["cabal", "build"]
