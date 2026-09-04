---
description: Refresh $SCOPE/<effort>/state.md based on current session context
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
1. Replace `$SCOPE/<effort>/state.md` with the new content.
2. Update `_meta.md` `last_updated:` to today's date.
3. Report path written.

User input: $ARGUMENTS
