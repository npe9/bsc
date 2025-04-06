# Dockerfile for building BSC with GHC 9.6.6 and Cabal 3.10.1.0
# Updated to include build process in workflow
FROM ubuntu:24.04

# Install system dependencies and clean up package lists
RUN apt-get update && \
    apt-get install -y \
    curl \
    gcc \
    git \
    libgmp-dev \
    libncurses5-dev \
    make \
    xz-utils \
    zlib1g-dev \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Install GHC and Cabal using ghcup
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 sh
ENV PATH="/root/.ghcup/bin:${PATH}"

# Configure ccache
ENV CCACHE_DIR=/ccache
ENV PATH="/usr/lib/ccache:${PATH}"

# Configure Cabal and install dependencies
RUN mkdir -p /root/.cabal && \
    echo "repository hackage.haskell.org" > /root/.cabal/config && \
    echo "  url: https://hackage.haskell.org/" >> /root/.cabal/config && \
    echo "  secure: True" >> /root/.cabal/config && \
    echo "  root-keys: []" >> /root/.cabal/config && \
    echo "  key-threshold: 0" >> /root/.cabal/config && \
    echo "  package-lists: []" >> /root/.cabal/config && \
    cabal update && \
    cabal v2-install syb --lib && \
    cabal update

# Set working directory
WORKDIR /work

# Copy source code
COPY . .

# Build command
CMD ["cabal", "build", "bsc"]
