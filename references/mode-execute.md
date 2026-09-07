# Execute mode — implement an existing plan

`/plan-execute-verify execute [<plan>] [<phase|sub-phase>]`. This is the mode
that writes production code. It follows SKILL.md's **session protocol** and
**coherence contract** throughout.

---

## E1 — Load and verify the starting point

Read `STATE.md` first, then only the phase file to execute. Check §1 `Status`
before anything else: `OPEN` means a unit was claimed and may be half-written —
read §6 and finish or revert it before starting anything new. When §3 has WIP
commits on and `HEAD` is a `wip:` commit, that diff is the authoritative record of
the half-done work: finish it and `amend` into the close commit, or revert it.
Re-run the gates from `STATE.md` §3: if the tree is not in the state §1, §7, and
§11 claim, reconcile first and say so.

Resolve the WIP-commit setting here: an explicit `--wip-commit` /
`--no-wip-commit` on this invocation wins and is written into §3; otherwise use
what §3 already says; otherwise off.

## E2 — Pick the unit of work

Default: the sub-phase in `STATE.md` §1 `Next action:`, then continue in order. A
phase or sub-phase selector narrows execution to it; refuse (and say why) when
its preconditions are not `DONE` in the §11 board.

## E3 — Execute, sub-phase by sub-phase

- **Open the unit in `STATE.md` §1 before editing any code** (`Type: sub-phase`,
  its `ID`, `Status: OPEN`, `Intent`, `Next action:`, §6 `claimed — nothing
  written yet`). This is what makes an interruption recoverable.
- Do exactly what the sub-phase's **Change** field says. Follow its assignment:
  delegate to the tagged agent, honor the `agent-1` review gates.
- Write the named unit and e2e tests with the stated assertions. A sub-phase
  whose tests do not exist is not done.
- Run the phase gates. Never mark work done on a red gate.
- **Do not improvise scope.** Something the plan did not foresee is either a
  deviation recorded in `STATE.md` §8 with its reason, or a question to the user —
  never a silent extra change.
- Stop and ask when the plan is ambiguous, contradicts the code, or needs a
  decision outside the plan's `D*` set. Cheaper than an unwinding.
- **A defective sub-phase is a plan bug, not an excuse to improvise.** If one of
  the seven fields is missing, or the named files, anchors, or symbols no longer
  exist: say exactly what is wrong, repair that phase file first (recording the
  edit in `STATE.md` §8), and only then execute it.
- **Close the unit in `STATE.md`** once the gates are green — §4 ledger row, §6
  back to `none`, §5 §7 §8 §9 §10 and the §11 board updated, §1 pointing at the
  next unit with `Status: none`. With WIP commits on, commit the closed unit
  (`sub-phase(<N.Y>): <intent>`) staging only its files plus the plan files, put
  the sha in the §4 row, and name the branch you committed to. Then apply the rest
  of the **coherence contract** before starting the next sub-phase. At the end of each phase, the
  README sub-phase runs like any other.

## E4 — Executing a correction plan (`execute verify [V<NNN>]`)

A verify report's correction plan is executable work like any other, and it lives
on disk precisely so it can be run later or in a fresh session.

- Templates for the files you re-status: `references/templates-audit.md`.
- Default target: the newest report in `<plan-folder>/verify/`; a `V<NNN>`
  selector picks an older one. Read `verify/index.md` first, then that report.
- Work through the correction plan in order, blockers first, treating each item
  as its own **unit**: opened in `STATE.md` §1 as `Type: correction` with
  `ID: V<NNN>-C<n>` before editing, closed after its gates are green — and
  committed as `correction(V<NNN>-C<n>): <intent>` when WIP commits are on. An
  interrupted correction run resumes from §1 (or from the `wip:` commit) without
  re-reading the whole report.
- **Re-verify each item before closing it.** A finding is `FIXED` only when the
  condition it described no longer holds and the evidence is recorded.
- Update `verify/index.md` for every item: `FIXED` (with date and how it was
  closed), `OPEN` still (with the reason it could not be closed), or `ACCEPTED`
  when the user decides to live with it. Mirror the status in the report file so
  the two never disagree.
- Corrections that reopen a phase already marked `DONE` set that phase back to
  `IN_PROGRESS` in the `STATE.md` §11 board until its done-criterion holds again.
- Apply the full **coherence contract** after each correction, exactly as for a
  sub-phase: a correction changing user-visible behavior updates `README.md`, one
  that proves a plan file wrong reconciles that plan file.
- Close by saying which findings are now `FIXED`, which remain `OPEN`, and
  recommend a fresh `/plan-execute-verify verify` when blockers were touched.

## E5 — Close

Terse chat summary: sub-phases completed, gate results, deviations recorded, files
touched, next action — plus, when WIP commits are on, the commits created and the
branch they landed on. State plainly what failed or was skipped and why — never
report a phase done when part of it is not.

Before reporting done, run the **Coherence checklist** in
`references/quality-checklist.md`.
