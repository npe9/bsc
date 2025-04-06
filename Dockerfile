# Dockerfile for building BSC with GHC 9.6.6 and Cabal 3.10.1.0
# Updated to include build process in workflow
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libffi-dev \
    libgmp-dev \
    libncurses-dev \
    libtinfo-dev \
    make \
    python3 \
    python3-pip \
    wget \
    zlib1g-dev \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Install GHC and Cabal
ENV GHC_VERSION=9.6.6
ENV CABAL_VERSION=3.10.1.0

RUN wget https://downloads.haskell.org/~ghc/${GHC_VERSION}/ghc-${GHC_VERSION}-x86_64-ubuntu20_04-linux.tar.xz && \
    tar -xf ghc-${GHC_VERSION}-x86_64-ubuntu20_04-linux.tar.xz && \
    cd ghc-${GHC_VERSION}-x86_64-unknown-linux && \
    ./configure && \
    make install && \
    cd .. && \
    rm -rf ghc-${GHC_VERSION}-x86_64-unknown-linux ghc-${GHC_VERSION}-x86_64-ubuntu20_04-linux.tar.xz

RUN wget https://downloads.haskell.org/~cabal/cabal-install-${CABAL_VERSION}/cabal-install-${CABAL_VERSION}-x86_64-linux-ubuntu20_04.tar.xz && \
    tar -xf cabal-install-${CABAL_VERSION}-x86_64-linux-ubuntu20_04.tar.xz && \
    mv cabal /usr/local/bin/ && \
    rm cabal-install-${CABAL_VERSION}-x86_64-linux-ubuntu20_04.tar.xz

# Configure ccache
ENV CCACHE_DIR=/ccache
ENV CCACHE_COMPRESS=true
ENV CCACHE_COMPRESSLEVEL=6
ENV PATH=/usr/lib/ccache:$PATH

# Configure cabal
RUN mkdir -p /ccache && \
    mkdir -p /root/.cabal && \
    echo "package *" > /root/.cabal/config && \
    echo "  optimization: 1" >> /root/.cabal/config && \
    echo "  split-sections: true" >> /root/.cabal/config && \
    echo "  ghc-options: -j2 +RTS -M4500M -A128m -RTS" >> /root/.cabal/config

# Set working directory
WORKDIR /work

# Copy source code
COPY . .

# Build command
CMD ["bash", "-c", "ccache --zero-stats --max-size 250M && \
    cabal v2-build --ghc-options=\"+RTS -M4500M -A128m -RTS\" -j2 && \
    cabal v2-install --installdir=inst/bin && \
    cabal v2-sdist && \
    tar xzf dist-newstyle/sdist/bsc-*.tar.gz -C dist-newstyle/sdist/ && \
    cd dist-newstyle/sdist/bsc-* && \
    cabal v2-build --ghc-options=\"+RTS -M4500M -A128m -RTS\" -j2 && \
    cabal v2-install --installdir=../../../../inst/bin && \
    cd ../../../.. && \
    tar czf inst.tar.gz inst"]
