---
description: Refresh knowledge/<effort>/state.md based on current session context
---

You are rewriting the `state.md` file for the current effort to reflect where work stands right now.

## Step 1: Determine the effort

Same detection as `/log-decision`:
- Branch match against `_meta.md` `branches:` field.
- Topic from recent conversation.
- Ask user if ambiguous.

If user passed `$ARGUMENTS`, treat it as the effort slug.

## Step 2: Draft state.md

Concise format - aim for 20-50 lines max:

```markdown
# Resume here - <effort name>

_Last updated: YYYY-MM-DD_

## What's done
- <recent completions>

## What's next
- <immediate next steps>

## Blockers
- <anything stalled, or "none">

## Open questions
- <unresolved questions, or "none">

## Pointers
- <links/paths to key files, dashboards, PRs>
```

Derive content from:
- Recent session messages (what was actually done in this session).
- Existing `state.md` (preserve still-relevant items).
- Recent commits if helpful: `git log --oneline -20`.
- `decisions.md` last few entries.

Do NOT include long prose, history, or rationale. That belongs in `decisions.md`.

## Step 3: Show + confirm

Show the drafted state.md. Wait for explicit approval or edits. Do NOT overwrite without approval.

## Step 4: Write + update _meta

On approval:
1. Replace `knowledge/<effort>/state.md` with the new content.
2. Update `_meta.md` `last_updated:` to today's date.
3. Report path written.

User input: $ARGUMENTS
