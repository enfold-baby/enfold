# Keeping docs up to date

> **Rule:** Any coding session that ships or materially advances work **must** update these docs before ending. Takes ~2 minutes. Future-you (and fresh agents) depend on it.

## End-of-session checklist

Run through this after meaningful work — skip only for pure Q&A with no code changes.

- [ ] **`feature/SESSION.md`** — what we did, what's next, blockers (always update)
- [ ] **`feature/README.md`** — bump version / schema / test count in the header if changed
- [ ] **`feature/todos/README.md`** — move completed items to "Recently completed"; add new todos
- [ ] **`feature/features/STATUS.md`** — if a module shipped or gaps closed
- [ ] **`feature/PICKUP.md`** — update version numbers in copy-paste prompts if changed
- [ ] **`BRANDING.md`** — add a phase line if a major milestone shipped
- [ ] **Todo detail doc** — mark checklist items `[x]` or archive doc if fully done

## What to update when

| Change | Update |
|---|---|
| Shipped a feature | `SESSION.md`, `features/STATUS.md`, `todos/README.md`, `BRANDING.md` phase |
| Fixed a known gap | Remove or downgrade in `todos/`, update `features/STATUS.md` |
| New pending work discovered | Add row to `todos/README.md` + create `todos/FOO.md` if non-trivial |
| Drift schema bump | `README.md` header, `features/STATUS.md`, `PICKUP.md` prompts |
| `pubspec.yaml` version bump | `README.md`, `feature/README.md`, `PICKUP.md`, `BRANDING.md` |
| VPS deploy | Note in `SESSION.md` + relevant `deploy/` todo doc |
| Tests added/removed | Bump count in `feature/README.md` + `PICKUP.md` |
| Firebase / store / content progress | Check boxes in the specific `todos/*.md` |

## `SESSION.md` format

Keep it short — one screen max:

```markdown
# Last session

**Date:** YYYY-MM-DD
**Version:** 0.1.0+4 · schema v8 · 84 tests

## Done this session
- Bullet list

## Next up (recommended)
1. Highest priority item + link to todo doc

## Blockers / waiting on
- e.g. "Firebase project not created yet"

## Quick resume prompt
(copy-paste block for fresh chat)
```

## New todo doc template

Create `feature/todos/SHORT_NAME.md` when work needs more than one line in the queue:

```markdown
# Todo — title

> **Priority:** P? · **Status:** Not started | In progress | Blocked

## Problem
## Implementation plan
## Verify
## Key files
```

Then link from `todos/README.md`.

## Agent instruction (for every session)

**Start:** Read `feature/SESSION.md` → `feature/todos/README.md` → linked todo doc.

**End:** Run the checklist above. Never leave `SESSION.md` stale.

## Files that stay stable (rarely touch)

| Doc | When to edit |
|---|---|
| `START_HERE.md` | Mission/architecture changes only |
| `roadmaps/VERSION.md` | Version boundaries shift (0.1 → 0.2) |
| `BRANDING.md` colors/identity | Brand decisions only |