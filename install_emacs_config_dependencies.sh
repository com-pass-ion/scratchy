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

# Install LSP servers via npm
sudo npm install -g pyright
sudo npm install -g bash-language-server

# Install Noto Sans Mono font (as specified in init.el)
sudo apt install -y fonts-noto

echo "All dependencies installed successfully."
