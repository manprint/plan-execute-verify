# Plan templates — a complete cold-start contract

Complete overview.md, phase_01.md …, then PROTOCOL.md, STATE.md, and an empty
history.md, preserving any earlier DRAFT research checkpoint. Replace every placeholder with
a concrete value or an explicit justified N/A. The seven top-level sub-phase
fields remain stable; their structured contents are mandatory where applicable.
Follow execution-contract.md when filling runtime rules.

The finished plan is READY only after the supervisor validates every sub-phase,
dependency, required contract, and gate specification. Share a phase's decisions,
setup, and commands once; give each unit only the details needed for its outcome.
Unresolved design or
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
| 0 | [phase_01.md](phase_01.md) | 0.1, 0.2 | none | <roster position> |

No live status in this table.

## Reuse map
| Need | Path and symbol | Contract to preserve |
|------|-----------------|----------------------|
| <need> | <path:line — symbol> | <signature/behavior> |

## Research and evidence

<Research scope and material external questions, or N/A with a reason for
entirely internal, established work. Follow the skill's research.md protocol.>

| ID | Question / required or optional | Evidence state | Affected decisions / units / tests |
|----|---------------------------------|----------------|------------------------------------|
| R1 | <concrete question and relevance> | <CONFIRMED/UNVERIFIED/ACCEPTED/SUPERSEDED> | <D/I/unit/test IDs> |

### R1 — <question>
- Sources: <primary URL and section, or local path/symbol and provenance>.
- Applicability: <source version/revision, target environment, limits>.
- Dates: <source publication/update date if available; actual access date>.
- Documented fact: <short supported statement, not a copied manual>.
- Supervisor inference: <reasoned conclusion, explicitly not a source guarantee;
  or none>.
- Local check: <command/environment/result and limits, or not run with reason>.
- Decision impact: <chosen approach, material rejected alternative/reason,
  resulting contract and acceptance tests; map to IDs above>.
- Unresolved/replacement: <missing evidence, owner and next action; replacement
  R ID when superseded; or none>.

<Network authorization: <environment or user answer, date, scope; or none>.
Required UNVERIFIED claims prevent READY and dependent dispatch unless the user
accepted them (ACCEPTED: who, when, risk, guarding test). Optional open
questions may be excluded only when no requirement/chosen design depends on them.
Retain superseded evidence; update local phase conclusions when decisions change.>

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

## Agent-assignment summary
Executor power: <low|medium|high> — <resulting decomposition, detail, and
executor latitude>.

| Unit(s) | Implementer | Required supervisor review |
|---------|-------------|----------------------------|
| <IDs> | <roster position, e.g. agent-2> | <agent-1: timing and focus> |
````

## 2. phase_NN.md

One file per logical phase; phase 0 maps to phase_01.md. A worker reads this
file plus STATE.md and named repository slices. Define the meanings of referenced
decisions/invariants once in Local design context; sub-phases may cite their IDs.
Do not copy the full runtime protocol or repeat gate commands in this file.

````markdown
# Phase <N> — <title>

Intent: <observable outcome>.
Prerequisites: <unit IDs and artifacts, or none>.
Phase closure: P<N>; review by agent-1.

## State and ownership contract
Read STATE.md §1 first (and PROTOCOL.md once without this skill) for scope,
ownership, recovery, checks, and commit
rules. Open before edits; checkpoint at a recovery boundary; close with
evidence. A delegated worker follows its assigned OPEN unit. Missing design goes
to agent-1, the supervisor. Executor power: <level>; <at high: plan your own
steps and internal decisions; the state writer records them in STATE.md §6 and
§8, a delegated worker returns them; escalate any contract change>.

## Local design context
Plan revision: <revision these excerpts implement>.
- D<n>: <decision meaning, exact interfaces/errors/defaults as applicable>.
- I-<n>: <invariant meaning and guarding test>.
- R<n>: <applicable fact, source/version and operative consequence for this unit;
  distinguish supervisor inference from documented guarantees, or state N/A>.
<Algorithm, data representation, ownership/lifecycle, failure/retry semantics,
compatibility and relevant input/output examples. Avoid unresolved alternatives.>
<Research-backed choices must already be translated into the steps and test
oracles below; do not leave "read these links and decide" to the implementer.>

## Sub-phases

### <N.1> <one independently verifiable outcome>
- **Agent:** <roster position only, e.g. agent-2; STATE.md resolves the name>
- **Assignment:** <responsibility; review before design/after diff; reviewer;
  `self-review` when the implementer is also the required reviewer>
- **Files:** READ <paths + symbols/contracts>; WRITE <paths + symbols>;
  NEW <paths, how registered/exported, existing directory convention>.
  Line numbers are hints; missing future NEW files are expected.
- **Change:**
  Preconditions: <prerequisite unit IDs, required artifacts, expected current state>.
  Contract: <input/output, types, defaults, errors, boundary cases>.
  Scope: <allowed changes and explicitly preserved behavior>.
  Steps:
  1. S1 — <coherent edit batch using named symbols>; expected <postcondition>.
  2. S2 — <wiring/callers and focused validation>; expected <postcondition>.
  Recovery boundary: <only a risky/long operation or likely handoff, or none>;
  record the last durable step and exact next action in STATE.md §6 then.
  Failure handling: <known cases and action; unknown design → named supervisor>.
  <For migrations/external effects, also specify idempotency and resume checks.>
- **Unit tests:** <test ID/name + path, fixture/inputs, exact assertions,
  relevant negative/boundary cases, targeted gate ID and discovery evidence>;
  or N/A — <why no unit test applies, such as a documentation-only unit>.
- **e2e tests:** <focused test ID/path, inputs, expected observations, targeted gate ID>;
  or N/A — <why this unit changes no observable behavior>.
- **Done:** <artifact/behavior postconditions>; targeted checks <IDs> pass with intended
  tests executed; <review evidence>; coherence complete; unit closed in STATE.md;
  completion commit resolved when configured. Full phase gates run at P<N>.

<If documentation is substantial, add one sub-phase using the same seven fields.
Otherwise name the implementation unit that updates affected README sections.>

## Phase gates and closure
- Required gates: <IDs from STATE.md §3>; assertions: <phase-level expectations>.
- README obligation: <unit/sections changed, or evidence sections remain accurate>.
- Every sub-phase DONE or explicitly justified SKIPPED. Run full phase gates now.
- agent-1 reviews integration, invariants, tests, and documentation.
- Open closure unit P<N>, record actual review and verified phase result, mark
  the phase DONE, and close. With full-autonomous:true or WIP enabled, commit
  this state change with the subject
  `phase(<plan>/P<N>): PHASE <N> COMPLETE — <title>; gates and review passed`.
  Never fabricate an empty commit.
- P<N> edits no production code or tests. A blocked gate keeps P<N> OPEN and
  BLOCKED until it can run (same attempt). A failing gate or rejected review closes
  that attempt as failed (commit none); reopen the responsible sub-phase with a new
  attempt or obtain a supervisor plan revision, then rerun P<N> as a new attempt.
- Final phase only: after P<N>, the PLAN closure runs <G-FINAL and reference
  scenario IDs>, agent-1's final review, and the commit
  `plan(<plan>): PLAN <plan> COMPLETE — <feature>; <K> phases, final gates passed`.
````


## 3. STATE.md

The live state only: what is true now and what remaining work needs. Keep the
section numbers (other records cite them), write `none` for an empty section,
and compact at every closure (execution-contract §8). Settled detail goes to
history.md, the static protocol to PROTOCOL.md. Target: under about 150 lines.

````markdown
# <Feature> — State

Plan <NNN> rev <n> · repo <absolute path> · baseline <commit> · updated <date time> by <agent-N:name>
§0 Protocol: without this skill read PROTOCOL.md once. History: history.md (append-only, never read to resume).

## 1. Now
- Run: <mode, unit or scope> · result <RUNNING|BLOCKED|COMPLETE|HANDOFF|PROPOSED> · style <delegated|handoff> · acting as <agent-N:name>
- Settings: autonomy <true|false> (<explicit|explicit (prompt)|scope|plan>) · WIP <on|off> (<source>) · deadline <dd-mm-yyyy_hh_mm|none>
- Stop latch: <none | HANDOFF user|deadline <time>>
- Scope: <plan|phase|sub-phase|report selector, or none> · <NOT_STARTED|RUNNING|BLOCKED|COMPLETE> · overrides <values|none>
- Unit: <sub-phase|phase-close|plan-close|task|bug|verify|correction> <ID>/<attempt> · <OPEN|none> · step <S<n>|review|commit> · assigned <agent-N> → actual <agent-N:name>
- Base: HEAD <sha> + tree <tree> · branch <branch> · last WIP tree <tree|none>
- Last closure: <unit:ID:attempt|none>
- Next: <exact next action> · next eligible: <unit ID>
- Owner: <writer> <active | released <time> <reason>> · takeover <previous → new, time, reason | none>

## 2. Readiness
<READY|DRAFT|BLOCKED> rev <n> — <supervisor evidence>. Open questions / required unverified claims: <none|IDs>.

## 3. Settings, roster, gates
- Roster: agent-1:<name> (supervisor), agent-2:<name>, …
- Plan defaults: autonomy <false|true> · WIP <off|on> · executor power <low|medium|high> — set by Plan <date>
- Setup: <versions, services, credentials, cwd, ports, cleanup>
- Supervisor access: <dispatch method or session-handoff procedure>

| Gate | Active from | Command (cwd) | Must assert / discover |
|------|-------------|---------------|------------------------|
| G-BASE | baseline | <command> | <existing assertions> |
| G-U01 | unit 0.1 | <command> | <test IDs/count> |
| G-P0 | P0 | <command> | <integration assertion> |
| G-FINAL | PLAN | <command> | <reference scenario> |

## 4. Unsettled ledger
none
<!-- Only rows still needing action: | Unit/attempt | Result | Commit: uncommitted <base-tree>..<closure-tree> · handoff:<ID>:<attempt> <base>..<closure> · none (failed) | -->

## 5. Owned files
none
<!-- OPEN unit only: <path>: <unit hunks>; pre-existing changes to preserve -->

## 6. Checkpoint
none
<!-- OPEN unit only: last durable step · actual diff · pending edits · next step · last check · running resources · stop reason / supervisor request · research checkpoint -->

## 7. Open-phase evidence
none
<!-- Latest result per gate, overwritten on rerun: | Gate | Result | Count | Revision/diff |
     Reviews: <unit>: <reviewer> <verdict> (self-review when implementer) -->

## 8. Revisions and decisions still needed
none
<!-- rev <n>: <superseded> → <replacement>, reason, dependents/revalidation · <unit>: internal decision (high) awaiting P<N> review -->

## 9. Blockers
none

## 10. Do-not-repeat
none

## 11. Board
| Phase | Status | Attempt | Sub-phases | Closure ref |
|-------|--------|---------|------------|-------------|
| 0 | TODO | 1 | 0.1–0.3 | — |
| PLAN | TODO | 1 | — | — |

<!-- Only the open phase is expanded; collapse it at P<N> DONE:
| ID | Depends | Status | Attempt | Assigned | Ref / note |
README obligation: <owning unit/sections>
Open corrections: | ID | Report | Findings | Reopens | Depends | Status | Attempt |
Open audits: | Report | Verdict | Unresolved findings | -->
Statuses: TODO, IN_PROGRESS, IN_REVIEW, DONE, SKIPPED (reason kept), BLOCKED.

## 12. Suspended implementation
none
<!-- While auditing unfinished work: prior §1 and §6 complete, revision, owner, pending ref, evidence refs; restoration <pending|date> -->
````

## 4. PROTOCOL.md

Static; written once by Plan and rewritten only by a plan revision that changes
the runtime contract. It lets an executor without this skill work safely; a
session with the skill does not read it. Fill in the plan ID.

````markdown
# Plan <NNN> — execution protocol (read once; live state is STATE.md)

1. Start: read STATE.md §1. If ownership is active and you are not its writer,
   an explicit user invocation counts as a resume request: take over only if
   STATE.md and a fresh snapshot (step 3) are unchanged between first read and
   takeover write; record previous/new writer, time, reason; otherwise ask.
   Task, Bug, and Verify never replace the saved scope, §3 defaults, or roster.
   Resume recovers OPEN or pending work first, then continues the saved scope,
   never a TODO unit named by ID or work outside it.
2. Recover: compare HEAD and a fresh snapshot with the unit base; preserve
   unrelated changes; an unresolved `Last closure` reference (step 7) is a
   pending closure to finish first. Resume OPEN work at its first unverified
   step; inspect the diff even if §6 is stale. A Verify of unfinished work saves
   §1 and §6 to §12 first, no nested suspension.
3. Open before editing: §1 unit, attempt, OPEN, step S1, assigned → actual
   agent; mark sub-phase and phase IN_PROGRESS. Base = HEAD + snapshot tree:
   ```bash
   idx="$(git rev-parse --git-dir)/pev-snapshot.$$.index"
   { GIT_INDEX_FILE="$idx" git read-tree HEAD 2>/dev/null ||
     GIT_INDEX_FILE="$idx" git read-tree --empty; } &&
   GIT_INDEX_FILE="$idx" git add -A && GIT_INDEX_FILE="$idx" git write-tree
   rm -f "$idx"
   ```
   Compare later with `git diff --stat <base-tree> <tree>`. Checkpoint §6 only
   before delegation, risky/long work, a blocker, or a likely pause.
4. Implement the phase file's steps; locate symbols, not line numbers. Missing
   or contradictory design, or two failed fixes of one issue, go to agent-1,
   who may revise technical steps within the approved scope; never weaken
   tests. Run the unit's focused checks and confirm tests actually executed.
   Required review by the assigned reviewer; `self-review` when it is the
   implementer.
5. Autonomy loop: continue to the next eligible unit in the same turn. Stop
   only at: scope complete; with autonomy false, after a phase closure P<N>
   (Task/Bug: at the approval gate); a real blocker (BLOCKED, with question and
   owner); a user stop, handoff, or deadline; the host ending the session.
   Never stop for a closed sub-phase, a commit, context size, a substitutable
   agent, or to report progress; never ask the user to type resume inside the
   scope. Permission modes never change the scope or the stop latch.
6. Roster: run units assigned to your position or a higher-numbered one;
   record substitutions. Reviews and plan revisions are agent-1's; a model
   outside the roster coordinates but implements nothing.
7. Close: append the unit's evidence to history.md (`cat >> history.md`), update
   §1, §11, next eligible unit, and compact STATE.md (below). With commits
   enabled (autonomy true, or WIP on), record `Last closure: unit:<ID>:<attempt>`,
   stage only owned changes (`git add -A -- <paths>`; for shared paths apply
   only the unit's hunks: `git diff --binary <base-tree> <closure-tree> --
   <path>` → `git reset -q <base-HEAD> -- <path>` → `git apply --cached`, with
   `--3way` fallback, else restore and report a blocker), plus STATE.md and
   history.md, and commit with the mandatory subject:
   - `sub-phase(<NNN>/<N.M>): sub-phase <N.M> of phase <N> complete — <title>`
   - `phase(<NNN>/P<N>): PHASE <N> COMPLETE — <title>; gates and review passed`
   - `plan(<NNN>): PLAN <NNN> COMPLETE — <feature>; <K> phases, final gates passed`
   - `task(<NNN>/T-A<n>)`, `bug(<NNN>/B-A<n>)`, `correction(<NNN>/V<n>-C<n>)`,
     `verify(<NNN>/V<n>)`, `wip(<NNN>/<unit>)`, `handoff(request-by-user)`
   and a final trailer block `PEV-Plan`, `PEV-Unit`, `PEV-Attempt`,
   `PEV-Result: complete|wip` beside any Co-Authored-By. Hooks run; never
   `--no-verify`; never push or switch branches. Resolve the reference by exact
   trailer values in `git log --format='%H%x09%(trailers:key=PEV-Unit,valueonly)' HEAD`
   (and PEV-Plan, PEV-Attempt, PEV-Result); zero matches = pending closure.
   With commits disabled, add a §4 row `uncommitted <base-tree>..<closure-tree>`.
8. Phase closure P<N>: all sub-phases DONE or SKIPPED with reason, README
   obligation met, full phase gates pass, agent-1 approves. P<N> never edits
   code or tests; a blocked gate keeps it OPEN/BLOCKED; a failure closes the
   attempt `failed` (commit none), reopens the responsible unit (attempt + 1)
   or revises the plan, then P<N> reruns. After the last P<N>, the plan closure
   PLAN runs G-FINAL and the reference scenario, agent-1's final review, marks
   the plan COMPLETE, and commits — no stop between them.
9. Compaction: STATE.md holds only the present. §4 only unsettled rows; §5/§6
   only the OPEN unit; §7 latest result per gate of the open phase; §8–§10 only
   what pending work needs; §11 expands only the open phase and collapses it to
   one row at P<N> DONE. Detail goes to history.md first. A legacy or
   oversized STATE.md is compacted when ownership is claimed, before any unit;
   a legacy plan with all phases DONE gets `PLAN | DONE` (legacy) and no PLAN
   run, unless the user asks for one.
10. Handoff (`handoff`, or a `--deadline` reached): set §1 `Stop latch: HANDOFF
    <trigger> <time>` and start nothing new; close the OPEN unit only if it takes
    about 10 minutes, else stop at a step boundary; save §6 with commands not
    run; result HANDOFF; release ownership. Code work: one local handoff commit
    even with commits disabled — owned changes of the OPEN or pending unit and
    every §4 `uncommitted` unit (one patch per unit), STATE.md, history.md;
    subject `handoff(request-by-user): <NNN>/<unit> stopped <point>`; trailers
    as above with `PEV-Result: wip`, `PEV-Handoff: user|deadline`,
    `PEV-Includes: <id>:<attempt>, …`; those rows become
    `handoff:<id>:<attempt>` with their trees. Never amended. Report the resume
    command, then stop: no tool call after the report, whatever the autonomy or
    permission mode. Only a new explicit user invocation clears the latch.
11. Task/Bug: agent-1 writes or validates the mini-plan (a Bug's with root
    cause) before code. With autonomy false stop once, entry PROPOSED, until a
    user reply or `resume <plan> <entry-id>` approves it.
12. Run end only: release ownership, then end the report with
    `Next` — Continue: one exact `/plan-execute-verify` command; Stop:
    `/plan-execute-verify handoff` when uncommitted work or held ownership
    remain, else nothing to save. Suggest both; never run them.
````

## 5. history.md

Created empty by Plan; append-only, never read to resume (execution-contract §8):

````markdown
# Plan <NNN> — history

## <date> <unit>/<attempt> <complete|failed> <commit ref or none>
Gates: <gate result (count)>; review: <agent verdict>; changes: <paths>; notes: <decisions, deviations>
````
