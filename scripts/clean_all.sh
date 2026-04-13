#!/bin/bash
# Project root = parent directory of this script (the parent of scripts/).
# This makes the script work the same whether invoked as
#   scripts/clean_all.sh   (from project root)
#   ./clean_all.sh         (from inside scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

clear
echo "======================================"
echo "  Cleaning: build bin lib install packages"
echo "======================================"

# Remove silently; missing directories are not an error.
rm -rf "$ROOT_DIR/build"
rm -rf "$ROOT_DIR/bin"
rm -rf "$ROOT_DIR/lib"
rm -rf "$ROOT_DIR/install"
rm -rf "$ROOT_DIR/packages"

echo ""
echo "[OK] Cleanup complete."