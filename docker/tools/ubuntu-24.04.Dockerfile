ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS builder-base

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libboost-dev \
    libboost-program-options-dev \
    autoconf \
    gperf \
    libgmp-dev \
    zlib1g-dev \
    bison \
    flex \
    && rm -rf /var/lib/apt/lists/*

# Build minisat (required by STP)
WORKDIR /build
RUN git clone --depth 1 https://github.com/niklasso/minisat.git && \
    cd minisat && \
    export CXXFLAGS="-fpermissive" && \
    make config prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# Build STP in its own layer
FROM builder-base AS builder-stp
WORKDIR /build
COPY src/vendor/stp /build/stp
WORKDIR /build/stp
RUN make install-stp PREFIX=/usr/local

# Build Yices in its own layer
FROM builder-base AS builder-yices
WORKDIR /build
COPY src/vendor/yices /build/yices
WORKDIR /build/yices
RUN make install-yices PREFIX=/usr/local

# Create final image
FROM ${BASE_IMAGE}

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libboost-program-options1.74.0 \
    libgmp10 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder stages
COPY --from=builder-base /usr/local/lib/libminisat* /usr/local/lib/
COPY --from=builder-base /usr/local/include/minisat /usr/local/include/minisat

COPY --from=builder-stp /usr/local/include/stp /usr/local/include/stp
COPY --from=builder-stp /usr/local/lib/lib*stp* /usr/local/lib/
COPY --from=builder-stp /usr/local/bin/stp* /usr/local/bin/

COPY --from=builder-yices /usr/local/include/yices* /usr/local/include/
COPY --from=builder-yices /usr/local/lib/libyices* /usr/local/lib/
COPY --from=builder-yices /usr/local/bin/yices* /usr/local/bin/

# Update library cache
RUN ldconfig

# Label the image
LABEL org.opencontainers.image.source=https://github.com/B-Lang-org/bsc
LABEL org.opencontainers.image.description="BSC tools (STP and Yices) for Ubuntu 24.04"
LABEL org.opencontainers.image.licenses=BSD-3-Clause 