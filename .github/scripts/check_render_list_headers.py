#!/usr/bin/env python3
"""Guard the website render list against the revealjs/HTML output-file collision.

Every page in the ``render:`` list of ``_quarto-website.yml`` is rendered to the
project's formats. The ``html`` format writes ``<stem>.html`` and the
``revealjs`` format defaults its output to the *same* ``<stem>.html``. When a
page is rendered to both without giving revealjs a distinct ``output-file``,
Quarto's project move fails with

    rename '.../<stem>.html' -> '_site/.../<stem>.html': No such file

and the publish workflow dies (see issue #966 / PR #967). ``publish.yml`` only
runs on push to ``main``, so a header-less page sails through PR CI and breaks
the site after merge -- this check catches it on the PR instead.

A render-list page is collision-safe when it does **not** render both ``html``
and ``revealjs`` with a bare revealjs output. Concretely, a page is flagged when:

* it declares no ``format:`` block -- it inherits the project formats (which
  include both ``html`` and ``revealjs``), so revealjs collides; or
* its effective formats include both ``html`` and ``revealjs`` and that
  revealjs entry carries no ``output-file``.

Exit status is 1 (with a per-file report) if any page is unsafe, 0 otherwise.
"""

from __future__ import annotations

import sys
from pathlib import Path

import yaml

WEBSITE_CONFIG = "_quarto-website.yml"


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


def revealjs_has_output_file(format_block) -> bool:
    """True when the `revealjs` entry in a format block sets `output-file`."""
    if not isinstance(format_block, dict):
        return False
    revealjs = format_block.get("revealjs")
    return isinstance(revealjs, dict) and "output-file" in revealjs


def collision_reason(qmd_path: Path, project_format) -> str | None:
    """Return why a render-list page would collide, or None if it is safe."""
    doc_format = front_matter(qmd_path).get("format")

    # No document-level `format:` block -> the page inherits the project
    # formats, which pair html with a bare revealjs.
    if doc_format is None:
        if {"html", "revealjs"} <= set(format_keys(project_format)):
            return "no `format:` block, so it inherits the project's html+revealjs (revealjs writes <stem>.html)"
        return None

    # Document declares its own formats -> it renders exactly those.
    keys = set(format_keys(doc_format))
    if {"html", "revealjs"} <= keys and not revealjs_has_output_file(doc_format):
        return "renders both html and revealjs but revealjs has no `output-file`"
    return None


def main() -> int:
    repo_root = Path(__file__).resolve().parents[2]
    config_path = repo_root / WEBSITE_CONFIG
    config = load_yaml(config_path)

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
        print("Render-list pages with an unsafe (colliding) format header:\n")
        for entry, reason in offenders:
            print(f"  - {entry}: {reason}")
        print(
            "\nGive each flagged page a `format:` block whose `revealjs` entry sets a "
            "distinct `output-file` (e.g. `<slug>-slides.html`), mirroring the sibling "
            "appendices, or restrict it to `format: {html: default}` if it is HTML-only. "
            "See issue #966 / PR #967."
        )
        return 1

    print(f"OK: all {len(qmd_entries)} website render-list pages have collision-safe format headers.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
