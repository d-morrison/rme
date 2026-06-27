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
- Aim to keep `.qmd` source files under ~100 lines; split longer files into named subfiles in `_subfiles/`
- `_extensions/` is vendored third-party code — do not review or modify it
- New book pages must be wired into each render profile that should include them — the profiles keep independent page lists, so a page added to only one is missing from the others:
  - `_quarto-website.yml` — the default profile (`profile.default: website` in `_quarto.yml`): add to the `render:` list, and to the navbar if it's a primary/navigable chapter (supplemental pages like appendices can stay in `render:` without a navbar entry)
  - `_quarto-book.yml` — the book/PDF TOC: add to `book.chapters:` (directly or inside a `part:` grouping)
  - `_quarto-handout.yml` — a curated PDF-handout subset with its own `render:` list; add the page here too if it belongs in the handouts

### Quarto
- Use `{{< slidebreak >}}` instead of `---` for slide breaks
- Add `{{< slidebreak >}}` immediately before every theorem-type div (`#thm-`, `#lem-`, `#cor-`, `#prp-`, `#cnj-`, `#def-`, `#exm-`, `#exr-`, `#rem-`)
- When a subfile begins with a theorem-type div, put the preceding `{{< slidebreak >}}` in the **parent** file (before the `{{< include >}}`), not inside the subfile
- Default to `#| code-fold: true` for figure/table chunks
- Use div format (`:::{#fig-...}`) for figures and tables, not chunk-option `fig-cap`/`tbl-cap`
- Do not indent `:::` fenced div markers inside lists
- One source line per major phrase in prose — keeps git diffs readable and review easier
- **Theorem-div headings** (`:::{#exm-...}`, `:::{#def-...}`, etc.): use `####` (level 4) or deeper for the name heading inside the div — using `##` or `###` creates numbered section headings that disrupt document structure and break example/definition numbering.

### Cross-references
- **Within-chapter** (`@id`): use Pandoc `@id` syntax for any element in the same rendered `.html` file — includes the parent chapter and all its `{{< include >}}`d subfiles.
- **Cross-chapter** (`other-chapter.qmd`): this is a Quarto `website` project (not `book`), so `@id` does **not** resolve across `.html` files. For elements in other chapters use an explicit relative link: `[text](other-chapter.qmd#id)`.

### Math Notation
- Use custom macros from `latex-macros/macros.qmd` instead of raw LaTeX
- Key macros: `\E{Y|X=x}`, `\ba`/`\ea`, `\tp{v}`, `\b`, `\g`, `\a`, `\devn(...)`, `\erf{...}`
- Include every intermediate step in derivations — do not skip steps
- Color coding: `\red{...}` for focal/extra terms, `\teal{...}` for shared terms (use `\teal`, not `\blue` — `\teal` reads better in dark mode)
- **Matrix dimensions**: always verify dimension compatibility for every matrix expression -- dimensions of each operand must be consistent with the operation
- **Annotate matrix dimensions with underbraces** in display math: use `\underbrace{M}_{m \times n}` for each matrix or vector
- **Zero matrices**: never write bare `\mathbf{0}` in a matrix equation -- subscript dimensions: `\mathbf{0}_{m \times n}`
- **Jacobian**: `\deriv{\vb} \vx` where both are p-vectors produces a p × p Jacobian matrix (not a vector)
- Estimators of vector estimands: the estimator symbol (e.g. `\hat`) goes
  on top of the vector symbol, not inside it — write `\hat{\vec{\mu}}`, not
  `\vec{\hat\mu}`. (Same for `\bar`, `\tilde`, etc.) Use `\vec{}` or `\vecf{}`,
  **not** `\v{}`: `\v` is a LaTeX built-in (the caron accent), so
  `\providecommand{\v}{...}` in `macros.qmd` is a no-op and `\hat{\v{\mu}}`
  renders as a broken red `\v` in MathJax.
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
- After every definition or concept, include a concrete example — preferably numerical — to illustrate the abstract idea; use a `{#exm-...}` div; if a counterexample is feasible, include one immediately after the example
- After every theoretical claim (thm, cor, lem): when a proof is feasible and in scope, (1) immediately follow with a proof, then (2) immediately follow with an example utilizing the claim; when a proof is non-elementary or out of scope (e.g., `@thm-fubini`, `@thm-fubini-tonelli`), omit the proof block and proceed directly to the example
- Always arrange divs and sections so that related items are adjacent: theorem → proof → example(s) → counterexample(s)
- Clearly distinguish **model structure** (how the data relate to the parameters — distributional family, link function, random effects, hierarchies, …) from **inference method** (how the parameters are estimated — MLE, Bayes, GEE, method of moments, …). The two are orthogonal: any model structure can be paired with any compatible inference method (e.g. a random-effects model can be fit by maximum likelihood *or* by Bayesian MCMC). Never write as if a structure belonged to one inference paradigm (avoid e.g. "the Bayesian version of random effects"); instead name the inference method being applied to the structure.

### Pull Requests
- Remove existing review requests immediately when starting work on a PR
- Always merge `main` into the feature branch when starting or resuming work on it
- Merge `main` again before pushing — not just before requesting review
- Verify all changed hyperlinks before requesting review
- If any `_subfiles/` were edited, add the "clear freezer" label
- Workflow / `.github/` / CI / infra changes go in their own dedicated PRs — never mix them with book-content PRs
- This checkout is often shared by concurrent agent sessions — the branch can switch under you, and commits land on PR branches from other sessions or the `@claude` bot. Work in an isolated `git worktree`: for **new** work `git worktree add -b <branch> <dir> origin/main`; to **resume** an existing PR branch `git worktree add -B <branch> <dir> origin/<branch>` (uppercase `-B` so it resets to the remote even if the local branch already exists; the `origin/<branch>` start point picks up the PR rather than starting a fresh branch from `main`). Then run `git submodule update --init` in the new worktree. Before every push, `git fetch` and reconcile `origin/<branch>` (merge or rebase) — another session may have already pushed the same change
- After opening (or when asked to watch) a PR, subscribe to its activity and keep watching until it is merged or closed: confirm CI results, surface review comments, and catch merge conflicts; re-arm a periodic check-in and only ping when something needs the author. Stop immediately if the author asks you to back off.
- **Do not wait indefinitely for CI or review jobs.** When monitoring a PR, if a check has been `in_progress` for more than 5–10 minutes without completion, investigate immediately: check job logs for errors, look for blockers, and either fix issues or report what's stuck. Do not passively wait for slow or hung jobs to finish.

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
