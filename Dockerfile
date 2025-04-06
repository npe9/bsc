# Dockerfile for building BSC with GHC 9.6.6 and Cabal 3.10.1.0
# Updated to include build process in workflow
FROM ubuntu:24.04

# Install system dependencies and clean up package lists
RUN apt-get update && \
    apt-get install -y \
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

# Create .cabal directory and config file
RUN mkdir -p /root/.cabal
RUN echo "repository hackage.haskell.org\n\
  url: http://hackage.haskell.org/\n\
  secure: True\n\
  root-keys: 7541f32a4ccca4f97aea3b22f5e593ba2c0267546016b992dfadcd2fe944e55d\n\
             26021a13b401500c8eb2761ca95c61f2d625bfef951b939a8124ed12ecf07329\n\
             f76d08be13e9a61a377a85e2fb63f4c5435d40f8feb3e12eb05905edb8cdea89\n\
  key-threshold: 3\n\
  package-index:\n\
    download-prefix: http://hackage.haskell.org/package/\n\
    hackage-security:\n\
      keyids:\n\
      - 7541f32a4ccca4f97aea3b22f5e593ba2c0267546016b992dfadcd2fe944e55d\n\
      - 26021a13b401500c8eb2761ca95c61f2d625bfef951b939a8124ed12ecf07329\n\
      - f76d08be13e9a61a377a85e2fb63f4c5435d40f8feb3e12eb05905edb8cdea89\n\
      key-threshold: 3" > /root/.cabal/config

# Update Cabal and install syb
RUN cabal update && cabal install syb

WORKDIR /work
ENV CCACHE_DIR=/ccache

CMD ["cabal", "build"]
