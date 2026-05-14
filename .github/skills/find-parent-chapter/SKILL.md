---
name: find-parent-chapter
description: Find the parent chapter for a changed Quarto subfile and print the exact HTML render command to run. Use when working in `_subfiles/` or when you need the owning `chapters/*.qmd` file.
argument-hint: Optionally provide a subfile path or chapter-related path to resolve
---

Resolve a changed content file
to the parent chapter that includes it.

This skill is for repo-specific Quarto routing,
not content editing.
If the user gives a file under `_subfiles/`,
find every `chapters/*.qmd` file that includes it,
then report the parent chapter path
and the exact command:

`quarto render chapters/<chapter>.qmd --to html`

Workflow:

1. Determine the target path.
   Use the user-provided path if present.
   Otherwise use the active file.
2. If the target is already a parent chapter under `chapters/`,
   report that directly and print the same HTML render command.
3. If the target is under `_subfiles/`,
   search for literal include lines of the form:
   `{{< include _subfiles/... >}}`
   inside `chapters/*.qmd`.
4. If exactly one parent chapter matches,
   return:
   - the parent chapter path
   - the render command
   - a brief note that local validation should run on the parent chapter, not the subfile
5. If multiple parents match,
   list all matches and tell the user to render each relevant parent.
6. If no parent chapter matches,
   say that explicitly and suggest checking nested includes in nearby `.qmd` files.

Keep the response compact.
Do not start editing content.
See [quarto-content.instructions.md](../../instructions/quarto-content.instructions.md)
and [copilot-instructions.md](../../copilot-instructions.md)
for the underlying repo policy.