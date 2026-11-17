# Hackathon Starter

My kit for hackathons with AI agents, solo by default with an optional team mode. Short in-person events, 24 to 48 hour weekends, and online multi-day builds.

Inspired by [Juan Lizarazo's hackathon-starter-kit](https://github.com/juanlizarazo/hackathon-starter-kit).

## Use it

1. **Use this template** → new repo for the event. Clone it and run `scripts/setup.sh`. It turns on the git hooks, which don't copy with templates.
2. Find the idea in the **Hackathon Bank** Claude Project (or `/idea` here).
3. Fill `brief/brief.md` and the Project section of `AGENTS.md`.
4. Run `/plan`. It picks the deploy path (Next.js → Vercel, anything else → AWS), lists the rules, templates and plugin you won't use, and deletes them when you say yes. Then it opens one GitHub issue per phase.
5. Run each issue in its own worktree: `claude -w issue-12`, then `/phase 12`. Issues with no open dependencies run in parallel.
6. Run the rest of the commands in order.

## Flow

| Step | What | Command | File |
|------|------|---------|------|
| 1 | Find the idea or the angle | `/idea` or `/bounty` | `start/` |
| 2 | Stack sponsor tracks, talk to sponsors | | `start/sponsors.md` |
| 3 | Brief: identity, wow moment, rubric, scope | | `brief/brief.md` |
| 4 | General plan and one issue per phase, blocking phase first | `/plan` | `plans/00-general.md` |
| 5 | One issue per worktree session, parallel when possible | `claude -w issue-12`, then `/phase 12` | `.github/ISSUE_TEMPLATE/phase.md` |
| 6 | Check the wow moment | `/wow` | |
| 7 | Fresh-session audit | `/audit` | |
| 8 | Persona reviews | `/persona sponsor Elastic https://...` | |
| 9 | UI polish, sized by the rubric | `/polish` | |
| 10 | Pitch script, Q&A bank, timed dry run | `/pitch 3` | `docs/pitch.md` |
| 11 | Submit: every Must-have ticked | | `.github/ISSUE_TEMPLATE/last-mile.md` |

Agents commit on their own issue branch. The pre-commit hook blocks commits on `main` (unless `ALLOW_MAIN=1`) and runs gitleaks on staged changes. After each commit, a Claude hook warns if the branch already conflicts with `main`. `.claude/settings.json` makes `git push`, `gh pr create`, `vercel`, `scripts/deploy.sh`, `cdk deploy` and AWS writes ask first. Merge PRs with merge commits, never squash, in dependency order.

## Team mode

Solo is the default. For a team, answer "team" when `/plan` asks and list each person's name and GitHub handle.

- Each person runs agents under their own `gh` login. Agents take only issues assigned to that login.
- Each issue touches only its owner's folders, and no two issues share a folder.
- `brief/` and `schema/` have one owner each. Everyone else opens an issue to change them.
- Roles: problem owner, builder, storyteller. See `AGENTS.md`.

## Day 0

Costs zero event hours if done before.

- [ ] Event repo made from this template, `scripts/setup.sh` run clean
- [ ] `gh auth status` shows you logged in
- [ ] Read the event rules for: pre-existing code, starter templates, AI disclosure, team size, public repo
- [ ] Idea picked, brief filled
- [ ] Sponsor tools tried in a tiny practice project
- [ ] Sponsor plugins turned on in `.claude/settings.json` (or added)
- [ ] Model API keys with credits, plus a second provider for when one hits limits
- [ ] Deploy target live with a hello world: Vercel for Next, or a Lightsail box over HTTPS for anything else (`aws.md`, `scripts/deploy.sh`)
- [ ] `hackathon` AWS profile in `us-west-2`, budget alarm, Bedrock model access

## Layout

```text
AGENTS.md            index: project, commands, demo walk, boundaries, gotchas
CLAUDE.md            imports AGENTS.md
.gitattributes       LF endings, so WSL/Windows edits can't break the deploy scripts
.claude/
  settings.json      plugins, push and deploy guard, merge-check hook, attribution off
  sponsors.json      per-sponsor markers the commit-msg hook looks for
  hooks/             merge-check.sh: warns after a commit that conflicts with main
  commands/          /idea /bounty /plan /phase /wow /audit /persona /polish /pitch
  rules/             core rules always load; stack rules load by file type
start/               find-an-idea, sponsors, pick-a-bounty
deploy/              Caddyfile, systemd unit, box setup, app IAM policy (non-Next stacks)
scripts/deploy.sh    build, upload and restart on the box
brief/brief.md       the spec
plans/               general plan (phases link to issues)
.github/ISSUE_TEMPLATE/  phase and last-mile issue templates
.githooks/           pre-commit: no commits on main, gitleaks; commit-msg: sponsor Evidence trailers
scripts/setup.sh     turns on .githooks, checks gh, gitleaks, jq, docker
scripts/evidence.sh  builds docs/evidence.md from Evidence trailers (main only)
docs/                decision and incident templates, evidence, pitch
.worktreeinclude     copies .env files into new worktrees
```

Stack rules: `react.md` (shared TS), `next.md` (Next + Vercel), `vite.md` (Vite SPA), `aws.md` (host picker, IAM and deploy for non-Next stacks), `bedrock.md` (model, agent harness, Qdrant), `rust.md` (axum service), `python.md` (FastAPI), `contract.md` (JSON Schema shared across languages). Claude loads them by file type. Other agents use the table in `AGENTS.md`.

## Disclosure

Keep this line in the event repo's README:

> Built on my MIT [hackathon-starter](https://github.com/melizalde-ds/hackathon-starter). Kit files are listed in the first commit. Everything else was written during the event.

## Plugins

- `superpowers`: brainstorming, debugging, parallel agents, verification. Skip its subagent-driven development and TDD skills.
- `vercel`: deploys and docs when the stack is Next.js.
- `deploy-on-aws`: AWS docs and pricing when the stack isn't Next.js.
- `impeccable`: UI audit and polish. If you already installed it globally, set it to `false` here so it doesn't load twice.
