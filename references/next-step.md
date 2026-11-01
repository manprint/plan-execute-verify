# Next step — end every run with Continue and Stop

Read before the final report of every mode, however the run ends: completion, a
phase-closure stop, a BLOCKED or approval-gate stop, a handoff, a rejected
invocation, or a run under `full-autonomous:true`. Only the end of the run
counts: a closed unit or a commit inside the scope is not an end, and gets no
report and no Next block (execution-contract §3, autonomy loop). The report ends
with this block, in the user's language including its labels, as its last
element:

```text
Next
- Continue: `/plan-execute-verify <command>` — <what it will do>
- Stop: `/plan-execute-verify handoff` — <what it saves>; then close the session
```

Each line takes the form N1 and N2 select. Continue may instead read "answer or
provide <item>, then `/plan-execute-verify <command>`" or "nothing to continue —
<reason>". Stop may instead read "nothing to save; close the session now".

## N1 — Continue

- One command: the first applicable row below, evaluated on the state the run
  leaves behind. Alternatives belong in the report body. Onboard O4 uses the
  same rows.
- Exact form: the full `/plan-execute-verify` prefix, real IDs, and the plan by
  number, so feature names and reserved words cannot misparse. The table's
  `<plan>`, `<unit-id>`, `<entry-id>`, and `V<NNN>` stand for actual values; the
  printed line has no placeholders.
- No options, except that a corrected command after a rejection keeps the
  user's valid options: recorded settings and roster travel with `resume`, and a
  `--deadline` never carries over. A new Execute scope starts from the plan
  defaults in §3, not from earlier scope overrides: label it a new scope and
  state its effective autonomy and WIP behavior.
- A missing decision or evidence: write "answer or provide <exact item>, then
  `<command>`", never a command that would be unsafe without it.
- A suggestion only: never run it, even under `full-autonomous:true`; the run
  already ended at its scope or stop.
- Nothing to continue: say so plainly, with the reason.

| # | State after the run | Continue |
|---|---------------------|----------|
| 1 | Invocation rejected before work started | The corrected command when the fix is unambiguous; otherwise the syntax from invocation.md and the exact question |
| 2 | This run ended by a handoff (result HANDOFF) | The resume command from mode-handoff.md H6 |
| 3 | This run stopped at the task/bug approval gate (PROPOSED) | `resume <plan or 000_adhoc> <entry-id>`, which approves it; to reject it, reply in the session or set the entry WITHDRAWN with a reason |
| 4 | Several candidate plans or ledgers; target, ownership, branch/baseline, or scope conflict; required source missing | The exact question or choice, or the session that owns the work; never blind execution, a branch switch, or a `handoff` of another session's work |
| 5 | BLOCKED unit, audit, or scope | The unblocking decision, owner, or capability, then `resume <plan> <unit-id>`; a historical BLOCKED label whose resolution the user supplied needs supervisor validation first |
| 6 | Interrupted unit, pending completion transaction, or suspended audit | `resume <plan> <unit-id>`, recovering in its original mode and scope; an OPEN audit or pending audit commit precedes its suspended implementation; blocked readiness or design goes to the supervisor first; never a new audit or later phase that bypasses recovery |
| 7 | Task or bug PROPOSED by an earlier run, awaiting approval | `resume <plan or 000_adhoc> <entry-id>`, which approves it, with the entry path and a summary of its mini-plan; to reject it, the user sets its status to WITHDRAWN with a reason; never approve or withdraw it on the user's behalf |
| 8 | DRAFT or BLOCKED plan, or an underspecified/legacy contract | The supervisor decision or evidence needed, naming the folder and affected unit, then `resume <plan>`; never a new plan or a readiness claim |
| 9 | Audit INCOMPLETE because required evidence is missing | Provide that evidence, then rerun this run's `verify` command with its selector |
| 10 | Audit corrections BLOCKED or awaiting a user decision | The decision or design needed, then `execute verify <plan> V<NNN>`, or in `000_adhoc` the corrected Task/Bug command; an OPEN finding alone never authorizes a fix, and blocking findings are never bypassed by ordinary implementation |
| 11 | READY audit corrections | `execute verify <plan> V<NNN>` with the actual report; in `000_adhoc` the first ready Task/Bug command |
| 12 | READY work remaining inside the saved execution scope, including a stop after a phase closure | `resume <plan>`, naming the next unit and its prerequisites |
| 13 | READY plan with saved execution scope `none` | `execute <plan>`, or a narrower phase or sub-phase selector, as a new scope |
| 14 | Saved scope complete while later plan work remains, including a pending P<N> after a sub-phase scope or a pending PLAN closure | Say the scope is complete; propose the later command (for P<N>, the phase selector) as a new scope, not a resume |
| 15 | Plan complete (PLAN closed) without an audit of its final state | `verify <plan>` |
| 16 | Task or bug completed by this run | `verify <plan or 000_adhoc> <entry-id>`, labelled optional; otherwise nothing to continue |
| 17 | Plan complete and its final state audited, or an ad-hoc audit closed, without open corrections | Nothing to continue; state the evidence and verification limits |
| 18 | Onboard: no resumable work and no user goal | Ask the desired outcome and explain Plan, Task, and Bug; never invent an argument or a roadmap from TODOs |
| 19 | Onboard: a concrete new goal supplied | `plan <goal>`, `task <description>`, or `bug <description>` at the actual scope |

## N2 — Stop

Derive the Stop line from the recorded state, not from the settings:

- Code work not yet committed (an open unit with changes, a pending closure, or
  units recorded `uncommitted`, including a `handoff:` reference that resolves
  to no commit), or ownership this session still holds (read the ownership
  field): suggest `/plan-execute-verify handoff`. Say that it saves the
  checkpoint, makes one local handoff commit of those units even with commits
  disabled (mode-handoff.md H5), and releases any ownership still held.
  Ownership held by another live session is a conflict (row 4): never suggest
  handing off its work.
- Otherwise: nothing to save; the session can be closed now and later
  continued with the Continue command.
- A handoff never commits a PROPOSED entry, a plan draft, an audit, or
  docs/onboarding.md, nor plan files beyond those execution-contract §6 step 2
  requires for its units. Name such uncommitted files with the suggested
  commit command, never run it, and never claim `handoff` saves them.
- After a handoff (row 2) say only that the session can be closed now, unless
  its commit failed on a hook: then give that commit command. Never suggest
  `handoff` again.
