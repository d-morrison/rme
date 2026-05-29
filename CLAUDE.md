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
- Use `\eqdef` instead of `=` for the defining equation in any `{#def-...}` div
- Include every intermediate step in derivations — do not skip steps
- Color coding: `\red{...}` for focal/extra terms, `\blue{...}` for shared terms

### Citations
- Always use BibTeX keys with `@citekey` Pandoc syntax — never plaintext author-date
- Include chapter/page locators: `[@dobson4e, Chapter 7, p. 194]`
- Only cite a page number after verifying it directly from the source PDF

### Content Writing
- Introduce concepts before using them — no forward references
- Factual claims must have a specific citation
- Variable definitions in exercises: use bullet points/table with symbol, meaning, and dataset column
- After every definition or concept, include a concrete example — preferably numerical — to illustrate the abstract idea; use a `{#exm-...}` div
- Never use "above" or "below" to refer to content — cross-reference with `@label` syntax instead
- For cross-page cross-references (labels in a different chapter), use direct markdown links `[text](chapter.qmd#label)` — Quarto `@label` syntax only resolves within the same page
- Always add a noun phrase after "This", "That", and "Those" to clarify the referent (e.g., "This estimator", not "This")

### Pull Requests
- Remove existing review requests immediately when starting work on a PR
- Ensure branch is up to date with `main` before requesting review
- Verify all changed hyperlinks before requesting review
- If any `_subfiles/` were edited, add the "clear freezer" label

## Workflow Responsibility

You are responsible for fixing failures caused by your changes only.
Do not fix pre-existing lint/spell errors in code you didn't modify.
If a failure is not caused by your changes, document it in the PR description.

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
