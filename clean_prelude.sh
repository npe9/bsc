#!/bin/bash

# Exit on error
set -e

echo "Cleaning prelude build artifacts..."

# Clean the build directory for compiled libraries
echo "Cleaning build/bsvlib directory..."
rm -rf build/bsvlib/*

# Clean htcl build artifacts
echo "Cleaning htcl build artifacts..."
cd src/vendor/htcl
cabal clean
rm -f HTcl.h
cd ../../..

echo "Prelude clean complete." 