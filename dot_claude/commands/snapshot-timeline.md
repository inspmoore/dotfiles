---
description: Regenerate knowledge/TIMELINE.md from all decisions.md files
---

Regenerate `knowledge/TIMELINE.md` by scanning all `knowledge/*/decisions.md` files. This command is deterministic and idempotent.

## Step 1: Collect entries

For each `knowledge/*/decisions.md`:
- Extract entries with header pattern `^## (\d{4}-\d{2}-\d{2}) - (.+)$`.
- Extract the `**Status:**` line that follows.
- Record: date, effort name (from folder), headline, status.

Use a Bash one-liner where convenient:
```bash
for f in knowledge/*/decisions.md; do
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

Overwrite `knowledge/TIMELINE.md` with the new content. No approval needed - this is mechanical regeneration.

Report: number of entries collected, time range covered.

## Idempotency

Running this command twice in a row must produce identical files. If the second run differs from the first, there's a non-deterministic ordering bug to fix.

User input: $ARGUMENTS (ignored)
