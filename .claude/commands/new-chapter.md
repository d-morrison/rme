---
description: Scaffold a new chapter in the book
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(quarto render *)
---

Create a new chapter from `$ARGUMENTS` (e.g. `/new-chapter ridge Ridge Regression`).

First, parse `$ARGUMENTS`: the first whitespace-delimited token is the **slug** (the filename, no `.qmd`); everything after the first space is the **title** (default the title to the slug if none is given).

Steps:

1. Create `chapters/<slug>.qmd` with YAML frontmatter holding just `title:` (set to the title). Do NOT set `date:` — the book sets `date: last-modified` globally, and a per-page `date:` would override it. Do NOT add a top-level `#` heading in the body — Quarto renders the frontmatter `title:` as the page heading.
2. Register the chapter in the `book.chapters:` list in `_quarto-book.yml` at a logical position (read the file first). If it belongs to an existing `part:`, nest it under that part. **Also** add an entry to the appropriate navbar dropdown (`Chapters` or `Appendices`) in `_quarto-website.yml`, and ensure the file is in the `render:` list. The navbar is NOT auto-generated from `_quarto-book.yml` -- manual addition is required. Finally, add the page to the `render:` list in `_quarto-handout.yml` **if** it belongs in the handout PDF subset (omit supplemental or HTML-only pages such as interactive-diagram appendices).
3. If the chapter is long, you may split content into includes under `chapters/_subfiles/<slug>/`. Subfiles must NOT start with a heading and must NOT contain a references section.
4. Confirm it renders: `quarto render chapters/<slug>.qmd --to html`.
5. If the chapter contains `def`/`thm`/`lem`/`cor`/`prp` callout divs,
   re-run `Rscript data-raw/callout-graph.R` to refresh
   `inst/extdata/callout-graph.rds` and keep the concept map current.

Style rules (see `.github/instructions/`):

- Blank line before every bullet list
- Chunk options via `#|` directives, not inline `r, opt = val`
- Link to source `.qmd` files, not rendered `.html`
- Use the project's math macros instead of raw LaTeX where one fits
