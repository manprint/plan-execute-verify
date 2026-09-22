---
name: plan-execute-verify
description: >
  Plan and execute phased development with explicit sub-phase contracts,
  resumable state, configured agents, and verification. Use to onboard an existing
  repository or recover its context; plan a feature, refactor, or migration;
  execute an existing plan; implement a small task;
  fix a bug; or audit implementation against a plan. Supports successive
  model sessions and coordinated subagents. full-autonomous:true continues
  within the requested scope and commits verified operational units locally.
---

# plan-execute-verify

Produce plans a less capable implementer can execute reliably, then preserve
their intent through implementation, interruptions, reviews, and corrections.
Correctness and recoverability take priority over token savings. Spend detail
where it removes a decision the worker would otherwise have to invent.

The strong supervisor designs the plan, resolves technical surprises within the
approved requirements, reviews risky sub-phases, and approves every phase.
Any configured worker may implement complex work when its contract is complete.
Support both successive sessions/models and a coordinator with subagents.

## Invocation and option parsing

```text
/plan-execute-verify [<options>] [<agent-prefix>] [<mode>] <args>
```

Options and the agent prefix belong to the leading run of tokens, in any order.
Stop parsing at the first token that is neither; the remainder is mode/arguments.
Thus `task add a --json flag` keeps `--json` in the task description.

| Leading option | Meaning | Default |
|----------------|---------|---------|
| `full-autonomous:true` | Continue the selected operational scope; commit every verified completion locally on the current branch | `false` |
| `full-autonomous:false` | Normal execution; may hand off at a verified unit boundary; adds no completion commits | — |
| `--wip-commit` | Commit completed code units and save interrupted units as WIP commits | off |
| `--no-wip-commit` | Disable that WIP behavior; autonomous completion commits still apply if enabled | — |

Reject unknown leading options, invalid boolean values, duplicate autonomous
options, conflicting WIP options, or invalid agent prefixes before work starts.
An option-looking token such as `full-autonomous:yes` is invalid, not a feature.

Each setting resolves independently: explicit invocation > selected plan's
STATE.md §3 > default. Store explicit overrides in §3. Without a plan,
`task`/`bug` use per-invocation settings recorded in their ledger. Plan mode
accepts these options as presets for execution; it neither implements nor commits.
Onboard is the exception to persistence: options apply only to that inspection,
never alter saved settings, and never authorize commits or subsequent execution.

`full-autonomous:true` does not authorize pushes, deployments, or broader scope.
`verify` still only audits; `task` still does only the requested task. Exact
mode behavior and commit precedence: [execution contract](references/execution-contract.md).

### Agent prefix

Accept `agent:<name>` or a comma-separated contiguous list
`agent-1:<name>,agent-2:<name>,...`. Names are nonempty tokens without spaces or
commas, passed unchanged to the host. Numbered entries start at 1 with no gaps.
Reject mixed forms, duplicate indexes, missing names, and invalid numbering.
A numbered roster containing only `agent-1` is equivalent to `agent:<name>`:
that one configured agent implements and explicitly self-reviews.

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku <feature>
/plan-execute-verify full-autonomous:true agent-1:gpt5-6-sol,agent-2:gpt5-6-luna execute 003
/plan-execute-verify agent:deepseek <feature>
```

Resolve the roster from explicit prefix > existing plan > legacy
Opus/Sonnet/Haiku default. Preserve it across model/session changes. Names are
configuration examples, not a promise that the current host provides them.
Validate availability before dispatch; never silently substitute a different
model or claim a review that did not occur. See
[agent roster](references/agent-roster.md).

### Modes and routing

Resolve the mode, then read its operating manual. Read supporting references only
when that manual calls for them. Reviewing or editing this skill itself is not
an invocation of its Plan/Execute workflow.

| Token | Mode | Manual | Result |
|-------|------|--------|--------|
| `onboard` | Onboard | [mode-onboard](references/mode-onboard.md) | Repository context and next-step guidance; onboarding document only |
| `plan` or no mode | Plan | [mode-plan](references/mode-plan.md) | Plan files; no production code |
| `execute` | Execute | [mode-execute](references/mode-execute.md) | Implementation of the selected plan/scope |
| `execute verify` | Corrections | [mode-execute](references/mode-execute.md) | Corrections from the selected audit |
| `task` | Task | [mode-taskbug](references/mode-taskbug.md) | One small change |
| `bug` | Bug | [mode-taskbug](references/mode-taskbug.md) | One reproduced defect fixed |
| `verify` | Verify | [mode-verify](references/mode-verify.md) | Audit artifacts and truthful state; no code fixes |

Routing is syntactic, not a guess from the description: the first token after
leading options/prefix selects a mode if it is exactly `onboard`, `plan`, `execute`,
`task`, `bug`, or `verify`. Otherwise the whole remainder is an implicit Plan
description.
Use `plan task queue for background jobs` or `plan bug reporting dashboard` for
features whose names begin with a reserved mode word. In natural-language
requests without command syntax, resolve material ambiguity before writing.
Missing required arguments or invalid selectors are errors, not permission to
fall back to another mode. Options alone do not authorize choosing a feature.

### Selection and execution scope

```text
/plan-execute-verify onboard
/plan-execute-verify onboard 003
/plan-execute-verify <feature>
/plan-execute-verify plan task queue for background jobs
/plan-execute-verify execute 003
/plan-execute-verify full-autonomous:true execute 003 phase_02
/plan-execute-verify execute 003 § 1.2
/plan-execute-verify execute verify
/plan-execute-verify execute verify V002
/plan-execute-verify execute verify 003 V002
/plan-execute-verify verify 003
/plan-execute-verify task add a --json flag to the status command
/plan-execute-verify bug missing config incorrectly exits 0
```

Plan selectors: 3-digit number, feature name, or folder path. Execute additionally
accepts `phase_02`, `1.2`, `§ 1.2`, or `phase_02 § 1.2`.
Numeric sub-phase IDs refer to their heading, not the file's numeric suffix:
logical phase 0 is stored in `phase_01.md`. Reject mismatched file/ID selectors.

Onboard accepts an optional plan selector, not a phase/report selector. Without
one it inventories the repository's plans and ad-hoc ledgers; it does not select
the highest number as the next work item. See its manual for ambiguity handling.

For execution/audit selection, without a selector use the highest numbered real
plan, ignoring `000_adhoc`;
if multiple plans are active and context does not identify one, ask which.
An explicit path always wins. `execute verify` means audit corrections; select
a plan literally named `verify` by number/path. It targets the selected/active
plan's newest report unless a report ID is supplied. The full correction syntax
is `execute verify [<plan>] [V<NNN>]`: a V-prefixed report ID is distinct from a
3-digit plan ID; use a path for a plan whose name resembles a report ID.
`task`/`bug` attach to
the unambiguous active plan, otherwise highest numbered plan, or `000_adhoc`
when none exists. Resolve multiple active plans before attaching new work.

A selector limits the scope even under full autonomy. A session resume preserves
that scope; a new explicit invocation can change it. Never start later phases
merely because a single selected sub-phase finished.

## Plan folder and identities

When creating a plan, use `docs/plans/<NNN>_plan-<FeatureName>/` under the target
repository root.
Create parent directories if absent. The number is the highest existing numeric
prefix plus one, starting at 001; never reuse gaps or renumber old plans.
FeatureName is a short PascalCase or kebab-case name without spaces.
Honor an explicit user path. `000_adhoc` is reserved for ledger-only work.

Each plan has an immutable repository baseline, a revision, configured roster,
resolved runtime settings, and stable phase/sub-phase/test IDs. Phase files hold
specifications; STATE.md holds live progress. An approved technical revision
preserves prior decisions with a superseding record and updates affected pending
contracts. Completion evidence always identifies which revision was implemented.

## Session and completion contract

Operational modes must read [execution-contract.md](references/execution-contract.md).
Planning embeds its cold-start, scope, ownership, review, and completion rules
into STATE.md and a concise reminder into every phase file.
Onboard is informational: it observes this state but never claims ownership,
opens/closes units, repairs records, or performs completion transactions.

- Read STATE.md first. Reconcile OPEN work, its step checkpoint, the actual diff,
  prerequisite sub-phase statuses, and unresolved commit references.
- One state writer owns shared records and commits. A delegated worker operates
  within the coordinator's claimed unit; it does not claim/revert it again.
- Open before code edits. Record step IDs and expected postconditions; checkpoint
  after meaningful edit/test batches, before long operations, and before handoff.
- Verify appropriate baseline/unit/phase/final gates. Future gates are not
  prematurely required; missing or zero-discovery mandatory tests are not green.
- Obtain the required real supervisor review. Workers escalate missing design;
  the supervisor can repair technical plans within approved requirements.
- Close only with evidence and coherent code/tests/docs/plan records. Under full
  autonomy commit every completed sub-phase, correction, task, bug, audit, and
  phase closure on the current branch. Match commits by stable identity, never
  by a self-referential SHA stored inside that same commit.
- Continue eligible work inside scope. Stop for its verified completion, an
  explicit user stop, or an actionable blocker. Save the exact next step when
  the host/session ends; do not promise automatic host-session restart.

Phase closure is a distinct `P<N>` unit after all sub-phases, documentation,
phase gates, and supervisor review are complete. An audit can complete with FAIL
while implementation remains blocked; audit closure never certifies failed code.

## Coherence contract

Every closed unit leaves the plan consistent with the repository. Apply these
updates before the completion commit, not afterward:

1. STATE.md: current/next unit, step checkpoint, ledger, owned changes,
   verification evidence, reviews, deviations, blockers, and sub-phase/phase
   progress. Live implementation status appears only here.
2. For out-of-plan work: `tasks.md` or `bugs.md`, with stable IDs
   `T-A<NNN>` / `B-A<NNN>`, allocated as highest existing plus one, never reused.
   See [ledger templates](references/templates-ledger.md).
3. README.md for changed user-visible behavior. For planned phase work, either
   update it in this unit or record the exact dependent README sub-phase as an
   outstanding obligation; that phase cannot close until the obligation passes.
   A scoped implementation sub-phase may finish without claiming the whole
   feature documented/complete. Tasks, bugs, and corrections update affected
   documentation within their own unit. Preserve language/structure; document
   usage, defaults, examples, limits, and troubleshooting.
4. Audit findings affected by the work: update `verify/index.md` and evidence in
   the original report; never silently drop or self-accept an unresolved finding.
5. Plan changes: the supervisor records superseded decisions, invariant/test
   impacts, dependencies, and updates pending sub-phases made stale by the change.
   Keep skipped units with a reason. Add necessary authorized work explicitly;
   never hide it in a vague deviation or rewrite old requirements to claim success.

Audit findings have their own register; that is not a second implementation
progress board. Reports preserve historical verdicts and record later resolution.

In `000_adhoc`, only `tasks.md`/`bugs.md` exist: persist the opened unit,
mini-plan, baseline, settings, checkpoints, results, and commit identity in the
entry itself. No STATE.md or fake phases; these folders are not execute/verify
targets. Existing ad-hoc history stays there when a real plan is later created.

## Detail and token discipline

Correctness first; optimize repeated discovery and irrelevant output. A strong
planner checks critical source contracts even when recon came from a weaker
agent. Implementers inspect the exact symbols, callers, and tests they modify.
Line numbers are hints; paths, symbols, and expected contracts are the anchors.

If docs/onboarding.md exists, use it as a source map after reading the active
state in operational modes. Recheck relevant paths against the current tree;
it is a dated context snapshot, not authority for requirements, progress, test
results, or permission. Its absence never blocks another mode and does not
require running Onboard first. Never stage an unrelated onboarding document
merely because a later operational unit creates a commit.

Plan includes repository recon followed by targeted internet research before
design decisions. Use [research.md](references/research.md) for material external
questions: primary sources, version applicability, privacy, evidence records,
and a stopping condition. The strong planner converts conclusions into local
contracts/tests; links alone are not a worker handoff. Execute/task/bug revisit
research only when needed; Verify checks relevant assumptions without redesign.
Required unverified claims prevent READY or dependent implementation. No extra
research flag is needed; research does not change full-autonomous or commit scope.

Phase files must include the decisions and invariants they need, with their
meaning, not unexplained tags. Preserve the seven top-level sub-phase fields,
but give Change explicit prerequisites, contracts, ordered steps, checkpoints,
failure handling, and scope limits. See the
[templates](references/output-template.md) and
[quality checklist](references/quality-checklist.md).

Use batched, focused recon where delegation is available; in successive sessions
perform it locally or hand off explicitly. Do not assume a subagent exists.
Keep routine replies concise; spend tokens on exact instructions, source checks,
and evidence. See [token economy](references/token-economy.md).

## References

- [Onboard](references/mode-onboard.md), [Plan](references/mode-plan.md),
  [Execute](references/mode-execute.md),
  [Task/Bug](references/mode-taskbug.md), [Verify](references/mode-verify.md)
- [Execution contract](references/execution-contract.md): operational policy and
  recovery; read for runtime work and when writing resumable plans
- [Plan templates](references/output-template.md),
  [onboarding template](references/template-onboarding.md),
  [ledger templates](references/templates-ledger.md),
  [audit templates](references/templates-audit.md): read the template being written
- [Agent roster](references/agent-roster.md): assignments, handoffs, and reviews
- [Research](references/research.md): Plan B2 and targeted external questions
  during implementation/audit; preserve evidence without repeating discovery
- [Quality checklist](references/quality-checklist.md): mode-specific final checks
- [Token economy](references/token-economy.md): cost reductions that preserve correctness
- [Worked example](references/worked-example.md): an authoring/evaluation aid;
  optional during real execution, never a substitute for the actual plan
