---
description: Save the latest plan-mode plan into a knowledge effort folder
---

Save the most recent approved plan from `~/.claude/plans/` into `knowledge/<effort>/plan.md`.

## Step 1: Get the effort slug

If `$ARGUMENTS` is non-empty, treat the first token as the effort slug. Otherwise:
- Detect candidate effort from current branch (`git rev-parse --abbrev-ref HEAD`) against each `_meta.md` `branches:` field.
- Fall back to topic match against `knowledge/EFFORTS.md`.
- If ambiguous, ask the user.

Validate that `knowledge/<effort>/` exists. If not, suggest `/new-effort <slug>` first and stop.

## Step 2: Find the latest plan

```bash
ls -t ~/.claude/plans/*.md 2>/dev/null | head -1
```

If no plan files exist, report it and stop. Show the user the path and modification time of the file you intend to copy so they can confirm it's the right one.

## Step 3: Decide overwrite policy

Read `knowledge/<effort>/plan.md`:
- If it's empty or only the scaffolded placeholder (`# <Effort name> - plan` followed by a note about read-on-demand), proceed.
- If it has real content, show a unified diff between current plan.md and the new plan, then ask the user to confirm before overwriting. Offer to write a backup at `knowledge/<effort>/plan-archive-YYYY-MM-DD.md` first.

## Step 4: Copy

Copy the source plan file to `knowledge/<effort>/plan.md`. Preserve the content verbatim.

## Step 5: Update `_meta.md`

Bump `last_updated:` to today's date.

## Step 6: Nudge `/log-decision`

Suggest the user run `/log-decision` to capture the plan-drafted moment with a timestamped entry. Offer to draft the entry inline. A typical entry shape:

```markdown
## YYYY-MM-DD - Plan drafted: <effort name>
**Status:** done
**Why:** <one-line rationale for starting this effort>
**Predecessor:** [[<related-effort>#<date-slug>]] (or omit)
**Touches:** <paths from plan>
**Result:** plan.md written
**Reversible:** yes
---
```

## Step 7: Report

Output:
- Source plan path
- Destination path
- Whether anything was archived
- Reminder to run `/log-decision` and `/snapshot-timeline`

User input: $ARGUMENTS
