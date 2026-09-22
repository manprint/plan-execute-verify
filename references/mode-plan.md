# Plan mode — scope, design, and executable handoff

The strong supervisor authors the plan. Planning writes no production code and
makes no commits. Runtime options, including full-autonomous, are presets for
later execution; they do not convert a planning request into implementation.

Read output-template.md, agent-roster.md, execution-contract.md, and the Plan
checklist in quality-checklist.md. Use token-economy.md for cost tradeoffs.

## A — Scope and baseline

Restate the goal, explicit exclusions, constraints, and an observable reference
scenario. Resolve the repository root and plan folder per SKILL.md. Record the
immutable starting commit and any existing dirty changes relevant to this plan;
do not treat those as future agent output.

Resolve the roster and runtime presets. Record whether execution will use
successive sessions (handoff), a coordinator with workers (delegated), or support
both with the active style chosen at execution. A fresh weak-model session must
know how to request the configured strong supervisor. If the host cannot supply
it, preserve that limitation rather than promising automatic review.

Separate questions requiring the user's product decision from technical choices
the strong supervisor is authorized to make.

## B1 — Repository recon

Gather exact paths, symbols/signatures, relevant callers, repository conventions,
test fixtures, command syntax, setup requirements, existing failures, and reuse
candidates. Prefer a batched exploration worker when available; local recon is
valid in handoff/single-agent environments.

The supervisor inspects correctness-sensitive contracts directly: transaction
boundaries, concurrency/lifecycle, schema compatibility, public interfaces, and
acceptance assertions. A weaker agent's summary is a locator, not proof of those
contracts. Read enough surrounding code and tests to validate the proposed change.

## B2 — Targeted internet research

After B1, read [research.md](research.md). Identify material external questions
from the actual repository versions and constraints, then investigate the
applicable primary sources before fixing the design. Compare approaches only
where the choice affects correctness or the approved requirements.

Record R<n> evidence in overview.md: question, source/version/dates, supported
fact, separately labelled inference/local result, and decision impact. The strong
planner checks critical passages directly. Preserve unresolved required questions
as UNVERIFIED with scoped blockers; no executable READY plan depends on them.
For entirely internal work with no external unknown, record justified N/A.

Use the research stopping and privacy rules. Initialize the minimal DRAFT state
described there before research starts; persist evidence as it is gathered and
save the next question/lookup at checkpoints or interruption.
This is a planning step, not an implementation sub-phase or a new commit unit;
planning still writes no production code and makes no commits.

## C — Design and resolve ambiguity

Write decisions D<n> with consequences; define interfaces, error behavior,
compatibility, invariants I-<n>, and architecture. Decide algorithms and data
representations before handing complex work to the weakest worker.
Translate the R<n> results into these decisions and the later local phase
contracts/tests. Record relevant alternatives rejected and why; do not hand a
worker only links or an unresolved instruction to choose the best approach.

Ask the user only about unresolved requirements, externally visible tradeoffs,
scope, or authority that existing instructions do not settle. Present relevant
options together with a recommendation and affected phases. Existing user
answers and delegated technical judgment remain valid; do not re-ask them.

For technical choices within that authority, choose and record a decision.
If no material question remains, proceed directly. Deferred product questions
have explicit dependent units marked BLOCKED; never both assume an answer and
claim those units executable. A material question blocks dependent design,
not independent evidence gathering or already settled portions of the draft.
Do not deliver that draft as an executable plan: READY requires every planned
unit's design and acceptance questions resolved and its contract validated.

## D — Decompose into executable units

Use phases that preserve existing behavior and can pass their own gates. Start
with additive scaffolding when useful. Assign stable logical phase/sub-phase IDs
and map them explicitly to phase files; logical phase 0 is phase_01.md.

Each sub-phase retains seven top-level fields:
Model · Assignment · Files · Change · Unit tests · e2e tests · Done.
The content requirements are in output-template.md; merely filling the headings
does not satisfy the contract.

Write for the least capable configured implementer, even when it will handle
complex logic. Each unit needs:

- Exact prerequisite unit IDs and artifacts, including newly created symbols.
- Local meanings of applicable decisions/invariants and the expected input/output
  types, defaults, errors, and compatibility behavior.
- Numbered implementation steps S1, S2, … with an expected postcondition and
  checkpoint after each meaningful batch. Include imports/exports, callers,
  configuration, wiring, and teardown where needed.
- The chosen algorithm/data structure and handling of relevant edge cases.
  For concurrency: ownership, synchronization, lock lifetime, ordering, and
  deterministic verification. For data changes: migration/retry/rollback behavior.
- Exact read/write targets, existing patterns to reuse, scope exclusions, and
  what must trigger supervisor escalation.
- Named tests with fixtures, assertions, location, command, and proof they are
  selected. Do not assign the worker the design of the acceptance oracle.
- Required reviewer and review timing, unit gates, and a checkable completion
  condition including state and the configured commit policy.

Split a sub-phase when it has several independently verifiable outcomes, requires
unrelated design decisions, or cannot be resumed from a short step checkpoint.
Do not impose an arbitrary file/line/token cap: a coherent complex change may
need substantial detail. Prefer small verifiable units over vague large units.

Tests may explicitly be N/A with a reason appropriate to the change. Acceptance
criteria must preserve the user's requirements; a low-capability assignment is
not a reason to reduce the test standard.

Every phase ends with a README sub-phase and then a phase closure P<N>.
README work names only affected sections and shipped behavior; when none changed,
verify accuracy and record that result without inventing content. Preserve
existing language and structure. Documentation explains installation, usage,
flags/config/defaults, examples, limits, and troubleshooting as applicable.

The supervisor reviews every phase at closure. Mark additional sub-phase gates
for concurrency, lifecycle, schema/protocol design, sensitive refactors, and
acceptance assertions. A weaker agent may implement these only from a complete
contract; lack of detail requires refinement before dispatch.

## E — Write the handoff

Complete overview.md and phase files, then finish STATE.md using output-template.md.
Preserve any DRAFT research checkpoint/evidence initialized in B2; do not discard
it when expanding the state to the full handoff template.

overview.md is a small design/routing reference: goal/reference scenario,
decisions with authority/source, unresolved questions, architecture, interfaces,
compatibility, phase/file map, reuse map, references, invariants, risks,
verification strategy, and the roster summary as its last section. Link readers
to STATE.md for all live progress.
The research/evidence register in overview.md retains source provenance and
question-to-decision traceability; phase excerpts carry its operative conclusions.

Each phase file is independently understandable together with STATE.md and the
relevant repository slices. Include local decision/invariant excerpts, dependency
and contract details, ordered sub-phase steps, review obligations, phase gates,
and completion criteria. Future source paths are marked NEW with explicit
creation/registration instructions, not treated as missing anchors.

Initialize STATE.md at planning time:
- Protocol and ownership rules sufficient for a session without this skill.
- Plan identity/revision, immutable baseline, roster, settings, and scope.
- Current unit none; next action points to a real first eligible sub-phase.
- Baseline/unit/phase/final gate applicability and setup.
- Empty but usable ledger, checkpoints, evidence/review/deviation tables.
- Every sub-phase, phase, named test, and README obligation in the progress board.
- Deferred requirements and unavailable capabilities as scoped blockers.

Do not duplicate implementation statuses in phase files or overview.md. Audit
findings keep their separate register. A decision/invariant excerpt in a phase
must be updated whenever its authoritative design revision changes.

## F — Validate the plan before handoff

Use the Plan checklist. Additionally perform a cold-reading check on the most
complex sub-phase: with only STATE.md, that phase file, and the named repository
slices, can a worker identify its first edit, expected result, test oracle,
reviewer, commit behavior, and exact next step without inventing design?

When a blind worker evaluation is available, use that input bundle and ask it to
identify the next actions and unresolved decisions; do not supply the planner's
intended answer. Resolve substantive ambiguity before calling the plan ready.
Do not confuse formatting validation with a successful execution evaluation.

Validate existing gate commands where practical. Gates that depend on future
artifacts specify activation units; they cannot be reported as already passing.
Explain remaining unverified prerequisites.

Return the folder path and a concise phase/assignment/configuration summary.
