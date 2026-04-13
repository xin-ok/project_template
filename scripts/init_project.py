#!/usr/bin/env python3
"""
Project initializer: turn the project_template template into a named project.

Steps performed (in order):
    1. Validate the project name
    2. Check whether the template has already been initialized
       (prevents a second run from corrupting the project)
    3. Clean build artifacts: build/ bin/ lib/ install/ packages/
    4. Replace the project name in a whitelist of files
       (no global search-and-replace)
    5. Rename cmake/project_templateConfig.cmake.in -> cmake/<name>Config.cmake.in
    6. Run cmake -P cmake/GeneratePresets.cmake to create CMakePresets.json

Note: the source directory is always src/ and does not depend on the project
name, so it is never renamed.

Usage (run from the project root):
    python scripts/init_project.py MyProject
    python scripts/init_project.py MyProject --dry-run      # preview only
    python scripts/init_project.py MyProject --force        # skip the initialized check
    python scripts/init_project.py MyProject --no-presets   # do not generate CMakePresets.json
    python scripts/init_project.py MyProject --keep-build   # do not clean build artifacts

Or run from inside the scripts directory:
    cd scripts
    python init_project.py MyProject

The script always treats the parent of its own directory as the project root,
independent of the current working directory.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

# ============================================================
#  Console encoding
# ============================================================
# On Windows, Python defaults to GBK when output is redirected, which raises
# UnicodeEncodeError for emoji / non-ASCII text. Force UTF-8 on stdout/stderr
# and replace unencodable characters instead of crashing.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, ValueError):
        pass

# ============================================================
#  Template constants
# ============================================================

TEMPLATE_NAME = "project_template"

# Source directory name: always src, independent of the project name.
SRC_DIR = "src"

# Project name rules: must start with a letter, only letters / digits / underscore.
# Reason: the name is used as PROJECT_NAME, the exported target <name>Targets and
#         the find_package package name. Characters such as '-', '.' or spaces
#         break CMake configuration or find_package.
NAME_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")

# Build artifact directories to clean
CLEAN_DIRS = ["build", "bin", "lib", "install", "packages"]

# Files that need text replacement (relative path -> [(old, new_template), ...])
# The @NAME@ token in the new template is replaced with the project name.
# Note: str.format is deliberately avoided here because the braces in the CMake
#       variable ${PROJECT_SOURCE_DIR} would be treated as placeholders and
#       raise KeyError.
NAME_TOKEN = "@NAME@"

TEXT_REPLACEMENTS: dict[str, list[tuple[str, str]]] = {
    "CMakeLists.txt": [
        (f"project({TEMPLATE_NAME} VERSION", f"project({NAME_TOKEN} VERSION"),
        (f"set(export_name {TEMPLATE_NAME})", f"set(export_name {NAME_TOKEN})"),
    ],
    "scripts/package_install.py": [
        (f'f"{TEMPLATE_NAME}-install-{{stamp}}"', f'f"{NAME_TOKEN}-install-{{stamp}}"'),
        (f"python scripts/package_install.py {TEMPLATE_NAME}-1.0.0-win64",
         f"python scripts/package_install.py {NAME_TOKEN}-1.0.0-win64"),
    ],
    # examples/lib_test links the in-project target name directly
    "examples/lib_test/CMakeLists.txt": [
        (f"    {TEMPLATE_NAME}\n", f"    {NAME_TOKEN}\n"),
    ],
    # Standalone build variant of examples/lib_test: find_package + namespaced target
    "examples/lib_test/CMakeLists.install.txt": [
        (f"find_package({TEMPLATE_NAME} REQUIRED)",
         f"find_package({NAME_TOKEN} REQUIRED)"),
        (f"{TEMPLATE_NAME}::{TEMPLATE_NAME}", f"{NAME_TOKEN}::{NAME_TOKEN}"),
    ],
}

# Files to rename (relative path -> new file name template)
FILE_RENAMES: dict[str, str] = {
    f"cmake/{TEMPLATE_NAME}Config.cmake.in": f"cmake/{NAME_TOKEN}Config.cmake.in",
}

# Directories to rename (relative path -> new directory name template)
# The source directory is always src/ and does not depend on the project name,
# so this mapping is empty.
DIR_RENAMES: dict[str, str] = {}


# ============================================================
#  Output helpers
# ============================================================

def info(msg: str) -> None:
    print(f"  {msg}")


def step(msg: str) -> None:
    print(f"\n[{msg}]")


def warn(msg: str) -> None:
    print(f"  ⚠️  {msg}")


def error(msg: str) -> None:
    print(f"  ❌ {msg}", file=sys.stderr)


# ============================================================
#  Validation
# ============================================================

def validate_name(name: str) -> str | None:
    """Validate the project name. Returns an error message, or None if valid."""
    if not name:
        return "Project name must not be empty"
    if not NAME_PATTERN.match(name):
        return (
            f"Invalid project name '{name}'.\n"
            "     Rule: must start with a letter and contain only letters, digits and underscores.\n"
            "     Examples: MyProject / my_project / App2"
        )
    if name == TEMPLATE_NAME:
        return f"Project name must not be the template name '{TEMPLATE_NAME}', please choose another"
    return None


def is_already_initialized(root: Path) -> bool:
    """Return True if the template has already been initialized
    (the top-level CMakeLists.txt no longer uses the template name)."""
    top = root / "CMakeLists.txt"
    if not top.is_file():
        return False
    content = top.read_text(encoding="utf-8")
    return f"project({TEMPLATE_NAME} VERSION" not in content


# ============================================================
#  Step implementations
# ============================================================

def clean_build_artifacts(root: Path, dry_run: bool) -> None:
    step("Cleaning build artifacts")
    removed = 0
    for d in CLEAN_DIRS:
        target = root / d
        if target.is_dir():
            info(f"Removing {d}/")
            if not dry_run:
                shutil.rmtree(target, ignore_errors=True)
            removed += 1
    if removed == 0:
        info("Nothing to clean")


def apply_text_replacements(root: Path, name: str, dry_run: bool) -> None:
    step("Replacing file contents")
    for rel_path, rules in TEXT_REPLACEMENTS.items():
        path = root / rel_path
        if not path.is_file():
            warn(f"Skipped (file not found): {rel_path}")
            continue

        content = path.read_text(encoding="utf-8")
        original = content
        hits = 0

        for old, new_tpl in rules:
            new = new_tpl.replace(NAME_TOKEN, name)
            count = content.count(old)
            if count:
                content = content.replace(old, new)
                hits += count
                info(f"{rel_path}: '{old}' -> '{new}'  ({count} occurrence(s))")

        if hits == 0:
            warn(f"{rel_path}: no matching content found (already initialized?)")
            continue

        if not dry_run and content != original:
            path.write_text(content, encoding="utf-8")


def rename_files(root: Path, name: str, dry_run: bool) -> None:
    step("Renaming files")
    for old_rel, new_tpl in FILE_RENAMES.items():
        old_path = root / old_rel
        new_path = root / new_tpl.replace(NAME_TOKEN, name)

        if not old_path.is_file():
            warn(f"Skipped (file not found): {old_rel}")
            continue
        if new_path.exists():
            warn(f"Skipped (target already exists): {new_path.relative_to(root)}")
            continue

        info(f"{old_rel} -> {new_path.relative_to(root)}")
        if not dry_run:
            old_path.rename(new_path)


def rename_dirs(root: Path, name: str, dry_run: bool) -> None:
    step("Renaming directories")
    for old_rel, new_tpl in DIR_RENAMES.items():
        old_path = root / old_rel
        new_path = root / new_tpl.replace(NAME_TOKEN, name)

        if not old_path.is_dir():
            warn(f"Skipped (directory not found): {old_rel}/")
            continue
        if new_path.exists():
            warn(f"Skipped (target already exists): {new_path.relative_to(root)}/")
            continue

        info(f"{old_rel}/ -> {new_path.relative_to(root)}/")
        if not dry_run:
            old_path.rename(new_path)


def generate_presets(root: Path, dry_run: bool) -> bool:
    """Run cmake -P cmake/GeneratePresets.cmake to create CMakePresets.json."""
    step("Generating CMakePresets.json")

    script = root / "cmake" / "GeneratePresets.cmake"
    if not script.is_file():
        warn(f"Not found: {script.relative_to(root)}, skipping")
        return False

    if dry_run:
        info("(dry-run) would run: cmake -P cmake/GeneratePresets.cmake")
        return True

    cmake = shutil.which("cmake")
    if not cmake:
        warn("cmake not found in PATH; please run scripts/generate_presets.bat or scripts/generate_presets.sh manually")
        return False

    result = subprocess.run(
        [cmake, "-P", str(script)],
        cwd=str(root),
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        warn(f"cmake failed (exit code {result.returncode}); please run generate_presets manually")
        return False

    info("[OK] CMakePresets.json generated")
    return True


# ============================================================
#  Main flow
# ============================================================

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Initialize the project_template template with a given project name",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  python scripts/init_project.py MyProject\n"
            "  python scripts/init_project.py MyProject --dry-run\n"
        ),
    )
    parser.add_argument("name", help="Project name (starts with a letter; letters/digits/underscores only)")
    parser.add_argument("--dry-run", action="store_true", help="Print planned changes without writing anything")
    parser.add_argument("--force", action="store_true", help="Skip the 'already initialized' check")
    parser.add_argument("--no-presets", action="store_true", help="Do not generate CMakePresets.json")
    parser.add_argument("--keep-build", action="store_true", help="Do not clean build artifacts")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent.parent
    name = args.name.strip()

    print("======================================")
    print("  Project initialization")
    print("======================================")
    info(f"Project name: {name}")
    info(f"Root directory: {root}")
    if args.dry_run:
        info("Mode: dry-run (no files will be modified)")

    # ---- 1. Validate the project name ----
    err = validate_name(name)
    if err:
        error(err)
        return 1

    # ---- 2. Check whether already initialized ----
    if is_already_initialized(root) and not args.force:
        error(
            "This template appears to have already been initialized "
            f"(top-level CMakeLists.txt no longer contains project({TEMPLATE_NAME} ...)).\n"
            "     Add --force to proceed anyway."
        )
        return 1

    # ---- 3. Clean build artifacts ----
    if args.keep_build:
        step("Cleaning build artifacts")
        info("Skipped (--keep-build)")
    else:
        clean_build_artifacts(root, args.dry_run)

    # ---- 4. Text replacement (must run before directory renames) ----
    apply_text_replacements(root, name, args.dry_run)

    # ---- 5. Rename files ----
    rename_files(root, name, args.dry_run)

    # ---- 6. Rename directories (last, to avoid stale paths) ----
    rename_dirs(root, name, args.dry_run)

    # ---- 7. Generate presets ----
    if args.no_presets:
        step("Generating CMakePresets.json")
        info("Skipped (--no-presets)")
    else:
        generate_presets(root, args.dry_run)

    # ---- Summary ----
    print()
    print("======================================")
    if args.dry_run:
        print("  [OK] dry-run complete (no files modified)")
    else:
        print(f"  [OK] Initialization complete: {name}")
    print("======================================")
    print()
    print("Next steps:")
    print(f"  cmake --list-presets")
    print(f"  cmake --preset <preset-name>")
    print(f"  cmake --build --preset <preset-name>")
    print()
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except BrokenPipeError:
        # Output pipe closed early (e.g. `| Select-String` / `| head`); exit quietly.
        sys.stderr.close()
        sys.exit(0)
    except KeyboardInterrupt:
        print("\nCancelled", file=sys.stderr)
        sys.exit(130)
