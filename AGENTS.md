# AGENTS.md

<!-- Fill the brackets at kickoff. Keep this file short. Detail lives in brief/ and .claude/rules/. -->

## Project

**[Product]**: [one-line identity from brief/brief.md].
Built for **[event]**, [solo | team of N]. Stack: [packs in use, e.g. Next.js on Vercel + Rust service].

Read `brief/brief.md` before touching any feature. Phases live in `plans/00-general.md` and run as GitHub issues labeled `phase`.

This is a hackathon build. `.claude/rules/hackathon.md` wins over any stricter rule.

## Team

<!-- Team mode only. /plan deletes this section for solo builds. -->

| Person | GitHub handle | Role | Folders owned |
|--------|---------------|------|---------------|
|        |               |      |               |

Owner of `brief/`: [handle]. Owner of `schema/`: [handle].

Roles split by decision, not code. One person can hold two.

- Problem owner: guards the demo path and decides cuts.
- Builder: runs agents, reviews and tests.
- Storyteller: design, pitch and demo, from hour one.

## Commands

| Task | Command |
|------|---------|
| Install | `[...]` |
| Dev | `[...]` → `http://localhost:[port]` |
| Build | `[...]` |
| Seed demo data | `[...]` |
| Deploy | `[...]` (ask first) |
| Live URL | `[...]` |

Ports: each worktree runs its own dev server. Take n from the worktree folder name (`.claude/worktrees/issue-12` gives n = 12). Dev uses `PORT=3000+n` and the API uses `8000+n`. Main uses 3000 and 8000.

## Walk the demo

1. Start with `[dev command]`, open `[url]`.
2. Log in as `[seeded user]` if there is auth.
3. Follow the demo path in `brief/brief.md` step by step in a browser tool.
4. Check phone width (375px).
5. Report what you clicked and what you saw.

## Rules

Claude loads these by file type. Other agents: read only the files for the area you touch.

| File | Load when |
|------|-----------|
| `.claude/rules/hackathon.md` | Always |
| `.claude/rules/ai.md` | Always (where the model goes) |
| `.claude/rules/git.md` | Always |
| `.claude/rules/react.md` | Any `.ts` or `.tsx` |
| `.claude/rules/next.md` | Next.js app (delete if Vite) |
| `.claude/rules/vite.md` | Vite SPA (delete if Next) |
| `.claude/rules/aws.md` | Always: host, IAM, deploy (delete if Next) |
| `.claude/rules/bedrock.md` | Always: model, harness, Qdrant (delete if no model) |
| `.claude/rules/rust.md` | `.rs`, `Cargo.toml` |
| `.claude/rules/python.md` | `.py`, `pyproject.toml` |
| `.claude/rules/contract.md` | `schema/`, or any code that crosses languages |

## Workflow

- `[AGT-01]` One issue per session, in its own worktree: `claude -w issue-12`, then `/phase 12`. Read the issue, the brief, the general plan and this file. Not the whole repo.
- `[AGT-02]` The issue is the plan. Build its checklist and tick items in the issue as they finish.
- `[AGT-03]` Use subagents only to run independent work in parallel. Don't use `superpowers:subagent-driven-development` or `superpowers:test-driven-development`.
- `[AGT-04]` Use `superpowers:brainstorming` to scope, `superpowers:systematic-debugging` for bugs, `superpowers:verification-before-completion` before saying it works.
- `[AGT-05]` When something is unclear, pick the reversible option, write the assumption at the top of your report, and keep going. Stop only if the choice changes the demo path or can't be undone.
- `[AGT-06]` A real trade-off gets a short decision record (`docs/decisions/0000-template.md`). A real failure gets a short incident note (`docs/incidents/0000-template.md`). Number them in order, a few lines each.
- `[AGT-07]` When a commit touches a sponsor's markers (`.claude/sponsors.json`), add an `Evidence:` trailer. Use a real number when you have one: `Evidence: dash0 | search p95 857ms -> 20ms | trace link or file`. Otherwise `Evidence: dash0 | none`. The commit-msg hook rejects the commit without it. `/pitch` and the submission read `docs/evidence.md`, which `scripts/evidence.sh` builds on main.

## Boundaries

Always:
- Keep secrets in `.env` (gitignored). Update `.env.example` with the key name.
- Keep the app runnable. The demo can be pulled at any moment.
- Deploy Next.js on Vercel (`next.md`). Anything else deploys on AWS (`aws.md`).
- Commit on your issue branch with conventional commits. Never on `main`.
- Merge PRs with merge commits, never squash. Merge in dependency order, rebased on `main` first.

Ask first:
- `git push`, opening a PR
- Deploying, sending email, calling a paid API in a loop
- Adding a dependency that isn't in a rules file
- Editing `brief/`
- Deleting or reshaping seed data

Never:
- Build what the brief says is out of scope
- Put a model in the decision path (see `ai.md`)
- Add `Co-Authored-By` or "Generated with" lines

Team mode only (`/plan` deletes this block for solo builds). Your owner is `gh api user -q .login`.
- Take only issues assigned to your owner: `gh issue list --assignee <handle> --label phase`. The assignee is the person. The `in-progress` label is the agent's claim.
- Touch only your owner's folders. Anything else is "ask first".
- `brief/` and `schema/` each have one named owner (see Team). If you aren't that owner's agent, don't edit them. Open an issue instead.

## Gotchas

<!-- Add a line each time an agent makes the same mistake twice. Delete lines that stop being true. -->

-
