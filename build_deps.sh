#!/bin/bash

# Set up environment for arm64 architecture
export ARCHFLAGS="-arch arm64"
export CFLAGS="-arch arm64"
export CXXFLAGS="-arch arm64"
export LDFLAGS="-arch arm64"

# Create a temporary directory for building dependencies
mkdir -p deps
cd deps

# Download and build GMP
echo "Building GMP..."
curl -O https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
tar xf gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure --prefix=$(pwd)/../gmp-inst \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            --target=aarch64-apple-darwin \
            --enable-static \
            --enable-shared \
            CFLAGS="$CFLAGS" \
            LDFLAGS="$LDFLAGS"
make -j$(sysctl -n hw.ncpu)
make install
cd ..

# Now build yices with our custom GMP
echo "Building yices..."
cd ../src/vendor/yices/v2.6/yices2
mkdir -p build
cd build

../configure --enable-mcsat \
            --host=aarch64-apple-darwin \
            --build=aarch64-apple-darwin \
            --target=aarch64-apple-darwin \
            --prefix=$(pwd)/../yices2-inst \
            LDFLAGS="$LDFLAGS -L$(pwd)/../../../deps/gmp-inst/lib" \
            CPPFLAGS="-I$(pwd)/../../../deps/gmp-inst/include" \
            CFLAGS="$CFLAGS" \
            CXXFLAGS="$CXXFLAGS"

make clean
make -j$(sysctl -n hw.ncpu)
make install

# Verify architecture
echo "Verifying library architecture..."
lipo -info ../yices2-inst/lib/libyices.2.dylib
lipo -info ../yices2-inst/lib/libyices.a

cd ../../../../../.. 