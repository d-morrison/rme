# CLAUDE.md — rme (Regression Models for Epidemiology)

## Project Overview

This is a Quarto-based textbook/lecture-notes R package for Epi 204 at UC Davis.
Content lives in `.qmd` files; chapters include subfiles from `_subfiles/`.
The repo is also an R package (`DESCRIPTION`) using `renv` for reproducible environments.

## Build & Test Commands

```bash
# Render a single chapter (HTML only — do NOT render the full book)
quarto render <chapter.qmd> --to html

# Lint changed R or .qmd files
Rscript -e 'lintr::lint("path/to/file.R")'
Rscript -e 'lintr::lint("path/to/file.qmd")'

# Spell check
Rscript -e 'spelling::spell_check_package()'
```

## Pre-Commit Checklist (MANDATORY)

Before committing any `.qmd`, `.R`, or config file change:

1. Run `quarto render <chapter.qmd> --to html` on each **parent chapter** whose subfiles were edited
2. Run `lintr::lint()` on each changed `.R` / `.qmd` file — fix only issues in code you changed
3. Run `spelling::spell_check_package()` — fix errors you introduced; add technical terms to `inst/WORDLIST`
4. Only commit after all three pass

**CI is not the test. Never rely on CI to catch rendering, lint, or spelling errors.**

## Key Conventions

### File Structure
- Subfiles (`_subfiles/`) must NOT begin with a section heading — place headings in the parent `.qmd`
- Link to `.qmd` source files, not rendered `.html` files
- `_extensions/` is vendored third-party code — do not review or modify it

### Quarto
- Use `{{< slidebreak >}}` instead of `---` for slide breaks
- Default to `#| code-fold: true` for figure/table chunks
- Use div format (`:::{#fig-...}`) for figures and tables, not chunk-option `fig-cap`/`tbl-cap`
- Do not indent `:::` fenced div markers inside lists
- One source line per major phrase in prose — keeps git diffs readable and review easier

### Math Notation
- Use custom macros from `latex-macros/macros.qmd` instead of raw LaTeX
- Key macros: `\E{Y|X=x}`, `\ba`/`\ea`, `\tp{v}`, `\b`, `\g`, `\a`, `\devn(...)`, `\erf{...}`
- Include every intermediate step in derivations — do not skip steps
- Color coding: `\red{...}` for focal/extra terms, `\blue{...}` for shared terms
- **Matrix dimensions**: always verify dimension compatibility for every matrix expression -- dimensions of each operand must be consistent with the operation
- **Annotate matrix dimensions with underbraces** in display math: use `\underbrace{M}_{m \times n}` for each matrix or vector
- **Zero matrices**: never write bare `\mathbf{0}` in a matrix equation -- subscript dimensions: `\mathbf{0}_{m \times n}`
- **Jacobian**: `\deriv{\vb} \vx` where both are p-vectors produces a p × p Jacobian matrix (not a vector)
- Ratios vs. factors:
  - Use the generic `\ratio`/`\ratiof` macro when a ratio's inputs are the **quantities themselves** (the odds, hazards, rates, etc.) — e.g. `\ratio(\odds_1, \odds_2)`, **not** `\ror(\odds_1, \odds_2)` — because the type of ratio is clear from the inputs.
  - Use the type-subscripted ratio macros (`\ror` for odds ratios, `\hazratio`/`\hr` for hazard ratios, `\rateratio`, `\riskratio`, `\prevratio`, `\cuhazratio`, …) only when the inputs are **covariate patterns** (e.g. `\ror(\vx,\vxs)`, `\hr(t\mid\vx:\vxs)`), where the subscript is needed to say which kind of ratio it is.
  - Factors compare **one** covariate pattern to the implicit baseline pattern (e.g. the Cox risk score `\hazfactor(\vx)`); always use the subscripted factor macros (`\hazfactor`, `\oddsfactor`, …; function forms `\hazfactorf`/`\hazff`, …).

### Citations
- Always use BibTeX keys with `@citekey` Pandoc syntax — never plaintext author-date
- Include chapter/page locators: `[@dobson4e, Chapter 7, p. 194]`
- Only cite a page number after verifying it directly from the source PDF

### Content Writing
- Introduce concepts before using them — no forward references
- Factual claims must have a specific citation
- Variable definitions in exercises: use bullet points/table with symbol, meaning, and dataset column
- After every definition or concept, include a concrete example — preferably numerical — to illustrate the abstract idea; use a `{#exm-...}` div

### Pull Requests
- Remove existing review requests immediately when starting work on a PR
- Always merge `main` into the feature branch before pushing — not just before requesting review
- Verify all changed hyperlinks before requesting review
- If any `_subfiles/` were edited, add the "clear freezer" label
- Workflow / `.github/` / CI / infra changes go in their own dedicated PRs — never mix them with book-content PRs

## Workflow Responsibility

You are responsible for fixing failures caused by your changes only.
Do not fix pre-existing lint/spell errors in code you didn't modify.
If a failure is not caused by your changes, document it in the PR description.

## Reporting

When summarizing PRs, issues, workflow runs, or jobs, always include the
GitHub URL alongside the reference (e.g.,
[#897](https://github.com/d-morrison/rme/pull/897), not just "#897").

## External Resources Available in This Session

- `$EPI202_TOKEN` — fine-grained PAT with read access to
  `https://github.com/ucdavis/epi202` (Epi 202 course materials). Use on
  demand to look up content from that repo; see
  `.github/copilot-instructions.md` → "Accessing the private
  `ucdavis/epi202` repository" for usage snippets. If the variable is
  empty, the repo is unavailable for this session.

- `$EPI204_TOKEN` — fine-grained PAT with read access to
  `https://github.com/ucdavis/epi204` (Epi 204 homework and solutions).
  Use on demand to look up homework/solution content from that repo;
  see `.github/copilot-instructions.md` → "Accessing the private
  `ucdavis/epi204` repository" for usage snippets. If the variable is
  empty, the repo is unavailable for this session.
