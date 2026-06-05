---
description: Release a previously-claimed PR so other agents (the @claude bot, other CLI sessions) know they can pick it up again.
allowed-tools:
  - mcp__github__add_issue_comment
  - mcp__github__list_pull_requests
  - mcp__github__pull_request_read
---

Counterpart to `/claim-pr`. Post a single, recognisable "paws off released" comment so other agents and sessions know the PR is free for the next person.

## Arguments

- `pr_number` (required) — the PR number, e.g. `860`.
- `lane` (optional, default `Claude Code CLI (local session)`) — who's releasing. Should match the lane used in the original `/claim-pr` so the release is unambiguous.
- `summary` (optional) — one short phrase describing what landed during the claim window, e.g. `merge conflicts resolved`, `addressed review findings`, `pushed reframe`.

If only one positional arg is given, treat it as `pr_number`.

## What to do

1. Sanity-check there's an actually-open claim to release:

    Call `mcp__github__pull_request_read(method = "get_comments", owner = "d-morrison", repo = "rme", pullNumber = <pr_number>)`. Walk the last ~10 comments and confirm:

    - the most recent claim/release exchange is an unmatched claim (a "paws off until I'm done" comment that hasn't been followed by a "paws off released"),
    - and that claim's `lane` matches the lane we're releasing.

    If the most recent signal is already a release, or the claim was by a different lane, stop and tell the user — don't post a stray release that misrepresents who was holding the PR.

2. Compose the comment body, exactly in this shape so other agents recognise it:

    ```
    <lane> done — paws off released.
    ```

    If `summary` is provided, append it in parentheses on the same line:

    ```
    <lane> done — paws off released. (<summary>)
    ```

3. Post the comment:

    `mcp__github__add_issue_comment(owner = "d-morrison", repo = "rme", issueNumber = <pr_number>, body = <body>)`.

4. Reply with one short confirmation including the PR's URL — no PR comment, no further work on the branch.

## Don't

- Don't push commits, open subagents, or modify files. Releasing is a no-op except for the comment.
- Don't release a claim that isn't yours unless the user explicitly tells you to (e.g. "the @claude bot crashed mid-claim, release it").
- Don't add or remove labels; the comment is the entire interface.
