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
    echo "remote-repo: hackage.haskell.org:http://hackage.haskell.org/" > /root/.cabal/config && \
    echo "remote-repo-cache: /root/.cabal/packages" >> /root/.cabal/config && \
    echo "local-repo: /root/.cabal/local-repo" >> /root/.cabal/config && \
    echo "package-db: global" >> /root/.cabal/config && \
    echo "package-db: user" >> /root/.cabal/config && \
    echo "extra-prog-path: /root/.cabal/bin" >> /root/.cabal/config && \
    echo "installdir: /root/.cabal/bin" >> /root/.cabal/config && \
    echo "build-summary: /root/.cabal/logs/build.log" >> /root/.cabal/config && \
    echo "remote-build-reporting: anonymous" >> /root/.cabal/config && \
    echo "jobs: \$ncpus" >> /root/.cabal/config && \
    cabal update && \
    cabal install --lib syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["cabal", "build"]
