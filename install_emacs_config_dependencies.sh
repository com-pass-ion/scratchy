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

# C++ Language Server
sudo apt install -y clangd

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
sudo apt install -y gdb rr

# Install LSP servers via npm
sudo npm install -g pyright
sudo npm install -g bash-language-server

# Mermaid CLI (for mermaid-mode)
sudo npm install -g @mermaid-js/mermaid-cli

# Install Noto Sans Mono font (as specified in init.el)
sudo apt install -y fonts-noto

echo "All dependencies installed successfully."
