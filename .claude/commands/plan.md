---
description: Write the general plan from the brief
---

First ask me: "Solo or team? If team, list name + GitHub handle per person."

- Solo: delete the team-only parts. That is the "Team" section and the "Team mode only" block in `AGENTS.md`, and the "Team mode" section in `README.md`. Set the format to "solo" in `AGENTS.md` and the `brief/brief.md` header.
- Team: set the format to "team of N" in `AGENTS.md` and the `brief/brief.md` header. Ask each person's role and folders, then fill the owners table in `AGENTS.md`. Name one owner for `brief/` and one for `schema/`.

Read `brief/brief.md` and `AGENTS.md`. Fill `plans/00-general.md`.

- High-level phases only. No code, no implementation detail.
- Phases run in parallel wherever possible. The blocking phase (contract + seed data) goes first.
- The wow moment gets its own hardening phase before the last mile.
- Copy every requirement from brief §6 verbatim.
- List what we cut on purpose and why.
- Anything that doesn't trace to the rubric or the demo path gets cut.

Then turn the phases into GitHub issues. Labels don't copy with "Use this template", so always create them:

1. Run `gh label create --force` for `phase`, `blocked`, `in-progress`, `wow` and `last-mile`.
2. Open one issue per phase from `.github/ISSUE_TEMPLATE/phase.md` with `gh issue create --label phase`. Add `wow` to the wow phase. The last phase uses `.github/ISSUE_TEMPLATE/last-mile.md` and the `last-mile` label. Fill every field. "Depends on" lists issue numbers, so open blocking phases first.
3. Add `blocked` to every issue whose dependencies are still open.
4. Team mode: assign each issue to the owner of the folders it touches (`--assignee <handle>`). Folder sets must not overlap between issues, because most agent merge conflicts come from overlapping files. If two issues need the same folder, ask me how to split it.
5. Write the issue numbers into the table in `plans/00-general.md`.

Then clean up the kit for this stack:

1. Ask me: "Do the rules ban starter or pre-existing code?" If yes, list what is code: `deploy/` (Caddyfile, unit file, setup), `scripts/deploy.sh` and any stack scaffolding. Delete it after one yes. Rules, commands and docs stay. The git hooks and kit scripts (`.githooks/`, `.claude/hooks/`, `scripts/setup.sh`, `scripts/evidence.sh`) are tooling: ask me separately whether the rules allow them.
2. Pick the host: Next.js → Vercel; anything else → the host table in `aws.md`. Then list what goes: `.claude/rules/` packs that don't apply (`bedrock.md` if there's no model), the deploy plugin we won't use (`vercel` or `deploy-on-aws`), `deploy/` + `scripts/deploy.sh` for Next.js or Lambda-only, `.env.example` lines for unused services, `.gitignore` sections for unused languages, and the `.gitattributes` lines that apply.
3. Ask me once: "Delete these now?"
4. On yes: delete the rule files, remove their rows from the `AGENTS.md` rules table, set the unused plugin to `false` in `.claude/settings.json`, trim `.gitignore` and `.env.example`, uncomment the `.gitattributes` lines, and set `APP` and `STACK` at the top of `scripts/deploy.sh`. Fill `.claude/sponsors.json` from the brief's tracks: per sponsor, the paths, package names and env var prefixes that mark its code (`{"dash0": ["OTEL_", "@dash0", "otel/"]}`). Show `git diff --stat`.
5. Ask me before the kickoff commit. Stage only the kit cleanup, not `brief/` or `plans/`, and commit on main with `ALLOW_MAIN=1 git commit -m "chore: hackathon-starter kit (pre-event)"`.
