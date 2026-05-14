---
applyTo: "**/*.{qmd,Rmd}"
description: "Use when editing Quarto chapters, subfiles, slides, handouts, or math-heavy narrative content in this repository."
---

# Quarto Content

- Treat the parent chapter as the execution target.
  If you edit a file under `_subfiles/`,
  find the including `chapters/*.qmd` file first,
  and run `quarto render chapters/<chapter>.qmd --to html` on that parent.
- Preserve the repo's source formatting style:
  prose and comments are written phrase-by-phrase on separate lines.
- Link to source `.qmd` files,
  not rendered `.html` files.
- Subfiles under `_subfiles/` must not start with a heading,
  and must not contain a references section.
- Prefer Quarto div wrappers for new figures and tables.
  Default figure/table chunks to `#| code-fold: true`
  unless the surrounding explanation needs visible code and output.
- Do not hard-code computed values in narrative text.
  Compute them in a chunk and reference them with inline R.
- For math notation,
  use the macros defined in [latex-macros/macros.qmd](../../latex-macros/macros.qmd)
  instead of raw LaTeX whenever an existing macro fits.

See also:

- [README.md](../../README.md)
- [SUBMODULE_SETUP.md](../../SUBMODULE_SETUP.md)
- [CLAUDE.md](../../CLAUDE.md)
- [copilot-instructions.md](../copilot-instructions.md)