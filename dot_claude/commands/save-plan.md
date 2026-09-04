---
description: Save the latest plan-mode plan into a knowledge effort folder
---

## Scope resolution (read this first)

Find the store, then the scope. Never hardcode either - the store can be cloned anywhere.

1. Read `~/.claude/knowledge-root`: a single line holding the absolute path to the
   knowledge store. Call it `$KROOT`. If that file is missing, the store is not
   bootstrapped on this machine - tell the user to run `<clone>/_hooks/bootstrap.sh`
   and stop.
2. Read `$KROOT/_hooks/scope-map`, and `$KROOT/_hooks/scope-map.local` too if it exists
   (tab-separated, `path-prefix -> scope dir`; a leading `~` means the home directory).
3. Match the current working directory against every prefix; longest match wins. This is
   what makes git worktrees and subprojects resolve to the right client.
4. `$SCOPE` is then `$KROOT/<matched scope>`, e.g. `$KROOT/clients/<client>`.
5. No match means the cwd belongs to no known client. Say so and stop - never write into
   another client's scope, and never guess.

All paths written `$SCOPE/...` below resolve against that.

Save the most recent approved plan from `~/.claude/plans/` into `$SCOPE/<effort>/plan.md`.

## Step 1: Get the effort slug

If `$ARGUMENTS` is non-empty, treat the first token as the effort slug. Otherwise:
- Detect candidate effort from current branch (`git rev-parse --abbrev-ref HEAD`) against each `_meta.md` `branches:` field.
- Fall back to topic match against `$SCOPE/EFFORTS.md`.
- If ambiguous, ask the user.

Validate that `$SCOPE/<effort>/` exists. If not, suggest `/new-effort <slug>` first and stop.

## Step 2: Find the latest plan

```bash
ls -t ~/.claude/plans/*.md 2>/dev/null | head -1
```

If no plan files exist, report it and stop. Show the user the path and modification time of the file you intend to copy so they can confirm it's the right one.

## Step 3: Decide overwrite policy

Read `$SCOPE/<effort>/plan.md`:
- If it's empty or only the scaffolded placeholder (`# <Effort name> - plan` followed by a note about read-on-demand), proceed.
- If it has real content, show a unified diff between current plan.md and the new plan, then ask the user to confirm before overwriting. Offer to write a backup at `$SCOPE/<effort>/plan-archive-YYYY-MM-DD.md` first.

## Step 4: Copy

Copy the source plan file to `$SCOPE/<effort>/plan.md`. Preserve the content verbatim.

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
