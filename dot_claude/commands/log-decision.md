---
description: Draft and append a decisions.md entry for the current effort
---

You are appending a structured decision entry to the appropriate `knowledge/<effort>/decisions.md` file.

## Step 1: Determine the effort

1. Read `knowledge/EFFORTS.md` to see all efforts.
2. Detect candidate effort by:
   - Current branch (`git rev-parse --abbrev-ref HEAD`) matched against each effort's `_meta.md` `branches:` field.
   - Files in `git diff --name-only HEAD` matched against `touches:` fields.
   - Topic from recent conversation.
3. If exactly one effort matches, propose it. If multiple or none match, ask the user.

## Step 2: Draft the entry

Format:

```markdown
## YYYY-MM-DD - <headline>
**Status:** done | proposed | superseded
**Why:** <rationale at the time>
**Predecessor:** [[other-effort#YYYY-MM-DD-slug]] (or omit if none)
**Touches:** <comma-separated paths>
**Result:** <outcome / measurement / link> (or omit if not yet measured)
**Caused:** [[other-effort#YYYY-MM-DD-slug]] (or omit if none)
**Reversible:** yes | no | partial
---
```

Rules:
- Date: today (use `date +%Y-%m-%d`).
- Headline: derive from the decision discussed in this session - imperative, short.
- `Touches:` prefill from `git diff --name-only HEAD` (best-effort, edit if needed).
- `Why:`, `Predecessor:`, `Caused:`: derive from conversation. If unclear, leave as `<fill in>` placeholder and ask the user.
- Status: usually `done` if action is taken; `proposed` if not yet implemented.

Arguments (optional): if the user passed `$ARGUMENTS`, treat it as the headline / topic hint.

## Step 3: Show + confirm

Show the drafted entry to the user. Wait for explicit approval or edits. Do NOT append without approval.

## Step 4: Append + update _meta

On approval:
1. Append entry to `knowledge/<effort>/decisions.md` (ensure separator `---` is present).
2. Update `_meta.md` `last_updated:` to today's date.
3. Report path written.

## Step 5: Nudge

Suggest the user run `/snapshot-timeline` if multiple new entries have been added since the last regen. Suggest `/snapshot-state` if `state.md` is now stale.

User input: $ARGUMENTS
