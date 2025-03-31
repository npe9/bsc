#!/bin/bash

# Exit on error
set -e

# Clean previous coverage data
rm -rf dist-newstyle/hpc

# Build and install BSC first
cabal build
cabal install

# Build Prelude and core libraries
./build_prelude.sh

# Build and run tests with coverage
cabal build --enable-coverage
cabal test --enable-coverage --test-show-details=always

# Generate coverage report
cabal hpc report --all

# Generate HTML coverage report
cabal hpc markup --all

# Print location of coverage report
echo "Coverage report generated at: dist-newstyle/hpc/vanilla/html/index.html" 