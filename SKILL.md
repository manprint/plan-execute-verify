---
name: plan-analize
description: >
  Turn a feature request into a rigorous, agent-assigned, phased implementation
  plan (phases/sub-phases, internal + e2e tests, quality gates, doc
  deliverables) at minimum token cost. Use WHENEVER the user wants to plan,
  scope, design, break down, or analyze a feature/refactor/migration before
  coding: "plan this", "make a work plan", "analyze and break this into
  phases", "design doc", "implementation plan", "handoff plan", "spec this
  out", "architecture for X", or any request that should produce a phased plan
  rather than immediate code. Also trigger when tasks split across
  models/agents. Produces a
  plan folder (overview.md + resume.md + one phase_NN.md per phase); writes no
  production code itself.
---

# plan-analize

Produce one artifact: a **self-contained, phased implementation plan** that any
downstream agent can execute with **zero re-exploration**, with **every
sub-phase assigned to the configured agent that can do it correctly**.

Two goals, equally hard:

1. **Minimize tokens** — both the tokens *you* spend writing the plan, and the
   tokens the *implementers* will spend executing it. A good plan is itself a
   token-minimization device: a self-contained sub-phase means the downstream
   agent never re-reads the codebase. See `references/token-economy.md`.
2. **Maximize plan quality** — correct architecture, exhaustive phase/sub-phase
   decomposition, formal internal + e2e tests, explicit quality gates, doc
  deliverables, and a clean division of labor across the configured agents.

The archetype output is a document shaped like the one in
`references/output-template.md`. Follow it.

---

## Invocation behavior

An optional agent-assignment prefix may appear at the beginning of the command,
before the feature description.

```text
/plan-analize agent-1:opus,agent-2:sonnet,agent-3:haiku <feature>
/plan-analize agent-1:gpt5-6-sol,agent-2:gpt5-6-terra,agent-3:gpt5-6-luna <feature>
/plan-analize agent:deepseek <feature>
```

Accepted forms are `agent:<name>` and a comma-separated contiguous list of
`agent-N:<name>` entries. Names are opaque, non-empty tokens without whitespace
or commas and are passed to the host unchanged. Numbered entries must start at
`1`, be unique, and have no gaps. Reject mixed forms, duplicate indexes,
missing names, and invalid numbering before starting Scope.

The remaining text after the prefix is the feature description. If a valid
prefix is present without a feature description, ask the user what to plan. If
there is no prefix and no description, preserve the existing behavior and ask
the user for the feature.

---

## Agent assignment

This skill supports one agent or an ordered list of agents. The position in a
numbered list determines responsibility, independently of the model or
provider name. Full rules: `references/agent-roster.md`.

| Assignment | Responsibility |
|------------|----------------|
| `agent-1:<name>` | Architect, supervisor, orchestrator, and phase approver. |
| `agent-2:<name>` | Primary implementer. In two-agent mode, also performs exploration and mechanical work. |
| `agent-3:<name>` and later | Exploration, scaffolding, documentation, and mechanical work. |
| `agent:<name>` | The same agent performs every stage and explicitly self-reviews. |

When no prefix is supplied, retain the existing Opus/Sonnet/Haiku assignment as
a backward-compatible default. Those names are not required for configured
assignments. Tag every sub-phase with the exact configured assignment, for
example `agent-2:gpt5-6-terra`.

---

## Workflow

The configured `agent-1` drives the six phases and approves the result.
Delegate recon to `agent-3` when available, otherwise to `agent-2`. In
single-agent mode, the configured agent performs recon and all later stages.
Prefer **one batched recon agent over many small ones**: every extra agent
re-pays context-load and re-reads overlapping files.

### A — Scope (`agent-1`, inline)
1. Restate the goal in one paragraph. Define the **reference scenario** that is
   the final acceptance test (concrete, observable: "host-A reaches X, not Y").
2. List open questions / ambiguities. If any materially change the design, ask
  the user now — cheaper than replanning. Otherwise pick sensible defaults and
  record them as decisions.
3. Locate the target: which repo/dir, where the plan file should land, what the
   gates command is (`cargo test`, `pytest`, `npm test`, …).

### B — Recon (one batched exploration agent)
Spawn **one configured exploration agent with a multi-part structured task** to gather
all facts in a single call. Consolidating fact-finding into one agent cuts API
calls and avoids re-reading the same files across agents. Split into 2+ parallel
agents **only** when the repo is too large for one agent's context to cover the
whole search — not by default. It returns **compact structured output only** —
file:line anchors, signatures, existing patterns, the test harness, the gates
command, reuse candidates. **No file dumps.** This is what fills the plan's
*reuse map* so implementers never re-explore. Example tasking:
> "In repo X, find: (1) where feature Y is currently wired (file:line), (2) the
> existing test harness + how to run it, (3) 5 reuse candidates for Z with
> exact paths and signatures. Return a terse bullet list of `path:line —
> what`. No code dumps, no prose."

One configured implementation agent is allowed for a single correctness-sensitive
probe (e.g. "does this lock get held across an await?"). Default to `agent-2`,
otherwise use `agent-1`.

### C — Design (`agent-1`, inline)
Synthesize the recon into: **approved design decisions** (table `D1..Dn` with
consequences — every non-obvious choice gets a row), **target architecture**
(data model, mechanisms, a diagram if it helps, the **reuse map** table), the
**interface** (CLI/API/config), and any **protocol/data-structure** changes with
backward-compat notes.

### D — Decompose (`agent-1`, inline)
Break the work into **phases → sub-phases**. Ordering rules:
- Phase 0 is **pure-additive, no behavior change** when possible (scaffolding
  that lands safely on its own).
- Each phase **independently shippable**; **zero regressions** tolerated.
- Each sub-phase is a self-contained block with **exactly** these fields:
  **Model** · **Files** (with line anchors) · **Change** · **Unit tests** ·
  **e2e tests** · **Done-criteria**.
- Tag the exact configured assignment per sub-phase. Mark **agent-1 review gates** explicitly (hot-path
  refactors, concurrency/lifecycle, data-model design, acceptance assertions,
  final docs read).
- Name tests with stable IDs (`T-FOO1`, unit test names) so they're referenceable.

**Write for a weak implementer.** `agent-1` must always assume the model executing
each sub-phase is less capable and has no surrounding context. Phase files must
be detailed enough that a weak model can execute them correctly with no
ambiguity: precise file paths and line anchors, exact symbol names, the full
change described step by step, explicit assertions for every test, and clear
done-criteria that require no judgment. If a step could be misread, rewrite it.

**Follow existing project structure.** Every sub-phase that creates or modifies
code, tests, scripts, or documentation must instruct the implementer to follow
the repo's pre-existing folder/file conventions. New directories may only be
created when no existing directory already serves the same purpose or semantics.
State this explicitly per sub-phase when new files are added.

### E — Write (`agent-1` authors directly)
**Professionalism standard:** All generated content — code, tests, scripts,
documentation — must be professional and production-grade. No emojis, no
decorative symbols, no informal language in any generated file. Plain, precise,
technical prose only.

Emit the plan as a **folder** using `references/output-template.md`. Write three
file types in this order:

1. **`overview.md`** — `agent-1` writes inline. Small routing doc: goal, reference
   scenario, D* decisions, phase list with file links, reuse map, invariants,
   risks. Must stay small. If detail creeps in, push it to the phase file.

2. **`phase_01.md`, `phase_02.md`, …** — one file per phase (1-indexed,
   zero-padded). Each is fully self-contained: sub-phases with all six fields,
  phase gates, done criterion. `agent-1` writes these directly because it
  holds the design context. Delegate prose to a lower-priority configured
  agent only when phases are many and purely mechanical; then spot-check.
  These files are the only place allowed to be long.

3. **`resume.md`** — `agent-1` writes inline last, after all phase files exist.
   Small machine-readable progress tracker: phase status table (all TODO at
   init), test status table, docs status, `Next:` pointer to the first
   sub-phase. Implementer updates this file after every sub-phase.

Folder path: `docs/plans/plan_<FeatureName>/` if a `docs/` tree exists, else
`plan_<FeatureName>/` at repo root. Honor any path the user gives.
End overview.md with the **model-assignment summary table**.

### F — Quality gate (`agent-1`, inline)
Before declaring done, run the checklist in `references/quality-checklist.md`.
Do not skip. If anything fails, fix it before returning.

---

## Output contract

- **Folder, not a single file.** Default: `docs/plans/plan_<FeatureName>/` if a
  `docs/` tree exists, else `plan_<FeatureName>/` at repo root. Honor any path
  the user gives. Confirm the folder path in your closing message.
- Required files (all must be present):
  - `overview.md` — small routing doc (goal, decisions, phase table, reuse map)
  - `resume.md` — small LLM-readable progress tracker (all phases TODO at init)
  - `phase_01.md`, `phase_02.md`, … — one per phase, detailed, self-contained
- **No production code is written by this skill.** It plans; implementers code.
- Every sub-phase carries the exact configured assignment in its model tag;
  `overview.md` ends with the assignment summary table.
- Phase files must follow the template's per-sub-phase block format **exactly** —
  downstream automation keys off it.

## Token discipline (applies to your own execution)

- Recon goes to **one batched exploration agent**, returning structured facts — never
  pull whole large files into your own context. Add agents only if one can't
  hold the search.
- Don't re-read what a subagent already summarized. Trust the anchors.
- Write the plan **once**. No verbose in-chat drafts; compose in the file.
- Conversational replies stay terse. Phase files are the only place allowed to
  be long — length there buys downstream token savings. overview.md and
  resume.md must stay small.

### Cache discipline (favor the prompt cache)
- Read each reference **at most once**, early, and do not re-read it mid-run —
  re-reads bust the cached prefix and re-bill the file.
- Prefer **fewer, larger agents** over many small ones: each agent is a fresh
  context, so every spawn re-pays setup.
- **Do NOT read `references/worked-example.md` during a run.** It is a learning
  aid only; `output-template.md` already gives the skeleton you write from.

## Reference files

Read these as needed:
- `references/output-template.md` — the canonical plan skeleton. **Always** open
  before writing.
- `references/agent-roster.md` — positional responsibilities and delegation
  rules for configured agents.
- `references/token-economy.md` — concrete tactics for minimizing tokens during
  planning and during the implementation the plan drives.
- `references/quality-checklist.md` — the phase-F gate. Run every time.
- `references/worked-example.md` — learning aid only. **Do not read during a
  run** — `output-template.md` is the skeleton you write from.
