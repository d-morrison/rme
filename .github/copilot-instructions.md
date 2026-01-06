# GitHub Copilot Instructions

## Pull Request Guidelines

- Always ensure that PR branch is up to date with main branch before requesting PR review

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
- `systemfonts` package requires `libfontconfig1-dev`
- Consider using `rocker/verse` Docker image for workflows to reduce installation requirements

## JAGS Dependencies

This repository uses JAGS (Just Another Gibbs Sampler) for Bayesian analysis:
- JAGS must be installed in workflows that render Quarto documents (using `sudo apt-get install -y jags`)
- R packages `rjags` and `runjags` depend on JAGS being installed
- The lint workflow also needs these packages installed to avoid false positives
