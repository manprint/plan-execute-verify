# Handoff — stop gracefully and leave resumable work

`/plan-execute-verify handoff [--deadline=dd-mm-yyyy_hh_mm]`

Handoff mode asks the running work to stop as soon as practical, or by a
deadline: bound the work in flight, leave state that a later session can resume,
make one handoff commit for code work, report the exact resume command, and
stop. The leading option `--deadline=dd-mm-yyyy_hh_mm` on any other mode
schedules the same procedure from the start. Do not confuse this mode with the
handoff execution style or a BLOCKED handoff (agent-roster.md): those describe
how sessions pass work on, not a user stop.

The stop is best effort, not a hard real-time guarantee. A handoff sent during a
run reaches the agent only between tool calls; the agent cannot interrupt its
own running tool call except by stopping a process it started, and an idle
session never wakes up by itself at a deadline. Users set the deadline earlier
than the moment they really need the machine.

Read execution-contract.md §3 and §6, then the manual of the interrupted mode
only for its checkpoint fields.

## H1 — Resolve the trigger and target

- A stop request is never rejected, because stopping early never loses work.
  `--deadline=…` may follow `handoff` or precede it as a leading option. Any
  other option, an agent prefix, a selector, or extra argument is reported as
  ignored. An invalid deadline, or two different ones, is reported and means an
  immediate handoff.
- Deadline format: `dd-mm-yyyy_hh_mm`, a real calendar date, 24-hour time, in
  the local time zone of the machine running the agent. Validate it and compute
  the minutes left, for example:

  ```bash
  python3 -c 'import sys, datetime as d
  t = d.datetime.strptime(sys.argv[1], "%d-%m-%Y_%H_%M")
  print(int((t - d.datetime.now()).total_seconds() // 60))' 31-10-2026_17_30
  ```

  Without Python, compare with `date +%d-%m-%Y_%H_%M` by hand. A deadline
  already past means an immediate handoff. As a leading option of another mode,
  an invalid value is an error before work starts.
- Sent during a run: the target is the current invocation's plan or ledger and
  unit. `handoff` alone starts the procedure now and cancels any earlier
  deadline. `handoff --deadline=…` lets the run continue, replacing any earlier
  deadline, and starts the procedure when that deadline is reached (H2).
- Sent to an idle session: the target is the plan or ledger whose state this
  session last wrote, else the unique plan or ledger with OPEN work, a pending
  closure, or units recorded `uncommitted`; several candidates require a user
  choice. With none, report that nothing needs a handoff, release ownership the
  session still holds, end with the Next block (next-step.md), and stop. An idle
  session has nothing to schedule, so a deadline there means an immediate
  handoff.
- Record the trigger (`user` or `deadline`), the request time, and the deadline
  in the invocation record (STATE.md §1, the ledger entry, or the audit report).
  The deadline belongs to this run only; it is never a scope override, never
  written to §3, and never carried into the resume command.

## H2 — Work under a deadline

Check the minutes left before opening a unit, before each step, review, gate
run, or long command, and after any long command. Do not start work expected to
finish after the deadline minus the time the handoff itself needs (a few
minutes). Bound a long command with `timeout <N>m`, N being the minutes left,
when the shell provides it. When the next action no longer fits, start H3 with
trigger `deadline`. Small overruns are acceptable; a scope that completes before
the deadline ends normally, without a handoff.

## H3 — Bound the work in flight

- Start nothing new: no unit, phase closure, review, research lookup, or
  delegation.
- If the OPEN unit can be closed in about 10 minutes, including its focused
  checks and required review, and before any deadline, close it normally
  (execution-contract §6), with its completion commit when the commit policy
  enables one. Otherwise stop at the next step boundary and leave no
  half-written file.
- Let a running command finish when it should end within that window. Otherwise
  stop it when the agent controls its process, and record it as not run. A P<N>
  closure interrupted during its full gates stays OPEN with those gates not run.
- Delegated style: the coordinator stops dispatching. A running worker is
  awaited when it should return within that window; otherwise the coordinator
  stops it through the host when possible and reconciles its partial diff as
  OPEN work. No worker keeps running after the handoff.
- Stop background services and temporary resources this run started, or record
  them in the checkpoint with their cleanup action.

## H4 — Leave resumable state

Write one coherent state update (execution-contract §7) that matches the actual
diff:

- §6 checkpoint: last durable step, exact next action, owned diff, pending
  edits, commands recorded as not run, and resources to clean up.
- The OPEN unit stays OPEN with its status and attempt; nothing is marked DONE
  that is not closed. The saved execution scope keeps its result (RUNNING or
  BLOCKED); a COMPLETE scope needs no handoff.
- The invocation result becomes `HANDOFF` with its trigger and time.
- Release ownership with time and reason `handoff`, so the next session needs no
  stale-ownership takeover.
- In `000_adhoc` the ledger entry holds the same checkpoint, result, and
  release.
- Plan: save the DRAFT research or planning checkpoint (mode-plan.md).
- Verify: keep the audit OPEN with its checkpoint in the report and index; a
  suspended implementation stays in §12.
- Onboard persists nothing beyond what it already wrote; it is simply rerun.

## H5 — Handoff commit

Execute, Execute verify, Task, Bug, and Resume of one of them always end with
one local handoff commit, even when completion and WIP commits are disabled: the
user's explicit handoff authorizes it. Plan and Verify never commit here; their
report warns that the draft or audit files are uncommitted and suggests the
commit command without running it. Onboard commits nothing.

- Content: the owned changes of the OPEN unit and of every unit of this plan or
  ledger recorded `uncommitted`, the plan files required by execution-contract
  §6 step 2, and STATE.md and the ledgers whole. Committing STATE.md without
  those units' code would claim work the commit does not contain.
- Staging: execution-contract §6 steps 2–3 with current HEAD as the reset
  target, but one owned patch per included unit. Reset the owned paths to HEAD
  once, then apply, in closure order, each closed unit's recorded
  `<base-tree>..<closure-tree>` patch, and last the OPEN unit's patch from its
  last WIP snapshot, or else its base tree, to a fresh snapshot. Patch every
  owned path this way, not only shared ones, so changes made between units,
  such as user edits, stay out of the commit. A unit recorded `uncommitted`
  without both trees (a legacy record) or with a pruned tree cannot be
  separated: leave it out, keep its reference, and list it in the report.
  Record the fresh snapshot as the last WIP snapshot in §1.
- Ledger: change each included closed unit's reference from `uncommitted …` to
  `handoff:<id>:<attempt>` (execution-contract §6) in the same state update.
- Message: subject
  `handoff(request-by-user): <unit-id or plan-id> <stop point>`; trailers
  `PEV-Plan`, `PEV-Unit` (the OPEN unit, or `none`), `PEV-Attempt` (its attempt,
  or `0`), `PEV-Result: wip`, `PEV-Handoff: user|deadline`, and, when closed
  units are included, `PEV-Includes: <id>:<attempt>, …`, in the final trailer
  block beside any `Co-Authored-By:` or `Signed-off-by:` lines.
- A handoff commit is never amended; later WIP and completion commits append
  after it.
- Hooks run; never use `--no-verify`. A failing hook leaves the work and
  checkpoint on disk uncommitted: restore the included units' `uncommitted …`
  references, then report the hook output and the commit command instead of
  fixing code now. With nothing to commit, make no empty commit.
- Never push, switch branches, or commit unrelated changes.

## H6 — Report and stop

Report the trigger and deadline, what completed, where work stopped, commands
not run, the commit SHA and branch or why there is none, remaining uncommitted
files, and the exact command that continues the interrupted invocation:

| Interrupted work | Resume command |
|------------------|----------------|
| Execute or Execute verify scope | `/plan-execute-verify resume <plan>` |
| Task, Bug, or Verify on a real plan | `/plan-execute-verify resume <plan> <unit-id>` |
| Ad-hoc task, bug, or audit | `/plan-execute-verify resume 000_adhoc <unit-id>` (`T-A<NNN>`, `B-A<NNN>`, or `V<NNN>`) |
| Plan draft | `/plan-execute-verify resume <plan>` |
| Onboard | `/plan-execute-verify onboard [<plan>]` |

Recorded settings and roster resume with the work, so the command repeats no
option; the deadline does not carry over. This command is the Continue line of
the Next block (next-step.md), whose Stop line says only that the session can be
closed now. Then stop: no further tool calls, even under `full-autonomous:true`.
