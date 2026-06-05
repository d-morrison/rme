---
description: Produce a grouped, at-a-glance status table for every open PR in this repo (head, behind-main count, lane/owner categorization, one-sentence next-action).
allowed-tools:
  - Bash
  - mcp__github__list_pull_requests
  - mcp__github__pull_request_read
---

Produce one Markdown report grouping every open PR by lane so the next thing to act on is obvious in one screen. Read-only — do not modify any PR while producing the sweep.

## When this fires

- "What's the status of each open PR?" / "PR status sweep" / "where do all the PRs stand?"
- After several PRs have moved in parallel and the user has lost track
- Before deciding what to merge / iterate next

Don't use it for a single-PR deep dive — call `mcp__github__pull_request_read` directly for that.

## Workflow

1. **Fetch open PRs** via `mcp__github__list_pull_requests(owner = "d-morrison", repo = "rme", state = "open", perPage = 50)`. Capture `number`, `title`, `draft`, `user.login`, `head.ref`, `head.sha`, `head.repo.full_name`, `labels`, `requested_reviewers`, `updated_at`, and `html_url` for each.

2. **Refresh local refs**:

    ```bash
    git fetch -q --all
    echo "main: $(git rev-parse --short origin/main)"
    ```

3. **Batch-compute behind-main counts** in one Bash call (don't loop in chat — one tool call):

    ```bash
    for spec in "<num>:<head_ref>" ...; do
      num=${spec%%:*}; br=${spec#*:}
      behind=$(git rev-list --count "origin/$br..origin/main" 2>/dev/null)
      printf "#%s behind=%s\n" "$num" "$behind"
    done
    ```

4. **Categorize each PR into a lane**, using the first signal that applies:

    | Lane | Signal |
    |---|---|
    | 🟪 External | `head.repo.full_name` ≠ `d-morrison/rme` |
    | 🟢 Workflow / infrastructure | Title or recent commits touch `.github/workflows/`, `.claude/`, `.github/skills/`, `CLAUDE.md`, `renv.lock`, or DESCRIPTION |
    | 🟡 Active iteration (owner) | `user.login == "d-morrison"`, very recent `updated_at` (≤ 24 h), with unresolved review threads or visible local-CLI / `@claude` round-tripping |
    | 🟦 Mine (other) | head ref starts `claude/…` and `user.login == "Claude"` (the anthropic-code-agent app), or my designated branch |
    | 🟧 Bot / Copilot lane | `user.login` in `{"github-actions[bot]", "Copilot", "copilot-swe-agent"}`, or auto-draft from an issue, awaiting owner review |

    When in doubt, peek at the latest 3-5 comments via `mcp__github__pull_request_read(method="get_comments")` to see who's actively pushing.

5. **Render five Markdown tables**, one per lane, with columns:

    | PR | Title | Behind | Status |

    - The `PR` cell must be a clickable Markdown link using the PR's `html_url`, e.g. `**[#860](https://github.com/d-morrison/rme/pull/860)**`. Don't rely on auto-linking — explicit links work in every surface.
    - Keep `Status` to **one short sentence**: the single most useful next thing the user could do, or the one thing blocking it.
    - Bold the behind count if `>= 15` to flag staleness; otherwise plain.

6. **Finish with one TL;DR line**: the single highest-leverage action across the whole queue (usually merging a workflow-fix PR that's blocking lint elsewhere, otherwise reviewing the actively-iterating chapter PR).

## Don't

- Don't fetch `get_files` / `get_diff` for every PR — that's a deep-dive workflow, not a sweep.
- Don't fetch `get_check_runs` for every PR. Only for the one or two you call out in the TL;DR. Otherwise you'll burn API budget on PRs the user is going to skim past.
- Don't post the report as a PR comment.
- Don't include closed/merged PRs even if they appeared in a recent webhook event. Call them out separately only if the user asks about a specific one.
- Keep total output ≤ ~80 lines; this is a dashboard, not an audit.
