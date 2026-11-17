---
description: Write the event retro from the repo, then ask me only what it can't show
---

Read these first. Skip any that don't exist.

- `git log --merges --oneline` and `git log --format='%h %ad %s' --date=short`
- `docs/evidence.md` and `docs/pitch.md`
- `brief/brief.md` for the event name and identity line
- Closed and open issues: `gh issue list --state all --label phase`
- The last-mile issue's "Cut on purpose" list: `gh issue list --label last-mile --state all`, then `gh issue view <n>`

Fill every field the repo shows. Then ask me only the rest, in one question box round:

- Result: placed, prize, or none
- Who won and why
- How many teams built the same idea
- Whether the rules allowed starter code
- One kit rule to change

Write `docs/retro.md` with these fields, one or two short lines each:

```markdown
# Retro

- Date:
- Event:
- Format: solo or team, hours, in person or online
- Built: the identity line, and the live link
- Result:
- Worked: what to keep, with a number from `docs/evidence.md` if there is one
- Broke: what failed or got cut, from the cut list and open issues
- Winners did: who won, why, and how many teams built the same idea
- Kit change: one rule to change in this kit
```

Note in Broke if starter code wasn't allowed.

End by telling me: paste `docs/retro.md` into Claude chat with "add this retro".
