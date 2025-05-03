#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${YELLOW}==>${NC} $1"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Function to build Docker images for a specific GHC and Ubuntu version
build_docker_images() {
    local GHC_VERSION=$1
    local UBUNTU_VERSION=$2

    print_status "Building Docker images for GHC ${GHC_VERSION} on Ubuntu ${UBUNTU_VERSION}"

    # Build GHC base image
    print_status "Building GHC base image"
    docker build -t ghcr.io/npe9/bsc-ghc-base-${GHC_VERSION} -f .github/workflows/Dockerfile.ghc-base .

    # Build BSC builder image
    print_status "Building BSC builder image"
    docker build --build-arg GHC_VERSION=${GHC_VERSION} \
                 -t ghcr.io/npe9/bsc-builder-${GHC_VERSION} \
                 -f .github/workflows/Dockerfile.bsc-builder .

    # Build runtime image
    print_status "Building runtime image"
    docker build --build-arg GHC_VERSION=${GHC_VERSION} \
                 -t ghcr.io/npe9/bsc-runtime-${GHC_VERSION}-${UBUNTU_VERSION} \
                 -f .github/workflows/Dockerfile.bsc-runtime .

    # Push images to GHCR
    print_status "Pushing images to GHCR"
    docker push ghcr.io/npe9/bsc-ghc-base-${GHC_VERSION}
    docker push ghcr.io/npe9/bsc-builder-${GHC_VERSION}
    docker push ghcr.io/npe9/bsc-runtime-${GHC_VERSION}-${UBUNTU_VERSION}

    # Run smoke tests
    print_status "Running smoke tests"
    docker run --rm \
      -v $(pwd):/work \
      ghcr.io/npe9/bsc-runtime-${GHC_VERSION}-${UBUNTU_VERSION} \
      bash -c 'cd /work/bsc/examples/smoke_test && make check-smoke'

    print_success "Build completed successfully for GHC ${GHC_VERSION} on Ubuntu ${UBUNTU_VERSION}"
}

# Build for GHC 9.2.8 on Ubuntu 20.04
build_docker_images "9.2.8" "20.04"

# Build for GHC 9.4.8 on Ubuntu 22.04
build_docker_images "9.4.8" "22.04"

# Build for GHC 9.6.6 on Ubuntu 22.04
build_docker_images "9.6.6" "22.04"

# Build for GHC 9.8.4 on Ubuntu 22.04
build_docker_images "9.8.4" "22.04"

# Build for GHC 9.10.1 on Ubuntu 22.04
build_docker_images "9.10.1" "22.04"

# Build for GHC 9.12.1 on Ubuntu 22.04
build_docker_images "9.12.1" "22.04"

print_success "All CI workflow tests completed successfully" 