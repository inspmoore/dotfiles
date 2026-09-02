---
name: knowledge-system
description: Use in any project that has a `knowledge/` folder with per-effort subfolders. Triggers when the user references prior work ("why did we", "what's the state of", "what did we decide about"), when working on a long-lived effort (refactor, upgrade, perf campaign, spike), when a non-trivial decision is being made worth logging, or when stepping away from work. Loads `knowledge/<effort>/state.md` and `knowledge/<effort>/decisions.md` for the relevant effort based on current git branch (via `_meta.md` `branches:` field) or topic match against `knowledge/EFFORTS.md`. Suggests `/log-decision` after decisions and `/snapshot-state` at session breaks. Project-agnostic.
---

# Knowledge system convention

This skill applies in any project where a `knowledge/` folder exists at the workspace root with per-effort subfolders. When active, it tells you how to read and write knowledge using the conventions below.

## What loads at session start

If the project has a SessionStart hook wired up, `knowledge/EFFORTS.md` (effort registry) and `knowledge/TIMELINE.md` (cross-effort chronology) are injected into context already. If you don't see them, the user may not have the hook configured; you can still read them via the Read tool.

## How to find the right effort

1. Read `knowledge/EFFORTS.md` first - it's a table mapping effort name to status, last_touched, branch, touches.
2. Match by any of:
   - Current branch: `git rev-parse --abbrev-ref HEAD` against each `_meta.md` `branches:` field.
   - Topic in user's prompt against effort names or summaries.
   - File paths mentioned in the conversation against `touches:` field.
3. Once matched, Read `knowledge/<effort>/state.md` and `knowledge/<effort>/decisions.md`.
4. If unsure between two efforts, ask the user.

## Per-effort folder shape

```
knowledge/<effort>/
  _meta.md          # frontmatter: status, created, last_updated, touches, related_efforts, branches
  plan.md           # original plan / spec / research. Read on demand.
  state.md          # 'Resume here' - short, current. Read when picking up work.
  decisions.md      # append-only, dated entries. Read for chronology and causality.
  measurements.md   # optional - measurements, benchmarks, raw data
```

## `_meta.md` frontmatter

```yaml
---
name: <effort-slug>
status: active            # active | paused | done | archived
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
touches: [path1, path2]
related_efforts: [other-effort-slug]
superseded_by: null
branches: [branch-name]
---
```

## `decisions.md` entry shape (append-only)

```markdown
## YYYY-MM-DD - <headline>
**Status:** done | proposed | superseded
**Why:** rationale at the time
**Predecessor:** [[other-effort#YYYY-MM-DD-slug]] - what enabled this
**Touches:** comma-separated paths
**Result:** outcome / measurement / link
**Caused:** [[other-effort#YYYY-MM-DD-slug]] - what this enabled
**Reversible:** yes | no | partial
---
```

### Wikilink format

`[[effort-name#YYYY-MM-DD-slug]]` is followed by Reading `knowledge/<effort-name>/decisions.md` and scanning for the `## YYYY-MM-DD - <slug>` header. The slug is the kebab-cased headline.

Use wikilinks for causality across efforts. Don't fake them - if you don't have a real predecessor/effect, omit the field.

## `state.md` is short

Resume-here only:
- What's done
- What's next
- Current blockers
- Open questions

If it grows past ~50 lines, content is leaking from decisions.md. Trim.

## When to nudge the user (do not auto-write)

- After a non-trivial decision is reached in conversation that affects how the codebase works: suggest `/log-decision`.
- Before the user signals they're stepping away from the effort, or at session end after meaningful work: suggest `/snapshot-state`.
- When decisions.md has grown with new entries since the last TIMELINE refresh: suggest `/snapshot-timeline`.

All writes are supervised. Never append to decisions.md without user approval.

## When NOT to load effort detail

- Pure file-search tasks ("find all usages of X") - skip.
- Trivial one-line fixes unrelated to any active effort - skip.
- User explicitly asks you not to.
- The conversation is about config/setup unrelated to ongoing efforts.

## Cross-effort awareness

When two efforts have overlapping `touches:` paths, expect interactions:
- A change in effort A may affect effort B's invariants.
- Cite both efforts when proposing work in the overlap area.

The user's `EFFORTS.md` may not surface overlap explicitly - infer it from `touches:` fields.

## When the system is broken / not yet set up

If `knowledge/` exists but is mostly empty, the project is in mid-migration. Don't assume historical context exists - work from what's there and flag gaps.

If `knowledge/` doesn't exist at all, this skill should not have triggered. Inform the user and stop.
