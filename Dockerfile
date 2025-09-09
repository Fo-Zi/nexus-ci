FROM ubuntu:22.04

LABEL maintainer="Nexus Ecosystem"
LABEL description="Base CI container with CMake, West, and GTest for Nexus project unit testing"
LABEL version="0.1.0"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install essential system packages
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    # Python and pip (required for West)
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    # Additional development tools
    pkg-config \
    ninja-build \
    ccache \
    device-tree-compiler \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install CMake (latest stable version)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
    && echo 'deb https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update \
    && apt-get install -y cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install West build tool
RUN pip3 install --no-cache-dir west

# Install Google Test and testing tools
RUN apt-get update && apt-get install -y \
    libgtest-dev \
    libgmock-dev \
    # Additional testing tools (gcov comes with gcc)
    lcov \
    valgrind \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 🔧 Upgrade lcov (Ubuntu provides 1.14, we need >=1.15 for --ignore-errors)
RUN apt-get update && apt-get install -y git perl \
    && git clone https://github.com/linux-test-project/lcov.git /tmp/lcov \
    && cd /tmp/lcov \
    && make install \
    && rm -rf /tmp/lcov

# Build and install GTest using CMake
RUN cd /usr/src/googletest \
    && mkdir build && cd build \
    && cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .. \
    && make \
    && make install

# Set up environment
ENV PATH="/usr/local/bin:${PATH}"
ENV CMAKE_PREFIX_PATH="/usr/local"

# Create working directory
WORKDIR /workspace

# Verify installations
RUN echo "=== Verifying installations ===" \
    && cmake --version \
    && west --version \
    && python3 --version \
    && gcc --version \
    && g++ --version \
    && pkg-config --version \
    && echo "=== Installation verification complete ==="

# Set default command
CMD ["/bin/bash"]
