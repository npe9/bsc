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
    && rm -rf /var/lib/apt/lists/*

# Install GHC and Cabal
RUN curl -sSL https://get.haskellstack.org/ | sh
RUN stack setup ghc-9.6.6
RUN stack install cabal-install

# Install ccache
RUN apt-get update && apt-get install -y ccache && rm -rf /var/lib/apt/lists/*

# Set up environment
ENV PATH=/root/.local/bin:/root/.stack/programs/x86_64-linux/ghc-9.6.6/bin:$PATH
ENV CCACHE_DIR=/ccache
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=6

# Create work directory
WORKDIR /work

# Copy build scripts
COPY .github/workflows/install_dependencies_ubuntu.sh /scripts/
RUN chmod +x /scripts/install_dependencies_ubuntu.sh

# Create cache directory
RUN mkdir -p /ccache
