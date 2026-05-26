---
description: Run the R package check suite and report ERRORs/WARNINGs/NOTEs
allowed-tools:
  - Bash(Rscript -e 'devtools::check*')
---

Run `Rscript -e 'devtools::check()'` to run the full R package check suite.

Report any ERRORs, WARNINGs, or NOTEs grouped by severity. For each issue explain what it means and suggest a fix. If the check passes cleanly, say so.
