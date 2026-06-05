---
description: Claim a PR for active work by posting a "paws off until I'm done" comment, so other agents (the @claude bot, other CLI sessions, other contributors) stop touching it.
allowed-tools:
  - mcp__github__add_issue_comment
  - mcp__github__list_pull_requests
---

Claim the given PR by posting a single, recognisable "paws off" comment. Other agents and sessions in this repo treat that comment as a hands-off signal until a `/release-pr` lands.

## Arguments

- `pr_number` (required) — the PR number, e.g. `860`.
- `lane` (optional, default `Claude Code CLI (local session)`) — who's claiming. Use:
  - `Claude Code CLI (local session)` — the human is driving from their terminal.
  - `Claude Code on the web` — a sandboxed cloud session.
  - `@claude` — the GitHub Actions review/agent bot.
  - Other free-form text is fine; keep it short and identifying.
- `reason` (optional) — one short phrase to put in parentheses, e.g. `resolving merge conflicts`, `addressing review comments`, `pushing the rate-scale fig fix`.

If only one positional arg is given, treat it as `pr_number`.

## What to do

1. Confirm the PR is open (don't claim a merged/closed PR):

    Call `mcp__github__list_pull_requests(owner = "d-morrison", repo = "rme", state = "open")` and verify `pr_number` is in the result.

    If not open, stop and tell the user — don't post anything.

2. Compose the comment body, exactly in this shape so other agents recognise it:

    ```
    <lane> is working on this — paws off until I'm done.
    ```

    If `reason` is provided, append it in parentheses on the same line:

    ```
    <lane> is working on this — paws off until I'm done. (<reason>)
    ```

3. Post the comment:

    `mcp__github__add_issue_comment(owner = "d-morrison", repo = "rme", issueNumber = <pr_number>, body = <body>)`.

4. Reply with one short confirmation including the PR's URL — no PR comment, no further work on the branch.

## Don't

- Don't push commits, open subagents, or modify any files. Claiming is a no-op except for the comment.
- Don't claim a PR someone else already claimed in the last few comments — if you see a recent "paws off" comment without a matching `/release-pr` release line, tell the user instead of stacking another claim.
- Don't add labels or modify reviewer requests; the comment is the entire interface.
