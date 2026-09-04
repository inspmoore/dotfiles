---
description: Regenerate $SCOPE/TIMELINE.md from all decisions.md files
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

Regenerate `$SCOPE/TIMELINE.md` by scanning all `$SCOPE/*/decisions.md` files. This command is deterministic and idempotent.

## Step 1: Collect entries

For each `$SCOPE/*/decisions.md`:
- Extract entries with header pattern `^## (\d{4}-\d{2}-\d{2}) - (.+)$`.
- Extract the `**Status:**` line that follows.
- Record: date, effort name (from folder), headline, status.

Use a Bash one-liner where convenient:
```bash
for f in $SCOPE/*/decisions.md; do
  effort=$(basename $(dirname "$f"))
  grep -nE '^## [0-9]{4}-[0-9]{2}-[0-9]{2} - ' "$f" | while read line; do
    # parse line
  done
done
```

Or read each decisions.md programmatically. Either works - the result must be deterministic.

## Step 2: Build TIMELINE.md

Sort all entries descending by date. Pad columns for readability:

```markdown
# Project timeline

_Regenerated YYYY-MM-DD by /snapshot-timeline. Do not edit by hand - changes will be overwritten._

## YYYY-MM-DD  <effort>            <headline>                       [<status>]
## YYYY-MM-DD  <effort>            <headline>                       [<status>]
...
```

## Step 3: Write

Overwrite `$SCOPE/TIMELINE.md` with the new content. No approval needed - this is mechanical regeneration.

Report: number of entries collected, time range covered.

## Idempotency

Running this command twice in a row must produce identical files. If the second run differs from the first, there's a non-deterministic ordering bug to fix.

User input: $ARGUMENTS (ignored)
