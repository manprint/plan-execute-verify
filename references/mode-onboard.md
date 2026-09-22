# Onboard — repository context and a safe next step

`/plan-execute-verify onboard [<plan>]`

Use for a first visit to an existing repository or a context refresh after an
interruption/model change. Read template-onboarding.md and the Onboard checklist
in quality-checklist.md. This is an informational mode, not Plan, Execute, or
Verify. It may create/update only docs/onboarding.md (or a user-specified context
document); all code, plan specifications, STATE.md, ledgers, and reports are read-only.

## O1 — Resolve the inspection boundary

1. Locate the target repository/worktree and its applicable instructions. Inspect
   Git branch/HEAD, staged/unstaged changes and untracked paths without modifying
   them. Without Git/a commit, record the limitation; context gathering can continue.
   Never switch branches, fetch, reset, stage, initialize Git, or request a
   code-search index rebuild/sync as part of onboarding.
2. Accept zero or one plan selector: existing 3-digit number, unique feature name,
   or plan folder path. A selector is a focus, not authority to execute. Invalid,
   ambiguous or extra selectors need clarification; never fall back to Plan or
   create missing plan files. `000_adhoc` is ledger history, not a real plan selector.
3. Without a selector, inventory docs/plans/ and any plan locations explicitly
   supplied or linked by repository documentation. Do not exhaustively search
   unrelated directories/worktrees. No discovered plan means "no plan found in
   inspected locations", not proof that the project has no previous work.
4. Read an existing onboarding map and its baseline as hints. Determine whether
   this is a new map, a refresh, or a partially documented/legacy repository.
   Existing code is never scaffolding to recreate merely because skill files
   are absent. Non-skill specifications remain relevant evidence, not automatically
   approved requirements or executable PEV plans.

All leading options use normal syntax validation. full-autonomous:true and WIP
options do not authorize commits, state changes, or executing the recommendation.
Do not persist them or carry them into a recommended execution command. Show the
selected plan's saved settings separately from invocation-local settings.
An explicit agent prefix applies only to this inspection, never saved assignments.
Read agent-roster.md if selecting/delegating an inspector: prefer a strong agent
for initial architecture reconstruction. An unavailable supervisor does not block
factual gathering; label unreviewed interpretations and the needed handoff.

## O2 — Build or refresh the source map

Inspect progressively: root instructions/README and architecture notes, manifests
and lockfiles, build/test/CI definitions, entrypoints, then representative modules,
their callers, and tests needed to explain the principal flows. In a monorepo,
map the top-level components and focus deeper inspection on the selected work.
Do not read every source file just to claim exhaustive understanding.

Record with concrete paths/symbols:

- What the project does and for whom, distinguishing documented intent from
  behavior inferred from code; unresolved product goals stay questions.
- Runtime/dependency versions: declared range versus resolved version where
  available; do not assume the installed environment matches a lockfile.
- Components, entrypoints, public interfaces, main data/control flow, persistence,
  integrations and ownership boundaries relevant to further work.
- Repository conventions and instructions, extension points, test locations,
  generated files, and sensitive areas that must not be casually changed.
- Build/run/test/lint commands with cwd, required setup and source. Inventory
  them by inspecting definitions, not executing project scripts, installing
  dependencies, starting services, migrations, or the full suite by default.
  Distinguish documented command, historical result, and a check actually run
  against a stated baseline. User-requested extra checks need safe scope and
  explicit results; inspecting a test file is never a passing test run.
- Relevant existing changes, known failures with evidence, missing configuration,
  uncertainty and excluded/uninspected areas. Record variable names/prerequisites,
  not secret values, private payloads or complete environment dumps.

On refresh, recheck relevant locators and their contents, including uncommitted
changes. A matching HEAD or recent date does not make the map authoritative.
Preserve still-supported context and inspect changed/uncertain areas; do not
repeat a full survey unnecessarily. Missing paths/contradictions are limitations,
not permission to repair code or invent an architectural explanation.

Internet research is not a routine prerequisite for onboarding. Defer design
comparisons and material external questions to Plan's research step. If explicitly
requested or essential to explain a specific external contract, follow the primary
evidence/privacy rules in research.md and record sources/version/date here; do
not create a research plan, mark READY, or launch an open-ended survey.

## O3 — Determine where existing work stands

When a real plan exists, read STATE.md before its phase details. Inspect overview,
the active/named phase, relevant tasks/bugs, verify/index.md and reports as needed
to explain the current checkpoint and next action. Consult execution-contract.md
for recovery/commit semantics, but observe only: never claim/release ownership,
finalize a pending commit, restore a suspension, upgrade a legacy plan or repair
statuses during onboarding.

Read the identity/revision, repository/branch/baseline, scope/result, roster and
settings, readiness, owner, OPEN unit/attempt/step, next eligible unit, outstanding
reviews/blockers and pending closure. Check the actual diff and relevant artifacts
against these claims. A commit only supports the identity/change it contains;
it does not prove current correctness. Keep these distinctions explicit:

- Recorded status: what STATE.md or a ledger says.
- Evidence inspected: relevant artifact, test/review record and tested revision,
  or matching completion commit identity.
- Current verification: only checks actually run; otherwise "not rerun".

Do not turn missing evidence into DONE, an observed discrepancy into a repaired
state, or an old PASS into a current PASS. An onboarding snapshot is not an audit.
If a writer is active or state changes while inspected, label the snapshot
unstable and direct the user to that owner; do not start a competing worker.

Inventory real plans and ledger-only 000_adhoc separately. Read open ad-hoc entries
even if no real plan exists; their mini-plan/checkpoint/settings are their recovery
record. Partial/legacy files are a third case, not "first use": report exactly
what is missing and hand off to the supervisor without inventing historical phases.

Without a focus selector, a unique consistent active plan can guide the summary;
multiple plausible plans or open plan/ad-hoc work require a user choice. Present
brief candidates with source links, not an automatic highest-number choice.
An explicit focus does not hide other OPEN work or ownership conflicts.

## O4 — Derive the next action without starting it

Use the first applicable condition below. Return one recommendation, its evidence,
and any prerequisite/choice; do not print an executable recommendation when a
missing decision would make it unsafe. Literal syntax below uses placeholders;
substitute actual IDs/paths in a real handoff.

| Observed condition | Next action / command guidance |
|--------------------|--------------------------------|
| Target, ownership, branch/baseline or scope conflict; required source missing | Explain the conflict and ask the exact question or hand off to the current owner. Do not switch branches or recommend blind execution. |
| Interrupted unit, pending completion transaction or suspended audit | Identify that identity's recovery first, in its original mode and scope. If readiness/design is blocked, hand it to the supervisor rather than proposing execution. An OPEN audit/pending audit commit takes precedence over its suspended implementation; never recommend a new audit or later phase to bypass recovery. |
| DRAFT/BLOCKED or underspecified/legacy contract | Give a strong-supervisor handoff naming the existing folder, missing decision/evidence and affected unit. No new plan and no claim of execution readiness. |
| Audit findings need a correction decision or ready contract | Explain the findings and request the missing approval/design. Do not bypass blocking findings by recommending ordinary implementation. |
| Authorized, READY audit corrections with eligible remaining units | Suggest `execute verify <plan> V<NNN>` with the actual report, not an ambiguous newest-report default. An OPEN finding alone is not authorization to fix it. |
| READY planned work remaining inside the saved scope | Suggest `execute <plan>` plus its saved phase/sub-phase selector when present. Explain the exact unit/step and prerequisites; retain saved settings and roster. |
| Saved scope complete, but later plan work exists | Say the requested scope is complete. Show the later command only as a proposed new scope requiring the user's choice, not as a resume. |
| Recorded plan complete, no outstanding work | State the evidence/verification limits. Offer `verify <plan>` only if a fresh audit is useful; do not invent implementation work. |
| No resumable work and no user goal | Ask the desired outcome. Explain Plan for a feature, Task for one small change, Bug for a defect; do not invent a command argument or infer a roadmap from TODOs. |
| Concrete new goal already supplied | Suggest `plan <goal>`, `task <description>` or `bug <description>` at the actual scope, without invoking it. |

First distinguish an unresolved blocker from a historical BLOCKED label: if the
user has supplied its resolution, a supervisor must validate it before execution.
When missing requirements or evidence prevent a safe next step, the exact handoff
is the result; do not loop indefinitely trying to make the project executable.

Command construction must follow SKILL.md, not invented convenience syntax.
Place options before the mode. Never broaden a saved sub-phase/phase scope to
the whole plan or replace saved execution settings with onboarding options.
Surface the effective autonomous/WIP behavior of the suggested invocation,
especially when a plain `execute` would inherit automatic commits.

Some resumes cannot be expressed by an ID selector in the current grammar:
task/bug ledger entries, an interrupted audit's exact identity, and an existing
draft refinement. Give an explicit natural-language handoff naming mode, absolute
or repository-relative path, ID/attempt/step and preserved scope/settings. For example:
"Use plan-execute-verify to resume existing bug B-A002 in
docs/plans/000_adhoc/bugs.md from its checkpoint. Preserve its identity and
settings; do not allocate a new bug." Never invent `bug B-A002`, `plan 003` or
`verify 003 V002` as a resume selector. Use numeric/path selectors for plan names
that collide with reserved words such as `verify`.

## O5 — Save and report

Use template-onboarding.md to create/update docs/onboarding.md. This is the only
default write target; it is not a plan, an implementation unit or a commit unit.
Keep the map compact but sufficient to locate sources and resume the inspection.
On a long/interrupted survey, save coverage and the next inspection action there,
not in STATE.md. All summaries of work are dated observations with links to the
authoritative record; never maintain a duplicate progress board.

The generated section uses explicit begin/end markers. Preserve user-authored
content outside it. If the path already exists without valid markers, or the
section changed concurrently, do not replace it blindly: retain useful content,
request agreement on a safe location/merge, and return the available summary.
If writing is prohibited, report that the map was not saved; do not claim it
exists or that onboarding failed to inspect facts already gathered.

Before finishing, run the Onboard checklist and check the actual resulting diff:
only the permitted context artifact may have changed because of this invocation.
Leave pre-existing dirty changes untouched; never stage/commit the map, even under
full-autonomous:true or --wip-commit. Do not change runtime settings or rewrite
STATE.md merely to record that onboarding ran.

Return a short recap: project/focus, recorded progress and evidence limits,
open unit/blocker, next action with the exact supported command or handoff,
and saved map path (or why not saved). Stop there. The user chooses whether to
run the suggested mode; an explicit future execution still performs its own
cold-start and source checks.
