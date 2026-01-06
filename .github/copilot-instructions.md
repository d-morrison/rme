# Copilot Instructions for RME Repository

## CI/CD and Workflow Debugging

When investigating CI/CD failures, build errors, test failures, or workflow issues:

- **ALWAYS read workflow logs directly** using GitHub MCP tools (`github-mcp-server-get_job_logs`, `github-mcp-server-list_workflow_runs`)
- Do NOT rely on assumptions or generic troubleshooting - examine the actual error output
- Use `failed_only: true` parameter to focus on failed jobs
- Use `return_content: true` to get the actual log content for analysis

## R Package Management

This repository uses `renv` for reproducible R package environments:

- Package versions are locked in `renv.lock`
- All workflows use `r-lib/actions/setup-renv@v2` for dependency installation
- CI dependencies (gh, lintr, purrr, pkgdown) are listed in DESCRIPTION Suggests

## System Dependencies

Some R packages require system-level libraries to compile from source:
- `curl` package requires `libcurl4-openssl-dev`
- `png` package requires `libpng-dev`
- Consider using `rocker/verse` Docker image for workflows to reduce installation requirements
