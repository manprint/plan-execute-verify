---
name: plan-execute-verify
description: >
  Phased plan/execute/verify workflow with resumable STATE.md, configured agents,
  and audits. Use only when the user invokes /plan-execute-verify or explicitly
  asks to use plan-execute-verify, or to continue a plan, STATE.md, or ledger it
  created. Not for ordinary tasks, bug fixes, or plans that do not name it.
---

# plan-execute-verify

Make the strong supervisor settle design and acceptance decisions before a weaker
agent implements them. Keep each unit self-contained through its phase context,
STATE.md, and named source slices. Preserve correctness, recoverability, and the
user's scope while removing repeated prose, checks, and state writes.

## Route the request

Command form: `/plan-execute-verify [<options and agent-prefix, any order>] [<mode>] <args>`.
For command syntax, settings precedence, selectors, and ambiguity, read
[invocation](references/invocation.md) before parsing. For natural-language
requests, resolve material ambiguity before writing. Reviewing this skill itself
does not invoke its Plan/Execute workflow.

| Mode | Read first | Result |
|------|------------|--------|
| `onboard` | [mode-onboard](references/mode-onboard.md) | Repository context only |
| `plan` or implicit | [mode-plan](references/mode-plan.md) | Plan files; no production code |
| `execute` / `execute verify` | [mode-execute](references/mode-execute.md) | Selected implementation/corrections |
| `task` / `bug` | [mode-taskbug](references/mode-taskbug.md) | One requested change/fix |
| `verify` | [mode-verify](references/mode-verify.md) | Audit and truthful state; no code fixes |
| `resume` | [mode-resume](references/mode-resume.md) | Recorded work continued; scope/settings unchanged |

Read only references called for by the selected mode and the artifact being
written. A later executor may lack this skill, so planning copies the concise
runtime/recovery contract and resolved settings into generated STATE.md.

## Shared boundaries

- The strong supervisor designs the plan, resolves technical surprises within
  approved requirements, reviews risky sub-phases, and approves every phase.
  Any configured worker can implement complex work when the contract fully
  specifies algorithm, interfaces, invariants, failure behavior, and test oracle.
- A selector limits scope even under `full-autonomous:true`. That setting
  commits verified operational units locally and continues within the selected
  scope; it never authorizes a push, deployment, or broader work. With `false`,
  execution stops after each phase closure instead. Preserve the saved execution
  scope and its option overrides across resumes and Task/Bug/Verify runs;
  Execute options never become plan defaults. Exact commit and handoff rules are
  in [execution-contract](references/execution-contract.md).
- The plan's immutable baseline, revision, roster, settings, stable IDs, gate
  registry, and progress live in STATE.md. Phase files specify work; STATE.md
  alone tracks live implementation status. One state writer owns shared records
  and commits; stale ownership changes hands only under the recorded takeover
  rule. An OPEN unit is reconciled against the actual diff and its snapshot base
  before new work.
- Open a unit before editing and close it with applicable evidence, review,
  documentation, state reconciliation (coherence contract), and a completion
  commit when configured.
  Checkpoint at recovery boundaries rather than after every step or test.
  Preserve unrelated changes and commit identity. A phase closes as a separate
  reviewed `P<N>` unit after its sub-phases, README obligation, and full gates.
- Run focused validation for each sub-phase. Run full integration/regression gates
  at phase closure and final gates at the last closure. Repeat a full gate only
  when changed evidence or a concrete failure requires it. Missing or
  zero-discovery mandatory tests are not green.
- A plan change records the superseded decision and updates affected pending
  contracts. Routine locator drift, implementation progress, and passing checks
  do not trigger plan revisions. Audit findings retain their own history.

## Plan shape and context cost

Create plans under `docs/plans/<NNN>_plan-<FeatureName>/`, creating missing
parent directories. Use the highest existing numeric prefix plus one, starting at
001; never reuse gaps or renumber old plans. FeatureName is a short PascalCase or
kebab-case name without spaces. Honor an explicit user path. `000_adhoc` is
reserved for task/bug ledgers without fake phases or STATE.md.

Size phases by observable integration results; a typical phase has 2–4 coherent
sub-phases. Keep a result in one unit when its edits share a contract and targeted
checks. Split at actual dependency, review, or recovery boundaries. A README
sub-phase is optional; every phase still has a documentation obligation.

Keep the seven sub-phase fields: Agent (a roster position, never a model name),
Assignment, Files, Change, Unit tests, e2e tests, Done. Define local design
meanings once per phase and refer to their IDs within its units. Keep exact
decisions, steps, postconditions, and test oracles that the weakest worker
needs; omit repeated runtime instructions, duplicated command/setup text, and
generic reminders. Follow [output-template](references/output-template.md) and
[quality-checklist](references/quality-checklist.md) when authoring/reviewing.

Use docs/onboarding.md as a dated source map if present, after reading active
state. Recheck relevant source contracts. Plan performs repository recon and
targeted external research for material questions; see
[research](references/research.md). Required unverified claims prevent READY.
Implementers inspect the exact symbols, callers, and tests they modify. Paths
and symbols are anchors; line numbers are hints.
