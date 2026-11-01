# Quality checklists

Run the relevant checks before reporting completion. A checklist is not evidence
by itself: record actual source inspection, command results, and review identity.
An unresolved required item prevents READY or implementation DONE.

## Onboard — context, not execution approval

- [ ] Repository/worktree, instructions, branch/HEAD or unavailable Git metadata,
      inspected scope, and relevant dirty changes are identified without claiming ownership.
- [ ] Map covers purpose, components/entrypoints, actual version evidence,
      conventions, command sources/setup, and important limits; facts and inferences differ.
- [ ] Existing onboarding content was revalidated, not treated as current because
      its timestamp or HEAD matches. Uncommitted changes and moved symbols count.
- [ ] Real plans, ad-hoc history, partial/legacy artifacts, and supplied custom
      paths are distinguished; absence of skill files is not absence of software.
- [ ] Returning-project summary links authoritative state/ledgers/reports and
      distinguishes recorded completion, inspected evidence, and current checks.
- [ ] OPEN/pending-commit/suspended work and active owners are surfaced before
      recommending new work. Missing evidence never becomes DONE or READY.
- [ ] Next action respects prerequisites, saved execution scope, settings,
      report ID, and actual host capabilities. Multiple candidates require a
      choice, not a guess.
- [ ] Suggested commands use supported syntax; resumes use
      `resume [<plan>] [<unit-id>]` with exact IDs. Unknown goals remain questions.
- [ ] Only the onboarding artifact was written, preserving unrelated content;
      no code/state/roster/index changes, unit claims, commits, or automatic next command.
- [ ] Snapshot has date/baseline, source locators, coverage limits, and a concise
      next action; it is not a second live progress board or a substitute for Verify.
- [ ] Report ends with the Next block (next-step.md): one exact Continue
      command, or why nothing follows, and the Stop option derived from state;
      nothing suggested was run.

## Plan readiness — strong supervisor

- [ ] Goal, exclusions, requirements, and reference scenario are concrete.
- [ ] Product ambiguities are resolved using user decisions; authorized technical
      choices are decided by the supervisor, with no unresolved alternatives.
- [ ] Every phase/sub-phase has stable IDs, exact dependencies, and artifacts.
- [ ] Phases have observable integration outcomes; adjacent work sharing a
      contract/checks is grouped. Each split has a dependency, review, or
      recovery reason; the weakest worker can still resume each unit.
- [ ] Decomposition and detail match the recorded executor-power (mode-plan D):
      low has elementary units, explicit patterns, and verified snippets for
      complex parts; medium detailed contracts and steps; high outcome units
      with the executor's latitude stated. Contracts, invariants, acceptance
      tests, and gates are supervisor-fixed at every level.
- [ ] Each sub-phase has all seven fields with complete structured contents:
      contracts, numbered steps/postconditions, checkpoint, scope, failure
      handling. Agents and reviewers are roster positions, not model names.
- [ ] Complex units specify algorithm, representation,
      synchronization/lifecycle, boundary cases, interfaces, and errors; the
      worker need not invent design. At executor power high, the internal
      algorithm/representation may be left to the executor; contracts, boundary
      cases, interfaces, and errors may not.
- [ ] Files distinguish existing symbols from NEW paths and explain registration,
      imports/exports/callers, and existing directory conventions.
- [ ] Local decision/invariant meanings are present; the phase works without
      rereading overview.md or relying on the planner's conversation.
- [ ] Critical source contracts were checked by the strong planner, not accepted
      solely from a weaker recon summary.
- [ ] After repository recon, material external questions were researched with
      applicable primary sources, or internal work has a justified N/A.
- [ ] Research records include question, source/provenance, version/environment,
      dates, decision impact, and separately labelled facts/inferences/local
      results. Critical sources were checked by the supervisor; network use was
      authorized by the environment or a recorded user answer; required
      UNVERIFIED claims block readiness unless the user ACCEPTED them with risk
      and guard. Browsing limitations are not disguised as confirmation.
- [ ] Research conclusions are translated into local contracts, steps and test
      oracles; no worker must infer the design from a reading list. Material
      alternatives/contradictions are resolved; no aimless source accumulation.
- [ ] Named tests have locations, fixtures, exact assertions, valid commands,
      setup, activation stages, and intended discovery evidence.
- [ ] Unit, phase, baseline, and final gates are distinguished; future gates do not
      block earlier units. Unit checks are focused; full gates run at phase
      closure, final gates and the reference scenario at the PLAN closure.
- [ ] Required strong reviews name reviewer, timing, and focus; complex work may
      go to weak workers only with those contracts/reviews. Units whose
      implementer is also the required reviewer are marked self-review.
- [ ] Each phase has a README obligation and a separate reviewed closure P<N>;
      documentation has its own sub-phase only when substantial.
- [ ] STATE.md is initialized lean (output-template.md §3) with immutable
      baseline, revision, roster, settings, saved execution scope none
      (NOT_STARTED), ownership, gate registry, one board row per phase plus
      PLAN, and the first phase's sub-phases; PROTOCOL.md and an empty
      history.md exist.
- [ ] Every dependency resolves; ordering has no cycle; next action names an
      eligible unit. SKIPPED does not silently satisfy a prerequisite.
- [ ] Full-autonomous and WIP behavior are resolved independently and explained.
- [ ] Both handoff and delegated workers can determine who owns state/commits.
- [ ] Cold-reading validation of the most complex unit found no missing decision.
      If evaluated by another agent, retain its actual result, not assumed success.
- [ ] Phase-local meanings, gate commands, and runtime rules are not repeated in
      every unit; no omitted detail forces the worker to design an acceptance oracle.
- [ ] Plan files contain no unfilled placeholders or contradictory instructions.
      Readiness is READY only after these checks; otherwise report the blockers.
- [ ] Report ends with the Next block (next-step.md): one exact Continue
      command, or why nothing follows, and the Stop option derived from state;
      nothing suggested was run.

## Coherence — execute, resume, task, bug, corrections

- [ ] Requested scope preserved; no unauthorized work or changed product requirement.
- [ ] Resume followed the recovery order, started no TODO unit named by ID and
      no work outside the saved scope, kept scope/§3/roster unchanged and each
      resumed unit's recorded settings, and recorded results under that unit's
      mode. Task/Bug/Verify left the saved execution scope, §3 settings, and
      roster unchanged; their explicit options were recorded with the invocation
      only.
- [ ] Task/bug attached to a named or clearly affected plan, otherwise 000_adhoc;
      the attachment reason is recorded.
- [ ] Task/bug mini-plan written or validated by agent-1 (a Bug's with its root
      cause) before code. With false it stopped PROPOSED, with no edits besides
      the ledger entry and no ownership, until an approval naming it, which ran
      only that entry; changed paths or edits were revalidated; a rejected
      proposal is WITHDRAWN, never erased.
- [ ] Actual unit revision/contracts/prerequisites checked before editing.
- [ ] Unit opened before edits with HEAD plus working-tree snapshot tree as base;
      owner and pre-existing changes identified. Stale ownership was taken over
      only under the recorded takeover rule.
- [ ] Assigned versus actual agents recorded; substitutions only by an equal or
      lower-numbered roster agent; supervisor reviews only by agent-1. Execution
      style chosen by the fixed rule in agent-roster.md and recorded with the
      invocation.
- [ ] Executor latitude respected: at high, expanded steps were recorded in §6
      and internal decisions in §8; no contract changed without the supervisor.
- [ ] OPEN/close writes and recovery-boundary checkpoints reflect actual work,
      including pending edits and next action; no per-step state churn.
- [ ] Specified behavior, wiring, tests, and documentation implemented.
- [ ] Intended focused tests ran for the unit; full gates ran at applicable phase
      closure. Required gates pass on
      the recorded change; no hidden skips, loosened tolerances, or zero-test pass.
- [ ] Required reviewer actually inspected the relevant design/diff/evidence;
      self-review is labelled; IN_REVIEW reflects any pending dispatched review.
- [ ] Supervisor-authorized technical revisions preserve requirements and update
      dependent contracts; historical specifications were not rewritten to hide defects.
- [ ] Version/environment changes or contradicted external assumptions triggered
      targeted research where needed; evidence, contracts and affected tests were
      updated under supervisor authority before dependent work continued.
- [ ] README covers affected behavior, or a named later unit or P<N> owns the
      obligation; no phase or feature closes while an obligation it owns is
      open. Tasks/bugs/corrections finish their own affected docs. Language and
      structure are preserved.
- [ ] Coherence contract (execution-contract §7) applied: state/ledgers/findings/
      reviews and sub-phase/phase/correction progress match reality.
- [ ] Phase DONE requires its closure review, integration gates, and all sub-phases.
      A failed P<N> attempt is recorded as failed without code edits; the
      responsible unit was reopened with a new attempt or the plan revised, and
      P<N> reran as a new attempt. A sub-phase scope did not run P<N>.
- [ ] Completion transaction finished: all coherence updates precede commit,
      owned hunks only, staged without interactive Git; hooks ran without
      --no-verify; PEV trailers sit in the final trailer block; stable identity
      resolves uniquely by exact string match when commit required.
- [ ] No own-SHA bookkeeping loop, duplicate/empty completion commit, unrelated
      staged changes, branch switch, push, or unowned WIP amendment.
- [ ] WIP policy is separate from autonomous completion; false alone does not
      cancel a persisted WIP setting. With WIP, each recovery-boundary
      checkpoint of an OPEN code unit updated one rolling WIP commit.
- [ ] Execute options were recorded as §1 scope overrides, never in §3; they
      lapsed when a different selector replaced the scope. Only Plan set §3.
- [ ] Autonomy loop (execution-contract §3): with full autonomy, eligible work
      continued in the same turn until scoped completion or one of the
      exhaustive stops; between units at most a progress line, never a report,
      Next block, question, or resume suggestion. With false, the only
      additional stop is after each phase closure (Task/Bug: once, for approval
      of the validated mini-plan). A natural-language autonomy request was
      honored as explicit.
- [ ] Commit subjects follow the mandatory table (execution-contract §6): plan,
      phase, and unit numbers visible; one `phase(<plan>/P<N>)` commit per
      closed phase and one `plan(<plan>): PLAN … COMPLETE` commit for the
      finished plan when commits are enabled.
- [ ] STATE.md compacted (execution-contract §8): §4 unsettled rows only, §5/§6
      only the OPEN unit, §7 latest per gate, closed phases collapsed, settled
      detail appended to history.md; no protocol text beyond the §0 pointer.
      A legacy STATE.md was compacted when ownership was claimed, before any
      unit; a legacy plan already complete got `PLAN | DONE` (legacy), not a
      new PLAN run.
- [ ] In 000_adhoc, the ledger itself holds the durable mini-plan/checkpoint and
      settings; no fake STATE.md/phases created.
- [ ] Handoff request or deadline (mode-handoff.md): stop latch set; nothing
      new started; the OPEN unit closed only if it fit about 10 minutes and no
      unit opened after it; §6 checkpoint, HANDOFF result, and released
      ownership recorded; no tool call after the handoff report. Code work sits in one handoff
      commit, never amended, holding the OPEN or pending-closure unit and every
      unit recorded uncommitted, staged one patch per unit without changes made
      between units; those units now reference handoff:<id>:<attempt> with their
      trees, restored on a failed commit. Plan and Verify
      stayed uncommitted with a warning. The deadline was recorded for this run
      only, not carried into the exact resume command that was reported.
- [ ] The run released the ownership it claimed, with time and reason
      (execution-contract §2).
- [ ] Final report distinguishes completed, skipped, blocked, and unverified
      work, and warns when changes or plan records remain uncommitted, with a
      suggested commit command.
- [ ] Report ends with the Next block (next-step.md): one exact Continue
      command, or why nothing follows, and the Stop option derived from state;
      nothing suggested was run.

## Verify

- [ ] Real plan or 000_adhoc selected; audit scope (whole plan, phase, sub-phase,
      or ledger entry), baseline, and dirty changes explicit; a scoped verdict
      is never presented as plan-wide.
- [ ] Active implementation checkpoint preserved if auditing unfinished work.
- [ ] Relevant modified units audited even if the board incorrectly says TODO.
- [ ] All twelve dimensions in mode-verify.md covered with evidence.
- [ ] Critical source and acceptance contracts inspected by the strong auditor.
- [ ] Relevant research claims match actual versions and applicable primary
      evidence; missing required proof prevents PASS; ACCEPTED assumptions are
      reported as accepted risks with their guards checked. New evidence is
      recorded in the report, not used to silently rewrite the plan or implement
      fixes.
- [ ] Applicable gates actually ran; missing required evidence recorded.
- [ ] Phase/sub-phase statuses, dependency claims, review records, and completion
      commit identities validated against the repository.
- [ ] Previous OPEN/FIXED findings rechecked; regressions retain traceability.
- [ ] Every finding has evidence, severity, impact, plan reference, and correction.
      Severity follows the definitions in mode-verify.md V4, impact recorded.
- [ ] Correction units are complete enough for a cold weak executor; each has a
      STATE.md §11 Corrections row (in 000_adhoc, a ready Task/Bug request
      instead).
- [ ] Explicit options/roster recorded in the report only; §3 and the saved
      execution scope unchanged.
- [ ] Correction readiness is explicit; unresolved design/evidence blocks dispatch
      without preventing an honest completed audit report.
- [ ] Verdict follows the explicit FAIL/INCOMPLETE/PASS WITH FINDINGS/PASS rules.
- [ ] Report and register saved with stable IDs; historical verdict preserved.
- [ ] State corrected and audit closed without certifying failed implementation.
- [ ] No production changes or automatic application of corrections.
- [ ] Autonomous audit commit contains only owned audit/state artifacts; WIP alone
      does not authorize an audit commit.
- [ ] Report ends with the Next block (next-step.md): one exact Continue
      command, or why nothing follows, and the Stop option derived from state;
      nothing suggested was run.
