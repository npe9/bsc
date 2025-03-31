#!/bin/bash

# Exit on error
set -e

# First build and install htcl
echo "Building htcl package..."
cd src/vendor/htcl

# Generate HTcl.h
echo "Generating HTcl.h..."
hsc2hs HTcl.hs
mv HTcl_out.hs HTcl.h

# Build and install htcl
cabal build
cabal install --lib --force-reinstalls
cd ../../..

# Create build directory for compiled libraries
echo "Creating build directory..."
mkdir -p build/bsvlib

# First compile the minimal Prelude with no dependencies
echo "Bootstrapping MinimalPrelude..."
bsc -p . -bdir build/bsvlib -no-use-prelude src/Libraries/Base1/MinimalPrelude.bs

# Now compile the full Prelude using the minimal one
echo "Compiling full Prelude..."
BSC_PATH=build/bsvlib:$BSC_PATH bsc -p . -bdir build/bsvlib src/Libraries/Base1/Prelude.bs
bsc -p . -bdir build/bsvlib src/Libraries/Base1/PreludeBSV.bsv

# Base2 libraries
echo "Compiling Base2 libraries..."
for f in src/Libraries/Base2/*.bs src/Libraries/Base2/*.bsv; do
  if [ -f "$f" ]; then
    echo "Compiling $f..."
    bsc -p . -bdir build/bsvlib "$f"
  fi
done

# Base3 libraries
echo "Compiling Base3 libraries..."
for d in src/Libraries/Base3-*; do
  if [ -d "$d" ]; then
    echo "Compiling in $d..."
    for f in "$d"/*.bsv; do
      if [ -f "$f" ]; then
        echo "Compiling $f..."
        bsc -p . -bdir build/bsvlib "$f"
      fi
    done
  fi
done

echo "Compilation complete." 