# Use an official Ubuntu base
FROM docker.m.daocloud.io/ubuntu:22.04

# Disable interactive prompts during package installs
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies including Clang and LLD
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-distutils \
    curl \
    wget \
    vim \
    unzip \
    zlib1g-dev \
    libedit-dev \
    libncurses5-dev \
    libtool \
    libxml2-dev \
    libffi-dev \
    clang \
    lld \
    ccache \
    && apt-get clean

# Set working directory
WORKDIR /root

# Clone LLVM project (including MLIR)
RUN git clone https://github.com/llvm/llvm-project.git


RUN mkdir -p llvm-project/build && cd llvm-project/build && \
    cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_BUILD_EXAMPLES=ON \
    -DLLVM_TARGETS_TO_BUILD="Native;NVPTX;AMDGPU" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON \
    -DLLVM_CCACHE_BUILD=ON \
    && cmake --build . --target check-mlir

ENV MLIR_DIR="/root/llvm-project/build/lib/cmake/mlir"
ENV LLVM_DIR="/root/llvm-project/build/lib/cmake/llvm"

# Default command
CMD ["/bin/bash"]
