FROM ubuntu:24.04 as builder

# Install build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    git \
    python3 \
    zlib1g-dev \
    flex \
    bison \
    cmake \
    libboost-all-dev \
    libgmp-dev \
    libtinfo-dev \
    gperf \
    autoconf \
    automake \
    libtool \
    && rm -rf /var/lib/apt/lists/*

# Build and install minisat with C++11 compatibility
RUN git clone --depth 1 https://github.com/niklasso/minisat.git && \
    cd minisat && \
    sed -i 's/friend Lit mkLit(Var var, bool sign = false);/friend Lit mkLit(Var var, bool sign);/' minisat/core/SolverTypes.h && \
    sed -i 's/inline  Lit  mkLit     (Var var, bool sign) { Lit p; p.x = var + var + (int)sign; return p; }/inline  Lit  mkLit     (Var var, bool sign = false) { Lit p; p.x = var + var + (int)sign; return p; }/' minisat/core/SolverTypes.h && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DCMAKE_CXX_FLAGS="-fpermissive -std=c++11" \
          .. && \
    make -j$(nproc) && \
    make install && \
    cd ../.. && \
    rm -rf minisat

# Build and install STP using CMake
RUN git clone --depth 1 https://github.com/stp/stp.git && \
    cd stp && \
    git submodule init && \
    git submodule update && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DSTATICCOMPILE=OFF \
          -DENABLE_PYTHON_INTERFACE=OFF \
          .. && \
    make -j$(nproc) && \
    make install && \
    cd ../.. && \
    rm -rf stp

# Build and install Yices
RUN git clone --depth 1 https://github.com/SRI-CSL/yices2.git && \
    cd yices2 && \
    autoreconf -i && \
    autoconf && \
    ./configure --prefix=/usr/local --enable-gmp && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf yices2

# Create final image
FROM ubuntu:24.04

# Install runtime dependencies and clean up
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libgomp1 \
    libboost-program-options1.74.0 \
    libboost-serialization1.74.0 \
    libgmp10 \
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder
COPY --from=builder /usr/local/bin/minisat /usr/local/bin/
COPY --from=builder /usr/local/lib/libminisat.* /usr/local/lib/
COPY --from=builder /usr/local/include/minisat /usr/local/include/minisat
COPY --from=builder /usr/local/bin/stp /usr/local/bin/
COPY --from=builder /usr/local/lib/libstp.* /usr/local/lib/
COPY --from=builder /usr/local/bin/yices* /usr/local/bin/
COPY --from=builder /usr/local/lib/libyices.* /usr/local/lib/

# Update library cache
RUN ldconfig

# Labels
LABEL org.opencontainers.image.description="BSC tools for Ubuntu 24.04"
LABEL org.opencontainers.image.source="https://github.com/B-Lang-org/bsc" 