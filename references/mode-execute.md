# Execute mode — implement and resume a selected scope

Read execution-contract.md and agent-roster.md. Use the Coherence checklist in
quality-checklist.md. These rules apply to both ordinary execution and
`execute verify`.

## E1 — Resolve and recover

Resolve the plan, scope, roster, execution style, full-autonomous setting, and WIP
setting per SKILL.md. Read STATE.md first. Preserve the previous scope on a
handoff; an explicit new selector supersedes it without abandoning OPEN work.

Check ownership, actual repository changes, checkpoint, unit base, commit
references, and current branch. Reconcile any OPEN/pending-commit unit first.
A delegated worker follows its assignment rather than taking over this root loop.

A plan must be READY at its recorded revision before dispatch. For legacy plans,
have the supervisor fill missing sub-phase rows, dependencies, local contracts,
steps, review/evidence fields, and runtime metadata from repository evidence.
If a required design decision is missing, refine the plan before implementation.

Run applicable baseline/resume checks. A future gate whose owning unit has not
created its target is not applicable yet, not a failure to repair by improvisation.
A required active gate that cannot run remains blocked.

## E2 — Select an eligible unit

Use the next eligible unit in scope, respecting order and explicit dependencies.
Require prerequisite sub-phases and artifacts, not just a phase's claimed DONE.
A SKIPPED dependency requires an explicit supervisor waiver/replacement.
Refuse inconsistent selectors with an actionable reason.

Record whether this invocation covers the whole plan, one phase, one sub-phase,
or a report. Full autonomy does not expand that selection.

## E3 — Execute the detailed contract

1. Open the unit and mark its phase/sub-phase IN_PROGRESS. Record ID/attempt,
   plan revision, base, ownership, intended files, and first step.
2. Read the local design context and named source slices. Confirm interfaces and
   relevant callers before editing. Follow numbered steps and their postconditions.
3. Checkpoint after meaningful edit/test batches and before yielding. Workers
   return evidence to the coordinator; only the state owner updates shared files.
4. Implement named tests with the stated fixtures and assertions. Verify that the
   intended tests actually execute; test absence or zero discovery is not success.
5. For locator drift, find and inspect the symbol. For missing/contradictory
   design, escalate to the strong supervisor. The supervisor may repair technical
   steps within unchanged requirements/scope, version the plan, and update
   dependents. The weak implementer must not quietly redesign it.
6. Run unit gates and required review against the actual diff. After two failed
   fixes of the same issue, escalate instead of retrying blindly or weakening tests.
7. Apply the coherence contract in full, then close and commit according to
   execution-contract.md. Resolve the completion commit identity before advancing.
   A failure to commit leaves closure pending and recoverable, not fully complete.
8. Continue the next eligible unit. Routine sub-phase completion is not a reason
   to ask the user to authorize work already in scope.

## E4 — Close each phase

After its implementation and README sub-phases, open P<N> as a phase-close unit.
Run phase gates, obtain the strong supervisor's review of integration/invariants/
tests/docs, and record evidence. Only then mark the phase DONE. With
full-autonomous:true, commit this nonempty state/review update on the current
branch, distinctly identifying phase completion.

The final phase additionally proves the reference scenario and final gates.
When a scoped sub-phase finishes, do not execute later sub-phases outside that
scope. Keep the next eligible plan unit recorded for the next invocation.

## E5 — Corrections from an audit

`execute verify [<plan>] [V<NNN>]` uses the selected/active plan's newest report by
default. Read STATE.md, verify/index.md, and the selected report. Use
templates-audit.md for record updates.
Check correction-plan readiness as well as the main plan. BLOCKED or legacy
underspecified corrections require supervisor refinement and evidence before
dispatch; an audit's completed status is not proof its corrections are executable.

Each correction is a unit V<NNN>-C<n>, with the same detailed contract as a
sub-phase. Recheck its finding against the current tree before editing. If it is
already resolved, record current evidence and avoid duplicate code or commits.

Work in dependency/severity order. A correction affecting a completed phase
reopens it; invalidate dependent evidence as needed. Re-run the affected phase
gates and supervisor review, then close it through P<N> with a new attempt.
No empty closure commits for phases that were not actually reopened.

Mark a finding FIXED only with evidence that its condition no longer holds.
Keep unresolved findings OPEN; ACCEPTED requires the user's decision; OBSOLETE
requires a concrete reason. Update both index and source report without rewriting
the historical audit verdict. Update pending plan contracts invalidated by fixes.

## E6 — Finish or hand off

Run the Coherence checklist before reporting completion. Summarize scope results,
gates/reviews, deviations, local completion commits/branch, and the next action.
State failed, blocked, skipped, or unverified work plainly.

When full autonomy is true, continue until the selected scope is verified complete
or an actual blocker/user stop/host interruption prevents further work. Save a
checkpoint and exact handoff when the session ends; never imply an unavailable
supervisor or host automatically performed the next step.
