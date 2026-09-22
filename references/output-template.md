# Plan templates — a complete cold-start contract

Write overview.md, phase_01.md …, then STATE.md. Replace every placeholder with
a concrete value or an explicit justified N/A. The seven top-level sub-phase
fields remain stable; their structured contents are mandatory where applicable.
Follow execution-contract.md when filling runtime rules.

The finished plan is READY only after the supervisor validates every sub-phase,
dependency, required contract, and gate specification. Unresolved design or
acceptance questions prevent READY. A working draft may be retained as BLOCKED,
but must not be handed off as executable.

## 1. overview.md

````markdown
# <Feature> — Plan overview

Authored <date> by <supervisor>. Folder: <path>.
Execution starts at [STATE.md](STATE.md); all live readiness and progress are there.

## Goal and reference scenario
<Observable outcome, inputs/invocation, exact expected outputs, exclusions.>

## Decisions
| ID | Decision and consequence | Authority/source | Supersedes |
|----|--------------------------|------------------|------------|
| D1 | <precise technical decision> | <user Q / supervisor, date> | — |

## Open questions
<None for a READY plan. Otherwise questions, affected units, and who can resolve
them; STATE.md must mark readiness BLOCKED. Do not apply unapproved defaults.>

## Architecture
<Data flow, ownership, key types, mechanisms; enough to route to detailed phases.>

## Interfaces and compatibility
| Surface | Exact name/type | Default | Errors/conflicts | Compatibility |
|---------|-----------------|---------|------------------|---------------|
| <CLI/API/config/schema> | <contract> | <value> | <behavior> | <strategy> |

## Phase map
| Logical phase | File | Sub-phase IDs | Depends on | Assignment |
|---------------|------|---------------|------------|------------|
| 0 | [phase_01.md](phase_01.md) | 0.1, 0.2 | none | <agent> |

No live status in this table.

## Reuse map
| Need | Path and symbol | Contract to preserve |
|------|-----------------|----------------------|
| <need> | <path:line — symbol> | <signature/behavior> |

## External references
| ID | Confirmed fact | Source URL | Pinned version/date |
|----|----------------|------------|---------------------|
| R1 | <fact> | <URL> | <version> |

<Explicit N/A for entirely internal work. UNVERIFIED facts block dependent work.>

## Invariants
| ID | Meaning | Guarding test |
|----|---------|---------------|
| I-1 | <specific property> | <test ID/name> |

## Risks
| Risk | Design mitigation | Verification |
|------|-------------------|--------------|
| <risk> | <concrete mitigation> | <test/review> |

## Verification strategy
<Which baseline, unit, phase, final gates prove the reference scenario.
STATE.md §3 is the command registry; phase files reference gate IDs and state
their assertions/applicability. Do not require all stages' commands to be identical.>

## Model-assignment summary
| Unit(s) | Implementer | Required supervisor review |
|---------|-------------|----------------------------|
| <IDs> | <exact configured assignment> | <timing and focus> |
````

## 2. phase_NN.md

One file per logical phase; phase 0 maps to phase_01.md. A worker reads this
file plus STATE.md and named repository slices. Include the meanings of all
referenced decisions/invariants here; references by ID alone are insufficient.

````markdown
# Phase <N> — <title>

Intent: <observable outcome>.
Prerequisites: <unit IDs and artifacts, or none>.
Phase closure: P<N>; review by <configured strong supervisor>.

## State and ownership contract
Read STATE.md first. In a fresh session reconcile the active unit, actual diff,
step checkpoint, scope, and commit reference before selecting work. In a delegated
worker session, follow the coordinator's assigned OPEN unit; do not take over
state/commits or revert active work. Open before edits; checkpoint after meaningful
batches and before yielding. Close after tests/review/coherence, commit when
configured, then continue only within scope. Missing design goes to the supervisor.

## Local design context
Plan revision: <revision these excerpts implement>.
- D<n>: <decision meaning, exact interfaces/errors/defaults as applicable>.
- I-<n>: <invariant meaning and guarding test>.
- R<n>: <confirmed external fact and URL/version, or N/A>.
<Algorithm, data representation, ownership/lifecycle, failure/retry semantics,
compatibility and relevant input/output examples. Avoid unresolved alternatives.>

## Sub-phases

### <N.1> <one independently verifiable outcome>
- **Model:** <exact configured assignment>
- **Assignment:** <responsibility; review before design/after diff; reviewer>
- **Files:** READ <paths + symbols/contracts>; WRITE <paths + symbols>;
  NEW <paths, how registered/exported, existing directory convention>.
  Line numbers are hints; missing future NEW files are expected.
- **Change:**
  Preconditions: <prerequisite unit IDs, required artifacts, expected current state>.
  Contract: <input/output, types, defaults, errors, boundary cases>.
  Scope: <allowed changes and explicitly preserved behavior>.
  Steps:
  1. S1 — <exact edit/action using named symbols>. Expected: <postcondition>.
  2. S2 — <next action, including wiring/callers if needed>. Expected: <postcondition>.
  Checkpoint: after <meaningful steps/batches>, record completed step IDs, actual
  files, verified result, and next step in STATE.md §6.
  Failure handling: <known cases and action; unknown design → named supervisor>.
  <For migrations/external effects, also specify idempotency and resume checks.>
- **Unit tests:** <test ID/name + path, fixture/inputs, exact assertions,
  relevant negative/boundary cases, gate ID/command and discovery evidence>.
- **e2e tests:** <test ID/path, setup, inputs, expected observations, gate ID>;
  or N/A — <why this unit changes no observable behavior>.
- **Done:** <artifact/behavior postconditions>; gates <IDs> pass with intended
  tests executed; <review evidence>; coherence complete; unit closed in STATE.md;
  completion commit resolved when configured. No unresolved required step.

### <N.last> Update README.md
- **Model:** <configured agent>
- **Assignment:** <documentation; supervisor checks at phase closure>
- **Files:** <existing README path; allowed sections>
- **Change:**
  Preconditions: <shipped implementation units>.
  S1 — Update <exact sections> for <actual commands/defaults/errors/limits>.
  Expected: examples and defaults match shipped code; preserve language/structure.
  S2 — Run <safe concrete examples/checks>. Expected: <documented outputs>.
  If no behavior shipped, inspect affected sections, leave them unchanged when
  accurate, and record the verification. No invented roadmap or implementation prose.
  Checkpoint: record examples checked, pending edits, and next action.
- **Unit tests:** <docs checks or justified N/A>
- **e2e tests:** <example commands/results or justified N/A>
- **Done:** affected guide sections accurate, applicable checks pass, state closed,
  commit resolved when configured.

## Phase gates and closure
- Required gates: <IDs from STATE.md §3>; assertions: <phase-level expectations>.
- README obligation satisfied; every sub-phase DONE or explicitly justified SKIPPED.
- Supervisor <agent> reviews integration, invariants, tests, and documentation.
- Open closure unit P<N>, record actual review and verified phase result, mark
  the phase DONE, and close. With full-autonomous:true commit this state change
  as a phase completion. Never fabricate an empty commit.
- On final phase: <reference scenario IDs and final integration gates>.
````

## 3. STATE.md

This is the single live implementation state. Keep the protocol usable without
the skill's references; fill in settings, identities, and commands. Ledger history
is append-only; a reopened unit gets a new attempt rather than erasing evidence.

````markdown
# <Feature> — Implementation state

Read first at every session. Updated <date/time> by <actual agent>.
Plan ID: <folder ID>. Revision: <n>. Repo root: <absolute path>.
Plan baseline: <immutable starting commit>; pre-existing changes: <paths/diff reference>.
Roster: <exact configured names>. Active execution style: <handoff|delegated>.
State writer: <session/coordinator identity>; ownership: <active|released>.

## 0. Resume and completion protocol

1. Read this state and identify readiness, active scope, role, unit/attempt, step,
   checkpoint, branch, and baseline. A new session may resume only after the
   previous state writer stopped/released ownership. A delegated worker stays
   inside its assigned OPEN unit and never owns shared state or commits.
2. Inspect HEAD, staged/working changes, and checkpoint postconditions; preserve
   unrelated changes, including hunks in shared files. Reconcile unresolved
   completion-commit references before starting any new unit. OPEN work resumes
   at its first unverified step; inspect reality even if the checkpoint is stale.
   Exception: to audit unfinished implementation, the state owner saves the
   complete prior §1 and §6 plus scope/revision/owner/evidence/pending-commit
   reference in §12 before opening the audit. No nested suspension. Verify
   inspects that work without finishing or committing it on its behalf.
   If a new explicit scope excludes unfinished OPEN implementation, preserve it
   and ask how to resolve the conflict; do not implement outside scope or overwrite
   its checkpoint to start new work.
3. Read the pointed phase/correction and local contracts. Check prerequisite
   sub-phase rows and artifacts; locate symbols rather than trusting line numbers.
   A changed contract or missing design goes to the configured strong supervisor.
4. Open before edits: set type/ID/attempt/OPEN, unit base, owned paths, step S1;
   mark its sub-phase and phase IN_PROGRESS. Checkpoint §6 after meaningful edit/
   test batches, before long operations, delegation, handoff, or stopping.
5. Run applicable gates; confirm intended tests executed. Record tested revision/
   diff and required real reviewer evidence. Future gates are not pass; missing,
   blocked, zero-discovery, or failing required checks prevent implementation DONE.
6. Finish docs and plan/audit reconciliation, append the ledger row, update
   progress, and point to the next eligible unit. If commit is required, store
   unit:<id>:<attempt> as the reference in this snapshot, stage only owned changes,
   and commit on the current branch with PEV-Plan, PEV-Unit, PEV-Attempt, and
   PEV-Result: complete trailers. Resolve the unique reachable matching commit
   before advancing. Do not store that commit's own SHA inside itself.
   If commits are disabled, record uncommitted and do not stage/commit.
   Include required plan artifacts authored for this request in earlier planning
   only after establishing provenance; preserve unrelated plan-file edits too.
   Planned implementation may leave README changes to its explicitly named
   dependent docs sub-phase; record that outstanding obligation and never close
   the phase/feature before it passes. Task/bug/correction documentation is part
   of that same unit, not an implicit future task.
7. If interrupted before commit, an unresolved reference means closure is pending:
   reconcile/finalize it before starting new work. If already committed, resolve
   the reference and continue without a duplicate commit. With WIP enabled only,
   interruption may create an owned wip(<id>) commit with PEV-Result: wip and OPEN
   state; amend only when owned, at HEAD, and local-only.
8. After sub-phases, open P<N> for phase gates and strong review. Record phase DONE
   and commit its closure when full autonomy is true. Continue eligible units
   without routine approval inside the persisted scope; final completion requires
   the reference scenario and all required gates/reviews.
9. A worker escalates missing decisions or two failed fixes of the same issue.
   The strong supervisor may revise technical steps within unchanged requirements/
   scope; record a revision, superseded decision, dependent updates/revalidation.
   Never weaken acceptance to fit a failed implementation. New product choices,
   scope, or external authority require the user; unavailable supervisor → BLOCKED
   handoff. Existing user authorization persists.
10. On handoff save exact next action, pending changes/resources, evidence, and
    ownership release. Do not assume the host can automatically start a session.
    With full autonomy false, a verified unit boundary may yield without marking
    the entire selected scope COMPLETE.

Audit closure may have verdict FAIL or INCOMPLETE; this closes the inspection,
never the failed implementation. Full autonomy commits its report/state only.
After a suspended audit, restore §12's prior unit/scope/checkpoint, attach audit
blockers, and revalidate the current diff/revision; never overwrite corrected
phase/test statuses with old values. Mark the snapshot restored. Recover an
unresolved audit completion commit before resuming the implementation, without
finalizing that implementation's pending commit. An OPEN audit resumes its own
checkpoint. Capture/open and restore/close are each one STATE.md update.

## 1. Current unit and scope

- Active scope: <plan|phase|sub-phase|task|bug|report and exact selector>
- Scope result: <NOT_STARTED|RUNNING|BLOCKED|COMPLETE>
- Type: <sub-phase|phase-close|task|bug|verify|correction|none>
- ID / attempt: <stable ID / n>
- Status: <OPEN|none>
- Intent: <one concrete outcome>
- Assigned: <actual worker>; supervisor: <configured reviewer>
- File / unit heading: <phase/report path and heading>
- Current step: <S<n> or review/commit/none>
- Next action: <exact next action for this invocation>
- Next eligible plan unit: <ID/file; may be outside the selected scope>
- Unit base: <HEAD before unit>; branch: <current branch>; owned changes: <paths/hunks>
- Repo state: <HEAD; clean/dirty; unrelated changes>

## 2. Feature context and readiness

Readiness: DRAFT | BLOCKED | READY — <supervisor evidence/revision>.
<Goal, exclusions, hard constraints, observable reference scenario.>
Current decisions: <IDs and meanings needed by remaining work>.
Unresolved design/acceptance questions: <none for READY>.
Required supervisor reviews cannot be silently replaced by weaker self-review.

## 3. Environment, settings, and gate registry

- Full autonomous: false <or true; source/date of override>
- WIP commits: off <or on; source/date>
- Completion policy: full autonomy commits operational units and phase closures;
  WIP alone commits completed code units; plan never commits. false adds no
  commits. --no-wip-commit does not disable autonomous completion commits.
- Scope/roster survive handoff. Explicit invocation overrides stored settings.
- Setup: <versions, services, credentials required, cwd, ports, cleanup>.
- Supervisor access: <host dispatch method or explicit session-handoff procedure>.

| Gate | Stage / active from | Exact command and cwd | Required assertions/discovery | Setup |
|------|---------------------|-----------------------|-------------------------------|-------|
| G-BASE | baseline | <command> | <existing regression assertions> | <setup> |
| G-U01 | unit <ID>, after S<n> | <command> | <specific test IDs/count> | <setup> |
| G-P0 | phase 0 closure | <command> | <integration assertion> | <setup> |
| G-FINAL | final phase | <command> | <reference scenario> | <setup> |

## 4. Work ledger

| Type | ID / attempt | Plan revision | Agent | Changes | Evidence/review | Commit |
|------|--------------|---------------|-------|---------|-----------------|--------|
| <unit type> | <ID/n> | <revision> | <actual agent> | <paths/summary> | <refs> | <uncommitted or unit:ID:attempt> |

Commit references match trailers PEV-Plan, PEV-Unit, PEV-Attempt, PEV-Result.
Compare exact trailer values in current HEAD's ancestry, not subject/substrings.
No match is pending closure; multiple matches are a conflict requiring reconciliation.
An unresolved required reference prevents advancing, except when explicitly
suspended for Verify; do not assume it was committed.
A SHA recorded by a later update is optional. Older valid SHA references remain valid.

## 5. Files and ownership

| Path/hunks | Existing changes to preserve | Unit changes | Owning unit |
|------------|------------------------------|--------------|-------------|

## 6. In-flight checkpoint

<none, or claimed — nothing written yet, or the concrete checkpoint below>
Completed steps: <IDs and verified postconditions>.
Actual files/diff: <owned changes>.
Pending edits: <exact changes>.
Next step: <ID and action>.
Last checks: <command/result/tested revision>.
Running resources: <process/service/migration identity and resume/cleanup action>.
Stop reason / supervisor request: <if applicable>.

## 7. Verification and reviews

| Gate/test | Command | Result | Test count/named evidence | Tested revision/diff | When |
|-----------|---------|--------|--------------------------|---------------------|------|

Results: pass, fail, blocked, not-run, not-applicable-yet. Only pass satisfies a
required active gate. Keep relevant failing output/evidence references.

| Review | Reviewer | Plan revision / reviewed change | Invariants/assertions checked | Verdict |
|--------|----------|---------------------------------|------------------------------|---------|

## 8. Technical revisions and deviations

| Revision | Previous decision/step | Approved replacement and reason | Supervisor | Dependents/revalidation |
|----------|------------------------|---------------------------------|------------|------------------------|

## 9. Blockers
<ID, affected units, evidence, resolution owner, exact next action; or none.>

## 10. Do-not-repeat
<Failed approaches and reasons; or none.>

## 11. Progress board

### Sub-phases
| ID | Phase file | Depends on | Status | Attempt | Evidence / reason |
|----|------------|------------|--------|---------|-------------------|
| 0.1 | phase_01.md | none | TODO | 1 | — |
| 0.2 | phase_01.md | 0.1 | TODO | 1 | — |

### Phases
| ID | File | Closure unit | Status | Review / commit reference |
|----|------|--------------|--------|---------------------------|
| 0 | phase_01.md | P0 | TODO | — |

Statuses: TODO, IN_PROGRESS, IN_REVIEW, DONE, SKIPPED, BLOCKED.
SKIPPED retains a reason and does not automatically satisfy dependent units.

### Tests
| ID/name | Owning unit | Gate | Status | Evidence |
|---------|-------------|------|--------|----------|

### Documentation
| Document/sections | Owning unit | Status | Evidence |
|-------------------|-------------|--------|----------|

### Audits
| Report | Verdict | Current unresolved findings | Evidence |
|--------|---------|-----------------------------|----------|

Audit finding details/statuses live in verify/index.md; phase progress lives here.

## 12. Suspended implementation (only while auditing unfinished work)

Snapshot state: none | captured | restored.
Reason/audit ID: <explicit audit request and V<NNN>>.
Previous current-unit record: <complete §1 including scope, base/branch and ownership>.
Previous checkpoint: <complete §6, including pending resources and next step>.
Previous plan revision / state writer: <values>.
Pending completion reference: <reference or none>.
Evidence/review references: <values>.
Restoration: <date, current-diff check, audit blockers attached; or pending>.
<Do not nest snapshots or discard an unrestored snapshot.>
````
