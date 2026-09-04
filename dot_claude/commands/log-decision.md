---
description: Draft and append a decisions.md entry for the current effort
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

You are appending a structured decision entry to the appropriate `$SCOPE/<effort>/decisions.md` file.

## Step 1: Determine the effort

1. Read `$SCOPE/EFFORTS.md` to see all efforts.
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
1. Append entry to `$SCOPE/<effort>/decisions.md` (ensure separator `---` is present).
2. Update `_meta.md` `last_updated:` to today's date.
3. Report path written.

## Step 5: Nudge

Suggest the user run `/snapshot-timeline` if multiple new entries have been added since the last regen. Suggest `/snapshot-state` if `state.md` is now stale.

User input: $ARGUMENTS
