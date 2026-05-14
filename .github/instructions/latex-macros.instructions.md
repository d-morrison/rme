---
applyTo: "latex-macros/**"
description: "Use when editing the latex-macros git submodule or changing shared LaTeX macro definitions used by this repository."
---

# Latex Macros Submodule

- `latex-macros/` is a git submodule,
  not an ordinary repo directory.
  Treat macro edits as shared upstream changes.
- Before adding raw LaTeX in chapter content,
  check whether an existing macro already covers it.
- If a repeatedly used expression needs a new macro,
  add it in the submodule,
  then stage the submodule pointer update in the main repo.
- When pushing macro changes,
  follow the authenticated submodule workflow documented in [SUBMODULE_SETUP.md](../../SUBMODULE_SETUP.md)
  and the repo policy in [copilot-instructions.md](../copilot-instructions.md).

See also:

- [SUBMODULE_SETUP.md](../../SUBMODULE_SETUP.md)
- [latex-macros/macros.qmd](../../latex-macros/macros.qmd)
- [copilot-instructions.md](../copilot-instructions.md)