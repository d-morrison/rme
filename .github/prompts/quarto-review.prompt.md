---
name: quarto-review
description: Review changed Quarto, R, and config work in this repository with a code-review mindset. Use when preparing or checking a PR that touches textbook content, rendering logic, or validation workflow files.
argument-hint: Optionally provide the files, diff, or PR scope to review
---

Review the requested changes
as a Quarto-first code review for this repository.

Scope:

- Prioritize changed `.qmd`, `.R`, `.Rmd`, `.yml`, and `.yaml` files.
- Treat files under `_extensions/` as vendored third-party code.
  Read them for context if needed,
  but do not flag or request changes there.
- Focus on behavior,
  rendering correctness,
  broken links or references,
  math macro misuse,
  and validation gaps.

Review checklist:

1. Check whether edited `_subfiles/` content still belongs under a parent heading
   and avoids headings or references sections inside the subfile itself.
2. Check that links point to source `.qmd` targets,
   not rendered `.html` files.
3. Check citations,
   attribution,
   and locator usage when adapted content or factual claims appear.
4. Check Quarto div usage,
   code-fold choices,
   and whether narrative text incorrectly hard-codes computed values.
5. Check math-heavy edits for required project macros from `latex-macros/macros.qmd`
   and for skipped algebraic steps.
6. Check whether the author ran the required local validation:
   parent-chapter HTML render,
   `lintr`,
   and package spell check.

Output format:

- Findings first,
  ordered by severity,
  with file references.
- Then open questions or assumptions.
- Then a short change summary only if useful.
- If there are no findings,
  say that explicitly
  and note any residual testing gaps.

Base the review on [copilot-instructions.md](../copilot-instructions.md),
[quarto-content.instructions.md](../instructions/quarto-content.instructions.md),
[r-and-config.instructions.md](../instructions/r-and-config.instructions.md),
and [CLAUDE.md](../../CLAUDE.md).