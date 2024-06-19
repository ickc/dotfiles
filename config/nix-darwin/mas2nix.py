#!/usr/bin/env python

"""Update flake.nix with the latest mas apps."""

from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


def mas_list(
    regex=re.compile(r" {2,}"),
) -> list[tuple[str, str, str]]:
    """Parse the output of `mas list` and return a list of tuples with the app id, name, and version."""
    out = subprocess.check_output(["/opt/homebrew/bin/mas", "list"], text=True)
    lines = out.split("\n")
    return [tuple(regex.split(line)) for line in lines if line]


def format_mas_to_nix(apps: list[tuple[str, str, str]]) -> list[str]:
    """Format the list of mas apps to a list of strings that can be written to a flake.nix file."""
    res = [f'              "{app[1]}" = {app[0]};\n' for app in apps]
    res.sort(key=str.lower)
    return res


def write_nix_from_nas(
    path: Path,
    nix_content: list[str],
) -> None:
    """Write the nix content to the flake.nix file."""
    path = Path(path)
    res: list[str] = []
    with path.open("r", encoding="utf-8") as f:
        lines = f.readlines()
    # Find the indices of the lines to replace
    start_index = -1
    end_index = -1

    for i, line in enumerate(lines):
        if line.strip() == "masApps = {":
            start_index = i + 1
        elif start_index != -1 and line.strip() == "};":
            end_index = i
            break

    if start_index == -1 or end_index == -1:
        raise ValueError("Could not find the target lines in the file.")

    # Replace the lines between the start and end index with content
    new_lines: list[str] = lines[:start_index] + nix_content + lines[end_index:]

    # Write the new content back to the file
    with path.open("w") as file:
        for line in new_lines:
            file.write(line)


def main(path: Path) -> None:
    """Update the flake.nix file with the latest mas apps."""
    apps = mas_list()
    nix_content = format_mas_to_nix(apps)
    write_nix_from_nas(path, nix_content)


def cli():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Update flake.nix with the latest mas apps"
    )
    parser.add_argument("path", type=Path, help="The path to the flake.nix file")
    args = parser.parse_args()
    main(args.path)


if __name__ == "__main__":
    cli()
