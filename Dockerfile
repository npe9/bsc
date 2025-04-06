FROM --platform=$BUILDPLATFORM ubuntu:24.04 as builder

# Install required packages
RUN apt-get update && apt-get install -y \n    build-essential \n    curl \n    git \n    libgmp-dev \n    libtinfo-dev \n    make \n    tcl-dev \n    tcl \n    && rm -rf /var/lib/apt/lists/*