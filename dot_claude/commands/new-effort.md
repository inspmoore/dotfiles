---
description: Scaffold a new effort folder under the current scope
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

Create a new effort folder under `$SCOPE/<slug>/` with all templates.

## Step 1: Get the slug

If the user passed `$ARGUMENTS`, treat it as the kebab-case slug. Otherwise ask.

Validate: lowercase, kebab-case, no spaces. Reject names that conflict with existing effort folders (run `ls $SCOPE/` to check).

## Step 2: Gather metadata

Ask the user:
- Status (default: `active`)
- Branch(es) where this effort lives (default: current branch)
- Short summary (1-2 sentences)
- `touches:` paths (optional, comma-separated)
- `related_efforts:` (optional)

## Step 3: Scaffold files

Create `$SCOPE/<slug>/` with:

### `_meta.md`
```markdown
---
name: <slug>
status: <status>
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
touches: [<paths>]
related_efforts: [<related>]
superseded_by: null
branches: [<branches>]
---

<short summary>
```

### `plan.md`
```markdown
# <Effort name> - plan

(Add the plan, spec, or research notes here. This file is read on demand, not eagerly.)
```

### `state.md`
```markdown
# Resume here - <effort name>

_Last updated: YYYY-MM-DD_

## What's done
- <nothing yet>

## What's next
- <first step>

## Blockers
- none

## Open questions
- none

## Pointers
- <add links>
```

### `decisions.md`
```markdown
# Decisions - <effort name>

Append entries below. Newest at the bottom. Format documented in the `knowledge-system` skill.

---
```

## Step 4: Update EFFORTS.md

Add a row to the active efforts table in `$SCOPE/EFFORTS.md`:

```
| [<slug>](<slug>/_meta.md) | <status> | <today> | <branch> | <touches> |
```

## Step 5: Report

Output:
- Path created
- Reminder to use `/log-decision` to capture decisions as they happen
- Reminder to use `/snapshot-state` at session breaks

User input: $ARGUMENTS
