# Audit templates — verify report and audit register

Written by `verify` (and re-statused by `execute verify`) into
`<plan-folder>/verify/`, created on demand. Plan-file templates live in
`output-template.md`; ledger templates in `templates-ledger.md`.

`<angle brackets>` = replace. `…` = repeat the block as needed.

---

## 1. verify/verify_<NNN>_<YYYY-MM-DD>.md — the report

Written into `<plan-folder>/verify/` (created on demand), with the same content
printed in chat. `<NNN>` = highest existing report number plus one, zero-padded;
earlier reports are never overwritten or renumbered. The filename carries the bare
number, the report ID carries the prefix (`V<NNN>`), and finding IDs are global
and stable: `V<NNN>-F<n>`.

Durable artifact: its correction plan must be executable later by
`/plan-execute-verify execute verify`, from this file alone, in a fresh session —
written to the same standard as a phase file's sub-phase.

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
| V<NNN>-F<n> | `verify_<NNN>_<date>.md` | `MAJOR` | <title> | `FIXED | OPEN | ACCEPTED | OBSOLETE` | <path:line or command output> |

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

Executable by `/plan-execute-verify execute verify` (or `execute verify V<NNN>`
for an older report) from this file alone. One block per correction, blockers
first.

### C<n> — closes <V<NNN>-F<n>>
- **Severity:** `BLOCKER | MAJOR | MINOR`
- **Belongs to:** `phase_<NN>.md § <N.Y>` (or `T-A<NNN>` / outside any phase)
- **Reopens a DONE phase:** yes/no — <if yes, the phase goes back to `IN_PROGRESS`>
- **Files:** `path:line`, …
- **Change:** <the smallest change that closes the finding, step by step>
- **Test:** `<test name>` — <assertion that proves the finding is closed>
- **Done:** <checkable condition> + gates green + closed in `STATE.md` (§4 ledger, §11 board) + `index.md` updated

## State re-sync

<Exact edits `STATE.md` (§1, §4, §7, §8, §9, §11) and the ledgers need to match
reality. "none — state accurate" when they already do.>

## Not verifiable

<What could not be checked and why. Flagged doubts with no repo evidence go here,
never in Findings.>
- none
````
---

## 2. verify/index.md — the audit register

The entry point of the audit trail. `verify` creates it with the first report,
appends on every run, and updates finding statuses; `execute verify` updates the
status of every finding it closes. Stays small — a register, not a copy of the
reports. A later session reads **this file** to know what is still open, without
opening any report.

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
