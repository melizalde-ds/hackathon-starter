---
description: Claim one phase issue and build it in this worktree
argument-hint: "[issue number]"
---

Issue: #$ARGUMENTS

Run this inside the issue's worktree: `claude -w issue-$ARGUMENTS`.

Read the issue (`gh issue view $ARGUMENTS`), `brief/brief.md`, `plans/00-general.md` and `AGENTS.md`. Only the rules for the files you touch.

1. Claim it. If `brief/brief.md` still has a template placeholder (`grep -qE '\[(Event|name, date|solo \| team|build time|main track)' brief/brief.md`), stop and tell me: main wasn't pushed with the filled brief, and worktrees start from `origin/HEAD`. If the issue has the `in-progress` or `blocked` label, stop and tell me. Otherwise run `gh issue edit $ARGUMENTS --add-label in-progress` and `gh issue comment $ARGUMENTS --body "Claimed by worktree issue-$ARGUMENTS"`. Claim by label, never by assignee. Team mode (`AGENTS.md` has a "Team" section): if the issue is assigned to someone other than `gh api user -q .login`, stop and tell me.
2. Work on branch `worktree-issue-$ARGUMENTS`, the one `claude -w` created.
3. Use ports from `AGENTS.md` Commands: 3000+n for dev, 8000+n for the API.
4. Build the checklist. Use subagents only for parts that are truly independent.
5. Commit freely on this branch with conventional commits. One commit per finished checklist item is a good size.
6. When an item is done, tick it in the issue: edit the body with `gh issue edit $ARGUMENTS --body-file`.
7. Other issues run in parallel. Don't touch files outside "Touches only". A schema change is "ask first".
8. If something is unclear, pick the reversible option and add it under "Assumptions made" in the issue.
9. Walk this phase's step of the demo path. Post what you clicked and what you saw as an issue comment.
10. Rebase on `main` (`git fetch origin && git rebase origin/main`).
11. Ask me before `git push` and `gh pr create`. The PR body follows `git.md` GIT-04 and has `Closes #$ARGUMENTS`.
