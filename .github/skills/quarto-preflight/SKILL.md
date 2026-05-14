---
name: quarto-preflight
description: Run the required local Quarto validation workflow for changed chapters, subfiles, R files, and config files in this repository. Use when preparing a Quarto or R change for review.
argument-hint: Optionally provide changed file paths or a chapter path to validate
---

Run the repo's local preflight checks
for Quarto, R, and config changes.

This skill automates the required validation order.
It should summarize failures clearly
and stop short of broad unrelated cleanup.

Validation order:

1. Identify the changed files.
   Use user-provided paths when available.
   Otherwise use the active file
   or inspect nearby changed files if the task context names them.
2. Map changed `_subfiles/` files
   to their parent `chapters/*.qmd` files.
   Render the parent chapters,
   not the subfiles.
3. Run `quarto render <chapter>.qmd --to html`
   on each affected parent chapter.
   Review the output for errors and warnings.
   Call out math, missing resource, link, and deprecated-syntax warnings explicitly.
4. Run `Rscript -e 'lintr::lint("path/to/file")'`
   on each changed `.R` file
   and each changed `.qmd` file with R code.
   Fix only issues introduced by the current change.
5. Run `Rscript -e 'spelling::spell_check_package()'`.
   Fix only spelling issues introduced by the current change.
   Add legitimate technical terms to `inst/WORDLIST` if needed.
6. Summarize the outcome as:
   - passed checks
   - warnings that were fixed
   - warnings or failures still blocking review

Behavior rules:

- Never render the full book unless the user explicitly asks for it.
- Prefer the smallest file set that satisfies the repo policy.
- Do not fix unrelated pre-existing failures.
- If a check fails outside the changed scope,
  say why it appears pre-existing.

See [copilot-instructions.md](../../copilot-instructions.md),
[quarto-content.instructions.md](../../instructions/quarto-content.instructions.md),
and [r-and-config.instructions.md](../../instructions/r-and-config.instructions.md)
for repo-specific expectations.