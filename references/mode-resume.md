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
  use the unique plan or ledger with OPEN, pending-closure, BLOCKED, or
  suspended work, or a set (not `none`) saved execution scope that is
  NOT_STARTED, RUNNING, or BLOCKED; several candidates require a user choice.
- Unit ID (optional): sub-phase `N.M`, phase closure `P<N>`, correction
  `V<NNN>-C<n>`, audit `V<NNN>`, task `T-A<NNN>`, or bug `B-A<NNN>`. It must name
  OPEN, pending-closure, BLOCKED, or suspended work. A TODO unit is new work: reject
  the selector and suggest the matching `execute` command instead.
- One argument: a token matching the unit-ID grammar is a unit ID, not a plan
  selector; select a plan named like one by number or path. Without a plan, a
  unit ID resolves to the unique plan or ledger (including `000_adhoc`) that
  records it as resumable; several matches require a user choice.
- Apply the stale-ownership rule in execution-contract §2; Resume is an explicit
  operational invocation.

## R2 — Recover recorded work first

In this order, finish recovery before anything else:
1. An OPEN audit or an unresolved audit completion commit (mode-verify.md); for
   `000_adhoc` it is recorded in its verify/index.md.
2. A pending completion transaction of the named or current unit (§6).
3. The OPEN unit, in its own mode: sub-phase, P<N>, or correction (mode-execute.md),
   task or bug (mode-taskbug.md), with its recorded settings.
4. A suspended implementation restored from §12 after its audit closed.
5. A DRAFT plan with a research or planning checkpoint (mode-plan.md).

A BLOCKED unit resumes only when its blocker is resolved; otherwise report the
blocker, its owner, and the exact question instead of retrying.

Work stopped by Handoff mode (invocation result `HANDOFF`) has already released
ownership. Its handoff commit is the OPEN unit's own WIP commit and is never
amended: continue from the §6 next action, and append later WIP and completion
commits after it. Closed units it holds are committed
(`handoff:<id>:<attempt>`), not pending. The interrupted run's deadline does not
carry over.

## R3 — Continue the saved execution scope

After recovery, without a unit ID, continue the saved execution scope while its
result is NOT_STARTED, RUNNING, or BLOCKED, exactly as Execute would under that
selector. With a unit ID, stop after that unit's recovery and closure.
`000_adhoc` has no saved execution scope or §3: stop after the recovered entry,
using the settings recorded in it. When nothing remains to resume, including a
saved scope of `none`, report that, the next eligible plan unit, and the command
that would start it; do not start it.
