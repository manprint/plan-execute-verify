# Verify — evidence-based audit without implementation

Read execution-contract.md, templates-audit.md, and the Verify checklist.
Verify writes reports, the finding register, correction rows, and truthful
STATE.md corrections. The audit itself never changes production code, rewrites
phase specifications, or applies fixes.
With full-autonomous:true it commits completed audit artifacts/state locally,
then applies the report's corrections in a separate pass (V6); otherwise it
does not commit, regardless of the WIP setting, and no correction follows. Explicit options and
roster apply to this audit only and are recorded in the report; they never change
§3 or the saved execution scope.

## V1 — Recover and identify the claim

`verify [<plan>] [<scope>]` audits the whole plan without a scope. A scope
narrows it to one phase (`phase_02`, with its sub-phases and P<N>), one
sub-phase (`1.2`), or one ledger entry (`T-A004`, `B-A002`). A scoped audit
inspects the selected units plus the interfaces, dependents, and previous
findings they touch; every dimension applies within that scope. Its verdict
covers only that scope and never stands for the whole plan.

`000_adhoc` is auditable as a whole ledger or by entry ID. It has no STATE.md:
its verify/index.md records the open audit and its checkpoint, and corrections
become ready Task/Bug requests citing their finding IDs instead of correction
units. The resulting ledger entry marks the finding FIXED with evidence;
`execute verify` does not apply to `000_adhoc`. Read its ledgers and
verify/index.md where a real plan reads STATE.md, and close the audit there.
Auditing an OPEN ad-hoc entry suspends nothing: its own ledger checkpoint stays
authoritative, and the audit only inspects it.

Resolve the plan and runtime settings. Read STATE.md first, respecting ownership
and OPEN-unit recovery. An audit of incomplete implementation does not require
finishing that implementation first: the state owner explicitly checkpoints it
and records the complete suspended-unit snapshot in STATE.md §12 before opening
the audit. Do not lose its step/checkpoint. Restore the suspended context on audit
closure using the execution contract, with findings attached.

Read overview.md, relevant phase files, tasks.md/bugs.md, and verify/index.md.
Within the audit scope, audit every DONE, IN_PROGRESS, IN_REVIEW, or BLOCKED
unit and any changed area mapped to the plan, even if its phase is erroneously
still TODO. Check readiness, revision history, scope, prerequisites, actual
review evidence, and commit policy. PROPOSED and WITHDRAWN ledger entries claim
no implementation: report them, never as incomplete closure.

Open the audit unit V<NNN> as the invocation; the saved execution scope stays
unchanged. Record the audited baseline/range and dirty changes;
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
Resolve required completion commits by plan/unit/attempt/result trailers, and a
`handoff:<id>:<attempt>` reference by the handoff commit's `PEV-Includes`
(execution-contract §6); legacy valid SHA references are also acceptable. An
unresolved required commit reference is incomplete closure, not a reason to
invent a SHA or commit on the unit's behalf.

Run applicable gates on the current tree, recording actual results and limitations.
Do not treat tests from future units as currently required. Never turn an
unavailable check into PASS.

## V3 — Audit dimensions

Cover:
1. Completeness of claimed units, steps, wiring, and phase acceptance.
2. Fidelity to approved requirements and the relevant plan revision.
3. Tests: exact assertions, execution/discovery, negative cases, no weakening.
4. Gates: current results and applicability.
5. Decisions/invariants, compatibility, supervisor-approved technical revisions,
   and high-power internal decisions staying within their contracts.
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
verify_<NNN>_<YYYY-MM-DD>.md, report ID V<NNN>. Findings have stable IDs
V<NNN>-F<n>, unique within their plan or ledger and never reused. Do not
overwrite old reports.

Severity:
- BLOCKER: the audited scope cannot be accepted or dependent work cannot proceed
  safely: a required behavior missing or broken, a mandatory gate failing, a
  regression of existing behavior, a security or data-integrity defect, or a
  false DONE/commit claim that later units rely on.
- MAJOR: a confirmed deviation from an approved requirement, decision, invariant,
  required test, review, or documentation obligation that does not block
  dependent work but prevents the affected unit or phase from counting as
  verified, including state errors that would misdirect a resume.
- MINOR: a confirmed issue that changes no approved behavior, acceptance
  evidence, or recovery path, such as a convention deviation or imprecise but
  not misleading text.

Assign the highest level whose definition the evidence fully meets and record
the impact that justifies it.

Verdict rules:
- FAIL: at least one confirmed BLOCKER or MAJOR.
- INCOMPLETE: no confirmed BLOCKER/MAJOR, but mandatory audit evidence is missing.
- PASS WITH FINDINGS: required checks complete; MINOR findings only.
- PASS: required checks complete; no unresolved findings in the audited scope.

If a FAIL audit also has missing evidence, list that limitation explicitly.
The historical verdict does not change when later fixes land.

Write corrections as complete units with the same seven fields as a sub-phase
(templates-audit.md), calibrated to the plan's executor power (mode-plan D):
Agent, Assignment (worker and reviewer), Files, Change (prerequisites, local
decisions, numbered steps), Unit tests and e2e tests (oracles and commands), and
Done. Map each correction to findings and
affected phases; flag phase reopening and required revalidation. Order by
dependencies and severity. Do not leave design beyond that level's latitude to
the correction executor.
Apply the same readiness rule to correction plans: READY only after their
contracts and prerequisites are validated. If a correction depends on an
unresolved product decision or unavailable evidence, label it BLOCKED with the
question, owner, and next action; under full autonomy agent-1 decides a
product question as an autonomous decision (execution-contract §4), recorded in
the report, and the correction is READY once its contract is validated. The audit may still close truthfully; it must
not present that correction as executable or invent an answer to finish the
report. Add one STATE.md §11 Corrections row per correction: TODO, or BLOCKED
with its question (none in `000_adhoc`).

Update verify/index.md with new findings, evidence-based status updates, report
metadata, and open blockers. FIXED requires proof; ACCEPTED requires the user's
decision; OBSOLETE requires a reason. Mirror resolution in the source report.

## V5 — Close the audit

Finish the agreed inspection and honestly record its result, including FAIL or
INCOMPLETE. Close the audit unit with its ledger row, verification evidence,
findings/blockers, progress corrections, and next action. Restore suspended work
if any; do not lose its checkpoint. Failed phases/tests remain failed or blocked.
A `handoff` request or `--deadline` instead keeps the audit OPEN with its
checkpoint and makes no commit (mode-handoff.md).

Under full-autonomous:true commit only owned audit/state changes on the current
branch using the completion transaction. The subject states the audit verdict.
This commits a finished inspection, not unverified implementation. Never stage
uncommitted production changes merely because the audit inspected them.

With full-autonomous:false no correction follows. Report the verdict, counts,
limitations, report path, commit when created, and the command to apply
corrections (in `000_adhoc`, the ready Task/Bug commands), and end with the
Next block (next-step.md). Use the report as the durable detailed output;
avoid duplicating it in full in chat. With true, continue with V6 first and
report once at its end.

Run the Verify checklist before the final response.

## V6 — Autonomous correction pass

With full-autonomous:true, once the audit is closed and its commit resolved,
the same run applies the report's READY corrections without a new audit:

- Real plan: exactly as `execute verify <plan> V<NNN>` (mode-execute.md E5):
  correction units with focused validation, reopened phases closed again with
  full gates and review, completion commits. The saved execution scope stays
  unchanged; the corrections run under this Verify invocation, recorded in §1.
  A suspended implementation restored at V5 is recovered and closed first, in
  its own mode (execution-contract §2).
- `000_adhoc`: each ready Task/Bug request runs as a Task or Bug entry
  (mode-taskbug.md), in dependency and severity order.
- Follow the autonomy loop (execution-contract §3). A correction still BLOCKED
  and a finding that only the user may mark ACCEPTED stay OPEN and are
  reported, never bypassed. A `handoff` or deadline stops the pass as it stops
  Execute verify (mode-handoff.md).

The final report covers the audit and the corrections: verdict, fixed and
still-open findings, gates, commits, autonomous decisions, and the Next block.
