#!/usr/bin/env python3
"""Guard the website render list against output-file collisions.

Every page in the ``render:`` list of ``_quarto-website.yml`` is rendered to the
project's formats. Each format writes an output file: ``html`` and ``revealjs``
both default to ``<stem>.html``, ``pdf`` to ``<stem>.pdf``, ``docx`` to
``<stem>.docx``. When two of a page's rendered formats resolve to the *same*
output path, Quarto's project move fails with

    rename '.../<stem>.html' -> '_site/.../<stem>.html': No such file

and the publish workflow dies (see issue #966 / PR #967). ``publish.yml`` only
runs on push to ``main``, so a colliding page sails through PR CI and breaks the
site after merge -- this check catches it on the PR instead.

The classic trigger is a page with no ``format:`` block: it inherits the project
formats (which pair ``html`` with a bare ``revealjs``, both writing
``<stem>.html``). But any page whose rendered formats resolve two identical
output paths is flagged -- e.g. a hand-edited header that sets
``revealjs: output-file: <stem>.html``, reusing the html default.

Exit status is 1 (with a per-file report) if any page collides, 0 otherwise.
"""

from __future__ import annotations

import sys
from pathlib import Path

import yaml

WEBSITE_CONFIG = "_quarto-website.yml"

# Default output extension per Quarto format. revealjs shares html's `.html`,
# which is the collision at the heart of #966. Formats not listed fall back to
# the format name, which cannot spuriously collide with these.
DEFAULT_EXT = {
    "html": "html",
    "revealjs": "html",
    "pdf": "pdf",
    "docx": "docx",
    "gfm": "md",
    "ipynb": "ipynb",
}


def load_yaml(path: Path) -> dict:
    """Parse a YAML file into a dict (empty dict if it holds no mapping)."""
    with path.open(encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    return data or {}


def front_matter(qmd_path: Path) -> dict:
    """Return a .qmd file's YAML front matter as a dict (empty if none)."""
    text = qmd_path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    return yaml.safe_load(parts[1]) or {}


def format_keys(format_block) -> list[str]:
    """Return the format names declared in a `format:` block."""
    if isinstance(format_block, dict):
        return list(format_block.keys())
    if isinstance(format_block, str):
        return [format_block]
    return []


def format_output_file(stem: str, fmt: str, doc_format, project_format) -> str:
    """Resolve the output filename a format writes for a page.

    A document-level `output-file` wins over a project-level one; absent both,
    the format writes `<stem>.<default-ext>`.
    """
    for source in (doc_format, project_format):
        if isinstance(source, dict):
            entry = source.get(fmt)
            if isinstance(entry, dict) and entry.get("output-file"):
                return str(entry["output-file"])
    return f"{stem}.{DEFAULT_EXT.get(fmt, fmt)}"


def collision_reason(qmd_path: Path, project_format) -> str | None:
    """Return why a render-list page's outputs collide, or None if it is safe."""
    doc_format = front_matter(qmd_path).get("format")

    # A document-level `format:` block restricts the page to exactly those
    # formats; without one, the page inherits the project's formats.
    rendered = format_keys(doc_format if doc_format is not None else project_format)
    stem = qmd_path.stem

    outputs: dict[str, list[str]] = {}
    for fmt in rendered:
        out = format_output_file(stem, fmt, doc_format, project_format)
        outputs.setdefault(out, []).append(fmt)

    collisions = {out: fmts for out, fmts in outputs.items() if len(fmts) > 1}
    if not collisions:
        return None

    inherited = "" if doc_format is not None else " (no `format:` block; inherits project formats)"
    detail = "; ".join(
        f"{out} <- {', '.join(sorted(fmts))}" for out, fmts in sorted(collisions.items())
    )
    return f"formats write the same output file{inherited}: {detail}"


def main() -> int:
    repo_root = Path(__file__).resolve().parents[2]
    config = load_yaml(repo_root / WEBSITE_CONFIG)

    project_format = config.get("format", {})
    render_list = config.get("project", {}).get("render", []) or []
    qmd_entries = [entry for entry in render_list if str(entry).endswith(".qmd")]

    offenders: list[tuple[str, str]] = []
    for entry in qmd_entries:
        qmd_path = repo_root / entry
        if not qmd_path.exists():
            offenders.append((entry, "listed in render: but the file does not exist"))
            continue
        reason = collision_reason(qmd_path, project_format)
        if reason is not None:
            offenders.append((entry, reason))

    if offenders:
        print("Render-list pages whose rendered formats collide on an output file:\n")
        for entry, reason in offenders:
            print(f"  - {entry}: {reason}")
        print(
            "\nGive each rendered format a distinct output path -- typically a `format:` "
            "block whose `revealjs` entry sets `output-file: <slug>-slides.html` "
            "(mirroring the sibling appendices), or restrict the page to "
            "`format: {html: default}` if it is HTML-only. See issue #966 / PR #967."
        )
        return 1

    print(f"OK: all {len(qmd_entries)} website render-list pages resolve distinct output files per format.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
