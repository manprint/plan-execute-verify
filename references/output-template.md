# Output templates — multi-file plan structure

The plan is a **folder**, not a single file.
Path: `docs/plans/plan_<FeatureName>/` (or `plan_<FeatureName>/` in repo root if no `docs/`).

Files to produce:
1. `overview.md` — routing doc, small
2. `resume.md` — progress tracker, small, LLM-readable
3. `phase_01.md`, `phase_02.md`, … — one per phase, detailed

`<angle brackets>` = replace. `…` = repeat block as needed.

---

## 1. overview.md

Small routing doc. `agent-1` authors this, or the single configured agent in
single-agent mode. Goal: an agent can cold-start from this file alone and know
where to go.

````markdown
# <Feature name> — Plan Overview

> **Status:** planning | **Supervisor authored:** <date>
> **Folder:** `docs/plans/plan_<FeatureName>/`

## Goal
<One paragraph. End state. Observable acceptance criterion.>

```
<Reference scenario: concrete invocation / inputs → expected outputs>
```

## Design decisions

| # | Decision | Consequence |
|---|----------|-------------|
| **D1** | <decision> | <what it forces in the code> |
| **D2** | … | … |

## Architecture summary
<2–4 lines. Core mechanism, data flow, key constraints. No detail — details live in phase files.>

## Phases

| Phase | File | Primary assignment | Shippable alone? |
|-------|------|-------|-----------------|
| 0 — <Scaffolding> | [phase_01.md](phase_01.md) | `agent-1:<name>` | yes |
| 1 — <First slice> | [phase_02.md](phase_02.md) | `agent-2:<name>` | yes |
| … | … | … | … |

## Reuse map (top candidates)
| Need | Reuse | Location |
|------|-------|----------|
| <capability> | <symbol> | `path:line` |

## Invariants
- **I-1:** <invariant the change must not break>
- **I-2:** …

## Risk register
| Risk | Mitigation |
|------|-----------|
| <risk> | <mitigation + which phase proves it> |
````

---

## 2. resume.md

Machine-readable progress tracker. Small. LLM-reads this to cold-start or resume.
`agent-1` initializes; the assigned implementer updates after every sub-phase.

````markdown
# <Feature name> — Resume

> **Next:** phase_<NN>.md § <X.Y> — <sub-phase title>
> **Last updated:** <date>

## Phase status

| Phase | File | Status | Notes |
|-------|------|--------|-------|
| 0 — <title> | phase_01.md | `TODO` | — |
| 1 — <title> | phase_02.md | `TODO` | — |

Status values: `TODO` · `IN_PROGRESS` · `DONE` · `SKIPPED` · `BLOCKED`

## Tests

| ID | Type | Status | Notes |
|----|------|--------|-------|
| T-<ID>1 | unit | `TODO` | <what it asserts> |
| T-<ID>2 | e2e | `TODO` | <observable criterion> |

## Docs
| File | Status | Notes |
|------|--------|-------|
| <doc> | `TODO` | — |

## Open blockers
- none

## Decisions changed at runtime
- none
````

---

## 3. phase_XX.md

One file per phase. Detailed, self-contained. Implementer opens only this file.
`agent-1` authors all phase files before handing off.

````markdown
# Phase <N> — <Title>

> **Intent:** <one-line. What this phase accomplishes.>
> **Shippable alone?** yes/no — <why>
> **Preconditions:** phase_<prev> DONE (or "none")

---

## Sub-phases

### <N.1> <Sub-phase title>
- **Model:** <agent-N:name | agent:name | legacy default>
- **Assignment:** <agent-N:name — responsibility, or self-review in single-agent mode>
- **Files:** `path:line`, …
- **Change:** <precise change. Cite reuse anchors: `path:line — symbol`.>
- **Unit tests:** `test_name` — <what it asserts>; …
- **e2e tests:** T-<ID> — <observable pass/fail criterion>; or "none (no behavior change)"
- **Done:** gates green (`<fmt>`, `<lint -D warnings>`, `<test>`) + <specific regression that must still pass>

### <N.2> …

---

## Phase gates

- **Fmt:** `<command>`
- **Lint:** `<command>`
- **Test subset:** `<command>`
- **Regression guard:** <T-IDs that must still pass>

## Phase done criterion
<Concrete, checkable statement. Observable behavior or test ID that proves this phase is complete.>
````

---

## Notes on filling it well

- **overview.md stays small.** If detail creeps in, move it to the phase file.
- **resume.md is for the agent, not the user.** Dense, no prose. Update it after every sub-phase.
- **phase files are the only place allowed to be long.** Anchors, precise changes, named tests — length here saves downstream re-exploration.
- **phase_NN numbering is 1-indexed, zero-padded** (`phase_01.md`, `phase_02.md`, …). Phase 0 (scaffolding) → `phase_01.md`.
- **Tests are not optional and not vague.** Name them. State the assertion.
- **Done-criteria must be checkable** by someone who didn't write the plan.
- **Mark behavior changes loudly.** If a default flips or an existing test must change, call it out with a blockquote in that sub-phase.
