#!/bin/bash
set -e

echo "Installing Emacs configuration dependencies..."

# Update package list
sudo apt update

# Core Emacs and Build tools
sudo apt install -y \
    emacs \
    build-essential \
    git \
    cmake \
    curl \
    wget

# C++ Language Server + toolchain extras
# clang-format : format-on-save (uses the nearest project .clang-format)
# bear         : generate compile_commands.json for non-CMake (legacy) projects
sudo apt install -y clangd clang-format bear

# Java Language Server
sudo apt install -y jdtls

# Python dependencies
sudo apt install -y python3 python3-pip python3-venv npm

# Media & Document support (pdf-tools, svg-tag-mode)
sudo apt install -y \
    libpoppler-glib-dev \
    libpoppler-private-dev \
    librsvg2-dev

# Ripgrep (fast grep for consult-ripgrep)
sudo apt install -y ripgrep

# C++ debugging (gdb + rr for the GDB workflow)
# NOTE: rr is x86_64-focused; on aarch64 the package installs but
# record/replay may fail at runtime. Tests treat those as SKIP, not FAIL.
sudo apt install -y gdb rr docker.io

# Install LSP servers via npm
sudo npm install -g pyright
sudo npm install -g bash-language-server

# Mermaid CLI (for mermaid-mode)
sudo npm install -g @mermaid-js/mermaid-cli

# Install Noto Sans Mono font (as specified in init.el)
sudo apt install -y fonts-noto

# Default dot files (tool-native configs versioned in this repo).
# Symlink into $HOME only when the target does not already exist, so a
# user's own configuration is never overwritten.
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)/dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
    echo "Linking default dot files from $DOTFILES_DIR..."
    shopt -s nullglob dotglob
    for src in "$DOTFILES_DIR"/*; do
        base="$(basename "$src")"
        dest="$HOME/$base"
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            echo "  skip $dest (already exists)"
        else
            ln -s "$src" "$dest"
            echo "  linked $dest -> $src"
        fi
    done
    shopt -u nullglob dotglob
else
    echo "No dotfiles directory found; skipping dot-file symlinks."
fi

echo "All dependencies installed successfully."
