# Plan file templates — the multi-file plan structure

The plan is a **folder**, not a single file, at the path given by SKILL.md's
plan-folder convention. This file holds the three templates plan mode writes;
`templates-ledger.md` holds the `task` / `bug` ledgers and
`templates-audit.md` the `verify` report and register.

Writing order in plan mode: `overview.md`, then the phase files, then `STATE.md`.
The section numbers below are this file's, not the writing order.

`STATE.md` is the **single** execution-state file: position, progress board,
ledger, in-flight work, deviations, blockers. There is no second status file.

Full folder shape once the other modes have run:

```
docs/plans/<NNN>_plan-<FeatureName>/
├── overview.md                    # §1 — routing doc, small
├── phase_01.md, phase_02.md, …    # §2 — one per phase, detailed
├── STATE.md                       # §3 — the live execution state, read first
├── tasks.md                       # created by the first `task`  (templates-ledger.md)
├── bugs.md                        # created by the first `bug`   (templates-ledger.md)
└── verify/                        # created by the first `verify` (templates-audit.md)
    ├── index.md                   # audit register, status of every finding
    └── verify_<NNN>_<date>.md     # one durable report per audit
```

Repos with no plan keep ad-hoc work in `docs/plans/000_adhoc/`, **ledger-only**:
`tasks.md` and `bugs.md` and nothing else. Never a `verify` or `execute` target.

`<angle brackets>` = replace. `…` = repeat the block as needed.

---

## 1. overview.md

Small routing doc, authored by `agent-1` (or the single configured agent). Goal:
an agent can cold-start from this file alone and know where to go.

````markdown
# <Feature name> — Plan Overview

> **Status:** planning | **Authored:** <date> by `agent-1:<name>`
> **Folder:** `docs/plans/<NNN>_plan-<FeatureName>/`
> **Executing this plan? Read [STATE.md](STATE.md) FIRST** — it is the only
> execution-state file: live position, progress board, environment, in-flight
> work, next action. Open a unit in it before touching code, close it after.

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

Rows answered by the user at the clarification gate carry the source, e.g.
`D7 (user, Q3)`. Anything the user deferred goes below, never into a silent guess.
A decision superseded during execution gets a new row marked as superseding the
old one, with reason and date; the deviation itself is recorded in `STATE.md` §8.

## Open questions

| # | Question | Assumed default in this plan | Affects |
|---|----------|------------------------------|---------|
| Q<n> | <deferred question> | <default applied> | phase <N> § <N.Y> |

<"none — all clarifications resolved" when the user answered everything.>

## Architecture summary
<2–4 lines. Core mechanism, data flow, key constraints. Details live in phase files.>

## Interface

| Surface | Name | Type / values | Default | Notes |
|---------|------|---------------|---------|-------|
| <CLI flag / API / config key / env var> | `<exact name>` | `<type>` | `<default>` | <conflict rules, validation> |

<"none — no user-facing surface changes" when the work adds no interface.>

## Protocol and data-structure changes

| Change | Shape | Backward-compat strategy |
|--------|-------|--------------------------|
| <wire format, schema, on-disk layout, public struct> | <new/changed shape, one line> | <version gate, migration, default that preserves old behavior> |

<"none — no protocol or persisted-data change" when nothing crosses a boundary.>

## Phases

| Phase | File | Primary assignment | Shippable alone? |
|-------|------|--------------------|------------------|
| 0 — <Scaffolding> | [phase_01.md](phase_01.md) | `agent-3:<name>` | yes |
| 1 — <First slice> | [phase_02.md](phase_02.md) | `agent-2:<name>` | yes |

Live status of every phase is in `STATE.md` §11, never duplicated here.

## Reuse map (top candidates)

| Need | Reuse | Location |
|------|-------|----------|
| <capability> | <symbol> | `path:line` |

## References (external documentation consulted)

| # | What it settled | Source | Version / date |
|---|-----------------|--------|----------------|
| R1 | <the fact this URL established, one line> | <URL> | <lib version or doc date> |

<"none — no external contract touched" when the work is purely internal.>
Unverified points are marked `UNVERIFIED` and appear in **Open questions**.

## Invariants
- **I-1:** <invariant the change must not break>
- **I-2:** …

## Risk register

| Risk | Mitigation |
|------|-----------|
| <risk> | <mitigation + which phase proves it> |

## Verification summary

| Gate | Command | Where it runs |
|------|---------|---------------|
| fmt / lint / unit / e2e | `<cmd>` | <every phase, or the phase that introduces it> |

**Acceptance:** the reference scenario is proven by <T-ID, T-ID> — <one line each
on the assertion that makes it observable>.
**Run caveats:** <rebuild, ports, credentials, serial execution — or "none">.
These commands are identical to `STATE.md` §3; they must not drift.

## Model-assignment summary

| Phase | Sub-phases by assignment | Primary | `agent-1` review gates |
|-------|--------------------------|---------|------------------------|
| 0 | <N.1, N.2 → `agent-3:<name>`> | `agent-3:<name>` | — |
| 1 | <1.1 → `agent-2:<name>`> | `agent-2:<name>` | 1.1 (hot path) |

<In single-agent mode every row names the same `agent:<name>` and the review
column reads "self-review".>
````

---

## 2. phase_XX.md

One file per phase, 1-indexed and zero-padded (phase 0 → `phase_01.md`).
Detailed and self-contained — the implementer opens only this file, cold, without
`overview.md`. `agent-1` authors all phase files before handing off. **The only
files allowed to be long.**

````markdown
# Phase <N> — <Title>

> **Intent:** <one line. What this phase accomplishes.>
> **Shippable alone?** yes/no — <why>
> **Preconditions:** phase_<prev> DONE (or "none")

## State contract (mandatory)

1. Before touching anything: read [STATE.md](STATE.md). If §1 `Status` is `OPEN`,
   finish or revert that unit first (§6 says how far it got). Run the gate
   commands in STATE.md **§3** and check the result against what §1, §7, and §11
   claim; the repo wins, so correct the file when they disagree.
2. **Open the sub-phase in STATE.md §1 before editing any code**: `Type:
   sub-phase`, its `ID`, `Status: OPEN`, `Intent`, `Next action:`, and §6 set to
   `claimed — nothing written yet`.
3. **Close it after the gates are green**: append the §4 ledger row, reset §6 to
   `none — tree consistent`, update §5 §7 §8 §9 §10 and the §11 board, point §1
   at the next unit with `Status: none`, bump the timestamp. When STATE.md §3 has
   WIP commits on, commit the closed sub-phase and put its sha in the §4 row. A
   sub-phase is not done until this is written.
4. If the session ends mid-sub-phase, leave §1 `OPEN` and write exactly what is
   half-finished into §6 before stopping — plus a `wip(<N.Y>)` commit when WIP
   commits are on.

---

## Sub-phases

### <N.1> <Sub-phase title>
- **Model:** <agent-N:name | agent:name | legacy default>
- **Assignment:** <agent-N:name — responsibility, or self-review in single-agent mode>
- **Files:** `path:line`, …
- **Change:** <precise change. Cite reuse anchors: `path:line — symbol`. Cite the
  external facts this sub-phase depends on as `R<n> — <fact> (<URL>)`, so the file
  stays self-contained.>
- **Unit tests:** `test_name` — <what it asserts>; …
- **e2e tests:** T-<ID> — <observable pass/fail criterion>; or "none (no behavior change)"
- **Done:** gates green (`<fmt>`, `<lint -D warnings>`, `<test>`) + <specific regression that must still pass> + closed in `STATE.md` (§1 → next unit, §4 ledger row, §6 `none`, §11 board)

### <N.2> …

### <N.last> Update README.md

Mandatory closing sub-phase of every phase. User guide only — no implementation
detail.

- **Model:** <agent-3+:name when present, else agent-2:name>
- **Assignment:** <agent-N:name — documentation; agent-1 reads it on the final phase>
- **Files:** `README.md` (repo root, or the project's existing README)
- **Change:** update these sections for what **this phase actually made usable**:
  <the exact sections, e.g. "Usage → new `<cmd>` sub-command", "Configuration →
  `<VAR>` (default `<x>`)", "Limitations → <constraint>">.
  Include: what it does, install/requirements, how to run, commands and flags with
  realistic examples and expected output, configuration and defaults, notes, known
  limits, troubleshooting.
  Exclude: module/class/function names, file layout, algorithms, refactoring notes,
  phase or plan references, unshipped roadmap.
  Preserve the existing README structure, tone, and language; edit, do not rewrite.
  <If the phase ships nothing user-visible: "No user-visible change in this phase —
  verify the README is still accurate and leave it unchanged; record that
  verification in STATE.md.">
- **Unit tests:** none (documentation) — <or a docs/link/example check if the repo has one>
- **e2e tests:** none — the examples in the README were executed and produced the documented output
- **Done:** a new user can install and use this phase's feature from the README
  alone, with no source reading; no implementation detail present; gates green;
  closed in `STATE.md` with the §11 docs row set for this phase

---

## Phase gates

- **Fmt:** `<command>`
- **Lint:** `<command>`
- **Test subset:** `<command>`
- **Regression guard:** <T-IDs that must still pass>
- **README:** updated for this phase's user-visible behavior (or explicitly
  verified as still accurate), free of implementation detail

## Phase done criterion
<Concrete, checkable statement. Observable behavior or test ID that proves this
phase is complete.> README.md reflects this phase's shipped behavior, and
`STATE.md` §11 shows this phase `DONE` with every sub-phase closed.
````

---

## 3. STATE.md

The **single** live execution-state file. `agent-1` **initializes it at plan
creation** (§0–§3 and §11 filled, §4–§10 empty-but-shaped, §1 `Status: none` with
`Next action:` = first sub-phase, §9 carrying any question the user deferred at
the clarification gate). Every unit of work opens and closes in it.
Self-describing on purpose: an agent with an empty context that opens only this
file must be able to continue correctly.

Bounded: one line per ledger entry, no code dumps, no narrative. The only
verbatim text allowed is failing gate/test output. The ledger is append-only —
compress older rows to one line rather than deleting them.

````markdown
# <Feature name> — Implementation State

> **READ THIS FILE FIRST at the start of every session, before any other plan
> file. OPEN a unit in §1 before touching code; CLOSE it after the gates pass.**
> **Last updated:** <date time> | **By:** <agent-N:name> | **Session:** <n>

## 0. Protocol

This is the only execution-state file — position, progress, ledger, and blockers
all live here. A **unit of work** is one sub-phase, one `task`, one `bug`, one
`verify` audit, or one correction from a verify report.

**Resume (cold start):**
1. Read this file end to end.
2. Read §1 `Status`:
   - `OPEN` — a unit was claimed and may be half-written. Read §6, then finish or
     revert it before starting anything new. If §3 has WIP commits on and `HEAD`
     is a `wip:` commit, that commit is the in-flight work: its diff is what got
     written, §6 says why it stopped. Finish and `amend` into the close commit,
     or revert it.
   - `none` — nothing in flight. Open the unit named in §1 `Next action:`.
3. Run the gate commands in §3 and compare the result with what §1, §7, and §11
   claim. The repo is the truth; correct this file if it drifted.
4. Open only the file §1 points at: the phase file at the named sub-phase, or the
   verify report for a correction. Read `overview.md` only if §2 is insufficient.

**Open a unit — before touching code, mandatory:** set §1 `Type`, `ID`,
`Status: OPEN`, `Intent`, `Next action:`, `Assigned`; set §6 to `claimed —
nothing written yet`; bump the header timestamp. Only then edit anything.

**Close a unit — after its gates are green, mandatory:** append a §4 ledger row;
reset §6 to `none — tree consistent`; update §5, §7, §8, §9, §10 and the §11
board; set §1 to the next unit with `Status: none`; bump the timestamp. When §3
has WIP commits on, commit the closed unit — code, tests, this file, docs, ledger
together — staging only the files in §5 plus the plan files, never `git add -A`,
and record the sha in the §4 row. A unit is not `DONE` until this is written.

**Interrupted mid-unit:** leave §1 `OPEN` and write into §6 exactly what is
half-finished — files written, edits still pending, temporary code to remove.
`OPEN` with an empty §6 is an execution bug. With WIP commits on, also commit
that state as `wip(<id>): <what remains>`.

## 1. Current unit

- **Type:** `sub-phase | task | bug | verify | correction`
- **ID:** <N.Y | T-A<NNN> | B-A<NNN> | V<NNN> | V<NNN>-C<n>>
- **Status:** `OPEN` | `none`
- **Intent:** <one line: what this unit changes>
- **Phase:** <N — title> (`phase_<NN>.md`) — or `n/a — out-of-plan work`
- **Next action:** <the next concrete step, imperative. When `Status: none`, the next unit to open.>
- **Assigned:** `agent-N:<name>`
- **Repo state:** branch `<branch>` | working tree `<clean|dirty>` | last commit `<sha> <subject>`

## 2. Feature context (self-contained recap)

<3–6 lines: goal and end state. Enough to execute without opening overview.md.>

**Reference scenario:** <concrete observable acceptance test>
**Hard constraints:** <backward-compat, perf, no-new-deps, …>
**Key decisions in force:** D<n> <one line each — only those affecting remaining work>

## 3. Environment and commands

The authoritative gate commands. Identical to the phase gates and to
`overview.md`'s verification summary — no drift.

- **Repo root:** `<path>`
- **Build:** `<cmd>` · **Fmt:** `<cmd>` · **Lint:** `<cmd>`
- **Unit tests:** `<cmd>` · **E2E:** `<cmd>`
- **Setup / caveats:** <env vars, services, ports, rebuild or permission quirks>
- **WIP commits:** `off` <or `on` — set <date> by `agent-N:<name>`. When `on`,
  every closed unit is committed locally on the current branch and an
  interruption leaves a `wip(<id>)` commit. Never pushed.>

## 4. Work ledger (append-only, one row per closed unit)

Every unit type shares this ledger, in the order it closed. `ID` is the sub-phase
(`N.Y`), the ad-hoc ledger ID (`T-A<NNN>` / `B-A<NNN>`), the report (`V<NNN>`), or
the correction (`V<NNN>-C<n>`). `Commit` is the sha when one exists, `uncommitted`
otherwise — with WIP commits off this skill does not commit on its own, so
`uncommitted` is the honest value.

| # | Type | ID | Agent | What changed | Files | Gates | Commit |
|---|------|----|-------|--------------|-------|-------|--------|
| 1 | `sub-phase` | <N.Y> | `agent-N:<name>` | <one line> | <n> | `green|red` | `<sha|uncommitted>` |
| 2 | `task` | T-A001 | `agent-N:<name>` | <one line> | <n> | `green` | `uncommitted` |
| 3 | `verify` | V001 | `agent-1:<name>` | <verdict + finding counts> | 0 | `red` | — |

## 5. Files touched

| Path | What was done | Unit |
|------|---------------|------|
| `<path>` | <created / modified: what> | <N.Y | T-A<NNN> | …> |

## 6. In-flight work

<`none — tree consistent`, or `claimed — nothing written yet`, or: exactly what is
half-finished — edits written, edits still pending, temporary code or TODO markers
to remove, why it stopped.>

## 7. Verification state

| Gate / test | Command | Last result | When |
|-------------|---------|-------------|------|
| <fmt|lint|unit|T-ID> | `<cmd>` | `pass|fail|not-run` | <date> |

**Failing output (verbatim, trimmed to the error):**
```
<none>
```

## 8. Runtime deviations from the plan

One row per deviation, including a superseded `D*` decision (the new row itself
goes in `overview.md`) and every edit made to a not-yet-executed phase file.

| # | Plan said | What was done | Why | Impact on later phases |
|---|-----------|---------------|-----|------------------------|

## 9. Blockers and open questions

<Questions the user deferred at the clarification gate, each with the default
applied and the unit it affects; every `OPEN` `BLOCKER` finding by ID; plus
anything blocking execution now.>
- none

## 10. Do-not-repeat

<Dead ends already tried and rejected, with the one-line reason. Prevents a
resumed session from re-spending tokens on a known-bad path.>
- none

## 11. Progress board

Whole-plan status at a glance. Updated when a unit closes; never allowed to
disagree with §1 and §4.

### Phases

| Phase | File | Status | Notes |
|-------|------|--------|-------|
| 0 — <title> | phase_01.md | `TODO` | — |
| 1 — <title> | phase_02.md | `TODO` | — |

Status values: `TODO` · `IN_PROGRESS` · `DONE` · `SKIPPED` · `BLOCKED`
A `SKIPPED` sub-phase or phase keeps its row and carries the reason.

### Tests

| ID | Type | Status | Notes |
|----|------|--------|-------|
| T-<ID>1 | unit | `TODO` | <what it asserts> |
| T-<ID>2 | e2e | `TODO` | <observable criterion> |

### Docs

One row per phase README sub-phase, so a partially documented feature is visible;
other docs get their own rows.

| Doc | Phase | Status | Notes |
|-----|-------|--------|-------|
| README.md | 0 | `TODO` | <sections that phase touches, or "no user-visible change"> |
| <other doc> | <N> | `TODO` | — |

### Audits

One row per verify report, so the audit history is visible from the entry point.
Findings themselves live in `verify/index.md`.

| Report | Date | Verdict | Open findings |
|--------|------|---------|---------------|
| <none yet> | — | — | — |
````

---

## Filling these well

- **overview.md stays small.** If detail creeps in, move it to the phase file.
- **STATE.md is initialized by the planner, never a stub.** It is the only file
  guaranteed to be read on a cold start, so §0 §2 §3 must stand alone.
- **One state file, no second status board.** Position, progress, ledger,
  blockers, and audit history are all in `STATE.md`. Nothing outside it may claim
  a status, so nothing can disagree with it.
- **§1 is a claim, not a report.** It is written before the work, so an
  interrupted session finds either `OPEN` with §6 explaining how far it got, or
  `none` with a `Next action:`. There is no third state. With WIP commits on, the
  `wip:` commit at `HEAD` carries the same information as a diff, which is
  stronger than prose: §6 explains, git proves.
- **Phase files are the only place allowed to be long.** Anchors, precise changes,
  named tests — length here saves downstream re-exploration.
- **Tests are not optional and not vague.** Name them. State the assertion.
- **Done-criteria must be checkable** by someone who did not write the plan.
- **Mark behavior changes loudly.** A flipped default or an existing test that
  must change gets a blockquote in that sub-phase.
