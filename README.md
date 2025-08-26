# Nexus CI Base Container

A Docker container image with essential dependencies for Nexus workspace unit testing and CI pipelines.

## Contents

This container includes:

- **CMake** (latest stable) - Build system generator
- **West** - Zephyr's meta-tool for multiple repositories
- **Google Test & Google Mock** - C++ testing framework
- **GCC/G++** - GNU Compiler Collection
- **Python 3** - Required for West and various tools
- **Development Tools** - pkg-config, ninja-build, ccache, device-tree-compiler
- **Testing Tools** - gcov, lcov, valgrind

## Usage

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/Fo-Zi/nexus-ci-base:latest
```

### Use in GitHub Actions

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/Fo-Zi/nexus-ci-base:latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Build and test
        run: |
          west init -l .
          west update
          cmake -B build
          cmake --build build
          ctest --test-dir build
```

### Local Development

```bash
# Run interactive container
docker run -it --rm -v $(pwd):/workspace ghcr.io/Fo-Zi/nexus-ci-base:latest

# Run specific command
docker run --rm -v $(pwd):/workspace ghcr.io/Fo-Zi/nexus-ci-base:latest \
  bash -c "cmake -B build && cmake --build build"
```

## Building Locally

```bash
cd nexus-ci
docker build -t nexus-ci-base .
```

## Versions

- **Ubuntu**: 22.04 LTS
- **CMake**: Latest stable from Kitware repository
- **West**: Latest from PyPI
- **GTest**: Built from source (latest)

## Size Optimization

The container is optimized for CI usage with:
- Multi-stage builds where appropriate
- Package cache cleanup
- Minimal layer count
- Essential tools only
