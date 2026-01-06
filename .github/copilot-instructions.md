# GitHub Copilot Instructions

## Pull Request Guidelines

- Always ensure that PR branch is up to date with main branch before requesting PR review

## Code Formatting Guidelines

When adding or editing text in source code (such as comments, documentation strings, or error messages):
- Add a newline at the end of every phrase or logical unit of text
- Each phrase should be on its own line in the source code
- A phrase is typically a complete thought, clause, or sentence
- This improves readability and makes diffs clearer

Example:
```r
# Good: Each instruction on its own line
# First, check if the input is valid.
# Then, process the data.
# Finally, return the result.

# Avoid: Multiple phrases on one line
# First, check if the input is valid. Then, process the data. Finally, return the result.
```

## CI/CD Workflow Debugging

When investigating CI/CD failures (build, test, or lint workflow issues):

1. **Use GitHub MCP tools to inspect job logs directly**:
   - Use `list_workflow_runs` to see recent workflow runs and their status
   - Use `get_job_logs` with `failed_only=true` to retrieve logs from failed jobs
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

## JAGS Dependencies

This repository uses JAGS (Just Another Gibbs Sampler) for Bayesian analysis:
- JAGS must be installed in workflows that render Quarto documents
- R packages `rjags` and `runjags` depend on JAGS being installed
- The lint workflow also needs these packages installed to avoid false positives
