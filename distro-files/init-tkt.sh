#!/bin/bash
set -e

REPO_DIR="/home/TKT/TKT"
REPO_URL="https://github.com/The-Kernel-Toolkit/TKT"

if [ -d "$REPO_DIR/.git" ]; then
    echo "Repo exists, pulling latest..."
    git -C "$REPO_DIR" pull --ff-only
else
    echo "Cloning repo fresh..."
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi
