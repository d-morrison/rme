---
description: Lint R source / .qmd files against .lintr.R
allowed-tools:
  - Bash(Rscript -e 'lintr::lint*')
---

Lint against the repo's `.lintr.R`. For each changed `.R` file run
`Rscript -e 'lintr::lint("path/to/file.R")'`; for a changed `.qmd` with R code, lint the `.qmd` itself. For a full sweep, `Rscript -e 'lintr::lint_dir()'`.

Report issues grouped by file, including:

- File path and line number
- The lint rule violated
- A one-line explanation of how to fix it

Fix only issues your change introduced; do not fix pre-existing lint. If there are no issues, confirm the code is clean.
