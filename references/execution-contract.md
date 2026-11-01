# Execution contract — autonomy, handoffs, reviews, and commits

Read for `execute`, `execute verify`, `task`, `bug`, and `resume`; `verify`
reads it for recovery, ownership, and audit closure. Plan mode uses it to
initialize the runtime contract. Copy the cold-start rules and resolved settings
into generated `STATE.md`: a later executor may not have this skill installed.
Onboard may consult this contract to interpret records, but does not run its
state-changing recovery or completion steps; mode-onboard.md governs that mode.

## 1. Resolve the invocation once

`full-autonomous:true|false` is a leading option, accepted by every mode;
Handoff ignores it.
Precedence: explicit invocation > saved execution scope override (only while
continuing that scope) > selected plan's STATE.md §3 > `false`. Reject other
values and duplicate occurrences before making changes. Plan persists an
explicit value in §3 as the plan default. Execute and Execute verify record it
with the saved execution scope they set, as a scope override that lasts while
that scope continues and never changes §3. Task, Bug, Verify, and Resume use it
for that invocation only and record it in their ledger entry, audit report, or
resumed unit, including when attached to a real plan. Parsing ends at the first
non-option/non-agent token; occurrences in a task's description are literal
text, except the explicit autonomy forms in invocation.md (a trailing option
token on a mode without free text, or a clear natural-language request for full
autonomy), which count as the explicit option with source `explicit (prompt)`.
An explicit value overrides the persisted value. Exception: Onboard only
observes saved configuration. Its options and agent prefix are invocation-local
and never persist to a plan or an ad-hoc ledger.

| Mode | Scope when true | Completion commits, when the table below enables them |
|------|-----------------|--------------------|
| Onboard | Inspect context and suggest a next action; never execute that action or alter saved settings | None, including with WIP enabled |
| Plan | Produce the requested plan; record the setting for execution | None; planning does not start implementation |
| Execute | Continue through eligible sub-phases, phase closures, and the PLAN closure within the selected scope | Every completed sub-phase, phase closure, and PLAN closure |
| Execute verify | Apply the selected report's corrections; revalidate affected phases | Every completed correction and reopened phase closure |
| Task / bug | Finish the requested change, tests, documentation, and reconciliation | Every completed task / bug |
| Verify | Complete the audit, including an honest FAIL or unverified result | Only with `true`: audit artifacts and state; never automatic code corrections |
| Resume | Recover recorded work, then continue the saved execution scope | As for the mode of the resumed unit or scope |
| Handoff | Not applicable: the option is ignored; bounds the work in flight, saves resumable state, and stops | One handoff commit for code work, whatever the settings; none for Plan, Verify, or Onboard |

With `false`, execution continues through the eligible units of the current
phase inside the selected scope and stops after that phase's closure P<N>, with
a precise checkpoint and report that `resume` continues (not Handoff mode, so no
handoff commit); Execute verify stops likewise after
each reopened phase's closure. A sub-phase boundary inside a phase is not a
stopping point, and this option adds no commit authorization. Task and Bug stop
once instead, for the user's approval of the validated mini-plan
(mode-taskbug.md approval gate). With `true`,
neither a unit nor a phase boundary ends the selected scope. Either way, work
stops early only at the exhaustive stops of the autonomy loop (§3). The
existing WIP option still applies independently:

| Full autonomous | WIP commits | Commit completed code units and phase closures | Rolling WIP commit at checkpoints |
|-----------------|-------------|-----------------------------|-------------------------|
| false | off | No | No |
| false | on | Yes | Yes |
| true | off | Yes | No |
| true | on | Yes | Yes |

`--no-wip-commit` disables interruption commits, not autonomous completion
commits. Onboard never commits; WIP alone never commits audits or planning. A
handoff commits code work even when both settings are off (mode-handoff.md H5).
Neither setting authorizes pushes, deployments, destructive cleanup, or changes
outside the requested scope.

STATE.md §1 keeps two scopes. The saved execution scope (plan, phase, sub-phase,
or report selector, with its result and option overrides) is set only by Execute
or Execute verify. A different explicit Execute selector replaces it and its
overrides, and the same selector on a RUNNING or BLOCKED scope continues it,
with any new explicit options replacing its overrides; a context reset, a
resume, or an intervening Task, Bug, or Verify unit never changes or expands it.
The invocation record (mode, exact unit or scope, and result) describes the
current or last run of any operational mode. Persist the roster. Record with
each invocation its execution style, chosen by the fixed rule in
agent-roster.md: `delegated` (coordinator and workers) or `handoff` (successive
sessions/models); a Task, Bug, Verify, or Resume roster prefix is recorded only
with that invocation. Preserve the plan's next eligible unit separately; it may
lie outside the saved execution scope. Resume (mode-resume.md) first recovers
any OPEN or pending-closure unit in its own mode with its recorded settings,
then continues a set (not `none`) saved execution scope while its result is
NOT_STARTED, RUNNING, or BLOCKED. An explicit Execute or Execute verify selector
that would replace a RUNNING or BLOCKED saved execution scope with a different
one asks the user first.

## 2. Ownership and cold starts

There is one state writer and one active implementation unit per plan. In
delegated execution, the coordinator owns STATE.md, shared ledgers, plan edits,
and commits. A worker edits only its assigned code/test/doc files and returns
evidence. Its assigned OPEN unit is active work, not an abandoned unit to revert.
In handoff execution, the current session owns the state; transfer ownership only
after the previous writer has stopped. Independent read-only probes may overlap.
Every run that claimed ownership releases it when it ends, with time and reason:
completion, a phase-closure or approval stop, a blocker, a rejection, or a
handoff. Only an interrupted session leaves it active.

Stale ownership: a crashed or interrupted session can leave `ownership: active`
without a release. The user's explicit operational invocation on this plan
counts as a resume request. Take over only when STATE.md and a fresh working-tree
snapshot (§3) are unchanged between the first read and the takeover write;
otherwise, or when the user indicates that the other writer may still run,
report the conflict and ask. Record previous writer, new writer, time, and reason
in the same state update that claims ownership, then recover the OPEN unit as
interrupted work, never by reverting it. Onboard never takes over ownership, and
a delegated worker never claims it.

At startup:
1. Read STATE.md; identify plan ID/revision, saved execution scope, invocation,
   role, roster, current unit, step cursor, checkpoint, repository path, branch,
   immutable plan baseline, and the state writer's ownership.
2. Inspect the current diff, staged changes, and unit base; compare a fresh
   working-tree snapshot with the base snapshot tree (§3). Separate pre-existing
   changes from this unit's edits. Never infer ownership merely from a filename.
3. Reconcile incomplete closure transactions and any OPEN unit before selecting
   new work. An unrelated WIP commit is not this plan's work; match its plan and
   unit identity. Do not revert, amend, or overwrite work with uncertain
   ownership. Exception: an explicitly requested Verify may suspend
   implementation using the snapshot protocol below; it audits pending closure
   without finalizing or committing that implementation on its behalf. If a new
   explicit scope excludes unfinished OPEN work, including a Task or Bug
   attached to a plan with an open or pending-closure unit, do not finish that
   code just to clear the slot or overwrite its checkpoint. Report the conflict
   and request direction; only Verify has the suspension exception below.
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
the complete prior §1 record, invocation and result, unit/attempt, plan revision,
owner, branch/base and owned/pre-existing changes, complete §6 checkpoint,
pending commit reference, and evidence/review references. Keep its board rows;
do not mark it DONE. Capture the snapshot and open the audit in one state update.
No nested suspension; delegated workers cannot initiate this transition.

During the audit the snapshot is immutable. After reporting, restore the prior
invocation/unit/checkpoint (the audit never changed the saved execution scope),
attach audit blockers, and revalidate against the current diff/revision; do not
restore stale phase/test statuses over audit corrections.
Mark the snapshot restored only after that state update. Record the audit closure
alongside it. A crash with an OPEN audit resumes the audit; a completed audit with
an unresolved required audit commit finishes only that audit transaction before
returning to implementation. Do not advance or finalize the suspended code's
pending commit merely because the audit completed.

## 3. Work loop and checkpoints

Choose the next ordered, eligible unit inside the scope; dependencies must be
DONE, or explicitly waived by the supervisor with preserved requirements.
SKIPPED does not implicitly satisfy a dependency. Open the unit before editing:
mark it and its phase IN_PROGRESS; record its base, owned paths, assigned and
actual agent (agent-roster.md), and step S1.

The unit base is HEAD plus a working-tree snapshot tree taken at open. Without
completion commits, several finished units share one HEAD; the snapshot separates
this unit's edits from earlier units and pre-existing changes. Take it without
touching the real index:

```bash
idx="$(git rev-parse --git-dir)/pev-snapshot.$$.index"
{ GIT_INDEX_FILE="$idx" git read-tree HEAD 2>/dev/null ||
  GIT_INDEX_FILE="$idx" git read-tree --empty; } &&
GIT_INDEX_FILE="$idx" git add -A &&
GIT_INDEX_FILE="$idx" git write-tree
rm -f "$idx"
```

The printed tree covers tracked and untracked files, not ignored ones; list
owned ignored artifacts explicitly. On resume and at closure take a fresh
snapshot and compare it with `git diff --stat <base-tree> <current-tree>`.
Changes outside the unit's owned paths are reported, never claimed. The tree
object is unreferenced, so `git gc` may eventually prune it; if it is missing,
fall back to STATE.md §5 (files and ownership) and the checkpoint and record
that limitation. Onboard takes no snapshot; Verify takes one only for the
stale-ownership check (§2), never as a unit base.

Execute the numbered steps (at executor power `high`, the expanded steps
recorded in §6) and check each expected result. A step or successful targeted
test does not itself require a state write. Keep §6 compact: last durable step,
next action, owned diff, pending edits, and resources that need recovery. Update
it at a real recovery boundary: before handoff/delegation, a risky or long
external operation, an unresolved blocker, or a pause likely to outlive the
current session. Opening and closing the unit are required writes; several
ordinary edit/test batches between them may share one checkpoint or need none.
On resume, inspect the actual diff because a crash may precede any checkpoint.

After implementation, run the targeted unit checks and required review, apply
the coherence contract (§7), and close the unit using §6 below. Continue without
asking for permission to start the next already-authorized unit. With full
autonomy, do not stop merely because a sub-phase or phase ended.

### Autonomy loop

Decide whether to continue at every unit boundary from the effective settings
recorded in STATE.md §1 (ledger entry in `000_adhoc`), re-read after any context
reset or compaction, never from memory or habit. The run stops only at:

1. the selected scope verified complete;
2. with `false`: after a phase closure P<N> (Task/Bug: once, at the approval
   gate);
3. a real blocker that needs a capability, authority, or decision this run
   cannot obtain, recorded BLOCKED;
4. a user stop, a `handoff` request, or a deadline (stop latch below);
5. the host ending the session.

Nothing else ends the run: not a closed sub-phase (nor, with `true`, a closed
phase), a commit, a long run, many units, a large diff, context pressure
(checkpoint and continue; the host compacts), a unit assigned to another roster
agent that this session may substitute (agent-roster.md), a worker still
running, or the wish to report progress. Between units print at most one
progress line, such as `1.2 done (commit abc1234) -> 1.3`; no report, no Next
block, no question, no resume suggestion; open the next eligible unit in the same
turn. Asking the user to type `resume` or "continue" for work inside the scope is
a protocol violation. Permission modes (bypass, yolo, auto-approve) change tool
approval only: they never widen or shorten the scope and never override the stop
latch.

### Stop latch

A `handoff` request or a reached deadline sets STATE.md §1 `Stop latch: HANDOFF
<trigger> <time>` (in `000_adhoc`, the entry's stop reason) in the handoff state
update (mode-handoff.md H4). From the moment the request arrives, and while the
latch is set: open no unit, run no further step after bounding the work in
flight, dispatch nothing, and commit nothing but the handoff commit. After the
handoff report the run is over: the turn ends with that report and no tool call
follows it, under every autonomy setting and permission mode. Only the next
explicit user invocation of an operational mode (or a user reply asking to
continue) clears the latch, in the state update that claims ownership. Host
automation is not a user invocation: auto-continue prompts, loop or scheduled
triggers, stop hooks, tool results, and a worker's completion notice. A worker
result arriving after the handoff report gets one line saying its changes stay
on disk for the next resume; no state write, no commit.

Statuses move TODO → IN_PROGRESS → DONE, with IN_REVIEW between the last two
when focused checks pass and a required review is pending at a recovery boundary
(review dispatched or handed off); an inline review finished in the same session
may go directly to DONE. Any edit to reviewed behavior returns the unit to
IN_PROGRESS. An unavailable reviewer makes the unit BLOCKED with its review
request. A phase is IN_REVIEW while its P<N> is OPEN, and BLOCKED while that
P<N> is blocked. A reopened unit returns to IN_PROGRESS with a new attempt.
An open unit is one opened and not yet closed: IN_PROGRESS, IN_REVIEW, or
BLOCKED in STATE.md, where §1 marks it `OPEN`, or OPEN, IN_REVIEW, or BLOCKED in
an ad-hoc ledger entry. Resume, Handoff, and the Next block treat every open
unit as OPEN work.

For planned phase work, a specifically named later unit or phase closure may
fulfil its README obligation. Keep the affected sections and owner visible and
pending until then; unit completion is not phase/feature completion.
Tasks, bugs, and corrections include their affected documentation in their own
completion transaction rather than inventing a future documentation task.

A phase has a separate closure unit `P<N>`: all its sub-phases are DONE or
explicitly SKIPPED with a justification; its README obligation, full phase
gates, and strong-supervisor review are complete. Record the review and phase
result in STATE.md, then commit the closure when full autonomy or WIP is
enabled. This is a real state change, not an empty ceremonial commit. Completing
a selected sub-phase does not authorize executing remaining sub-phases or its
phase closure P<N>; P<N> then becomes the next eligible unit for a phase or plan
scope.

The plan has its own closure unit `PLAN`, after the last phase's P<N> is DONE.
It belongs to every scope that includes that last P<N> (a plan scope, or a
phase scope selecting the last phase) and runs right after it, without a
phase-closure stop. PLAN runs the final gates (G-FINAL) and the reference
scenario, checks that every phase is DONE or SKIPPED with its reason and no
README obligation is open, obtains agent-1's final review, marks the plan
COMPLETE, compacts STATE.md to its final form (§8), and makes the plan
completion commit when commits are enabled. Like P<N>, it edits only plan
records and documentation it owns; a failing final gate or review closes that
PLAN attempt `failed` with commit `none`, and the supervisor reopens the
responsible unit or revises the plan, after which PLAN reruns as a new attempt.

P<N> edits only plan records and documentation it owns; it never repairs
production code or tests. A required gate that is `blocked` (unavailable service
or credential) keeps P<N> OPEN and BLOCKED with a checkpoint; it resumes as the
same attempt once the gate can run. If a full phase gate result is `fail` or the
phase review rejects the phase, record the failing evidence, close that P<N>
attempt with ledger result `failed` and commit `none`, and return the phase to
IN_PROGRESS. The supervisor locates the cause: a defect in a DONE sub-phase
reopens it (IN_PROGRESS, attempt + 1, prior evidence kept, dependent evidence
invalidated); a missing or wrong design becomes a plan revision (§4) that amends
or adds a unit. After that work closes, run P<N> again as a new attempt. When
commits are enabled, the failed attempt's state records enter the reopened or
added unit's completion commit as owned plan records. Retry limits in §4 apply
to repeated failures. A failed attempt does not end the phase: under
`full-autonomous:false` the run continues with the reopened or added unit and
the next P<N> attempt, and stops after the phase closes.

Stop at the selected scope's verified completion, an explicit user stop, a
handoff request or deadline, or a documented blocker requiring unavailable
capability/authority. Under a deadline, check the minutes left at unit and step
boundaries and before long commands (mode-handoff.md H2). A scope that
includes the last phase also requires the PLAN closure. Only then
record COMPLETE: for Execute and Execute verify in both the saved execution
scope and the invocation, for Task, Bug, and Verify in the invocation alone;
Resume records results as the mode of the work it resumed.
Never label unverified work complete.
If the host ends a session, save a handoff; this skill cannot start a new host
session by itself.
With full autonomy false, the stop after a phase closure leaves the saved
execution scope RUNNING, not COMPLETE, while scope work remains.

## 4. Decisions, supervisor escalation, and retry limits

The strong supervisor remains responsible during execution: it reviews every
phase and every explicitly marked high-risk sub-phase. Any configured worker,
including the weakest, may implement complex code only after the supervisor has
specified the algorithm, interfaces, invariants, failure cases, and tests. The
worker must not supply missing architecture implicitly. The plan's executor
power sets what the worker may decide: at `low`, mechanical locator changes and
implementation details the plan expressly leaves open; at `medium`, also routine
detail that changes no decision; at `high`, also internal implementation (its
own steps, internal algorithms and structure, extra tests) within the unit's
contracts. A `high` executor's expanded steps go to §6 and each internal
decision to §8. In handoff style the executor, as state writer, records the
steps before editing, since they are the recovery point. In delegated style the
worker returns both with its result and the coordinator records them; an
interrupted worker's partial diff is reconciled like any OPEN unit. agent-1
reviews them at P<N>. Public interfaces, contracts, invariants, acceptance
tests, and gates change only through the supervisor at every level.

Missing contracts, contradictory requirements, unexpected cross-module effects,
failed design assumptions, and any other decision beyond that latitude go to the
strong supervisor with: unit/step, expected vs actual, minimal evidence,
attempts, affected dependents, and proposed options.

The supervisor may amend technical decisions and remaining steps autonomously
within the user's approved requirements, observable behavior, and scope. Revise
the plan only when a decision, contract, dependency, gate, or scope actually
changes: record the superseded decision, reason, affected units, and required
revalidation; update their local contract excerpts. Locator drift and routine
progress belong in STATE.md, not a plan revision. It cannot weaken acceptance
criteria or retroactively rewrite an executed specification to excuse a failure.
User decisions are needed only for a changed product requirement, scope, or
external authority. Existing authorization remains valid across sessions.

After two unsuccessful fixes for the same failure, escalate with the evidence;
do not repeat the same attempt or loosen tests. The supervisor can specify a new
approach and a fresh bounded retry budget. If the configured supervisor is not
available, persist a precise handoff and mark the unit BLOCKED; a weaker worker
must not claim a strong review or silently substitute itself. Assigned versus
actual agents and the only permitted substitutions are defined in
agent-roster.md.

Review evidence includes reviewer identity, unit/plan revision, reviewed change
identity (commit or base plus owned diff/checkpoint), inspected invariants, result,
and any follow-up. Label it `self-review` when the reviewer is also the unit's
actual implementer. Edits affecting reviewed behavior invalidate that review.

## 5. Verification appropriate to the current stage

Define baseline, unit, phase, and final gates separately. Each gate records its
exact command, cwd, setup, activation unit, assertions/test IDs, and applicability.
Run the focused baseline checks needed to identify pre-existing failures before
the first edit; rerun only checks whose prior evidence the actual diff or changed
environment invalidates. At each sub-phase run only
focused tests/checks for its changed behavior and immediate contract, including a
narrow regression when relevant. Run the complete integration/regression gate once
at phase closure P<N>, after all sub-phases and documentation, and final gates at
the plan closure PLAN. Repeat a full gate only when a later change invalidates
its evidence or a concrete failure needs diagnosis. Do not require a future test
target before the sub-phase that creates it. `not-applicable-yet` is not `pass`.

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
not. Record these identity trailers on completion and WIP commits, in the
message's final paragraph (Git's trailer block) together with any required
`Co-Authored-By:` or `Signed-off-by:` lines; nothing may follow that block.
`git commit --trailer` places them correctly:

```text
PEV-Plan: <plan-id>
PEV-Unit: <unit-id>
PEV-Attempt: <n>
PEV-Result: complete | wip
```

Subjects are mandatory, never free-form: the reader of `git log --oneline` must
see which plan, phase, and unit closed. `<plan>` is the folder number (`003`,
or `000_adhoc`), `<N>` the logical phase number, titles come from the plan:

| Commit | Subject |
|--------|---------|
| Sub-phase | `sub-phase(<plan>/<N.M>): sub-phase <N.M> of phase <N> complete — <title>` |
| Phase closure | `phase(<plan>/P<N>): PHASE <N> COMPLETE — <phase title>; gates and review passed` |
| Plan closure | `plan(<plan>): PLAN <plan> COMPLETE — <feature>; <K> phases, final gates passed` |
| Task / bug | `task(<plan>/T-A<NNN>): task T-A<NNN> complete — <title>` / `bug(<plan>/B-A<NNN>): bug B-A<NNN> fixed — <title>` |
| Correction | `correction(<plan>/V<NNN>-C<n>): correction V<NNN>-C<n> complete — <title>` |
| Audit | `verify(<plan>/V<NNN>): audit V<NNN> complete — verdict <VERDICT>, <n> blockers` |
| WIP | `wip(<plan>/<unit>): WIP <unit kind> <unit> — at <step>` |
| Handoff | `handoff(request-by-user): <plan>/<unit> stopped <stop point>` |

A retry of a failed or reopened unit adds ` (attempt <n>)` to the subject. When a
hook or commitlint rejects the type, map only the type to an allowed one (for
example `chore`), keeping the scope and description verbatim. The body is at
most six lines before the trailer block: `Plan: <id> <feature> rev <n>`,
`Phase: <N> — <title>`, `Unit: <id> — <title>` (not for phase or plan closure),
`Gates: <gate> <result> (<test count>)`, `Review: <agent> <verdict>` or
`self-review`, `Next: <next eligible unit or none>`.

1. Check the gates applicable to this unit and its required review; finish all
   coherence updates (§7) before staging. Record the closed unit, its ledger
   result (`complete`, or `failed` for a failed P<N> or PLAN attempt), evidence
   (appended to history.md, §8), next eligible unit, and commit reference
   `unit:<id>:<attempt>` (§1 `Last closure` and the board row) in the same
   proposed snapshot. When commits are disabled, record in a §4 row
   `uncommitted <base-tree>..<closure-tree>`: the unit base tree and a fresh
   closure snapshot (§3), which a later handoff commit needs to separate this
   unit's changes. Do not try to embed a commit's own SHA inside itself.
   If completion commits are disabled, closure ends here; do not run steps 2–4.
   The final report then warns that the work and plan records are uncommitted
   and suggests a commit command, never run. A failed P<N> or PLAN attempt records
   commit `none` and also ends here under every commit policy; it is never a
   pending closure.
2. Stage only owned changes and their plan records. Include required plan files
   created for this request during an earlier planning session once their
   provenance is established; otherwise a fresh checkout could lack its
   contract. Being inside the plan folder alone does not establish ownership.
   STATE.md, ledgers, and audit reports belong to the state writer and are
   staged whole. Never use interactive staging. If the index already holds
   staged changes this unit does not own, report a blocker; never unstage them.
   Stage paths only this unit changed with `git add -A -- <paths>`. For a shared
   path that also holds pre-existing or other units' hunks, stage only this
   unit's hunks, diffing the unit base tree against a fresh closure snapshot
   tree (§3):

   ```bash
   p="$(git rev-parse --git-dir)/pev-owned.patch"
   git diff --binary <base-tree> <closure-tree> -- <shared-paths> > "$p" &&
   git reset -q <unit-base-HEAD> -- <shared-paths> &&
   { git apply --cached --check "$p" 2>/dev/null && git apply --cached "$p" ||
     git apply --cached --3way "$p"; }
   rm -f "$p"
   ```

   Skip the reset on an unborn branch. The `--3way` fallback places owned hunks
   whose context includes a nearby pre-existing change; it never touches the
   working tree. If the patch still does not apply (overlapping hunks leave
   unmerged index entries, an edited pre-existing untracked file, or a Git that
   rejects `--3way` with `--cached`), restore those index entries
   with `git reset -q HEAD -- <shared-paths>`, commit nothing mixed, keep the work
   recoverable, and report a blocker. Inspect `git diff --cached` against the
   owned intent; unrelated changes must not enter the commit.
3. Commit on the current branch; do not create/switch branches, push, or make an
   empty duplicate commit. Confirm the branch still matches the unit's recorded
   branch before committing; unexpected changes require reconciliation. For
   detached HEAD, persist a blocker instead of inventing a branch. Let hooks
   run; never pass `--no-verify` or disable them. A failing hook is a failed
   gate: fix it inside the unit and restage only owned changes (inspect files a
   hook rewrote), or report a blocker. A rejected WIP commit leaves that
   checkpoint uncommitted and recorded.
4. Resolve the ledger reference using the unique reachable completion commit
   matching all four trailer values exactly in its trailer block, within current
   HEAD's ancestry. Do not use subject text or substring matches (1.2 is not 1.20):

   ```bash
   f='%H%x09%(trailers:key=PEV-Plan,valueonly,separator=%x2C)'
   f="$f"'%x09%(trailers:key=PEV-Unit,valueonly,separator=%x2C)'
   f="$f"'%x09%(trailers:key=PEV-Attempt,valueonly,separator=%x2C)'
   f="$f"'%x09%(trailers:key=PEV-Result,valueonly,separator=%x2C)'
   k="$(printf '%s\t%s\t%s\t%s' '<plan-id>' '<unit-id>' '<n>' complete)"
   git log --format="$f" HEAD | awk -F'\t' -v k="$k" \
     '$2 "\t" $3 "\t" $4 "\t" $5 == k {print $1}'
   ```

   The awk test compares strings, never numbers. If the output contains a
   literal `%(trailers`, this Git lacks the format: parse each candidate with
   `git log -1 --format=%B <sha> | git interpret-trailers --parse` instead, or
   report a blocker; never read zero matches from an unsupported format as a
   pending closure. Zero `complete` matches means pending closure; multiple
   `complete` matches mean an identity conflict to reconcile, not permission to
   choose one arbitrarily or add another commit. Use `wip` instead of `complete`
   to list the unit's WIP commits: several are normal, because a handoff commit
   is never amended, and all of them are this unit's own work. Confirm the
   commit contains the intended owned diff and state. Report its actual SHA; no
   extra bookkeeping commit is necessary. An existing resolved identity means
   this unit was already committed.

The reference in the committed snapshot resolves to that commit; the SHA may be
recorded by a later genuine update but is not required. If interrupted after
step 1 but before commit, the unresolved reference means closure is pending:
resume/reconcile that same attempt and finish the transaction before new work;
this recovery is not a reopening and must not increment the attempt.
If interrupted after commit, resolve it and continue without committing twice.
An explicitly requested audit can suspend that implementation transaction as
specified in §2; unresolved audit closure is recovered before restoring execution.

With WIP enabled, every recovery-boundary checkpoint of an OPEN code unit
(before risky or long work, delegation, a blocker, a handoff, or a stop) also
saves the unit's owned changes and STATE.md in one rolling `wip(<plan>/<unit>)` commit
with `PEV-Result: wip`; §1 remains OPEN. Stage it by steps 2–3 with a fresh
checkpoint snapshot as the closure tree, and record that tree in §1 as the last
WIP snapshot. Amend only when the WIP commit is owned, local-only, at HEAD, not
a handoff commit, and the unit's only WIP commit directly on the unit base HEAD;
staging then uses the unit base tree and HEAD as in step 2. Otherwise append:
use the last WIP snapshot as `<base-tree>` and current HEAD as the reset target,
so already committed hunks are not applied twice. On recovery, commits that the
step 4 lookup with `wip` matches to this plan, unit, and attempt are this unit's
own work, not foreign changes, and a HEAD recorded in STATE.md that an amend
replaced is expected. A crash loses at most the work since the last checkpoint,
which the working-tree snapshot comparison still recovers. Finish into a
completion commit under the same amend rule. Inspect current changes as well as
the WIP diff. Full autonomy alone never requires committing broken or unreviewed
work.

A handoff commit (mode-handoff.md H5) is a WIP commit with the subject
`handoff(request-by-user): <plan>/<unit> stopped <stop point>`, for a deadline
too, since the user set it, and
the extra trailer `PEV-Handoff: user|deadline`. It may also hold closed units
recorded `uncommitted` and a unit with a pending closure, listed in the trailer
`PEV-Includes: <id>:<attempt>, …`. Their ledger reference becomes
`handoff:<id>:<attempt> <base-tree>..<closure-tree>`, keeping the trees, and
resolves to the unique commit in HEAD's ancestry with that `PEV-Plan` whose
`PEV-Includes` lists that exact entry after splitting on commas and trimming:

```bash
f='%H%x09%(trailers:key=PEV-Plan,valueonly,separator=%x2C)'
f="$f"'%x09%(trailers:key=PEV-Includes,valueonly,separator=%x2C)'
git log --format="$f" HEAD | awk -F'\t' -v p='<plan-id>' -v u='<id>:<attempt>' \
  '$2 == p { n = split($3, a, ","); for (i = 1; i <= n; i++) {
     gsub(/^[ \t]+|[ \t]+$/, "", a[i]); if (a[i] == u) print $1 } }'
```

A `handoff:` reference with zero matches (a failed or interrupted handoff
commit) counts as `uncommitted` with its recorded trees; several matches are an
identity conflict. The commit is never amended: later WIP and completion
commits append after it, using its closure tree as the last WIP snapshot.

## 7. Coherence contract

Every closed unit leaves the plan consistent with the repository. Apply these
updates before the completion commit, not afterwards:

1. STATE.md: invocation and saved execution scope, current and next unit,
   checkpoint, ledger row, owned changes, verification evidence, reviews,
   deviations, blockers, and sub-phase/phase/correction progress. Live
   implementation status appears only here, compacted per §8.
2. Out-of-plan work: `tasks.md` or `bugs.md` entries with stable IDs
   `T-A<NNN>` / `B-A<NNN>`, allocated as the highest existing number in that
   ledger plus one and never reused (templates-ledger.md). Ad-hoc history stays
   in `000_adhoc` when a real plan is created later.
3. README.md for changed user-visible behavior: usage, defaults, examples,
   limits, and troubleshooting, preserving language and structure. Planned phase
   work either updates it in the unit or keeps the obligation visible with the
   named later unit or P<N> that owns it; tasks, bugs, and corrections update
   affected documentation themselves.
4. Audit findings affected by the work: update `verify/index.md` and the source
   report's resolution; never silently drop or self-accept an unresolved finding.
5. Plan changes: the supervisor records superseded decisions, invariant/test
   impact, dependencies, and revalidation, and updates pending units made stale.
   Skipped units keep their reason. Necessary authorized work is added explicitly,
   never hidden in a vague deviation or in rewritten requirements.

The Coherence checklist in quality-checklist.md verifies these updates.

## 8. State size and history

STATE.md is the present state of the work plus what the remaining work needs,
never a history. Its cost is paid at every read, so keep it lean:

- §0 is one pointer line to `PROTOCOL.md`, the static cold-start protocol
  written once at planning time; a session with this skill never reads it.
- §4 ledger keeps only unsettled rows: commit `uncommitted` or a `handoff:`
  reference, or a failed P<N>/PLAN attempt not yet rerun. A committed closure
  writes its `unit:<id>:<attempt>` reference in its §11 board row and in §1
  `Last closure` instead; unresolved on resume, that reference is the pending
  closure (§6). A `handoff:` row whose reference resolves moves to the board at
  the next state write.
- §5 and §6 describe only the OPEN unit; clear them at closure (`none`).
- §7 keeps the latest result per gate and the reviews of the open phase only;
  overwrite a rerun, never append it.
- §8 keeps revisions and internal decisions that pending units or the next
  P<N> review still need; §9 open blockers; §10 entries relevant to pending
  units.
- §11 expands only open phases. At P<N> DONE collapse the phase into one
  Phases row (`DONE`, attempt, sub-phase range, closure reference) and drop its
  sub-phase, test, and documentation rows, §7 rows, reviewed §8 decisions, and
  stale §10 entries.
- PLAN COMPLETE leaves the header, §1, §3, the collapsed board, and open audits
  or corrections; every other section reads `none`.

Before deleting detail, append it to `history.md` in the plan folder, one entry
per closure, written with an append (`cat >> history.md`), never by reading it:

```text
## <date> <unit>/<attempt> <complete|failed> <commit ref or none>
Gates: <gate result (count)>; review: <agent verdict>; changes: <paths>; notes: <decisions, deviations>
```

`history.md` is append-only and never read to resume; Verify and the user may
read it for evidence. A completion commit includes it beside STATE.md.

### Format version and migrations

STATE.md's header carries `Format: pev-state <n>`; a STATE.md without it is
format 1. This skill writes format 2. `000_adhoc` ledgers carry no format
version. The state writer applies every missing migration below in order, in
the same state update that claims ownership and before any unit opens, in every
operational mode, Handoff and Verify included, then sets the header to the
latest format. Every OPEN, pending-closure, uncommitted, handoff, or failed
record stays in STATE.md unchanged. Onboard, a delegated worker, and a session
that does not own the state never migrate. The migrated files enter the next
commit the run makes; with commits disabled they stay uncommitted like other
plan records.

| From → to | Migration |
|-----------|-----------|
| 1 → 2 | Move the §0 protocol text to `PROTOCOL.md` (output-template.md §4) and leave the §0 pointer line. Create `history.md` and move settled detail there per the rules above. Add the §1 fields `acting as`, `Stop latch: none`, and `Last closure`. Add the PLAN board row: when every phase is DONE or SKIPPED the plan completed under format 1, which ran the final gates at the last P<N>, so write `PLAN \| DONE \| 1 \| — \| legacy: final gates at P<N>` and treat the plan as complete, with no PLAN run and no commit unless the user explicitly asks for one; otherwise write `PLAN \| TODO`. |

A STATE.md whose format is newer than this skill's latest is never written:
reject the invocation before work starts and ask the user to update the skill
(next-step.md row 1). A later skill version adds one row to this table and
raises the latest format; it never edits an earlier row.

Oversized state: when a STATE.md of the current format exceeds about 150 lines,
the state writer compacts it by the rules above at the same moment.
