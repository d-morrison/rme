---
description: Spell-check the package and report misspellings
allowed-tools:
  - Bash(Rscript -e 'spelling::spell_check*')
---

Run `Rscript -e 'spelling::spell_check_package()'` to check spelling across the package's documentation and content.

Report misspellings grouped by file. Add legitimate technical terms to `inst/WORDLIST` (keep it ASCII-sorted) rather than disabling the check. Fix only misspellings your change introduced. If there are none, say so.
