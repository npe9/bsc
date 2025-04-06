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
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ENV PATH="/root/.ghcup/bin:${PATH}"

# Configure ccache
ENV CCACHE_DIR=/ccache
ENV PATH="/usr/lib/ccache:${PATH}"

# Configure Cabal and install dependencies
RUN mkdir -p /root/.cabal && \
    echo "\
repository hackage.haskell.org\n\
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
      key-threshold: 3\n" > /root/.cabal/config

RUN . /root/.ghcup/env && \
    cabal update && \
    cabal install syb

# Set working directory
WORKDIR /work

# Copy source code
COPY . .

# Build command
CMD ["cabal", "build", "bsc"]
