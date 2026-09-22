# Agent roster — design authority and execution roles

Names are host-supported identifiers, passed unchanged. Position assigns
responsibility; it does not guarantee model availability or actual capability.

## Responsibilities

| Assignment | Responsibility |
|------------|----------------|
| agent-1:<name> | Strong architect/supervisor; technical plan revisions; risky sub-phase reviews; every phase's approval |
| agent-2:<name> | Primary implementer, including complex changes with complete contracts |
| agent-3:<name> and later | Recon and other assigned implementation; complex work is allowed when fully specified and supervised |
| agent:<name> | All responsibilities; review is explicitly labelled self-review |

A roster with only agent-1 has the same single-agent behavior as agent:<name>.
With multiple agents, assign only positions actually present in the roster.

Legacy defaults are Opus/Sonnet/Haiku in those positions. Explicit configuration
overrides the plan's roster; otherwise preserve the stored roster across sessions.
Record an intentional override and its effect on remaining assignments. Do not
treat opening a plan in a different model as an automatic roster override.

Select work by the worker's required reasoning, available context, and contract
completeness. The weakest worker can implement complex logic when the supervisor
has already decided the design and supplied exact steps, edge cases, and tests.
If a worker must invent a concurrency protocol or acceptance oracle, refine the
plan or escalate that decision before implementation.

## Two supported execution styles

### Handoff — successive sessions or models

STATE.md and the phase file are the handoff, not chat memory. Store the roster,
supervisor request, scope, current step, and evidence there. The active session
is the sole state writer. Before model/session transfer, checkpoint and release
ownership; the new session verifies the actual repository before resuming.

A weak executor requests the strong supervisor through the host when available.
Otherwise it saves a BLOCKED handoff naming the decision/review needed. A new
strong-model session resumes that same unit and records its review or revision.
The skill cannot create host capabilities or restart a session autonomously.

### Delegated — coordinator and workers

The coordinator alone changes shared state, plan specifications, ledgers, and
commits. It opens a unit, sends a bounded assignment, then verifies the worker's
result and invokes the strong supervisor for required reviews.

The worker must not apply the root cold-start protocol as though the coordinator's
OPEN unit were abandoned. It checks that plan/unit/revision/owner match its
assignment, then performs only the assigned steps. No nested delegation unless
the coordinator explicitly authorizes it. One implementation unit is active;
read-only research may be parallel.

## Dispatch bundle — implementation

Send the same facts that a cold handoff would need:

- Repository root, branch, plan ID/revision, unit ID/attempt, and current step.
- Phase file plus local contracts, prerequisites, allowed read/write paths.
- Scope, relevant existing dirty changes, required tests/gates, and expected output.
- Resolved full-autonomous/WIP settings; which agent owns state and commits.
- Explicit role: worker, reviewer, or coordinator; supervisor identity.
- Return format: completed steps, actual paths/diff, test evidence and discovery,
  deviations, unresolved decisions, and the next action. Report what actually ran.

A worker may read relevant callers and fixtures beyond the write allowlist.
Unexpected necessary writes go to the coordinator/supervisor for scope checking.

## Review and escalation bundle

The supervisor checks the actual diff, applicable decisions/invariants, relevant
source contracts, and test assertions/results. Review high-risk design before
implementation and the result before closing the unit. Approve every phase only
after all sub-phases and phase acceptance hold.

Record reviewer, plan revision, reviewed change identity, checks, verdict, and
remaining actions. A statement that the worker followed instructions is not a
review. Revalidate after changes to the reviewed behavior.

Technical corrections within unchanged requirements/scope can be approved by the
supervisor without returning to the user. Missing product decisions or additional
external authority still require the user. If the supervisor is unavailable,
persist the request; never impersonate it or relabel a weak self-review as approval.

## Recon and announcements

Batch focused recon: paths, signatures, callers, test harness, command syntax,
reuse candidates, and unknowns. The supervisor inspects critical contracts
directly rather than trusting a terse weaker-agent summary blindly.

Announce the actual configured assignment for material work and reviews. Record
both the intended and actual reviewer/worker when availability affects execution.
Keep reports focused, but include enough evidence to verify their claims.
