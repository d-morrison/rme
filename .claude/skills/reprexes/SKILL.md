---
name: reprexes
description: >
  Isolate a technical problem into a minimal reproducible example ("reprex")
  and iterate fixes on that instead of inside the full application. Use when
  debugging a bug whose cause isn't obvious after a first look, when a failure
  only surfaces deep in a large pipeline / app / render, when the full-context
  test loop is slow, or before filing an upstream issue. Invoke explicitly
  with /reprexes.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
---

# reprexes

When a technical problem is hard to pin down, **don't debug it in the full
context of the motivating application.** Extract a minimal, self-contained
reproduction of the phenomenon, iterate candidate fixes on *that* (a fast,
clean loop), then port the working fix back to the real code.

Reference: <https://r4ds.hadley.nz/workflow-help.html#making-a-reprex>.
The payoff is real: often, the act of building a thorough reprex surfaces the
cause on its own — the noise you strip away was hiding it.

## When this fires

- A bug whose cause isn't obvious after a first read of the code.
- A failure that only shows up deep inside a large pipeline, app, or a full
  `quarto render` — where each reproduction attempt is slow.
- Iterating on a fix that's expensive to test in the full context.
- Before asking a human for help or filing an upstream/package issue — a
  reprex is what they'll ask for anyway.

Don't bother for a one-line obvious fix, or a problem you can already see and
test cheaply in place.

## The two requirements

A reprex is only useful if it is BOTH:

1. **Reproducible** — it captures *everything* needed to trigger the
   phenomenon: every `library()` call, and code that creates every object it
   uses. Someone (or a fresh session) can run it cold and see the same thing.
2. **Minimal** — everything unrelated to the phenomenon is stripped out:
   small or built-in data instead of the real dataset, only the lines that
   matter.

The tension between these two is the whole game: include enough to reproduce,
but nothing more.

## Procedure

1. **Hypothesize the minimal trigger.** What is the smallest combination of
   data + operation you believe causes the phenomenon?
2. **Create a standalone scratch file** outside the repo tree (e.g.
   `/tmp/reprex.R`, or a tiny `/tmp/reprex.qmd` for a render bug; on a
   non-Unix machine use `tempfile(fileext = ".R")` / `tempdir()` for a
   portable path). Put in it, in order:
   - the package loads (`library(...)`),
   - the minimal data (see tactics below),
   - the minimal code that triggers the phenomenon, with a comment marking
     where it goes wrong.
3. **Run it in a clean session** and confirm it reproduces. For R, run with
   `Rscript /tmp/reprex.R` (a fresh process — no stale `globalenv()` state
   masking or faking the bug). For a Quarto page, render just that file:
   `quarto render /tmp/reprex.qmd --to html`, not the whole site.
4. **Minimize.** Remove pieces until the phenomenon disappears — the last
   removal that "fixes" it implicates that piece. (Or build up from nothing
   until it appears.) Keep the data as small as it can be while still failing.
5. **Iterate fixes on the reprex**, not the full app. This is the fast loop
   the whole technique exists to create.
6. **Port the fix back** to the real code and verify it there.
7. **Clean up.** Delete the scratch file (it lives in `/tmp`, so it never
   touches the repo). If the bug was subtle, consider promoting the reprex
   into a real regression test (`testthat`) instead of discarding it.

## Minimizing the data

- Prefer a **built-in dataset** (`mtcars`, `mpg`) or a hand-built
  tiny frame over the real data.
- If you must use a slice of real data, serialize the minimal slice with
  `dput()` so the reprex recreates it inline — no external file dependency.
- Shrink to the fewest rows/columns that still show the phenomenon.

## R / Quarto specifics

- In R packages and Quarto projects, reprexes are usually short R snippets or
  a single standalone `.qmd` page. Respect the repo's lint config if the
  reprex code will be ported back.
- The **`reprex` package** (tidyverse, <https://reprex.tidyverse.org/>)
  formats a reprex for sharing: it runs your code in a clean, separate R
  session (via `callr` since reprex 2.0) and emits code **plus actual
  output**.
  Copy the code and call `reprex::reprex()` (reads the clipboard by default),
  or point it at a file with `reprex(input = "/tmp/reprex.R")` (or a
  `tempfile(fileext = ".R")` path on non-Unix machines) — handy from a
  non-interactive CLI session where there's no clipboard. Use it when the
  output is destined for a PR comment or an upstream issue. Useful arguments:
  - `venue =` — output format:
    - `"gh"` — GitHub-flavored Markdown (default)
    - `"so"` / `"ds"` — Stack Overflow / Discourse
    - `"slack"` — Slack message
    - `"r"` — runnable R script with commented output
    - `"html"` — HTML
    - `"rtf"` — rich text for presentations
  - `session_info = TRUE` — append `sessionInfo()` / `sessioninfo::session_info()`,
    so versions travel with the reprex (set this when the bug may be
    version-dependent).
  - `std_out_err = TRUE` — capture stdout/stderr too (e.g. `system()` /
    subprocess or C-level output that doesn't come back as normal R results).
  - `wd =` — set the working directory when the code needs one.
  - Validation bonus: because `reprex()` runs in a fresh session, if it errors
    on a missing object or package, your example wasn't actually
    self-contained — fix that before sharing.

  Companion helpers handle "wild-caught" reprexes (all exported in reprex
  2.x): `reprex_clean()` (strip the `#>` output markers from a rendered/pasted
  reprex, leaving runnable code), `reprex_rescue()` (recover code from
  R-console output with `>`/`+` prompts), and `reprex_invert()` (the inverse
  of `reprex()` — recover the input code from a rendered reprex).
- When the bug might be **version-dependent**, capture `sessionInfo()` (or set
  `session_info = TRUE` above) in the reprex so versions are part of the
  record. If you suspect *stale* packages are the cause,
  `tidyverse::tidyverse_update()` outside the reprex can rule that out — but it
  updates packages, it doesn't
  record versions, so don't put it in the reprex itself.
- Build artifacts (`_site/`, `_freeze/`, `.quarto/`) are common confounders
  for "it renders differently" bugs — a clean standalone render sidesteps
  stale freeze caches.

## Before declaring the reprex good

- A fresh session runs it top-to-bottom and shows the phenomenon (and nothing
  else breaks first).
- It references no object, file, or option it didn't create itself.
- It's as small as you can make it and still reproduce.

## Don't

- Don't paste the entire app/module — that's the opposite of a reprex.
- Don't commit scratch reprex files; keep them in `/tmp` (or `tempdir()` on
  non-Unix machines) or a gitignored scratch path.
- Don't iterate fixes in the slow full-context loop once you have a reprex
  that reproduces.
