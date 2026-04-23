# GitHub Copilot Instructions

> [!IMPORTANT]
> **MANDATORY TESTING BEFORE EVERY COMMIT:**
> 
> Before committing ANY changes to `.qmd`, `.R`, or config files:
> 
> 1. **Run `quarto render` on the FULL repository** (not individual files)
> 2. **Verify it completes successfully** (exit code 0, no errors)
> 3. **Run linter on changed files**:
>    - For R files: `lintr::lint("path/to/file.R")`  
>    - For .qmd files with R code: Extract and lint R code chunks
>    - **Fix lint issues in code you wrote or modified** - ignore pre-existing issues in unchanged code
> 4. **Run spellcheck**: `spelling::spell_check_package()`
>    - **Fix spelling errors you introduced** - ignore pre-existing errors
>    - Add technical terms to `inst/WORDLIST` if needed (create file if it doesn't exist, one word per line)
> 5. Only then commit your changes
>
> **CRITICAL RULES:**
> - **CI is NOT the test** - you must test locally BEFORE pushing
> - **NEVER rely on CI to discover rendering, lint, or spelling errors** - that's your job
> - **ALWAYS run full `quarto render`** - testing individual files is insufficient
> - **Only fix lint/spell issues in code YOU changed** - don't fix unrelated pre-existing issues
> - **This is a hard requirement - no exceptions, no excuses**

## General Development Principles

**CRITICAL**: Do not make assumptions about what code will do - always test it yourself.

- **Test your changes**: Run the actual commands to verify functionality
- **Run `quarto render` on FULL repository**: Testing individual files misses cross-file issues
- **Verify output**: Check that expected files are created with correct content
- **Never claim success without evidence**: Only report that something works after you've confirmed it yourself

## Pull Request Guidelines

- Always ensure that PR branch is up to date with main branch before requesting PR review
- **ALWAYS verify all changed hyperlinks are correct before requesting PR review**:
  - Check that internal links point to existing files/sections
  - Verify external URLs are accessible and correct
  - Test cross-references and anchor links
  - Ensure relative paths are correct

## Linking Within the Quarto Website

When linking to other pages within this Quarto website, always link to the **source `.qmd` file**, not the rendered `.html` file.
This follows the [Quarto website linking guidelines](https://quarto.org/docs/websites/#linking).

**Correct** (link to source file):
```markdown
[chain rule](math-prereqs.qmd#thm-chain-rule)
```

**Incorrect** (link to rendered HTML):
```markdown
[chain rule](math-prereqs.html#thm-chain-rule)
```

This ensures links work correctly across all output formats and during local development.

## Decomposing content into subfiles

When splitting a chapter or formula sheet into include subfiles,
keep the top-level section headers in the main `.qmd` file.
Move only the section body content into the subfile.
This keeps document structure visible in the parent file
and makes partial includes easier to compose consistently.

## Citation Grammar Conventions

When using Pandoc-style citation keys (e.g., `@dobson4e`) as the grammatical subject of a sentence,
treat the citation as a **singular** subject and use third-person singular verb forms:

- **Correct**: `@dobson4e omits … but describes …`
- **Incorrect**: `@dobson4e omit … but describe …`

This applies whether the citation refers to one author or multiple authors (e.g., "Dobson and Barnett").
Pandoc renders `@dobson4e` as a noun phrase (e.g., "Dobson and Barnett (2018)"),
but grammatically the citation key itself is treated as a singular pronoun/name.

## Attribution for Adapted Content

When adapting any content from another source,
always include specific attribution in the chapter text.
Use a BibTeX-backed citation key
with a chapter or page locator
(for example, `[@dobson4e, Chapter 7]` or `[@vittinghoff2e, p. 194]`).
Do not use generic acknowledgements without locators
or plaintext author-title references
when a BibTeX citation is available.

## Code Formatting Guidelines

When adding or editing text in source code (such as comments, documentation strings, or error messages) or in Quarto document text chunks:
- Add a newline at the end of every phrase or logical unit of text
- Each phrase should be on its own line in the source code
- A phrase is typically a complete thought, clause, or sentence
- This improves readability and makes diffs clearer

## Parentheticals and Asides in Quarto

When parenthetical references or short asides are supplementary
(for example, `c.f. @dunn2018generalized §2.10.3`),
place them in a `::: notes` div
instead of leaving them inline in the main narrative.

## Fenced Divs and List Indentation in Quarto

Do not indent `:::` fenced div markers
as if they were list-continuation content.
In this project,
indented fenced div markers can render as literal `:::`
instead of being parsed as div blocks.

When you need a notes/callout div related to a list item,
end the list first,
then start the div at the left margin
with blank lines around the fenced block.

Example:
```r
# Good: Each instruction on its own line
# First, check if the input is valid.
# Then, process the data.
# Finally, return the result.

# Avoid: Multiple phrases on one line
# First, check if the input is valid. Then, process the data. Finally, return the result.
```

## Quarto Code Chunk Options

When the code **and** its console output are both needed for the surrounding narrative to make sense, use `#| code-fold: false` so that neither is hidden:

```qmd
```{r}
#| code-fold: false
deviance(my_model)
sum(residuals(my_model)^2)
```
```

Use `code-fold: false` whenever:
- The output value is referenced or explained in the surrounding text
- The reader needs to see both the code and the result to follow the argument

## Landscape Tables in PDF

When a table is too wide for portrait orientation in PDF,
wrap the table div in a `.landscape` fenced div.

Use this pattern:

```qmd
::: {.landscape}

:::{#tbl-your-wide-table}
... table content ...
:::

:::
```

Apply this only where needed,
so HTML and RevealJS output stay unchanged.

## Math Notation

This repository uses custom LaTeX macros defined in `latex-macros/macros.qmd` (a git submodule).
Always use the custom macros instead of raw LaTeX equivalents.

Key macros to use:
- **Expectation operator**: Use `\E{Y|X=x}` (renders as $\text{E}[Y|X=x]$), **not** raw `E[Y|X=x]`
- **Aligned equations**: Use `\ba` / `\ea` for `\begin{aligned}` / `\end{aligned}`
- **Greek letters**: Use `\b` for $\beta$, `\g` for $\gamma$, `\a` for $\alpha$
- **Formatting**: Use `\red{...}` and `\blue{...}` for colored text in math
- **Deviation/error notation**: Use `\erf{...}` for deviations of estimates/estimators from their estimands; use `\devn(...)` for all other deviations (e.g., observations from population means)

matrix-product helper macros:

- `\iprod{u}{v}` for inner products (`\tp{u} v`)
- `\oprod{u}{v}` for outer products (`u \tp{v}`)
- `\siprod{u}` for self-inner products (`\tp{u} u`)
- `\soprod{u}` for self-outer products (`u \tp{u}`)

Residual and deviation helper macros include:

- `\err` is deprecated; prefer `\devn(...)` for new non-estimation deviations while legacy uses are being phased out
- `\erf{\theta}` for estimate/estimand deviations
- `\devn(...)` for other deviations
- `\resid` for residual symbols (`r`)
- `\stdresid` for standardized residual symbols (`r'`)
- `\modresid` for modified residual symbols (`r^*`)

- **Transpose**: Use `\tp{v}` (renders as $v'$) instead of the raw prime `v'` notation.
  However, `\tp{v}` appends `^{\top}` to the argument, so if the argument already carries a superscript
  (e.g., `\vxs` expands to `{{\vec{x}^*}}` which has `^*`), wrap it in parentheses first:
  use `\tp{(\vxs)}` not `\tp{\vxs}`.
  This avoids LaTeX "Double superscript" errors.

Always check `latex-macros/macros.qmd` for available macros before writing raw LaTeX.

## Color Coding Strategy for Math Expressions

Use `\red{...}` and `\blue{...}` purposefully and consistently to help readers:

1. **Focal coefficient**: Use `\red{...}` for the coefficient being interpreted or derived in the current context.
   This draws the reader's eye to the quantity that the surrounding text is about.
   Example: When deriving that $\b_A$ is the slope, color it `\red{\b_A}` throughout the derivation.

2. **Differences between similar expressions**: When comparing two expressions that differ in certain components,
   use `\red{...}` for the unique/extra term and `\blue{...}` for the shared term.
   This makes it visually clear what cancels and what remains.
   Example: Male slope $= \blue{\b_A} + \red{\b_{AM}}$, female slope $= \blue{\b_A}$,
   difference $= \blue{\b_A} + \red{\b_{AM}} - \blue{\b_A} = \red{\b_{AM}}$.

3. **Reference level constraints**: In models with interactions, coefficient interpretations are constrained
   to a specific reference level of other covariates.
   Use `\red{0}` (or `\red{P = 0}`, `\red{A = 0}`, etc.) to highlight reference levels that constrain an interpretation.
   Use `\blue{m}` (or the generic variable name) when the interpretation holds for any value.
   This visually distinguishes interaction models (constrained) from additive models (unconstrained).

4. **Chain rule components**: When applying the chain rule, use `\red{...}` for the first factor
   and `\blue{...}` for the second factor.
   This connects the factored form to the simplified form on the next line.

5. **Connected components across equations**: When a term is defined in one equation and expanded
   or substituted in another, use the same color for the term and its expansion.
   This creates a visual link between the definition and its use.

## Math Derivations

Include as many intermediate steps as possible in math derivations.
Every non-trivial algebraic manipulation should be shown explicitly on its own line inside an aligned equation.
Do not skip steps even if they seem obvious.
This helps readers follow the logic and makes errors easier to spot.

## CI/CD Workflow Debugging

When investigating CI/CD failures (build, test, or lint workflow issues):

1. **Use GitHub MCP tools to inspect job logs directly**:
   - **ALWAYS read workflow logs directly** using GitHub MCP tools (`github-mcp-server-get_job_logs`, `github-mcp-server-list_workflow_runs`)
   - Do NOT rely on assumptions or generic troubleshooting - examine the actual error output
   - Use `list_workflow_runs` to see recent workflow runs and their status
   - Use `get_job_logs` with `failed_only=true` and `return_content=true` to retrieve logs from failed jobs
   - These tools provide direct access to workflow run details and logs without needing to manually check GitHub UI

2. **Running lintr locally**:
   - You can run `lintr` yourself using R to verify linting issues
   - Ensure all required packages are installed before running the linter
   - The lint workflow configuration is in `.github/workflows/lint-changed-files.yaml`

### Fixing Lint Workflow Failures Due to Missing Packages

If the lint workflow fails with errors like "Could not find exported symbols for package X":

1. **Check if the package is already in DESCRIPTION**:
   - Look in `Imports:` or `Suggests:` sections
   - If it's in `Suggests:`, it won't be installed by default in CI

2. **Preferred solution**: Ensure the lint workflow installs all dependencies:
   - Use `dependencies: '"all"'` in `setup-r-dependencies` to install both `Imports` and `Suggests`
   - This is better than manually listing packages in the workflow

3. **Install system dependencies if needed**:
   - Some R packages require system libraries (e.g., `rjags` requires JAGS)
   - Add a step before `setup-r-dependencies` to install system packages
   - Example: `sudo apt-get update && sudo apt-get install -y jags`

4. **Alternative**: Move the package from `Suggests` to `Imports` if it's truly required for the package to function

## R Package Management

This repository uses `renv` for reproducible R package environments:

- Package versions are locked in `renv.lock`
- All workflows use `r-lib/actions/setup-renv@v2` for dependency installation
- CI dependencies (gh, lintr, purrr, pkgdown) are listed in DESCRIPTION Suggests

## System Dependencies

Some R packages require system-level libraries to compile from source:
- `curl` package requires `libcurl4-openssl-dev`
- `png` package requires `libpng-dev`
- `jpeg` package requires `libjpeg-dev`
- `systemfonts` package requires `libfontconfig1-dev`
- Consider using `rocker/verse` Docker image for workflows to reduce installation requirements

## JAGS Dependencies

This repository uses JAGS (Just Another Gibbs Sampler) for Bayesian analysis:
- JAGS must be installed in workflows that render Quarto documents (using `sudo apt-get install -y jags`)
- R packages `rjags` and `runjags` depend on JAGS being installed
- The lint workflow also needs these packages installed to avoid false positives

## Computer Algebra Systems (CAS)

The Copilot environment includes two computer algebra systems for symbolic mathematics.
Use them to verify or derive formulas, derivatives, integrals, and algebraic simplifications
when working on the mathematical content in this repository.

### SymPy (Python)

SymPy is available as `python3 -c "import sympy; ..."` or in a Python script.
It supports symbolic differentiation, integration, equation solving, simplification, and LaTeX output.

```python
from sympy import symbols, diff, integrate, simplify, solve, latex, exp, log

x, mu, sigma = symbols('x mu sigma', real=True)

# Differentiate the normal log-likelihood with respect to mu
log_lik = -((x - mu)**2) / (2 * sigma**2)
score = diff(log_lik, mu)
print(score)          # (x - mu) / sigma**2
print(latex(score))   # \frac{x - \mu}{\sigma^{2}}
```

Common SymPy operations:
- `diff(expr, x)` — symbolic derivative
- `integrate(expr, x)` — symbolic integral
- `solve(expr, x)` — solve equation for x
- `simplify(expr)` — algebraic simplification
- `latex(expr)` — convert to LaTeX string for use in `.qmd` files
- `factor(expr)` / `expand(expr)` — factor or expand polynomials

### Maxima

Maxima is available from the shell as the `maxima` command.
It is a full-featured CAS with strong support for calculus and algebra.

```bash
# Single expression (non-interactive)
echo "diff(x^3 + 2*x^2 - x - 2, x);" | maxima --very-quiet

# Multi-step batch computation saved to a file
cat > /tmp/cas_check.mac << 'EOF'
expr: x^3 + 2*x^2 - x - 2;
factor(expr);
diff(expr, x);
integrate(expr, x);
EOF
maxima --very-quiet --batch=/tmp/cas_check.mac
```

### When to use CAS tools

- **Verifying derivations**: Check that hand-derived formulas match CAS output before including them in documents.
- **Generating LaTeX**: Use `sympy.latex()` to produce correct LaTeX for complex expressions.
- **Solving equations**: Use `sympy.solve()` or Maxima's `solve()` to find closed-form solutions.
- **Simplifying expressions**: Use `sympy.simplify()` or Maxima's `ratsimp()` to confirm algebraic equivalences.

## Quarto Rendering

**CRITICAL REQUIREMENTS** before requesting code review:

1. **Run `quarto render` yourself locally** on the full repository and ensure it passes
2. **Verify it completes successfully** (exit code 0, no errors)
3. **Do NOT rely solely on CI workflows** to catch rendering issues
4. **Test the actual command and wait for completion** - do not assume success
5. **Check exit code to confirm success** - partial output doesn't count
6. **If quarto render fails locally**, investigate and fix the issue before pushing changes

**What "successful rendering" means**:
- The command completes without errors (exit code 0)
- All expected output files are generated
- No error messages in the output
- All documents render correctly (check for missing images, broken math, etc.)

**Common mistakes to avoid**:
- Testing individual files only (use `quarto render` for full repository)
- Not waiting for the command to complete
- Assuming success without checking the exit code
- Claiming "it works" without actually running the command
- Relying on CI to catch rendering issues

This ensures all dependencies are properly configured and all documents render successfully.

## Linting

**CRITICAL**: Always lint changed files before requesting code review and before committing.

```r
# Lint R code files you modified
lintr::lint("path/to/modified/file.R")

# Lint Quarto documents (lints R code chunks)
lintr::lint("path/to/modified/file.qmd")

# Lint all R files in the repository (use sparingly)
lintr::lint_dir()
```

**When to lint**:
- Before calling the `code_review` tool
- After making changes to R files (`.R`) or Quarto documents (`.qmd`)
- Before committing code changes

**Linting workflow for changed files**:
1. Identify which files you've changed
2. For `.R` files: Run `lintr::lint("filename.R")` on each changed file
3. For `.qmd` files: Run `lintr::lint("filename.qmd")` on each changed file to lint R code chunks
4. Fix any linting errors or warnings
5. Only then proceed to code review

**Important notes**:
- **Only fix lint issues in code you wrote or modified** - do not fix pre-existing issues in unchanged code
- If lint errors exist in code you didn't change, ignore them - they're not your responsibility
- The lint-changed-files workflow will flag issues, but you should catch them locally first

## Spell Checking

**CRITICAL**: Always run spellcheck locally BEFORE committing.

```r
# Run spell check on the entire repository
spelling::spell_check_package()

# Check specific files
spelling::spell_check_files("README.md")
spelling::spell_check_files("path/to/modified/file.qmd")
```

**Spell checking workflow**:
1. Identify which files you've changed
2. Run `spelling::spell_check_package()` to check all documentation
3. Review any spelling errors found
4. Either fix the spelling errors OR add legitimate technical terms to `inst/WORDLIST` (create this file if it doesn't exist, one word per line)
5. Re-run spell check to verify all errors are resolved
6. Only then proceed to code review or commit

**Important notes**:
- **Only fix spelling errors you introduced** - ignore pre-existing errors in unchanged files
- Add legitimate technical terms (e.g., "renv", "Bayesian", "MCMC") to `inst/WORDLIST`
- Don't add typos to the wordlist - fix the typos instead

## Code Review Workflow

**MANDATORY ORDER OF OPERATIONS** before finalizing a pull request:

1. **Lint changed files FIRST**
   - Run `lintr::lint()` on all changed `.R` and `.qmd` files
   - Fix any linting errors or warnings
   - See the "Linting" section above for detailed commands

2. **Run spellcheck**
   - Run `spelling::spell_check_package()`
   - Fix spelling errors you introduced or add legitimate terms to `inst/WORDLIST`

3. **Then request code review**
   - Use the `code_review` tool to get automated feedback
   - The tool must be called AFTER linting and spellcheck are complete
   - Review and address any valid comments from the code review

4. **Finally run security checks**
   - Use the `codeql_checker` tool after code review
   - Address any security vulnerabilities found
   - Re-run if you make significant changes

**CRITICAL**: Never call `code_review` without linting and spell-checking changed files first. Linting and spell-checking catch basic issues that should be fixed before more comprehensive code review.

## Determining Responsibility for Workflow Failures

**IMPORTANT**: Not all workflow failures are your responsibility to fix.

**You ARE responsible for** fixing workflow failures if:
- The failure is in code or files you directly modified
- The failure is caused by changes you introduced (e.g., new dependencies, configuration changes)
- The error message indicates an issue with YOUR specific changes

**You are NOT responsible for** fixing workflow failures if:
- The failure is in pre-existing code you didn't modify
- Lint errors exist in unchanged files or unchanged sections of files
- Spelling errors exist in files you didn't modify
- The workflow itself has an environment or infrastructure issue (e.g., package installation failures, Docker issues)
- The error occurs in lines of code that existed before your changes

**How to determine responsibility**:
1. Check the workflow logs to identify which files/lines are causing the failure
2. Use `git diff` or `git show` to verify whether you modified those specific lines
3. If you only modified prose (text/comments) but errors are in code blocks, those are pre-existing
4. If the error is "file X line Y" and you didn't touch line Y, it's pre-existing

**What to do**:
- **If it's your responsibility**: Fix the issue and re-run the workflow
- **If it's NOT your responsibility**: Document it in your PR description and notify the repository maintainer
- **Never** fix unrelated pre-existing issues - focus on your changes only
