# Agent roster — who does what, by priority

The skill accepts either one configured agent or an ordered list. The position
in the list determines responsibility; the configured name is opaque and may
be a vendor model name, a local alias, or any other host-supported identifier.

## The positions

### agent-1 - architect and supervisor
- Owns scope, architecture, decisions, decomposition, and final review.
- Assigns work to lower-priority agents and approves every completed phase.
- Performs every responsibility when it is the only configured agent.

### agent-2 - implementer
- Implements non-trivial changes, tests, and refactors.
- Performs exploration and mechanical work too when only two agents are
  configured.

### agent-3 and later - explorer and mechanical worker
- Gathers codebase facts and exact anchors.
- Handles scaffolding, documentation, repetitive edits, and other mechanical
  work.

### agent - single-agent mode
- Performs scope, recon, design, implementation, documentation, testing, and
  review with the same configured name.
- The final review is a self-review and must be labelled as such.

## The legacy vendor aliases

### Opus
Legacy no-prefix alias for `agent-1`: architect, supervisor, and approver.

### Sonnet
Legacy no-prefix alias for `agent-2`: primary implementer.

### Haiku
Legacy no-prefix alias for `agent-3`: explorer and mechanical worker.

---

## Delegation decision tree

```
Is it architecture, a design decision, or a review gate?
  └─ yes -> agent-1
  └─ no  -> Is it exploration, documentation, or mechanical work?
            └─ yes -> agent-3 or later, otherwise agent-2
            └─ no  -> agent-2, otherwise agent-1
```

If the configured list has one agent, use that agent for every branch. If a
configured name is not recognized by the host, pass it through unchanged and
let the host report the model error.

---

## agent-1 review gates - when supervisor review is required

Tag a sub-phase as **"agent-1 review -> assigned agent implements"** when it is:
- a hot-path or performance-critical refactor,
- concurrency or lifecycle work,
- a data-model or protocol design,
- acceptance-test assertions,
- the final documentation read before ship.

These are gates, not full implementations by `agent-1`. The assigned
implementer writes the change and `agent-1` signs off on the design and result.

---

## How to dispatch configured agents

Use the host's normal agent mechanism with the exact configured name. Prefer
one batched exploration task carrying all required fact-finding questions.

Give the agent a narrow, structured-output task. Demand terse results.
- Never ask an agent to "summarize the file" — ask for the **specific anchors**
  you need for the reuse map.
- Prefer one agent over many: each extra agent re-pays context-load and re-reads
  overlapping files.

Good recon tasking:
> Repo: `<path>`. Find and return ONLY a bullet list of `path:line — what`:
> 1. where `<feature>` is currently wired,
> 2. the test harness + exact command to run it,
> 3. 5 reuse candidates for `<capability>` with signatures,
> 4. the lint/fmt/test gate commands.
> No code dumps. No prose. If something doesn't exist, say "none".

Bad recon tasking (burns tokens):
> Read `src/server.rs` and tell me what it does.

Bundle several independent facts into **one** agent's multi-part task — fewer
calls, no duplicate reads. Split into parallel agents only when one agent's
context can't hold the whole search; wall-clock parallelism is a token cost, not
a saving.

---

## Announce the assignment - every step

Show the configured assignment used for each task/sub-task.
- In the conversation: identify the position and configured name, for example
  `Recon (agent-3:gpt5-6-luna)` and `Design (agent-1:gpt5-6-sol)`.
- In the plan files: every sub-phase has a `**Model:**` line containing the
  exact configured assignment, and `overview.md` ends with the model-assignment
  summary table.
