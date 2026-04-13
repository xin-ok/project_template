#!/usr/bin/env python3
"""
Merge all preset build outputs under install/ into a single zip archive.

Every subdirectory of install/ (e.g. msvc18-debug, msvc18-release) is copied
into a temporary staging directory, which is then zipped.

Usage (run from the project root):
    python scripts/package_install.py                       # name gets a timestamp
    python scripts/package_install.py project_template-1.0.0-win64

Or run from inside the scripts directory:
    cd scripts
    python package_install.py

The script always treats the parent of its own directory as the project root,
independent of the current working directory.
"""

import shutil
import sys
import tempfile
import zipfile
from datetime import datetime
from pathlib import Path


def main() -> int:
    # ---------- Determine package name ----------
    package_name = sys.argv[1] if len(sys.argv) > 1 else ""
    if not package_name.strip():
        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        package_name = f"project_template-install-{stamp}"

    # Strip a manually supplied .zip suffix
    if package_name.lower().endswith(".zip"):
        package_name = package_name[:-4]

    # ---------- Prepare directories ----------
    # This script lives in scripts/, so the project root is its parent.
    root_dir    = Path(__file__).resolve().parent.parent
    install_dir = root_dir / "install"
    output_dir  = root_dir / "packages"

    # ---------- Validate install directory ----------
    if not install_dir.is_dir():
        print(f"Error: install directory not found: {install_dir}")
        return 1

    sub_dirs = [d for d in install_dir.iterdir() if d.is_dir()]
    if not sub_dirs:
        print("Error: install directory contains no subdirectories to merge")
        return 1

    print("======================================")
    print("  Merging install/ and packaging as zip")
    print("======================================")

    output_dir.mkdir(parents=True, exist_ok=True)

    # ---------- Stage into a temporary directory ----------
    staging = Path(tempfile.mkdtemp(prefix="nspkg_"))
    try:
        # ---------- Merge each subdirectory ----------
        for d in sub_dirs:
            print(f"Merging directory: {d.name}")
            # dirs_exist_ok=True allows overwriting existing files
            shutil.copytree(d, staging, dirs_exist_ok=True)

        # ---------- Create the zip ----------
        zip_path = output_dir / f"{package_name}.zip"
        if zip_path.exists():
            zip_path.unlink()

        top_items = list(staging.iterdir())

        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for item in staging.rglob("*"):
                if item.is_file():
                    # arcname is relative to staging so the staging folder
                    # name itself is not written into the archive
                    zf.write(item, item.relative_to(staging))

        print()
        print(f"Package created: {zip_path}")
        print("Top-level contents:")
        for item in top_items:
            print(f"  - {item.name}")

    finally:
        # ---------- Clean up the temporary directory ----------
        if staging.exists():
            shutil.rmtree(staging, ignore_errors=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())