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
    echo "remote-repo: hackage.haskell.org:http://hackage.haskell.org/\n\
remote-repo-cache: /root/.cabal/packages\n\
package-db: global\n\
package-db: user\n\
extra-prog-path: /root/.cabal/bin\n\
installdir: /root/.cabal/bin\n\
build-summary: /root/.cabal/logs/build.log\n\
remote-build-reporting: anonymous\n\
jobs: \$ncpus" > /root/.cabal/config

# Update Cabal and install dependencies
RUN cabal update && \
    cabal install syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["cabal", "build"]
