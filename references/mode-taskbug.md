# Task and Bug — small changes with durable recovery

Read execution-contract.md and templates-ledger.md. Resolve options, roster, and
plan attachment per invocation.md. Explicit options and roster apply to this
invocation only and are recorded in the ledger entry; they never change a plan's
§3 or its saved execution scope. Both modes implement only the requested change;
full-autonomous:true does not authorize unrelated plan phases.

Use a short but persistent mini-plan, calibrated to the attached plan's executor
power (`low` in `000_adhoc`): exact files/symbols, prerequisites,
input/output/error contract, numbered steps with postconditions, named tests,
review requirements, and done criterion. Save it before editing so a
model/session handoff can resume without chat history. agent-1 writes the
mini-plan or validates it before any code edit, for a Bug together with the root
cause; a single-agent roster labels this a self-review. When agent-1 is
unavailable, save a BLOCKED handoff naming the validation (agent-roster.md),
even under full-autonomous:true.

For a material external unknown, follow [research.md](research.md) before the
dependent edit: reuse applicable evidence or run a targeted lookup, with design
impact resolved by the supervisor. Record the evidence in the real plan's R
register or, for 000_adhoc, in this unit's ledger entry. Research stays within
the requested change; unavailable required evidence blocks the dependent work.

With a real plan, open the unit in STATE.md as the invocation, after any
approval gate and without replacing the saved execution scope, and link its
ledger entry. Without one, create the entry in docs/plans/000_adhoc/tasks.md or
bugs.md before code edits, PROPOSED while it awaits approval and OPEN once the
unit opens; that entry holds settings, owner, baseline (HEAD plus working-tree
snapshot tree, execution-contract §3), mini-plan, checkpoint, and commit
identity. Never invent STATE.md or phases for ad-hoc work.

If the request is materially larger than a small unit, the supervisor scopes a
proper plan before implementation; do not silently turn one task into a project.
Existing user authorization to complete a larger task may already cover planning.

## Approval gate

With full-autonomous:false, resolved as in invocation.md, the run stops once for
the user's approval after agent-1 has validated the mini-plan: a Task right
after it, a Bug after reproduction, root cause, and mini-plan, before the
regression test. With true there is no stop, but the validation still applies.

- Before approval edit nothing besides the ledger entry and, with a real plan,
  the §1 invocation record with result `PROPOSED`. Ignored build or test
  byproducts are allowed; reproduction probes stay outside the repository or are
  removed. No unit is opened and no ownership is claimed.
- The entry records status `PROPOSED`, the validated mini-plan, a Bug's
  diagnosis, and a proposal snapshot tree (execution-contract §3). Until
  approval the ledger entry owns this status, also in a real plan.
- Report the entry path, a summary of the mini-plan, the approval command, and
  that the entry is uncommitted, then stop. The user may first edit the
  mini-plan in the entry.
- Approval is an explicit user reply to that proposal in the same session, or a
  Resume naming the entry ID: `resume <plan or 000_adhoc> <entry-id>`. A Resume
  without the entry ID never approves a proposal. Approval does not trigger the
  gate again; explicit options on that Resume apply as usual. Approving handles
  only that entry: other recoverable work is reported with its resume command,
  not run.
- - On approval compare the proposal snapshot with a fresh one for the paths the
  mini-plan names. If they changed, the proposal tree is missing (pruned), or
  the user edited the mini-plan, agent-1 revalidates it; when the validated
  mini-plan then differs materially from the approved one, it is a new proposal
  and stops again. Otherwise open the unit with a fresh base (execution-contract
  §3) and continue.
- The user rejects a proposal with a reply in the same session, or by setting
  the entry's status to `WITHDRAWN` with a reason in the ledger. A withdrawn
  entry is never erased and never resumed.
- An entry BLOCKED because agent-1 was unavailable is not PROPOSED: resuming it
  by ID validates the mini-plan, and with false the gate still stops for
  approval, because the user has not seen it yet.

## Task

1. Define the observable outcome and mini-plan, have agent-1 validate it, and
   pass the approval gate. Explain material assumptions; settled technical
   choices do not require repeated user approval.
2. Open the unit/ledger entry and implement the numbered steps. Checkpoint at a
   recovery boundary such as handoff, risky operation, or blocker. Follow existing
   repository structure.
3. Add named tests with concrete assertions, or document why a test is not
   applicable for this change. Run applicable gates and required review.
4. Apply the coherence contract (execution-contract §7): README, plan
   decisions/dependents, tests, and any affected audit findings. Close the task
   with evidence.
5. When full autonomy or WIP completion policy requires it, commit locally on
   the current branch with the stable task identity; otherwise leave uncommitted.
   A mandatory unresolved gate/review prevents a completion commit.

## Bug

1. Reproduce the defect with an input/command and expected vs actual result.
   If reproduction fails, record attempts and blocker rather than guessing a fix.
2. Establish the root cause and affected paths. If a plan decision is wrong,
   involve the strong supervisor and update dependent contracts.
3. Persist the mini-plan and pass the approval gate; then open the unit and
   write the regression test first.
   Observe its relevant failure, then implement the fix and check it passes.
   If such a test is impossible, require an explicit supervisor-approved
   alternative verification; do not call missing verification green.
4. Run the focused regression and relevant full regression suite; record actual
   discovery/results, environment limits, and required reviews.
5. Apply the same coherence and commit transaction as Task, using B-A<NNN>.

For either mode, a weak worker escalates missing design or two unsuccessful fixes
of the same issue; the supervisor may correct the approach within the approved
requirements. New scope/product choices remain user decisions.

At handoff retain OPEN with the next unverified step. With the separate WIP
option, each recovery-boundary checkpoint also updates one rolling WIP commit
(execution-contract §6). Completion reporting includes stable ID, outcome,
verification, deviations, and commit SHA/branch when committed, and ends with
the Next block (next-step.md). A user `handoff` request or `--deadline` follows
mode-handoff.md, including its handoff commit.

Run the Coherence checklist in quality-checklist.md before the final report.
