FROM ubuntu:22.04 as build

# Install build dependencies
ADD .github/workflows/install_dependencies_ubuntu.sh /build/
RUN DEBIAN_FRONTEND=noninteractive \
    /build/install_dependencies_ubuntu.sh

# Copy source and build script
ADD . /build/
ADD .github/workflows/build-docker.sh /build/

# Build BSC
RUN cd /build && \
    chmod +x build-docker.sh && \
    ./build-docker.sh 9.2.8 22.04 && \
    rm -rf /build/src /build/inst/lib/ghc-9.2.8/package.conf.d

# Final image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        build-essential \
        tcl \
        iverilog \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy BSC installation
COPY --from=build /build/inst /opt/bluespec/

# Set up environment
ENV PATH /opt/bluespec/bin:$PATH
ENV BLUESPECDIR /opt/bluespec/lib
ENV BLUESPEC_LICENSE_FILE /opt/bluespec/license

# Create a non-root user
RUN useradd -m -s /bin/bash bsc
USER bsc
WORKDIR /home/bsc

# Default command
CMD ["bsc", "--help"]
