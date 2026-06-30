#!/usr/bin/env python3
"""Update pinned GitHub archive externals in .chezmoiexternal.toml.

The script is intentionally deterministic: it rewrites the external file in a
stable order, updates GitHub tag archive URLs to the latest tag, and refreshes
checksum metadata for each archive URL.
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
import tomllib
import urllib.request
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
EXTERNALS = ROOT / ".chezmoiexternal.toml"
TAG_ARCHIVE_RE = re.compile(
    r"^https://github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+)/archive/refs/tags/(?P<tag>[^/]+)\.tar\.gz$"
)

HEADER = """# Third-party zsh plugins, fetched by chezmoi into $XDG_DATA_HOME/zsh/plugins.
# Pinned to release tags for reproducibility; \"archive\" + stripComponents fetches
# plain files (no .git directory).
#
# .zshrc sources these from \"$XDG_DATA_HOME/zsh/plugins/<name>\"; the target paths
# below match the default XDG_DATA_HOME (~/.local/share).
#
# Run scripts/update_chezmoi_externals.py to update GitHub tag pins and refresh
# checksum metadata.
"""


def fetch_json(url: str) -> Any:
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "dotfiles-chezmoi-external-updater"}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode())


def latest_tag(owner: str, repo: str) -> str:
    tags = fetch_json(f"https://api.github.com/repos/{owner}/{repo}/tags?per_page=1")
    if not tags:
        raise RuntimeError(f"No tags found for {owner}/{repo}")
    return tags[0]["name"]


def checksum_and_size(url: str) -> tuple[str, int]:
    req = urllib.request.Request(url, headers={"User-Agent": "dotfiles-chezmoi-external-updater"})
    digest = hashlib.sha512()
    size = 0
    with urllib.request.urlopen(req, timeout=120) as resp:
        while chunk := resp.read(1024 * 1024):
            size += len(chunk)
            digest.update(chunk)
    return digest.hexdigest(), size


def toml_value(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, str):
        return json.dumps(value)
    raise TypeError(f"Unsupported TOML value: {value!r}")


def render(data: dict[str, Any]) -> str:
    lines = [HEADER.rstrip(), ""]
    key_order = ["type", "url", "format", "stripComponents", "refreshPeriod"]
    for target, entry in data.items():
        lines.append(f"[{toml_value(target)}]")
        for key in key_order:
            if key in entry:
                lines.append(f"    {key} = {toml_value(entry[key])}")
        checksum = entry.get("checksum", {})
        if checksum:
            lines.append(f"    checksum.sha512 = {toml_value(checksum['sha512'])}")
            if "size" in checksum:
                lines.append(f"    checksum.size = {toml_value(checksum['size'])}")
        for key in entry:
            if key not in set(key_order) | {"checksum"}:
                lines.append(f"    {key} = {toml_value(entry[key])}")
        lines.append("")
    return "\n".join(lines)


def main() -> int:
    data = tomllib.loads(EXTERNALS.read_text())
    for entry in data.values():
        url = entry.get("url")
        match = TAG_ARCHIVE_RE.match(url or "")
        if match:
            tag = latest_tag(match["owner"], match["repo"])
            entry["url"] = f"https://github.com/{match['owner']}/{match['repo']}/archive/refs/tags/{tag}.tar.gz"
        if entry.get("type") in {"archive", "archive-file"} and str(entry.get("url", "")).endswith(".tar.gz"):
            entry.setdefault("format", "tar.gz")
        sha512, size = checksum_and_size(entry["url"])
        entry["checksum"] = {"sha512": sha512, "size": size}
    EXTERNALS.write_text(render(data))
    return 0


if __name__ == "__main__":
    sys.exit(main())
