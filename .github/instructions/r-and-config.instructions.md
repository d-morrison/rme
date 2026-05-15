---
applyTo: "**/*.{R,r,yml,yaml}"
description: "Use when editing R source, Quarto configuration, or GitHub workflow files in this repository."
---

# R And Config Work

- This repo is both a Quarto project and an R package using `renv`.
  Check [DESCRIPTION](../../DESCRIPTION),
  [_quarto.yml](../../_quarto.yml),
  and the relevant workflow file before changing package, render, or CI behavior.
- For changed `.R` files,
  run `Rscript -e 'lintr::lint("path/to/file.R")'`.
  For changed `.qmd` files with R code,
  lint the `.qmd` file itself.
- If your change affects rendering,
  render only the touched parent chapter in HTML,
  not the full book.
- Run `Rscript -e 'spelling::spell_check_package()'`
  before finishing changes to `.R`, `.qmd`, or config files.
  Fix only errors you introduced.
- Workflow and render changes must account for repo-specific dependencies.
  JAGS-backed content and `renv` setup are already wired into existing workflows;
  align with those patterns instead of inventing parallel setup.

See also:

- [DESCRIPTION](../../DESCRIPTION)
- [_quarto.yml](../../_quarto.yml)
- [CLAUDE.md](../../CLAUDE.md)
- [lint-changed-files.yaml](../workflows/lint-changed-files.yaml)
- [preview.yml](../workflows/preview.yml)
- [copilot-instructions.md](../copilot-instructions.md)