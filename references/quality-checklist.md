# Quality checklists

Run the relevant checks before reporting completion. A checklist is not evidence
by itself: record actual source inspection, command results, and review identity.
An unresolved required item prevents READY or implementation DONE.

## Plan readiness — strong supervisor

- [ ] Goal, exclusions, requirements, and reference scenario are concrete.
- [ ] Product ambiguities are resolved using user decisions; authorized technical
      choices are decided by the supervisor, with no unresolved alternatives.
- [ ] Every phase/sub-phase has stable IDs, exact dependencies, and artifacts.
- [ ] Each sub-phase has all seven fields with complete structured contents:
      contracts, numbered steps/postconditions, checkpoint, scope, failure handling.
- [ ] Complex units specify algorithm, representation, synchronization/lifecycle,
      boundary cases, interfaces, and errors; the worker need not invent design.
- [ ] Files distinguish existing symbols from NEW paths and explain registration,
      imports/exports/callers, and existing directory conventions.
- [ ] Local decision/invariant meanings are present; the phase works without
      rereading overview.md or relying on the planner's conversation.
- [ ] Critical source contracts were checked by the strong planner, not accepted
      solely from a weaker recon summary.
- [ ] External facts are confirmed for pinned versions or explicitly N/A.
      Required UNVERIFIED facts block readiness.
- [ ] Named tests have locations, fixtures, exact assertions, valid commands,
      setup, activation stages, and intended discovery evidence.
- [ ] Unit, phase, baseline, and final gates are distinguished; future gates do not
      block earlier units. The final gates prove the reference scenario.
- [ ] Required strong reviews name reviewer, timing, and focus; complex work may
      go to weak workers only with those contracts/reviews.
- [ ] Each phase has a README obligation and a separate reviewed closure P<N>.
- [ ] STATE.md is initialized with immutable baseline, revision, roster, scope,
      settings, ownership, step checkpoints, evidence tables, and every sub-phase.
- [ ] Every dependency resolves; ordering has no cycle; next action names an
      eligible unit. SKIPPED does not silently satisfy a prerequisite.
- [ ] Full-autonomous and WIP behavior are resolved independently and explained.
- [ ] Both handoff and delegated workers can determine who owns state/commits.
- [ ] Cold-reading validation of the most complex unit found no missing decision.
      If evaluated by another agent, retain its actual result, not assumed success.
- [ ] Plan files contain no unfilled placeholders or contradictory instructions.
      Readiness is READY only after these checks; otherwise report the blockers.

## Coherence — execute, task, bug, corrections

- [ ] Requested scope preserved; no unauthorized work or changed product requirement.
- [ ] Actual unit revision/contracts/prerequisites checked before editing.
- [ ] Unit opened before edits; owner and pre-existing changes identified.
- [ ] Steps/checkpoints reflect actual work, including pending edits and next action.
- [ ] Specified behavior, wiring, tests, and documentation implemented.
- [ ] Intended tests really ran with required assertions; required gates pass on
      the recorded change; no hidden skips, loosened tolerances, or zero-test pass.
- [ ] Required reviewer actually inspected the relevant design/diff/evidence.
- [ ] Supervisor-authorized technical revisions preserve requirements and update
      dependent contracts; historical specifications were not rewritten to hide defects.
- [ ] README covers affected behavior or, for a planned implementation sub-phase,
      an exact pending README sub-phase owns the obligation. Phase closure never
      defers it; tasks/bugs/corrections finish their own affected docs. Language
      and structure are preserved.
- [ ] State/ledgers/findings/reviews and sub-phase/phase progress match reality.
- [ ] Phase DONE requires its closure review, integration gates, and all sub-phases.
- [ ] Completion transaction finished: all coherence updates precede commit,
      owned hunks only, stable identity resolves uniquely when commit required.
- [ ] No own-SHA bookkeeping loop, duplicate/empty completion commit, unrelated
      staged changes, branch switch, push, or unowned WIP amendment.
- [ ] WIP policy is separate from autonomous completion; false alone does not
      cancel a persisted WIP setting.
- [ ] With full autonomy, continue eligible work until scoped completion or a real
      blocker/stop/interruption; no routine approval pause after each unit.
- [ ] In 000_adhoc, the ledger itself holds the durable mini-plan/checkpoint and
      settings; no fake STATE.md/phases created.
- [ ] Final report distinguishes completed, skipped, blocked, and unverified work.

## Verify

- [ ] Real plan selected; audit baseline, dirty changes, and scope explicit.
- [ ] Active implementation checkpoint preserved if auditing unfinished work.
- [ ] Relevant modified units audited even if the board incorrectly says TODO.
- [ ] All twelve dimensions in mode-verify.md covered with evidence.
- [ ] Critical source and acceptance contracts inspected by the strong auditor.
- [ ] Applicable gates actually ran; missing required evidence recorded.
- [ ] Phase/sub-phase statuses, dependency claims, review records, and completion
      commit identities validated against the repository.
- [ ] Previous OPEN/FIXED findings rechecked; regressions retain traceability.
- [ ] Every finding has evidence, severity, impact, plan reference, and correction.
- [ ] Correction units are complete enough for a cold weak executor.
- [ ] Correction readiness is explicit; unresolved design/evidence blocks dispatch
      without preventing an honest completed audit report.
- [ ] Verdict follows the explicit FAIL/INCOMPLETE/PASS WITH FINDINGS/PASS rules.
- [ ] Report and register saved with stable IDs; historical verdict preserved.
- [ ] State corrected and audit closed without certifying failed implementation.
- [ ] No production changes or automatic application of corrections.
- [ ] Autonomous audit commit contains only owned audit/state artifacts; WIP alone
      does not authorize an audit commit.
