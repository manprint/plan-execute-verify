# Verify — evidence-based audit without implementation

Read execution-contract.md, templates-audit.md, and the Verify checklist.
Verify writes reports, the finding register, and truthful STATE.md corrections.
It never changes production code, rewrites phase specifications, or applies fixes.
With full-autonomous:true it commits completed audit artifacts/state locally;
otherwise it does not commit, regardless of the WIP setting.

## V1 — Recover and identify the claim

Resolve the plan and runtime settings. Read STATE.md first, respecting ownership
and OPEN-unit recovery. An audit of incomplete implementation does not require
finishing that implementation first: the state owner explicitly checkpoints it
and records the complete suspended-unit snapshot in STATE.md §12 before opening
the audit. Do not lose its step/checkpoint. Restore the suspended context on audit
closure using the execution contract, with findings attached.

Read overview.md, relevant phase files, tasks.md/bugs.md, and verify/index.md.
Audit every DONE, IN_PROGRESS, IN_REVIEW, or BLOCKED unit and any changed area
mapped to the plan, even if its phase is erroneously still TODO. Check readiness,
revision history, scope, prerequisites, actual review evidence, and commit policy.

Open the audit unit V<NNN>. Record the audited baseline/range and dirty changes;
a commit range alone is insufficient when planned work is uncommitted.

## V2 — Gather evidence and run checks

Use focused repository inspection, optionally delegated in a batched read-only
probe. The strong auditor inspects critical contracts, diffs, and assertions
directly. State is a claim; worker summaries are evidence locators.

For relevant external assumptions, use [research.md](research.md). Check recorded
facts against the actual dependency versions/environment and refresh evidence
when stale, conflicting, or insufficient. Keep new evidence in the report with
source/version/dates and original R IDs; do not revise the plan's specifications
or conduct an unrelated architecture survey. Distinguish documented facts from
inferences/local observations. Missing required evidence is Not verifiable and
prevents PASS; a proven contradiction is an evidenced finding.

For each claimed completion verify the specified behavior, symbols/wiring, tests
and their discovery, docs, dependencies, required review, and applicable gates.
Resolve required completion commits by plan/unit/attempt/result trailers; legacy
valid SHA references are also acceptable. An unresolved required commit reference
is incomplete closure, not a reason to invent a SHA or commit on the unit's behalf.

Run applicable gates on the current tree, recording actual results and limitations.
Do not treat tests from future units as currently required. Never turn an
unavailable check into PASS.

## V3 — Audit dimensions

Cover:
1. Completeness of claimed units, steps, wiring, and phase acceptance.
2. Fidelity to approved requirements and the relevant plan revision.
3. Tests: exact assertions, execution/discovery, negative cases, no weakening.
4. Gates: current results and applicability.
5. Decisions/invariants, compatibility, and supervisor-approved technical revisions.
6. External facts against the documented pinned version.
7. Repository conventions and promised user-facing documentation.
8. Scope: unexplained changes, distinguishing pre-existing user changes.
9. Regressions and cross-phase integration.
10. State accuracy: sub-phase dependencies, checkpoints, reviews, scope, ownership,
    commit references, and phase closures.
11. Ad-hoc reconciliation: ledger changes reflected in affected future contracts.
12. Previous findings: recheck OPEN and FIXED; surface regressions without losing IDs.

Every finding needs concrete source/command evidence. Unproved doubts and checks
that could not run belong under Not verifiable, not invented findings.

## V4 — Save the report and executable corrections

Use the next unused report number (highest existing plus one), filename
verify_<NNN>_<YYYY-MM-DD>.md, report ID V<NNN>. Findings have stable global IDs
V<NNN>-F<n>, never reused. Do not overwrite old reports.

Verdict rules:
- FAIL: at least one confirmed BLOCKER or MAJOR.
- INCOMPLETE: no confirmed BLOCKER/MAJOR, but mandatory audit evidence is missing.
- PASS WITH FINDINGS: required checks complete; MINOR findings only.
- PASS: required checks complete; no unresolved findings in the audited scope.

If a FAIL audit also has missing evidence, list that limitation explicitly.
The historical verdict does not change when later fixes land.

Write corrections as complete units with the same seven-field contract as a
sub-phase: worker/reviewer, files, prerequisites, local decisions, numbered steps,
test oracles/commands, and done criterion. Map each correction to findings and
affected phases; flag phase reopening and required revalidation. Order by
dependencies and severity. Do not leave design for a weaker correction executor.
Apply the same readiness rule to correction plans: READY only after their
contracts and prerequisites are validated. If a correction depends on an
unresolved product decision or unavailable evidence, label it BLOCKED with the
question, owner, and next action. The audit may still close truthfully; it must
not present that correction as executable or invent an answer to finish the report.

Update verify/index.md with new findings, evidence-based status updates, report
metadata, and open blockers. FIXED requires proof; ACCEPTED requires the user's
decision; OBSOLETE requires a reason. Mirror resolution in the source report.

## V5 — Close the audit

Finish the agreed inspection and honestly record its result, including FAIL or
INCOMPLETE. Close the audit unit with its ledger row, verification evidence,
findings/blockers, progress corrections, and next action. Restore suspended work
if any; do not lose its checkpoint. Failed phases/tests remain failed or blocked.

Under full-autonomous:true commit only owned audit/state changes on the current
branch using the completion transaction. The subject states the audit verdict.
This commits a finished inspection, not unverified implementation. Never stage
uncommitted production changes merely because the audit inspected them.

No automatic correction follows verify, even in full autonomy. Report the verdict,
counts, limitations, report path, commit when created, and the command to apply
corrections. Use the report as the durable detailed output; avoid duplicating it
in full in chat.

Run the Verify checklist before the final response.
