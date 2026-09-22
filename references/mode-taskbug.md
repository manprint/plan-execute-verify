# Task and Bug — small changes with durable recovery

Read execution-contract.md and templates-ledger.md. Resolve options, roster, and
plan attachment per SKILL.md. Both modes implement only the requested change;
full-autonomous:true does not authorize unrelated plan phases.

Use a short but persistent mini-plan: exact files/symbols, prerequisites,
input/output/error contract, numbered steps with postconditions, named tests,
review requirements, and done criterion. Save it before editing so a model/session
handoff can resume without chat history.

With a real plan, open the unit in STATE.md and link its ledger entry. Without
one, create an OPEN entry in docs/plans/000_adhoc/tasks.md or bugs.md before code
edits; that entry holds settings, owner, baseline, mini-plan, checkpoint, and
commit identity. Never invent STATE.md or phases for ad-hoc work.

If the request is materially larger than a small unit, the supervisor scopes a
proper plan before implementation; do not silently turn one task into a project.
Existing user authorization to complete a larger task may already cover planning.

## Task

1. Define the observable outcome and mini-plan. Explain material assumptions;
   settled technical choices do not require repeated user approval.
2. Open the unit/ledger entry and implement the numbered steps. Checkpoint after
   meaningful batches. Follow existing repository structure.
3. Add named tests with concrete assertions, or document why a test is not
   applicable for this change. Run applicable gates and required review.
4. Reconcile README, plan decisions/dependents, tests, and any affected audit
   findings. Close the task with evidence.
5. When full autonomy or WIP completion policy requires it, commit locally on
   the current branch with the stable task identity; otherwise leave uncommitted.
   A mandatory unresolved gate/review prevents a completion commit.

## Bug

1. Reproduce the defect with an input/command and expected vs actual result.
   If reproduction fails, record attempts and blocker rather than guessing a fix.
2. Establish the root cause and affected paths. If a plan decision is wrong,
   involve the strong supervisor and update dependent contracts.
3. Persist the mini-plan, open the unit, and write the regression test first.
   Observe its relevant failure, then implement the fix and check it passes.
   If such a test is impossible, require an explicit supervisor-approved
   alternative verification; do not call missing verification green.
4. Run the focused regression and relevant full regression suite; record actual
   discovery/results, environment limits, and required reviews.
5. Apply the same coherence and commit transaction as Task, using B-A<NNN>.

For either mode, a weak worker escalates missing design or two unsuccessful fixes
of the same issue; the supervisor may correct the approach within the approved
requirements. New scope/product choices remain user decisions.

At handoff retain OPEN with the next unverified step. WIP commits are controlled
by the separate WIP option. Completion reporting includes stable ID, outcome,
verification, deviations, and commit SHA/branch when committed.

Run the Coherence checklist in quality-checklist.md before the final report.
