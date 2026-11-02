# Resume — continue recorded work without changing it

`/plan-execute-verify [<options>] resume [<plan>] [<unit-id>]`

Resume continues work already recorded by this skill. It never starts a TODO
unit named by ID or work outside the saved execution scope, never changes that
scope, and never rewrites saved settings or roster. A resumed unit keeps the
effective settings and roster recorded on it (ledger entry, audit report, or §1
invocation record); continuing the saved execution scope uses its overrides,
then §3. Explicit options and an agent prefix override either for this
invocation only. Read execution-contract.md, then the manual of the mode that
owns the resumed work.

## R1 — Resolve the target

- Plan: a real plan selector, or `000_adhoc` for ad-hoc ledgers. Without one,
  use the unique plan or ledger with OPEN (any open unit, execution-contract
  §3), pending-closure, BLOCKED, or suspended work, or a set (not `none`) saved
  execution scope that is NOT_STARTED, RUNNING, or BLOCKED; several candidates
  require a user choice (with `full-autonomous:true`, an autonomous decision,
  execution-contract §4). A PROPOSED task or bug never counts here.
- Unit ID (optional): sub-phase `N.M`, phase closure `P<N>`, plan closure
  `PLAN`, correction
  `V<NNN>-C<n>`, audit `V<NNN>`, task `T-A<NNN>`, or bug `B-A<NNN>`. It must name
  OPEN, pending-closure, BLOCKED, or suspended work, or a PROPOSED `T-A<NNN>` or
  `B-A<NNN>`: naming it approves the proposal (mode-taskbug.md approval gate). A
  TODO unit is new work: reject the selector and suggest the matching `execute`
  command instead.
- One argument: a token matching the unit-ID grammar is a unit ID, not a plan
  selector; select a plan named like one by number or path. Without a plan, a
  unit ID resolves to the unique plan or ledger (including `000_adhoc`) that
  records it as resumable; several matches require a user choice (with
  `true`, an autonomous decision).
- Apply the stale-ownership rule in execution-contract §2; Resume is an explicit
  operational invocation. When it claims ownership, apply pending format
  migrations and compact an oversized STATE.md first (execution-contract §8).

## R2 — Recover recorded work first

In this order, finish recovery before anything else:
1. An OPEN audit or an unresolved audit completion commit (mode-verify.md); for
   `000_adhoc` it is recorded in its verify/index.md.
2. A pending completion transaction of the named or current unit (§6).
3. The OPEN unit, in its own mode: sub-phase, P<N>, or correction (mode-execute.md),
   task or bug (mode-taskbug.md), with its recorded settings.
4. A suspended implementation restored from §12 after its audit closed.
5. A DRAFT plan with a research or planning checkpoint (mode-plan.md).
6. A PROPOSED task or bug named by its entry ID: approve it, revalidate, and
   continue it (mode-taskbug.md approval gate). With `false` this handles only
   that entry: items 1–5 of its plan are reported with their resume commands,
   not run. With `true` items 1–5 are recovered first, in order.

A BLOCKED unit resumes only when its blocker is resolved; otherwise report the
blocker, its owner, and the exact question instead of retrying. With `true`, a
blocker that was only a user decision is decided now (execution-contract §4)
and the unit resumes.

Work stopped by Handoff mode (invocation result `HANDOFF`) has already released
ownership. This explicit Resume clears its stop latch in the state update that
claims ownership (execution-contract §3). Its handoff commit (mode-handoff.md H5) holds the OPEN unit's work
and the closed units listed in `PEV-Includes`, and is never amended: continue
from the §6 next action, and append later WIP and completion commits after it.
Units it holds are committed (`handoff:<id>:<attempt>`), not pending, unless
that reference resolves to no commit: they are then still uncommitted, with
their recorded trees (execution-contract §6). The interrupted run's deadline
does not carry over.

## R3 — Continue the saved execution scope

After recovery, without a unit ID, continue a set (not `none`) saved execution
scope while its result is NOT_STARTED, RUNNING, or BLOCKED, exactly as Execute
would under that selector, including its autonomy loop: under
`full-autonomous:true` a resumed run does not stop at the next sub-phase or
phase boundary. A Verify correction pass (mode-verify.md V6) interrupted with
`true` first finishes that report's remaining READY corrections. With a unit
ID and `false`, stop after that unit's recovery and closure; with `true`,
continue after it as above. `000_adhoc` has no saved execution scope or §3:
with `false`, stop after the recovered entry, using the settings recorded in
it; with `true`, then recover every other resumable entry of that ledger in
ledger order (never a PROPOSED one not named). When nothing remains to
resume, including a saved scope of `none`, report that, any PROPOSED entries
with their approval commands, the next eligible plan unit, and the command that
would start it; do not start it. Every Resume ends with the Next block
(next-step.md).
