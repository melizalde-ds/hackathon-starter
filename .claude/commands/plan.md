---
description: Write the general plan from the brief
---

Read `brief/brief.md` and `AGENTS.md`. Fill `plans/00-general.md`.

- High-level phases only. No code, no implementation detail.
- Phases run in parallel wherever possible. The blocking phase (contract + seed data) goes first.
- The wow moment gets its own hardening phase before the last mile.
- Copy every requirement from brief §6 verbatim.
- List what we cut on purpose and why.
- Anything that doesn't trace to the rubric or the demo path gets cut.

Then clean up the kit for this stack:

1. Pick the host: Next.js → Vercel; anything else → the host table in `aws.md`. Then list what goes: `.claude/rules/` packs that don't apply (`bedrock.md` if there's no model), the deploy plugin we won't use (`vercel` or `deploy-on-aws`), `deploy/` + `scripts/deploy.sh` for Next.js or Lambda-only, `.env.example` lines for unused services, `.gitignore` sections for unused languages, and the `.gitattributes` lines that apply.
2. Ask me once: "Delete these now?"
3. On yes: delete the rule files, remove their rows from the `AGENTS.md` rules table, set the unused plugin to `false` in `.claude/settings.json`, trim `.gitignore` and `.env.example`, uncomment the `.gitattributes` lines, and set `APP` and `STACK` at the top of `scripts/deploy.sh`. Show `git diff --stat`. Don't commit.
