# Install system dependencies and GHC packages
FROM bsc-tools:ubuntu-24.04 as builder

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    bison \
    build-essential \
    clang \
    flex \
    gawk \
    ghc \
    git \
    gperf \
    libfontconfig1-dev \
    libghc-regex-compat-dev \
    libghc-syb-dev \
    libgmp-dev \
    libtinfo-dev \
    python3 \
    tcl-dev \
    tcl \
    tcllib \
    && rm -rf /var/lib/apt/lists/*

# Install Haskell dependencies using v1-install as per workflow
RUN cabal update && \
    cabal v1-install old-time regex-compat split syb && \
    ghc-pkg recache

WORKDIR /build/bsc

# Copy source files
COPY . .

# Initialize submodules with verbose output
RUN git config --global --add safe.directory /build/bsc && \
    git config --global --add safe.directory /build/bsc/src/vendor/stp && \
    git submodule update --init --recursive -v && \
    echo "Verifying STP source:" && \
    ls -la src/vendor/stp

# Build and install STP
RUN echo "Building STP..." && \
    echo "Contents of /build/bsc/src/vendor/stp:" && \
    ls -la /build/bsc/src/vendor/stp && \
    echo "Contents of /build/bsc/src/vendor/stp/src:" && \
    ls -la /build/bsc/src/vendor/stp/src && \
    cd /build/bsc/src/vendor/stp && \
    make clean && \
    make -j$(nproc) && \
    mkdir -p /usr/local/lib && \
    cp lib/libstp.so* /usr/local/lib/ && \
    ldconfig

# Build BSC with workflow-specified flags and install all components
RUN cd /build/bsc && \
    echo "Building and installing BSC..." && \
    cd src && \
    make -j$(nproc) install && \
    echo "Checking installation directory structure:" && \
    find /build/bsc/inst -type f -ls && \
    echo "Installing binaries to /usr/local/bin:" && \
    cp -v /build/bsc/inst/bin/bsc* /usr/local/bin/ && \
    cp -v /build/bsc/inst/bin/bluetcl /usr/local/bin/ && \
    echo "Installing BSC libraries:" && \
    mkdir -p /usr/local/lib/BSC && \
    cp -rv /build/bsc/inst/lib/Libraries/* /usr/local/lib/BSC/ && \
    echo "Verifying installed binaries and libraries:" && \
    ls -la /usr/local/bin/bsc* /usr/local/bin/bluetcl && \
    ls -la /usr/local/lib/BSC && \
    echo "Setting up tcllib:" && \
    mkdir -p /usr/local/lib/tcllib && \
    cp -rv /usr/share/tcltk/tcllib* /usr/local/lib/tcllib/ && \
    echo "Build completed."

# Runtime stage
FROM ubuntu:24.04 as runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ghc \
    cabal-install \
    libgmp10 \
    zlib1g \
    tcl \
    tcllib \
    && rm -rf /var/lib/apt/lists/*

# Install Haskell dependencies in runtime
RUN cabal update && \
    cabal v1-install old-time regex-compat split syb && \
    ghc-pkg recache

# Create necessary directories
RUN mkdir -p /usr/local/lib/BSC /usr/local/lib/tcllib

# Copy built files from builder stage
COPY --from=builder /usr/local/lib/libgmp.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/libstp.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/libyices.so* /usr/local/lib/
COPY --from=builder /usr/local/bin/bsc* /usr/local/bin/
COPY --from=builder /usr/local/bin/bluetcl /usr/local/bin/
COPY --from=builder /usr/local/lib/tcllib/* /usr/local/lib/tcllib/
COPY --from=builder /usr/local/lib/BSC/* /usr/local/lib/BSC/

# Set PATH and LD_LIBRARY_PATH
ENV PATH="/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib"

CMD ["bash"]