# Dockerfile for building BSC with GHC 9.6.6 and Cabal 3.10.1.0
# Updated to include build process in workflow
FROM ubuntu:24.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libgmp-dev \
    libffi-dev \
    libncurses5-dev \
    libtinfo-dev \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Install GHC and Cabal
RUN curl --proto '=https' --tlsv1.2 -sSf https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/local/bin/ghcup && \
    chmod +x /usr/local/bin/ghcup && \
    ghcup install ghc 9.6.6 && \
    ghcup set ghc 9.6.6 && \
    ghcup install cabal 3.10.1.0 && \
    ghcup set cabal 3.10.1.0

# Configure ccache
ENV PATH=/usr/lib/ccache:$PATH
ENV CCACHE_DIR=/ccache

# Configure Cabal and download package list
RUN mkdir -p /root/.cabal && \
    echo "repository hackage.haskell.org" > /root/.cabal/config && \
    echo "  url: http://hackage.haskell.org/" >> /root/.cabal/config && \
    echo "  secure: True" >> /root/.cabal/config && \
    cabal update

# Set working directory
WORKDIR /work

# Copy source code
COPY . .

# Build command
CMD ["cabal", "build", "bsc"]
