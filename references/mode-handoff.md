# Handoff — stop gracefully and leave resumable work

`/plan-execute-verify handoff [--deadline=dd-mm-yyyy_hh_mm]`

Handoff mode asks the running work to stop as soon as practical, or by a
deadline: bound the work in flight, leave state that a later session can resume,
make one handoff commit for code work, report the exact resume command, and
stop. A handoff is terminal for the run: it overrides `full-autonomous:true`,
the saved scope, and every permission mode (bypass, yolo, auto-approve), and it
sets the stop latch (execution-contract §3): `handoff` alone at once,
`handoff --deadline=…` only at the cutoff before that deadline (H2). The leading option `--deadline=dd-mm-yyyy_hh_mm` on any other mode
schedules the same procedure from the start. Do not confuse this mode with the
handoff execution style or a BLOCKED handoff (agent-roster.md): those describe
how sessions pass work on, not a user stop.

A handoff is always honored, under every autonomy setting, saved scope, and
permission mode, and a deadline is binding both ways: by the deadline time the
work in flight is bounded, state saved, the handoff commit made, and the report
written (H2), and before its cutoff the run keeps working, so a deadline never
stops it early, not even while it waits for a worker. Because a request reaches
the agent only between tool calls and the agent cannot interrupt its own running
tool call except by stopping a process it started, it keeps every call short
enough to meet the deadline. Only a session with no run in progress (H1) hands
off at once under a deadline: it has no work to continue, and a handoff never
starts work.

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
- Run in progress: this session's current invocation has not yet ended with its
  final report (the Next block or a handoff report). That includes a session
  whose host shows the turn ended while a worker, background command, or tool
  call it started has not sent its completion notice: it is waiting, not idle.
  An idle session has no run in progress; a RUNNING scope left in STATE.md by
  an ended run, or a deadline wake-up still armed, does not make one.
- Sent during a run in progress: the target is the current invocation's plan or ledger and
  unit. `handoff` alone starts the procedure now, sets the stop latch at once,
  and cancels any earlier deadline. `handoff --deadline=…` lets the run continue, replacing any earlier
  deadline, and starts the procedure at the cutoff before that deadline, so it
  ends by the deadline (H2). Before the cutoff it sets no latch, stops or
  recalls no worker, and writes no handoff report: it records the deadline,
  prints one line with the deadline and cutoff, and continues the work or the
  wait (H2).
- Sent to an idle session: the target is the plan or ledger whose state this
  session last wrote, else every plan or ledger with OPEN work, a pending
  closure, or units recorded `uncommitted`, handed off one after another, each
  with its own state update and commit; never a question, since stopping never
  loses work. Work owned by another live session is never a target: report it as an
  ownership conflict (execution-contract §2) and leave it to that session. With
  no target, report that nothing needs a handoff, release ownership this session
  still holds, end with the Next block (next-step.md), and stop. With no run in
  progress there is no work to continue until the deadline, and a handoff never
  starts work, so a deadline there means an immediate handoff; the report says
  so.
- Record the deadline and the request time as soon as they arrive in the
  invocation record (STATE.md §1 Settings `deadline`, the ledger entry, or the
  audit report), so they survive a context reset or compaction while the run
  works or waits; record the trigger (`user` or `deadline`) when the procedure
  starts. The deadline belongs to this run only; it is never a scope override, never
  written to §3, and never carried into the resume command.

## H2 — Work under a deadline

The deadline is a hard limit for the end of H6, not for the start of the
handoff. Plan backwards from it:

- Reserve: the minutes H3–H6 need, at least 10, more when closing the OPEN
  unit, awaiting a worker, or staging many units needs it. The cutoff is the
  deadline minus the reserve; recompute both at every check.
- Check the clock before opening a unit, before each step, review, gate run,
  dispatch, or command, after each command, and at every progress line.
- Start only work expected to finish before the cutoff: no unit, review, gate,
  research lookup, or delegation that would cross it. Prefer stopping early to
  overrunning.
- Bound every command that may run over a minute with `timeout <N>m`, N being
  the minutes left before the cutoff; without `timeout`, do not start a command
  that might cross it. Give a delegated worker the cutoff as its return time,
  and stop it through the host when it passes.
- Whenever the run waits for a worker or background command under a deadline,
  also one received during that wait: leave it running, send the worker the
  cutoff as its new return time when the host can message it, and arm a
  wake-up at the cutoff with whatever the host provides (a scheduled wake-up, a
  monitor, or a background timer command whose exit notifies the session), so
  the clock is checked at the cutoff even if no notice arrives earlier. Without
  such a mechanism the worker's return is the next check, and the report says
  the cutoff could only be checked then. Arm one wake-up per deadline: a
  replacing deadline, `handoff` alone, and every run end cancel it.
- A completion notice that arrives before the cutoff is the run's own work, not
  host automation: reconcile the result and continue the autonomy loop under
  the deadline (execution-contract §3). A fired wake-up is a clock check: at
  the cutoff start H3, before it keep waiting. A wake-up that fires after the
  run ended or the latch was set gets one line and nothing else.
- At the cutoff, or when the next action no longer fits, start H3 with trigger
  `deadline`. A deadline received when its cutoff has already passed means an
  immediate handoff with the shortest H3: stop at the current step boundary.

A scope that completes before the cutoff ends normally, without a handoff, and
cancels any wake-up it armed.

## H3 — Bound the work in flight

- Start nothing new: no unit, phase closure, review, research lookup, or
  delegation. The scope's remaining units, and the plan's next eligible unit,
  stay for the resume command, even under full autonomy.
- If the OPEN unit can be closed in about 10 minutes, including its focused
  checks and required review, and, under a deadline, within the reserve with
  time left for H4–H6 before the deadline, close it normally (execution-contract §6), with its
  completion commit when the commit policy enables one; that closure is the
  last work of the run. Otherwise stop at the next step boundary and leave no
  half-written file.
- Let a running command finish when it should end within that window. Otherwise
  stop it when the agent controls its process, and record it as not run. A P<N>
  closure interrupted during its full gates stays OPEN with those gates not run.
- Delegated style: the coordinator stops dispatching. A running worker is
  awaited when it should return within that window; otherwise the coordinator
  stops it through the host when possible and reconciles its partial diff as
  OPEN work. No worker keeps running after the handoff.
- Stop background services, temporary resources, and any deadline wake-up this
  run started, or record them in the checkpoint with their cleanup action.

## H4 — Leave resumable state

Write one coherent state update (execution-contract §7) that matches the actual
diff:

- §6 checkpoint: last durable step, exact next action, owned diff, pending
  edits, commands recorded as not run, and resources to clean up.
- The OPEN unit stays OPEN with its status and attempt; nothing is marked DONE
  that is not closed. The saved execution scope keeps its result (RUNNING or
  BLOCKED); a COMPLETE scope needs no handoff.
- The invocation result becomes `HANDOFF` with its trigger and time, and §1
  records `Stop latch: HANDOFF <trigger> <time>`.
- Release the ownership this session holds with time and reason `handoff`, so
  the next session needs no stale-ownership takeover.
- In `000_adhoc` the ledger entry holds the same checkpoint, result, and
  release.
- Plan: save the DRAFT research or planning checkpoint (mode-plan.md).
- Verify: keep the audit OPEN with its checkpoint in the report and index; a
  suspended implementation stays in §12.
- Onboard persists nothing beyond what it already wrote; it is simply rerun.

## H5 — Handoff commit

Execute, Execute verify, Task, Bug, a Verify correction pass (mode-verify.md
V6), and Resume of one of them always end with one local handoff commit, even
when completion and WIP commits are disabled: the user's explicit handoff
authorizes it. Plan and an audit never commit here; their
report warns that the draft or audit files are uncommitted and suggests the
commit command without running it. Onboard commits nothing.

- Content: the owned changes of the OPEN unit, of a unit with a pending
  closure, and of every unit of this plan or ledger recorded `uncommitted`, the
  plan files required by execution-contract §6 step 2, and STATE.md and the
  ledgers whole. Committing STATE.md without
  those units' code would claim work the commit does not contain.
- Staging: execution-contract §6 steps 2–3 with current HEAD as the reset
  target, but one owned patch per included unit. Reset the owned paths to HEAD
  once, then apply, in closure order, each closed unit's recorded
  `<base-tree>..<closure-tree>` patch, and last the patch of the OPEN or
  pending-closure unit from its last WIP snapshot, or else its base tree, to a
  fresh snapshot. Patch every
  owned path this way, not only shared ones, so changes made between units,
  such as user edits, stay out of the commit. A unit recorded `uncommitted`
  without both trees (a legacy record) or with a pruned tree cannot be
  separated: leave it out and keep its reference, so the committed STATE.md
  still shows it uncommitted, and list it in the report.
  Record the fresh snapshot as the last WIP snapshot in §1.
- Ledger: change each included closed or pending-closure unit's reference to
  `handoff:<id>:<attempt> <base-tree>..<closure-tree>` (execution-contract §6)
  in the same state update. If staging or the commit fails, restore the
  previous references before reporting.
- Message: subject
  `handoff(request-by-user): <plan>/<unit-id> stopped <stop point>` (`<plan>`
  alone when no unit is open), also for a
  deadline, which the user set; trailers
  `PEV-Plan`, `PEV-Unit` (the OPEN unit, or `none`), `PEV-Attempt` (its attempt,
  or `0`), `PEV-Result: wip`, `PEV-Handoff: user|deadline`, and, when closed
  or pending-closure units are included, `PEV-Includes: <id>:<attempt>, …`, in
  the final trailer
  block beside any `Co-Authored-By:` or `Signed-off-by:` lines.
- A handoff commit is never amended; later WIP and completion commits append
  after it.
- Hooks run; never use `--no-verify`. A failing hook leaves the work and
  checkpoint on disk uncommitted: restore the included units' previous
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
closed now. Then stop: the report is the last output of the run and no tool
call follows it, under every autonomy setting and permission mode. Later host
automation (auto-continue, loops, hooks, a worker's completion notice, a
deadline wake-up) does not
restart work; only a new explicit user invocation clears the latch.
