---
description: Audit the build against the brief in a fresh session
---

You didn't build this. Read `brief/brief.md` and `plans/00-general.md`, then audit the code and the running app (see "Walk the demo" in `AGENTS.md`).

First check the brief. If §1 (one-line identity) or the §3 impact number is missing, the audit fails. Say so at the top and stop there.

For each requirement in brief §6:
- Score 0 to 100% done
- Where it lives (file or screen)
- What's missing or broken

Also check:
- The wow moment (run the `/wow` checks)
- Each stacked track's real requirement from `start/sponsors.md`: is the sponsor tool core, or bolted on?
- Unreachable screens, broken flows, missing loading, empty and error states
- Phone width
- README: identity, live link, demo steps
- Secrets in the repo
- Each sponsor in `.claude/sponsors.json` has at least one `Evidence:` trailer that isn't "none" (`git log --format=%B | grep '^Evidence:'`)
- README has the disclosure line and the live link
- History has merge commits, not one squash (`git log --merges --oneline`)
- No phase issue still open or `in-progress` (`gh issue list --label phase --state open`)

Finish with an overall %, and a fix list ranked by rubric weight. Don't fix anything yet.
