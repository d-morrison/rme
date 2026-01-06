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
