#!/bin/bash

# Exit on error
set -e

# Build and install bsc in staging area
echo "Building bsc in staging area..."
cabal build
cabal install --install-method=copy --installdir=dist-newstyle/staging

# Set up environment to use staging bsc
export PATH="$(pwd)/dist-newstyle/staging:$PATH"

# Build Prelude and libraries using staging bsc
echo "Building Prelude and libraries..."
./build_prelude.sh

# Build and run tests with coverage
echo "Building and running tests with coverage..."
cabal build --enable-coverage
cabal test --enable-coverage --test-show-details=always

# Generate coverage report
echo "Generating coverage report..."
cabal hpc report --all
cabal hpc markup --all

echo "Build complete. Coverage report at: dist-newstyle/hpc/vanilla/html/index.html" 