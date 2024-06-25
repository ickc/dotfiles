#!/usr/bin/env python

from pathlib import Path
import re

import defopt
import pandas as pd


def get_executable_paths(
    nix_bin_dir: Path = Path("/run/current-system/sw/bin"),
) -> list[Path]:
    """Get realpath to executables in the nix bin directory."""
    return [path.readlink() for path in nix_bin_dir.iterdir()]


def get_package_install_name(p: str) -> str:
    """Get the package install name by patching it manually."""
    if p == "Image-ExifTool":
        return "exiftool"
    if p == "mpv-with-scripts":
        return "mpv"
    if p == "patch":
        return "gnupatch"
    if p == "nixfmt-unstable":
        return "nixfmt-rfc-style"
    if p == "whisper-cpp":
        return "openai-whisper-cpp"
    if p == "pandoc-cli":
        return "pandoc"
    if p == "pam_reattach":
        return "pam-reattach"
    return p


def parse_nix_path(
    path: Path,
    version_regex: str = re.compile(r'^(?P<interpreter>(python|perl)[.0-9]+-)?(?P<package>.+?)(?P<version>-[-_.0-9p]+(pre)?)?(?P<date>\+date=[-0-9]+)?(?P<git>\+git[-0-9]+)?(?P<bin>-bin)?$'),
) -> list[str | Path]:
    """Parse a nix path."""
    command = path.name
    parent = path.parent
    assert parent.name == "bin"
    parent = parent.parent
    name = parent.name
    assert parent.parent == Path("/nix/store")
    assert name[32] == "-"
    symbolink_name = name[33:]
    match = version_regex.match(symbolink_name)
    if not match:
        raise ValueError(f"Invalid format for: {symbolink_name}")
    groups = match.groupdict()
    
    interpreter = groups['interpreter']
    package = groups['package']
    version = groups['version']
    date = groups['date']
    git = groups['git']
    is_bin = not groups['bin']
    if interpreter:
        interpreter = interpreter[:-1]
    if version:
        version = version[1:]
    if date:
        date = date[6:]
    if git:
        git = git[5:]
    return [command, get_package_install_name(package), interpreter, package, version, date, git, is_bin, path]


def parse_nix_paths(
    nix_bin_dir: Path = Path("/run/current-system/sw/bin"),
) -> pd.DataFrame:
    paths = get_executable_paths(nix_bin_dir)
    return pd.DataFrame((parse_nix_path(path) for path in paths), columns=["executable", "install", "interpreter", "package", "version", "date", "git", "is_bin", "path"])


def read_environment_systemPackages(
    path: Path = Path("flake.nix"),
) -> list[str]:
    """Read environment.systemPackages from flake.nix.

    Read the lines between these 2 lines:

        environment.systemPackages = with pkgs; [
        ];
    """
    with path.open("r", encoding="utf-8") as f:
        lines = f.readlines()
    # Find the indices of the lines to replace
    start_index = -1
    end_index = -1

    for i, line in enumerate(lines):
        if line.strip() == "environment.systemPackages = with pkgs; [":
            start_index = i + 1
        elif start_index != -1 and line.strip() == "];":
            end_index = i
            break

    if start_index == -1 or end_index == -1:
        raise ValueError("Could not find the target lines in the file.")

    return [line.strip() for line in lines[start_index:end_index]]


def command2package(
    path: Path,
    *,
    nix_bin_dir: Path = Path("/run/current-system/sw/bin"),
) -> None:
    df = parse_nix_paths(nix_bin_dir)
    df.to_csv(path, index=False)


def cli() -> None:
    defopt.run(command2package)


if __name__ == "__main__":
    cli()
