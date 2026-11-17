# Git Rules

- `[GIT-01]` Commit freely on your issue branch. Never commit on `main` (the pre-commit hook blocks it). Push or open a PR only when asked.
- `[GIT-02]` Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`. Say why, not what.
- `[GIT-03]` One branch per issue: `worktree-issue-<n>`, the one `claude -w issue-<n>` creates.
- `[GIT-04]` PR body:
  ```markdown
  ## Changes
  - main changes

  ## Check
  - [ ] one box per thing to open, click and verify on the demo path
  ```
- `[GIT-05]` When updating a PR body, keep checked boxes. Only append new ones.
- `[GIT-06]` No `Co-Authored-By` or "Generated with" lines.
- `[GIT-07]` Never squash. Merge PRs with merge commits so the history shows the real process; judges read `git log`. Merge in dependency order, and rebase each branch on `main` first.
