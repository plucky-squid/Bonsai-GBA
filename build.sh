#!/bin/bash
#
# Bonsai GBA build script
#
# Compiles the Bonsai GBA emulator for PSP using the pspdev toolchain.
# Intended to run inside the pspdev/pspdev Docker image (see Dockerfile
# and docker-compose.yml). Outputs are copied to the top-level build/
# directory so they survive after the container exits.

set -e

echo "=== Bonsai GBA build script ==="
echo "Setting up PSP development environment..."

export PSPDEV=/usr/local/pspdev
export PATH=$PATH:$PSPDEV/bin
export PSPSDK=$PSPDEV/psp/sdk

echo "Checking PSP toolchain..."
if ! command -v psp-gcc &> /dev/null; then
    echo "ERROR: PSP toolchain not found. Make sure the Docker image was built correctly."
    exit 1
fi

echo "PSP GCC version:"
psp-gcc --version | head -1

echo "PSP SDK path: $PSPSDK"
echo "PSP DEV path: $PSPDEV"

cd source

echo "=== Building Bonsai GBA ==="
echo "Cleaning previous build..."
make clean || true

echo "Starting compilation..."
make -j"$(nproc 2>/dev/null || echo 2)"

if [ -f "BonsaiGBA.prx" ] && [ -f "EBOOT.PBP" ]; then
    echo "=== BUILD SUCCESSFUL ==="
    echo "Generated files:"
    ls -la BonsaiGBA.prx EBOOT.PBP

    mkdir -p ../build
    cp BonsaiGBA.prx ../build/
    cp EBOOT.PBP ../build/

    echo "Build artifacts copied to build/ directory"
    echo "You can now copy EBOOT.PBP to your PSP's PSP/GAME/BonsaiGBA/ folder"
else
    echo "=== BUILD FAILED ==="
    echo "Expected output files not found"
    exit 1
fi
