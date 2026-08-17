# Output templates — multi-file plan structure

The plan is a **folder**, not a single file.
Path: always `docs/plans/<NNN>_plan-<FeatureName>/` under the repo root.
`docs/` and `docs/plans/` are created if missing — plans never land in the repo
root. `<NNN>` is the next free zero-padded 3-digit sequence number (`001` first,
then `002`, …), so the folder listing shows the plan order.

Files to produce (plan mode; verify writes §5's report and the §8 register under
`verify/`; task/bug append to the §6/§7 ledgers — all created on demand):
1. `overview.md` — routing doc, small
2. `resume.md` — progress tracker, small, LLM-readable
3. `phase_01.md`, `phase_02.md`, … — one per phase, detailed
4. `STATE.md` — detailed live execution state, initialized at plan creation,
   read first at every session start, updated after every sub-phase

Full folder shape once the other modes have run:

```
docs/plans/<NNN>_plan-<FeatureName>/
├── overview.md
├── resume.md
├── STATE.md
├── phase_01.md, phase_02.md, …
├── tasks.md                       # §6 — created by the first `task`
├── bugs.md                        # §7 — created by the first `bug`
└── verify/                        # created by the first `verify`
    ├── index.md                   # §8 — audit register, statuses of every finding
    └── verify_<VNNN>_<date>.md    # §5 — one durable report per audit
```

`<angle brackets>` = replace. `…` = repeat block as needed.

---

## 1. overview.md

Small routing doc. `agent-1` authors this, or the single configured agent in
single-agent mode. Goal: an agent can cold-start from this file alone and know
where to go.

````markdown
# <Feature name> — Plan Overview

> **Status:** planning | **Supervisor authored:** <date>
> **Folder:** `docs/plans/<NNN>_plan-<FeatureName>/`
> **Executing this plan? Read [STATE.md](STATE.md) FIRST** — it holds the live
> position, environment, in-flight work, and the next action. Update it after
> every sub-phase.

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
`D7 (user, Q3)`. Anything the user deferred goes below, not into a silent guess.

## Open questions

| # | Question | Assumed default in this plan | Affects |
|---|----------|------------------------------|---------|
| Q<n> | <deferred question> | <default applied> | phase <N> § <N.Y> |

<"none — all clarifications resolved" when the user answered everything.>

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
````

---

## 2. resume.md

Machine-readable progress tracker. Small. LLM-reads this to cold-start or resume.
`agent-1` initializes; the assigned implementer updates after every sub-phase.

````markdown
# <Feature name> — Resume

> **Next:** phase_<NN>.md § <X.Y> — <sub-phase title>
> **Last updated:** <date>
> Status board only. Full execution state lives in [STATE.md](STATE.md); on any
> disagreement, STATE.md wins. Update both after every sub-phase.

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
| README.md | `TODO` | user guide — updated at the end of every phase |
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

## State contract (mandatory)

1. Before touching anything: read [STATE.md](STATE.md) and confirm it points at
   a sub-phase in this phase. Re-run the gate commands in STATE.md §7 to verify
   the recorded state matches the repo.
2. After **every** sub-phase below: update `STATE.md` (position, ledger, files
   touched, in-flight work, verification, deviations, `Next action:`,
   timestamp) and sync `resume.md`. A sub-phase is not done until this is done.
3. If the session ends mid-sub-phase, write exactly what is half-finished into
   `STATE.md` §6 before stopping.

---

## Sub-phases

### <N.1> <Sub-phase title>
- **Model:** <agent-N:name | agent:name | legacy default>
- **Assignment:** <agent-N:name — responsibility, or self-review in single-agent mode>
- **Files:** `path:line`, …
- **Change:** <precise change. Cite reuse anchors: `path:line — symbol`. Cite the
  external facts this sub-phase depends on as `R<n> — <fact> (<URL>)`, so the
  file stays self-contained.>
- **Unit tests:** `test_name` — <what it asserts>; …
- **e2e tests:** T-<ID> — <observable pass/fail criterion>; or "none (no behavior change)"
- **Done:** gates green (`<fmt>`, `<lint -D warnings>`, `<test>`) + <specific regression that must still pass> + `STATE.md` and `resume.md` updated

### <N.2> …

### <N.last> Update README.md

Mandatory closing sub-phase of every phase. User guide only — no implementation
detail.

- **Model:** <agent-3+:name when present, else agent-2:name>
- **Assignment:** <agent-N:name — documentation; agent-1 reads it on the final phase>
- **Files:** `README.md` (repo root, or the project's existing README)
- **Change:** update these sections for what **this phase actually made usable**:
  <list the exact sections, e.g. "Usage → new `<cmd>` sub-command", "Configuration
  → `<VAR>` (default `<x>`)", "Limitations → <constraint>">.
  Include: what it does, install/requirements, how to run, commands and flags
  with realistic examples and expected output, configuration and defaults,
  notes, known limits, troubleshooting.
  Exclude: module/class/function names, file layout, algorithms, refactoring
  notes, phase or plan references, unshipped roadmap.
  Preserve the existing README structure, tone, and language; edit, do not rewrite.
  <If the phase ships nothing user-visible: "No user-visible change in this
  phase — verify the README is still accurate and leave it unchanged; record
  that verification in STATE.md.">
- **Unit tests:** none (documentation) — <or a docs/link/example check if the repo has one>
- **e2e tests:** none — the examples in the README were executed and produced the documented output
- **Done:** a new user can install and use this phase's feature from the README
  alone, with no source reading; no implementation detail present; gates green;
  `STATE.md` and `resume.md` updated

---

## Phase gates

- **Fmt:** `<command>`
- **Lint:** `<command>`
- **Test subset:** `<command>`
- **Regression guard:** <T-IDs that must still pass>
- **README:** updated for this phase's user-visible behavior (or explicitly
  verified as still accurate), free of implementation detail

## Phase done criterion
<Concrete, checkable statement. Observable behavior or test ID that proves this phase is complete.> README.md reflects this phase's shipped behavior.
````

---

## 4. STATE.md

The live execution state. `agent-1` **initializes this file at plan creation**
(sections 0–3 filled, 4–9 empty, `Next action:` = first sub-phase). Every
implementer rewrites it after every sub-phase. It is self-describing on
purpose: an agent with an empty context that opens only this file must be able
to continue correctly.

Rules: one line per ledger entry, no code dumps, no narrative. The only
verbatim text allowed is failing gate/test output. Keep the ledger append-only;
compress older rows to one line each rather than deleting them.

````markdown
# <Feature name> — Implementation State

> **READ THIS FILE FIRST at the start of every session, before any other plan
> file. UPDATE IT after every sub-phase and before any session ends.**
> **Last updated:** <date time> | **By:** <agent-N:name> | **Session:** <n>

## 0. Protocol

**Resume (cold start):**
1. Read this file end to end.
2. Re-run the commands in §3 gates / §7 to verify the repo matches what §1 and
   §7 claim. The repo is the truth; correct this file if it drifted.
3. Open only the phase file named in §1 `Next action:`, at the named sub-phase.
   Read `overview.md` only if §2 is insufficient for the work at hand.
4. If §6 is non-empty, finish or revert that in-flight work before starting
   anything new.

**Update (after every sub-phase, mandatory):** rewrite §1, append to §4, update
§5 §6 §7, add rows to §8 if the plan was deviated from, refresh §9 §10, bump
the header timestamp, then sync `resume.md`. A sub-phase is not `DONE` until
this is written.

## 1. Current position

- **Phase:** <N — title> (`phase_<NN>.md`) — status `<TODO|IN_PROGRESS|DONE>`
- **Sub-phase:** <N.Y — title> — status `<...>`
- **Next action:** `phase_<NN>.md` § <N.Y> — <first concrete step, imperative>
- **Assigned:** `agent-N:<name>`
- **Repo state:** branch `<branch>` | working tree `<clean|dirty>` | last commit `<sha> <subject>`

## 2. Feature context (self-contained recap)

<3-6 lines: goal and end state. Enough to execute without opening overview.md.>

**Reference scenario:** <concrete observable acceptance test>
**Hard constraints:** <backward-compat, perf, no-new-deps, …>
**Key decisions in force:** D<n> <one line each — only those affecting remaining work>

## 3. Environment and commands

- **Repo root:** `<path>`
- **Build:** `<cmd>` · **Fmt:** `<cmd>` · **Lint:** `<cmd>`
- **Unit tests:** `<cmd>` · **E2E:** `<cmd>`
- **Setup / caveats:** <env vars, services, ports, rebuild or permission quirks>

## 4. Work ledger (append-only, one line per sub-phase)

| # | Phase.Sub | Agent | What changed | Files | Gates | Commit |
|---|-----------|-------|--------------|-------|-------|--------|
| 1 | <N.Y> | `agent-N:<name>` | <one line> | <n files> | `green|red` | `<sha|uncommitted>` |

## 5. Files touched

| Path | What was done | Phase.Sub |
|------|---------------|-----------|
| `<path>` | <created / modified: what> | <N.Y> |

## 6. In-flight work

<`none — tree consistent`, or: exactly what is half-finished — edits written,
edits still pending, temporary code or TODO markers to remove, why it stopped.>

## 7. Verification state

| Gate / test | Command | Last result | When |
|-------------|---------|-------------|------|
| <fmt|lint|unit|T-ID> | `<cmd>` | `pass|fail|not-run` | <date> |

**Failing output (verbatim, trimmed to the error):**
```
<none>
```

## 8. Runtime deviations from the plan

| # | Plan said | What was done | Why | Impact on later phases |
|---|-----------|---------------|-----|------------------------|

## 9. Blockers and open questions

<Questions the user deferred at the clarification gate, each with the default
applied and the sub-phase it affects; plus anything blocking execution now.>
- none

## 10. Do-not-repeat

<Dead ends already tried and rejected, with the one-line reason. Prevents a
resumed session from re-spending tokens on a known-bad path.>
- none
````

---

## 5. verify/verify_<VNNN>_<YYYY-MM-DD>.md (verify mode only)

Written by `/plan-execute-verify verify` into `<plan-folder>/verify/` (created on
demand), with the same content printed in chat. `<VNNN>` is the next free
3-digit report number; earlier reports are never overwritten or renumbered.
Finding IDs are global and stable: `V<NNN>-F<n>`.

The report is a durable artifact: its correction plan must be executable later
by `/plan-execute-verify execute verify`, from this file alone, in a fresh session.
Write the corrections to the same standard as a phase file's sub-phase.

````markdown
# <Feature name> — Verification report

> **Report:** `V<NNN>` | **Verdict:** `PASS | PASS WITH FINDINGS | FAIL`
> **Date:** <date> | **Auditor:** <agent-1:name>
> **Plan:** `docs/plans/<NNN>_plan-<FeatureName>/` | **Register:** [index.md](index.md)
> **Reviewed:** phases <list> | commits `<sha>..<sha>` | tree `<clean|dirty>`
> **Carried over:** <n> findings still `OPEN` from earlier reports

## Phase results

| Phase | Claimed | Verified | Findings |
|-------|---------|----------|----------|
| <N — title> | `DONE` | `DONE | PARTIAL | DIVERGENT | NOT_DONE` | <n> (<b> blocker) |

## Findings

### V<NNN>-F<n> — <one-line title>
- **Status:** `OPEN` <updated to `FIXED` / `ACCEPTED` / `OBSOLETE` when closed, with date and evidence>
- **Severity:** `BLOCKER | MAJOR | MINOR`
- **Category:** missing · divergent · untested · failing-gate · rule-violation · scope-creep · regression · stale-state · unfixed-regression
- **Where:** `path:line` — plan ref `phase_<NN>.md § <N.Y>` (or `D<n>` / `I-<n>` / `T-<ID>` / `R<n>` / `T-A<NNN>` / `B-A<NNN>`)
- **Expected:** <one line, quoted from the plan>
- **Actual:** <one line, evidence from the repo>
- **Impact:** <why it matters>
- **Correction:** <the concrete fix>

## Findings carried over

| ID | From | Severity | Title | Status now | Evidence |
|----|------|----------|-------|------------|----------|
| V<NNN>-F<n> | `verify_<VNNN>_<date>.md` | `MAJOR` | <title> | `FIXED | OPEN | ACCEPTED | OBSOLETE` | <path:line or command output> |

## Verified clean

| Dimension | Result | Evidence |
|-----------|--------|----------|
| Completeness / Fidelity / Tests / Gates / Decisions / Invariants / External facts / Plan rules / Scope / State / Ad-hoc reconciliation / Previous findings | `ok` | <command output or `path:line`> |

## Gate results

| Gate | Command | Result |
|------|---------|--------|
| fmt / lint / unit / e2e | `<cmd>` | `pass | fail | could-not-run` |

## Ad-hoc work

| ID | What it changed | Reconciled with the plan? | Findings |
|----|-----------------|---------------------------|----------|
| T-A<NNN> / B-A<NNN> | <one line> | yes / no — <what is missing> | <finding IDs or none> |

<Plus any diff hunk explained by neither the plan nor a ledger entry.>

## Correction plan

Executable by `/plan-execute-verify execute verify` from this file alone. One block per
correction, ordered blockers first.

### C<n> — closes <V<NNN>-F<n>>
- **Severity:** `BLOCKER | MAJOR | MINOR`
- **Belongs to:** `phase_<NN>.md § <N.Y>` (or `T-A<NNN>` / outside any phase)
- **Reopens a DONE phase:** yes/no — <if yes, the phase goes back to `IN_PROGRESS`>
- **Files:** `path:line`, …
- **Change:** <the smallest change that closes the finding, step by step>
- **Test:** `<test name>` — <assertion that proves the finding is closed>
- **Done:** <checkable condition> + gates green + `STATE.md` / `resume.md` /
  `index.md` updated

## State re-sync

<Exact edits `STATE.md`, `resume.md`, and the ledgers need to match reality. "none — state accurate" when they already do.>

## Not verifiable

<What could not be checked and why. Flagged doubts with no repo evidence go here, never in Findings.>
- none
````

---

## 6. tasks.md (task mode ledger)

Created on demand in the plan folder by the first `/plan-execute-verify task`. Append
only; entries are never edited away. This is what tells a later `verify` that an
out-of-plan change was intentional.

````markdown
# <Feature name> — Task ledger

> Out-of-plan changes made with `/plan-execute-verify task`. Append-only.
> IDs are never reused. Every entry must be reconciled with the plan.

## T-A<NNN> — <one-line title>
- **Date:** <date> | **Agent:** <agent-N:name>
- **Request:** <what the user asked for, one line>
- **Change:** <what was actually done, one line per file group>
- **Files:** `path:line`, …
- **Tests:** `<test name>` — <assertion>; or "none — <explicit reason>"
- **Gates:** `<cmd>` → pass | fail
- **README:** updated `<sections>` | not user-visible
- **Plan impact:** none | <what was reconciled: superseding `D<n>`, adjusted
  `I-<n>`, edited `phase_<NN>.md § <N.Y>`, sub-phase marked `SKIPPED`, new
  sub-phase added>
- **Related:** phase <N> § <N.Y> (or "outside any phase")
````

---

## 7. bugs.md (bug mode ledger)

Same rules as `tasks.md`, plus the diagnosis. A bug entry without a root cause
and a regression test is incomplete.

````markdown
# <Feature name> — Bug ledger

> Defects fixed with `/plan-execute-verify bug`. Append-only.
> IDs are never reused. Every entry must be reconciled with the plan.

## B-A<NNN> — <one-line title>
- **Date:** <date> | **Agent:** <agent-N:name> | **Severity:** <blocker|major|minor>
- **Symptom:** <observable failure: command/input → wrong result>
- **Reproduction:** `<command or test that showed it>`
- **Root cause:** <one line> — `path:line`
- **Fix:** <what changed, one line per file group>
- **Files:** `path:line`, …
- **Regression test:** `<test name>` — fails before the fix, passes after
- **Gates:** `<cmd>` (full suite) → pass | fail
- **README:** updated `<sections>` | not user-visible
- **Plan impact:** none | <a plan assumption proved wrong: superseding `D<n>`,
  adjusted `I-<n>`, edited pending `phase_<NN>.md § <N.Y>` that shared the
  faulty assumption>
- **Related:** phase <N> § <N.Y> (or "outside any phase")
````

---

## 8. verify/index.md (audit register)

The entry point of the audit trail. `verify` creates it with the first report,
appends to it on every run, and updates finding statuses; `execute verify`
updates the status of every finding it closes. It must stay small — it is a
register, not a copy of the reports.

A later session reads **this file** to know what is still open, without opening
any report.

````markdown
# <Feature name> — Audit register

> Findings never disappear: they move to `FIXED`, `ACCEPTED`, or `OBSOLETE`,
> always with evidence. Statuses here and in the reports must agree.

## Reports

| # | File | Date | Verdict | Blocker | Major | Minor | Auditor |
|---|------|------|---------|---------|-------|-------|---------|
| V001 | [verify_001_<date>.md](verify_001_<date>.md) | <date> | `PASS WITH FINDINGS` | 0 | 2 | 1 | <agent-1:name> |

## Findings

| ID | Severity | Category | Title | Status | Closed by | Evidence |
|----|----------|----------|-------|--------|-----------|----------|
| V001-F01 | `MAJOR` | divergent | <one-line title> | `OPEN` | — | — |
| V001-F02 | `MAJOR` | untested | <one-line title> | `FIXED` | `execute verify` <date> | `<test name>` passes |

Status values: `OPEN` · `FIXED` · `ACCEPTED` (user decided to live with it, with
the reason) · `OBSOLETE` (no longer applies, with the reason)

## Open blockers
- none
````

---

## Notes on filling it well

- **overview.md stays small.** If detail creeps in, move it to the phase file.
- **resume.md is for the agent, not the user.** Dense, no prose. Update it after every sub-phase.
- **STATE.md is initialized by the planner, never left empty.** It is the only
  file guaranteed to be read on a cold start, so §0 §2 §3 must stand alone.
- **resume.md = status board; STATE.md = execution state.** No duplication of
  detail: resume.md holds statuses and the `Next:` line, STATE.md holds
  position, ledger, in-flight work, deviations, failures, dead ends. On
  disagreement, STATE.md wins.
- **phase files are the only place allowed to be long.** Anchors, precise changes, named tests — length here saves downstream re-exploration.
- **phase_NN numbering is 1-indexed, zero-padded** (`phase_01.md`, `phase_02.md`, …). Phase 0 (scaffolding) → `phase_01.md`.
- **Tests are not optional and not vague.** Name them. State the assertion.
- **Done-criteria must be checkable** by someone who didn't write the plan.
- **Mark behavior changes loudly.** If a default flips or an existing test must change, call it out with a blockquote in that sub-phase.
