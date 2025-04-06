# Dockerfile for building BSC with GHC 9.6.6 and Cabal 3.10.1.0
# Updated to include build process in workflow
FROM --platform=$BUILDPLATFORM ubuntu:24.04 as builder

# Install required packages
RUN apt-get update && apt-get install -y \
    ghc \
    cabal-install \
    iputils-ping \
    dnsutils \
    curl \
    netcat-openbsd \
    traceroute \
    iproute2 \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Debug network configuration
RUN echo "=== Network Configuration ===" && \
    cat /etc/resolv.conf && \
    echo "=== IP Configuration ===" && \
    ip addr && \
    echo "=== Route Table ===" && \
    ip route && \
    echo "=== Testing DNS Resolution ===" && \
    nslookup hackage.haskell.org && \
    echo "=== Testing Network Connectivity ===" && \
    ping -c 4 hackage.haskell.org && \
    echo "=== Testing HTTP Access ===" && \
    curl -v https://hackage.haskell.org/ && \
    echo "=== Testing TCP Connection ===" && \
    nc -zv hackage.haskell.org 443 && \
    echo "=== Testing Route to Hackage ===" && \
    traceroute hackage.haskell.org

# Create Cabal repository configuration
RUN mkdir -p /root/.cabal && \
    echo "repository hackage.haskell.org" > /root/.cabal/config && \
    echo "  url: https://hackage.haskell.org/" >> /root/.cabal/config && \
    echo "  secure: True" >> /root/.cabal/config && \
    echo "  root-keys:" >> /root/.cabal/config && \
    echo "    fe331502606802feac15e514d9b9ea83fee8b6ffef71335479a2e68d84adc6b0" >> /root/.cabal/config && \
    echo "    1ea9ba32c526d1cc91ab5e5bd364ec5e9e8cb67179a471872f6e26f0ae773d42" >> /root/.cabal/config && \
    echo "    51f0161b906011b52c6613376b1ae937670da69322113a246a09f807c62f6921" >> /root/.cabal/config && \
    echo "  key-threshold: 2" >> /root/.cabal/config

# Update Cabal package list with verbose output
RUN cabal update -v3

WORKDIR /work
CMD ["/bin/bash"]

# Final stage
FROM --platform=$TARGETPLATFORM ubuntu:24.04

# Copy only the necessary files from builder
COPY --from=builder /usr/bin/cabal /usr/bin/
COPY --from=builder /usr/lib/ghc /usr/lib/ghc
COPY --from=builder /usr/bin/ghc /usr/bin/
COPY --from=builder /usr/bin/ghc-pkg /usr/bin/
COPY --from=builder /root/.cabal /root/.cabal

# Copy architecture-specific libraries
COPY --from=builder /usr/lib/*-linux-gnu/libgmp* /usr/lib/*-linux-gnu/

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgmp-dev \
    libffi-dev \
    libncurses-dev \
    libtinfo-dev \
    libz-dev \
    make \
    xz-utils \
    zlib1g-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["/bin/bash"]
