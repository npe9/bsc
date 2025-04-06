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
    echo "repository hackage.haskell.org" > /root/.cabal/config && \
    echo "  url: http://hackage.haskell.org/" >> /root/.cabal/config && \
    echo "  secure: True" >> /root/.cabal/config && \
    echo "  root-keys: 0a5c7ea47cd1b15f800f7289e56d51643c87d179" >> /root/.cabal/config && \
    echo "  key-threshold: 3" >> /root/.cabal/config && \
    echo "remote-repo-cache: /root/.cabal/packages" >> /root/.cabal/config && \
    echo "local-repo: /root/.cabal/packages" >> /root/.cabal/config && \
    echo "package-db: /root/.cabal/store/ghc-9.6.6/package.db" >> /root/.cabal/config && \
    echo "extra-prog-path: /root/.cabal/bin" >> /root/.cabal/config && \
    echo "install-dirs user" >> /root/.cabal/config && \
    echo "  prefix: /root/.cabal" >> /root/.cabal/config && \
    echo "build-summary: /root/.cabal/logs/build.log" >> /root/.cabal/config && \
    echo "remote-build-reporting: anonymous" >> /root/.cabal/config && \
    echo "jobs: \$ncpus" >> /root/.cabal/config && \
    cabal update && \
    cabal install --lib syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["cabal", "build"]
