# Audit report and register templates

Use mode-verify.md and execution-contract.md. Reports preserve their original
verdict and evidence; later resolution updates retain that history.
A correction has the same seven top-level fields and detailed content as a
phase sub-phase in output-template.md.

## Report

````markdown
# <Feature> — Audit V<NNN>

Date: <date>. Auditor: <actual configured reviewer>.
Plan: <path/ID/revision>. Reviewed scope: <units/phases>.
Baseline/range: <commits>; owned/uncommitted/pre-existing changes: <details>.
Verdict: PASS | PASS WITH FINDINGS | FAIL | INCOMPLETE.
Scope limitations: <none or concrete missing evidence>.

## Phase and unit results
| Unit/phase | Claimed | Verified | Evidence/findings |
|------------|---------|----------|-------------------|

## Findings
### V<NNN>-F<n> — <title>
- Status: OPEN | FIXED | ACCEPTED | OBSOLETE — <resolution date/evidence if any>
- Severity: BLOCKER | MAJOR | MINOR
- Category: missing | divergent | untested | failing-gate | rule-violation |
  scope-creep | regression | stale-state | unfixed-regression
- Where: <path:symbol/line and plan unit/decision/invariant>
- Expected: <approved requirement>
- Actual: <concrete repository or command evidence>
- Impact: <effect>
- Correction: <correction unit ID>

## Previous findings
| ID | Previous status | Current status | Rechecked evidence |
|----|-----------------|----------------|--------------------|

## Verified clean
| Dimension/unit | What was checked | Evidence |
|----------------|------------------|----------|

## Gate results
| Gate | Command/cwd | Applicability | Result/discovery | Tested revision/diff |
|------|-------------|---------------|------------------|----------------------|

## Ad-hoc reconciliation
| Ledger ID / unexplained change | Plan impact | Evidence / findings |
|-------------------------------|-------------|---------------------|

## Correction plan
Readiness: READY | BLOCKED — <supervisor validation, or unresolved questions,
affected correction IDs, resolution owner and exact next action>.
<No unresolved contract or acceptance choice may be labelled READY.>
### C<n> — <outcome; closes finding IDs>
- **Model:** <configured implementer>
- **Assignment:** <responsibility; strong reviewer and timing>
- **Files:** <exact read/write paths, symbols, existing/NEW>
- **Change:**
  Belongs to: <phase/sub-phase or outside plan>.
  Reopens: <completed phase IDs, or none>.
  Preconditions: <correction/unit IDs and artifacts>.
  Local contract: <decisions, invariants, interface/error/compatibility behavior>.
  S1 — <action>; expected <postcondition>.
  S2 — <action>; expected <postcondition>.
  Checkpoint: <meaningful boundaries, next step>.
  Failure/escalation: <known handling, supervisor for missing design>.
- **Unit tests:** <name/path, fixture, exact assertions, command/discovery>
- **e2e tests:** <same detail, or justified N/A>
- **Done:** finding rechecked and closed with evidence, required gates/review pass,
  affected phase revalidation scheduled/completed, state/register/report updated,
  configured completion commit resolved.

## State reconciliation
<Exact readiness/progress/evidence/blocker corrections; reference to the complete
suspended implementation snapshot in STATE.md §12, when applicable.>

## Not verifiable
<Unperformed mandatory checks and why; unproved doubts; or none.>
````

## verify/index.md

````markdown
# <Feature> — Audit register

## Historical reports
| ID | File | Date | Original verdict | Original counts | Auditor |
|----|------|------|------------------|-----------------|---------|

Verdicts: PASS, PASS WITH FINDINGS, FAIL, INCOMPLETE. Historical counts/verdicts
are not recomputed as findings are fixed; current unresolved findings are below.

## Findings
| ID | Severity | Title | Current status | Closed by / date | Evidence |
|----|----------|-------|----------------|------------------|----------|

Statuses: OPEN, FIXED, ACCEPTED (user decision), OBSOLETE (reason recorded).
Never silently remove a finding. Update the source report's resolution too.

## Open blockers
<IDs and affected units, or none.>
````
