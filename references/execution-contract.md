# Execution contract — autonomy, handoffs, reviews, and commits

Read for `execute`, `execute verify`, `task`, and `bug`; `verify` reads it for
recovery, ownership, and audit closure. Plan mode uses it to initialize the
runtime contract. Copy the cold-start rules and resolved settings into generated
`STATE.md`: a later executor may not have this skill installed.
Onboard may consult this contract to interpret records, but does not run its
state-changing recovery or completion steps; mode-onboard.md governs that mode.

## 1. Resolve the invocation once

`full-autonomous:true|false` is a leading option, accepted by every mode.
Precedence: explicit invocation > selected plan's STATE.md §3 > `false`.
Reject other values and duplicate occurrences before making changes. The value
persists in §3; in `000_adhoc` it is per invocation and recorded in the ledger.
Parsing ends at the first non-option/non-agent token; occurrences in a task's
description are literal text. An explicit value overrides the persisted value.
Exception: Onboard only observes saved configuration. Its options and agent
prefix are invocation-local and never persist to a plan or an ad-hoc ledger.

| Mode | Scope when true | Completion commits |
|------|-----------------|--------------------|
| Onboard | Inspect context and suggest a next action; never execute that action or alter saved settings | None, including with WIP enabled |
| Plan | Produce the requested plan; record the setting for execution | None; planning does not start implementation |
| Execute | Continue through eligible sub-phases and phase closures within the selected scope | Every completed sub-phase and phase closure |
| Execute verify | Apply the selected report's corrections; revalidate affected phases | Every completed correction and reopened phase closure |
| Task / bug | Finish the requested change, tests, documentation, and reconciliation | Every completed task / bug |
| Verify | Complete the audit, including an honest FAIL or unverified result | Audit artifacts and state only; never automatic code corrections |

With `false`, normal mode behavior continues and may yield at a verified unit
boundary with a precise handoff; this option adds no commit authorization.
With `true`, a routine unit boundary does not end the selected scope. The
existing WIP option still applies independently:

| Full autonomous | WIP commits | Commit completed code units | Commit interrupted work |
|-----------------|-------------|-----------------------------|-------------------------|
| false | off | No | No |
| false | on | Yes | Yes |
| true | off | Yes | No |
| true | on | Yes | Yes |

`--no-wip-commit` disables interruption commits, not autonomous completion
commits. Onboard never commits; WIP alone never commits audits or planning.
Neither setting authorizes pushes, deployments, destructive cleanup, or changes
outside the requested scope.

In operational modes, persist the requested scope (plan, phase, sub-phase, task,
bug, or report), the configured roster, and the selected execution style: `handoff` (successive
sessions/models) or `delegated` (coordinator and workers). A new explicit selector
replaces the scope; a context reset or resume does not expand it. Preserve the
plan's next eligible unit separately from the current invocation's scope.

## 2. Ownership and cold starts

There is one state writer and one active implementation unit per plan. In
delegated execution, the coordinator owns STATE.md, shared ledgers, plan edits,
and commits. A worker edits only its assigned code/test/doc files and returns
evidence. Its assigned OPEN unit is active work, not an abandoned unit to revert.
In handoff execution, the current session owns the state; transfer ownership only
after the previous writer has stopped. Independent read-only probes may overlap.

At startup:
1. Read STATE.md; identify plan ID/revision, scope, role, roster, current unit,
   step cursor, checkpoint, repository path, branch, and immutable plan baseline.
2. Inspect the current diff, staged changes, and unit base. Separate pre-existing
   changes from this unit's edits. Never infer ownership merely from a filename.
3. Reconcile incomplete closure transactions and any OPEN unit before selecting
   new work. An unrelated WIP commit is not this plan's work; match its plan and
   unit identity. Do not revert, amend, or overwrite work with uncertain ownership.
   Exception: an explicitly requested Verify may suspend implementation using
   the snapshot protocol below; it audits pending closure without finalizing or
   committing that implementation on its behalf.
   If a new explicit scope excludes unfinished OPEN work, do not finish that code
   just to clear the slot or overwrite its checkpoint. Report the conflict and
   request direction; only Verify has the suspension exception below.
4. Read the named sub-phase plus its local contracts and approved revisions.
   Check prerequisite sub-phase rows, required artifacts, and applicable gates.
   A moved line is a locator change: find the named symbol and inspect its actual
   contract. A changed interface or behavior needs supervisor review.
5. Resume from the first unverified step. Check the recorded postcondition before
   rerunning a migration, generator, or other step that may not be idempotent.

For older plans, the supervisor upgrades the touched phase and state metadata
before implementation. Derive completed sub-phases from the ledger and repository
evidence, never from a phase-level DONE alone. Record uncertain items as BLOCKED;
do not rewrite historical work as newly completed.

### Auditing suspended implementation

Only the state owner may suspend an OPEN or pending-commit implementation unit
for an explicitly requested audit. Before replacing §1/§6, save STATE.md §12:
the complete prior §1 record, active scope/result, unit/attempt, plan revision,
owner, branch/base and owned/pre-existing changes, complete §6 checkpoint,
pending commit reference, and evidence/review references. Keep its board rows;
do not mark it DONE. Capture the snapshot and open the audit in one state update.
No nested suspension; delegated workers cannot initiate this transition.

During the audit the snapshot is immutable. After reporting, restore the prior
unit/scope/checkpoint, attach audit blockers, and revalidate against the current
diff/revision; do not restore stale phase/test statuses over audit corrections.
Mark the snapshot restored only after that state update. Record the audit closure
alongside it. A crash with an OPEN audit resumes the audit; a completed audit with
an unresolved required audit commit finishes only that audit transaction before
returning to implementation. Do not advance or finalize the suspended code's
pending commit merely because the audit completed.

## 3. Work loop and checkpoints

Choose the next ordered, eligible unit inside the scope; dependencies must be
DONE, or explicitly waived by the supervisor with preserved requirements.
SKIPPED does not implicitly satisfy a dependency. Open the unit before editing,
mark its phase IN_PROGRESS, record its base and owned paths, and name step S1.

Execute the numbered steps and check each expected result. Update §6 after each
meaningful edit/test batch, before delegation, before a long-running operation,
and before yielding. Record completed steps, next step, actual changed files,
pending edits, last verification, and any process/resource that must be resumed
or cleaned up. A crash can precede the next checkpoint: always inspect the diff
on resume, even when §6 still says `claimed — nothing written yet`.

After implementation, run the unit gates and required review, reconcile affected
plan files and docs, and close the unit using §6 below. Continue without asking
for permission to start the next already-authorized unit. With full autonomy,
do not stop merely because a sub-phase or phase ended.

For planned phase work, a specifically named dependent README sub-phase may
fulfil its documentation obligation later in that phase. Keep the obligation
visible and pending until then; unit completion is not phase/feature completion.
Tasks, bugs, and corrections include their affected documentation in their own
completion transaction rather than inventing a future documentation task.

A phase has a separate closure unit `P<N>`: all its sub-phases are DONE or
explicitly SKIPPED with a justification; its README obligation, phase gates, and
strong-supervisor review are complete. Record the review and phase result in
STATE.md, then commit the closure when full autonomy is true. This is a real
state change, not an empty ceremonial commit. Completing a selected sub-phase
does not authorize executing remaining sub-phases; its containing phase may be
closed if all requirements are already satisfied and review is in scope.

Stop at the selected scope's verified completion, an explicit user stop, or a
documented blocker requiring unavailable capability/authority. The last phase
also requires the reference scenario and final integration gates. Record
`Scope result: COMPLETE` only then. Never label unverified work complete.
If the host ends a session, save a handoff; this skill cannot start a new host
session by itself.
With full autonomy false, a verified unit boundary may instead yield a handoff;
record that the selected scope is still RUNNING, not COMPLETE.

## 4. Decisions, supervisor escalation, and retry limits

The strong supervisor remains responsible during execution: it reviews every
phase and every explicitly marked high-risk sub-phase. Any configured worker,
including the weakest, may implement complex code only after the supervisor
has specified the algorithm, interfaces, invariants, failure cases, and tests.
The worker must not supply missing architecture implicitly.

Workers may resolve mechanical locator changes and implementation details
expressly left open by the plan. Missing contracts, contradictory requirements,
unexpected cross-module effects, and failed design assumptions go to the strong
supervisor with: unit/step, expected vs actual, minimal evidence, attempts,
affected dependents, and proposed options.

The supervisor may amend technical decisions and remaining steps autonomously
within the user's approved requirements, observable behavior, and scope. Record
the new plan revision, superseded decision, reason, affected units, and required
revalidation; update their local contract excerpts. It cannot weaken acceptance
criteria or retroactively rewrite an executed specification to excuse a failure.
User decisions are needed only for a changed product requirement, scope, or
external authority. Existing authorization remains valid across sessions.

After two unsuccessful fixes for the same failure, escalate with the evidence;
do not repeat the same attempt or loosen tests. The supervisor can specify a new
approach and a fresh bounded retry budget. If the configured supervisor is not
available, persist a precise handoff and mark the unit BLOCKED; a weaker worker
must not claim a strong review or silently substitute itself.

Review evidence includes reviewer identity, unit/plan revision, reviewed change
identity (commit or base plus owned diff/checkpoint), inspected invariants, result,
and any follow-up. Edits affecting reviewed behavior invalidate that review.

## 5. Verification appropriate to the current stage

Define baseline, unit, phase, and final gates separately. Each gate records its
exact command, cwd, setup, activation unit, assertions/test IDs, and applicability.
Run baseline checks before the first edit; at resume rerun checks affected by the
actual diff or uncertain previous evidence. Do not require a future test target
before the sub-phase that creates it. `not-applicable-yet` is not `pass`.

For test gates, confirm the intended tests were discovered and executed; an exit
code of zero with zero selected tests does not prove the unit. Record command,
result, tested revision/diff, and relevant test count or named evidence. An
unavailable service/credential is `blocked`, not `pass` or a waived gate. Known
baseline failures must be recorded and assessed by the supervisor; never conceal
a new failure among them. A mandatory unresolved failure prevents completion.

The implementer cannot delete, skip, broaden tolerances, or weaken required tests
to get green. A proven defective test needs supervisor-authorized correction
that preserves the acceptance requirement and records the before/after evidence.

An audit is different from an implementation: it completes when the agreed
inspection is performed and findings/limitations are recorded, even if its
verdict is FAIL. This closes the audit, not the audited phases. Use
`INCOMPLETE` when mandatory inspection cannot be performed; do not issue PASS.

## 6. Completion transaction and Git identity

Use a stable identity: plan folder ID (or `000_adhoc`), unit ID, and attempt
number. Reopened work increments the attempt; a retry after interruption does
not. Record these identity trailers on completion and WIP commits:

```text
PEV-Plan: <plan-id>
PEV-Unit: <unit-id>
PEV-Attempt: <n>
PEV-Result: complete | wip
```

Suggested subjects (adapt to the repository's convention without losing meaning):
`sub-phase(1.2): complete quota validation`,
`phase(1): complete limiter integration and review`,
`task(T-A001): complete --json output`, `bug(B-A001): fix missing-config exit`,
`correction(V001-C1): complete Retry-After assertion`,
`verify(V001): complete audit; FAIL, 1 blocker`.

1. Check gates/review and finish all coherence updates before staging. Record the
   closed unit, evidence, next eligible unit, and ledger commit reference
   `unit:<id>:<attempt>` in the same proposed snapshot. When commits are disabled,
   record `uncommitted`. Do not try to embed a commit's own SHA inside itself.
   If completion commits are disabled, closure ends here; do not run steps 2–4.
2. Stage only owned changes and their plan records. Include required plan files
   created for this request during an earlier planning session once their
   provenance is established; otherwise a fresh checkout could lack its contract.
   Being inside the plan folder alone does not establish ownership.
   Preserve pre-existing hunks
   even in a file this unit also edits. Inspect the staged diff; unrelated staged
   changes must not enter the commit. If they cannot be isolated safely, keep the
   work recoverable and report a blocker rather than sweeping them in.
3. Commit on the current branch; do not create/switch branches, push, or make an
   empty duplicate commit. Confirm the branch still matches the unit's recorded
   branch before committing; unexpected changes require reconciliation. For
   detached HEAD, persist a blocker instead of inventing a branch.
4. Resolve the ledger reference using the unique reachable completion commit
   matching all four trailer values exactly in its trailer block, within current
   HEAD's ancestry. Do not use subject text or substring matches (1.2 is not 1.20).
   Zero matches means pending closure; multiple matches mean an identity conflict
   to reconcile, not permission to choose one arbitrarily or add another commit.
   Confirm the commit contains the intended owned diff
   and state. Report its actual SHA; no extra bookkeeping commit is necessary.
   An existing resolved identity means this unit was already committed.

The reference in the committed snapshot resolves to that commit; the SHA may be
recorded by a later genuine update but is not required. If interrupted after
step 1 but before commit, the unresolved reference means closure is pending:
resume/reconcile that same attempt and finish the transaction before new work;
this recovery is not a reopening and must not increment the attempt.
If interrupted after commit, resolve it and continue without committing twice.
An explicitly requested audit can suspend that implementation transaction as
specified in §2; unresolved audit closure is recovered before restoring execution.

With WIP enabled, interruption commits carry `PEV-Result: wip` and §1 remains
OPEN. Finish into a completion commit; amend only an owned, local-only WIP at
HEAD, otherwise append. Inspect current changes as well as the WIP diff. Full
autonomy alone never requires committing broken or unreviewed work.
