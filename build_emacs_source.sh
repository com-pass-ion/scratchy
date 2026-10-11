#!/bin/bash
set -e

# --- Configuration ---
INSTALL_PREFIX="$HOME/.local"
BUILD_DIR="$HOME/emacs-build"
EMACS_VERSION="stable" # Will clone the master/main branch or a specific tag if provided

echo "Preparing to build Emacs from source..."

# 1. Install dependencies
echo "Installing build dependencies..."
sudo apt-get update

# Resolve libgccjit version dynamically for Ubuntu/Debian/RaspiOS
GCCJIT_PKG=$(apt-cache search libgccjit-dev | grep -o 'libgccjit-[0-9]*-dev' | head -n 1)
NATIVE_COMP="yes"
if [ -z "$GCCJIT_PKG" ]; then
    echo "Warning: Could not find libgccjit-dev package. Native compilation will be disabled."
    GCCJIT_PKG=""
    NATIVE_COMP="no"
else
    echo "Found gccjit package: $GCCJIT_PKG"
fi

sudo apt-get install -y \
    build-essential \
    texinfo \
    libgtk-3-dev \
    libxpm-dev \
    libgnutls28-dev \
    libxml2-dev \
    libncurses-dev \
    libjansson-dev \
    libpng-dev \
    libjpeg-dev \
    libgif-dev \
    libtiff-dev \
    libtree-sitter-dev \
    libcairo2-dev \
    zlib1g-dev \
    git \
    curl \
    $GCCJIT_PKG

# 2. Clone source
if [ -d "$BUILD_DIR" ]; then
    echo "Build directory exists. Updating..."
    cd "$BUILD_DIR" && git pull
else
    echo "Cloning Emacs source..."
    git clone --depth 1 --branch master https://git.savannah.gnu.org/git/emacs.git "$BUILD_DIR"
    cd "$BUILD_DIR"
fi

# 3. Configure
echo "Configuring Emacs..."
./autogen.sh
./configure \
    --prefix="$INSTALL_PREFIX" \
    --with-native-compilation="$NATIVE_COMP" \
    --with-tree-sitter \
    --with-json \
    --with-x-toolkit=gtk3 \
    --with-modules \
    --with-cairo

# 4. Build
# Use total CPUs minus 1 to keep system responsive
CPUS=$(nproc)
BUILD_JOBS=$((CPUS > 1 ? CPUS - 1 : 1))
echo "Building with $BUILD_JOBS threads..."
make -j"$BUILD_JOBS"

# 5. Install
echo "Installing to $INSTALL_PREFIX..."
make install

# 6. Update shell profiles
echo "Updating shell profiles..."
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC" ]; then
        if ! grep -q "$INSTALL_PREFIX/bin" "$RC"; then
            echo "Adding $INSTALL_PREFIX/bin to $RC"
            echo "" >> "$RC"
            echo "# Emacs source build" >> "$RC"
            echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> "$RC"
        fi
    fi
done

echo "--------------------------------------------------"
echo "Emacs build and installation complete!"
echo "Binary location: $INSTALL_PREFIX/bin/emacs"
echo "Please restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc)."
echo "--------------------------------------------------"
