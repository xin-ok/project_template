#!/bin/bash
# Project root = parent directory of this script (the parent of scripts/).
# This makes the script work the same whether invoked as
#   scripts/generate_presets.sh   (from project root)
#   ./generate_presets.sh         (from inside scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================"
echo "  Generating CMakePresets.json"
echo "======================================"

if ! cmake -P "$ROOT_DIR/cmake/GeneratePresets.cmake"; then
    echo ""
    echo "[ERROR] Generation failed."
    exit 1
fi

echo ""
echo "[OK] Generation complete."
