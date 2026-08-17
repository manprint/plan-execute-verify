---
name: plan-execute-verify
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
  plan folder (overview.md + resume.md + STATE.md + one phase_NN.md per phase);
  STATE.md is the detailed live state file that lets a fresh/cleared session
  resume exactly where execution stopped. Writes no production code itself.
  Also exposes four sub-commands: `verify` ("check the implementation against
  the plan", "audit what has been built") hard-reviews the work done so far and
  reports missing pieces, divergences and corrections; `execute` ("implement the
  plan", "continue the plan") implements a plan sub-phase by sub-phase;
  `task` implements one small change; `bug` diagnoses and fixes one defect.
  execute/task/bug write code and keep every plan file, state file, and the
  task/bug ledgers coherent so a later verify stays accurate.
---

# plan-execute-verify

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
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku <feature>
/plan-execute-verify agent-1:gpt5-6-sol,agent-2:gpt5-6-terra,agent-3:gpt5-6-luna <feature>
/plan-execute-verify agent:deepseek <feature>
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

### Modes

The first token after the optional agent prefix selects the mode:

| Token | Mode | What it does |
|-------|------|--------------|
| `verify` | **Verify** | Hard review of the implementation done so far against an existing plan. Read-only; produces a findings report. |
| `execute` | **Execute** | Implements an existing plan, sub-phase by sub-phase, keeping every plan file coherent. `execute verify` applies a stored verify report's correction plan. |
| `task` | **Task** | Implements one small change with an in-memory mini-plan; logged in the task ledger. |
| `bug` | **Bug** | Diagnoses and fixes one bug with an in-memory mini-plan; logged in the bug ledger. |
| anything else | **Plan** (default) | The A → F planning workflow described below. |

```text
/plan-execute-verify verify
/plan-execute-verify verify 003
/plan-execute-verify verify docs/plans/003_plan-Multitenancy
/plan-execute-verify agent-1:opus,agent-2:sonnet verify

/plan-execute-verify execute
/plan-execute-verify execute 003
/plan-execute-verify execute 003 phase_02
/plan-execute-verify execute 003 § 1.2
/plan-execute-verify execute verify          # apply the newest verify report's correction plan
/plan-execute-verify execute verify V002     # apply an older report's correction plan

/plan-execute-verify task add a --json flag to the status command
/plan-execute-verify bug the CLI exits 0 when the config file is missing
```

**Plan selection.** For `verify` and `execute`, the token after the mode
optionally selects the plan: a 3-digit number, a feature name, or a folder path;
for `execute` a further token may narrow it to one phase or one sub-phase.
Without a selector, use the plan folder with the highest `NNN` in `docs/plans/`;
if several plans are in progress, list them and ask which one.

For `task` and `bug`, everything after the mode token is the description. They
attach to the **active plan** (the one `STATE.md` shows as in progress, or the
highest `NNN`) so the ledgers live with it; if the repo has no plan folder, they
use `docs/plans/000_adhoc/` (created on demand, `000` is reserved for work with
no plan).

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

The configured `agent-1` drives the stages A → B → C → D → D2 → E → F and
approves the result. **D2 is a blocking user checkpoint**: no plan file is
written before the user has answered the grey-area questions.
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
3. Locate the target: which repo/dir, what the gates command is (`cargo test`,
   `pytest`, `npm test`, …), and **resolve the plan folder now**: list
   `docs/plans/` from the repo root, compute the next 3-digit sequence number,
   and fix the path as `docs/plans/<NNN>_plan-<FeatureName>/` (see §E). One
   cheap listing here; do not recompute it later.

### B — Recon (one batched exploration agent)

#### B1 — Codebase recon
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

#### B2 — External documentation research (when needed)
The repo does not always contain the truth. When the feature depends on
something outside it, **research the external documentation before designing** —
a design built on a misremembered API is the most expensive kind of replanning.

**Trigger it when any of these hold:**
- a third-party library, framework, SDK, cloud service, or CLI is involved, and
  the plan will touch its API, configuration, or migration path
- a standard, protocol, spec, or file format must be implemented or respected
  (OAuth/OIDC, HTTP semantics, JWT, WebSocket, OpenTelemetry, wire formats, …)
- version-specific behavior matters: the repo pins a version whose API you are
  not certain about, or the plan implies an upgrade/migration
- the feature has known best practices or security implications where guessing
  is unacceptable (auth, crypto, payments, PII, rate limiting, concurrency)
- your own knowledge of the area may be stale or you find yourself hedging

**Skip it when** the work is purely internal to the repo (refactor, rename,
internal test coverage) and no external contract is touched. Say so in one line
rather than researching for form's sake.

**How to run it:**
- Prefer the **documentation tools available in the host** (a docs-lookup MCP
  server such as Context7, then web search/fetch). Official documentation for
  the **exact pinned version** beats blog posts; check the repo's manifest or
  lockfile for the version first.
- **Batch it into the same recon step.** Give the exploration agent both parts —
  codebase facts and doc questions — or one additional agent when the search is
  large. Never one agent per question.
- Ask **closed questions**, not "read the docs for X". Example tasking:
  > "Library `<lib>` version `<X.Y>` (pinned in `package.json:23`). Answer only:
  > (1) exact signature and options of `<api>`; (2) the documented way to do
  > `<task>`; (3) anything deprecated or changed since `<X.Y-1>`; (4) documented
  > error/retry semantics. Return one bullet per answer, each with the source
  > URL and the doc's version. No prose, no page dumps."
- Returned output must be **compact and sourced**: one line per fact, each with
  a URL. No pasted documentation pages.

**Use of the findings:**
- Facts that constrain the design become `D*` rows in `overview.md`.
- Uncertainty that survives research becomes a **D2 question** to the user, not
  a silent assumption.
- Every source used is listed in the `overview.md` **References** table
  (what it settled · URL · version/date), so implementers and later sessions do
  not re-search the same thing. Copy the entries relevant to a phase into that
  phase file so it stays self-contained.
- **Never quote large blocks of documentation into the plan.** Cite the URL and
  state the fact in one line. Exception: an exact signature, header, or wire
  format the implementer must reproduce verbatim.
- Mark anything you could not confirm as unverified — an invented API is worse
  than an open question.

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
- Every sub-phase's **Done-criteria** ends with `STATE.md` and `resume.md`
  updated — state tracking is part of the definition of done, not a suggestion.
- **Every phase ends with a README sub-phase.** The last sub-phase of every
  phase creates or updates the project `README.md` (repo root, or the existing
  README the project already uses) so the user-facing documentation never lags
  behind the shipped behavior. See "README deliverable" below.

**Write for a weak implementer.** `agent-1` must always assume the model executing
each sub-phase is less capable and has no surrounding context. Phase files must
be detailed enough that a weak model can execute them correctly with no
ambiguity: precise file paths and line anchors, exact symbol names, the full
change described step by step, explicit assertions for every test, and clear
done-criteria that require no judgment. If a step could be misread, rewrite it.

**README deliverable (mandatory, once per phase).** The final sub-phase of each
phase is `<N.last> Update README.md`, assigned to the lowest-capability agent
that can do it (`agent-3+` when present, otherwise `agent-2`), with an `agent-1`
read on the last phase. It is a **user guide, not a design document**:

- **Include:** what the application does and who it is for; install /
  requirements; how to run it; the full command / sub-command / flag surface
  with realistic examples and expected output; configuration and environment
  variables with defaults; notes and caveats; **known limits and limitations**;
  troubleshooting for the common failure modes; where to get more help.
- **Exclude:** implementation details — internal module/class/function names,
  file layout, algorithms, data structures, refactoring notes, phase or plan
  references, roadmaps of unshipped work. If a sentence only makes sense to
  someone reading the source, it does not belong in the README.
- **Only shipped behavior.** Each phase documents what that phase actually made
  usable; nothing planned-but-absent. If a phase ships nothing user-visible
  (pure scaffolding), the sub-phase says so explicitly and limits itself to
  keeping the existing README accurate — it is never silently skipped.
- **Update, don't rewrite.** Preserve the project's existing README structure,
  tone, and language; edit the affected sections. Follow the professionalism
  standard: no emojis, no informal language.
- The sub-phase must state which README sections that phase touches, and its
  done-criterion is that a new user can install and use the phase's feature
  from the README alone, with no source reading.

**Follow existing project structure.** Every sub-phase that creates or modifies
code, tests, scripts, or documentation must instruct the implementer to follow
the repo's pre-existing folder/file conventions. New directories may only be
created when no existing directory already serves the same purpose or semantics.
State this explicitly per sub-phase when new files are added.

### D2 — Clarification gate (`agent-1`, inline, **blocking**)

**Mandatory. Never skip, never merge into E.** After the decomposition exists
but **before writing any plan file**, present the user with a compact overview
plus the **grey areas of every phase**, and let the user decide. Detailed phase
files written on top of unresolved ambiguity are expensive to rewrite; a
question here costs a few hundred tokens.

1. **Show the skeleton first** — in chat, terse: goal, reference scenario, the
   `D*` decisions already taken, and the phase → sub-phase list (titles only,
   one line each). No file written yet.
2. **Sweep every phase for grey areas.** Walk phase by phase, sub-phase by
   sub-phase, and collect every point where more than one reasonable
   implementation exists or where you had to guess. Typical sources:
   - naming, module/file placement, public vs internal API surface
   - data model and schema shape, defaults, nullability, migration strategy
   - error handling, failure modes, retry/timeout policy
   - backward compatibility, feature flags, opt-in vs opt-out defaults
   - concurrency, ordering, idempotency, transaction boundaries
   - test depth and boundaries: what is unit vs e2e, what gets mocked
   - scope edges: what is explicitly out of scope for this plan
   - performance/limits targets, observability (logs, metrics)
   - dependency choices: new dependency vs hand-rolled vs existing utility
3. **Ask them all in one batch, grouped by phase.** Do not drip-feed questions
   across turns. Format each question as: `Q<n> [phase N]` — the question, the
   concrete options, and your **recommended default** with a one-line reason.
   Every question must be answerable by picking an option; no open essays.
   Number them so the user can answer `Q1:a, Q2:b, Q3: <custom>`.
4. **State the blast radius** per question: which phases/sub-phases change
   depending on the answer. This is what tells the user which questions matter.
5. **Wait for the answers.** Do not start §E until the user replies. If the user
   answers only some questions, or says "use your judgment", adopt the
   recommended default for the rest and say explicitly which defaults you took.
6. **Record every answer as a `D*` decision row** (decision + consequence) in
   `overview.md`, and let the answers drive the phase-file detail. Questions the
   user deferred become `Open questions` in `overview.md` and blockers in
   `STATE.md` §9 — never silent guesses.

Keep it proportional: one batch, ordered by impact, the high-blast-radius
questions first. If a phase genuinely has no grey area, say so in one line
rather than inventing a question.

### E — Write (`agent-1` authors directly)
**Professionalism standard:** All generated content — code, tests, scripts,
documentation — must be professional and production-grade. No emojis, no
decorative symbols, no informal language in any generated file. Plain, precise,
technical prose only.

Emit the plan as a **folder** using `references/output-template.md`. Write four
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
  Every phase file opens with the **state contract** block (read `STATE.md`
  first, update it after every sub-phase) and every sub-phase `Done` field ends
  with `+ STATE.md updated`.

3. **`resume.md`** — `agent-1` writes inline, after all phase files exist.
   Small machine-readable progress tracker: phase status table (all TODO at
   init), test status table, docs status, `Next:` pointer to the first
   sub-phase. Implementer updates this file after every sub-phase.

4. **`STATE.md`** — `agent-1` writes inline last, initialized at plan creation
   (never left for the implementer to create). This is the **detailed live
   state file**: the single entry point that lets a cleared or brand-new
   session resume execution correctly with full working context. It is
   self-describing — it carries its own resume protocol and update protocol so
   an agent that reads nothing else still knows what to do. At init it holds
   the resume protocol, the self-contained feature recap, the environment and
   gate commands, an empty work ledger, and `Next action:` pointing at the
   first sub-phase. See `references/output-template.md` §4.

**Folder path — always** `docs/plans/<NNN>_plan-<FeatureName>/`, resolved from
the **repo root** (the root of the target repo, not the current working
directory). Rules:
- Create `docs/` and `docs/plans/` when missing. **Never** write a plan folder
  in the repo root.
- `<NNN>` is a zero-padded 3-digit sequence number giving the plan order. List
  the existing entries of `docs/plans/`, take the highest leading `NNN`, and use
  `NNN + 1`. First plan in a repo is `001`. Ignore entries without a numeric
  prefix when computing the maximum, and never reuse or renumber an existing
  plan folder.
- `<FeatureName>` is short and PascalCase or kebab-case, no spaces.
- Example: `docs/plans/001_plan-RateLimit/`, then `docs/plans/002_plan-Multitenancy/`.
- Honor any path the user gives explicitly; if the user gives only a name, still
  apply the `docs/plans/<NNN>_plan-` convention.
End overview.md with the **model-assignment summary table**, and state near the
top that `STATE.md` is read first at every session start.

**resume.md vs STATE.md.** `resume.md` is the compact status board (tables,
one `Next:` line) — cheap to scan. `STATE.md` is the deep state (in-flight
edits, runtime deviations, failing-gate output, dead ends, environment) — what
a cold agent needs to not redo or break work. Both are updated after every
sub-phase and must never disagree; if they do, `STATE.md` wins.

### F — Quality gate (`agent-1`, inline)
Before declaring done, run the checklist in `references/quality-checklist.md`.
Do not skip. If anything fails, fix it before returning.

---

## Execution protocol (baked into the generated plan)

The plan must instruct its own execution. The rules below are **written into
the plan files themselves** — `STATE.md` §0, the state-contract block at the
top of every phase file, and one line near the top of `overview.md` — so they
survive a `/clear`, a new session, or a handoff to an agent that never saw this
skill.

**Session start (any agent, any context state):**
1. Read `STATE.md` **first**, before any other plan file.
2. Verify reality against `STATE.md` §7 (re-run the gate commands) before
   editing anything. The file describes intent; the repo is the truth. Fix the
   file if they disagree.
3. Read only the phase file named in `Next action:`, and only the named
   sub-phase. Read `overview.md` only when `STATE.md` flags missing design
   context.

**After every sub-phase (mandatory, not optional):**
1. Update `STATE.md`: current position, work ledger row, files touched,
   in-flight work (`none` when clean), verification results, runtime
   deviations, blockers, `Next action:`, timestamp.
2. Update `resume.md` status tables and `Next:` pointer to match.
3. Only then start the next sub-phase.

**Before ending a session or when context is about to be cleared:** flush
`STATE.md` §6 (in-flight work) with exactly what is half-done — files written,
edits still pending, temporary code to remove. An interrupted sub-phase with an
empty §6 is a bug in execution.

A sub-phase is not `DONE` until gates are green **and** `STATE.md` is updated.

---

## Coherence contract (every mode, no exceptions)

The plan folder must always tell the truth about the repository. **Whatever
command is invoked, it leaves the folder coherent**: `plan` creates it,
`execute` / `task` / `bug` keep it in sync with the code they write, `verify`
records what it found and the status of every finding. A later `verify` reads
only these files: whatever is not written here becomes an unexplained diff and
is reported as a finding. Updating them is part of the work, not paperwork
after it.

The audit trail is part of the contract: `verify/index.md` and its reports are
written by `verify`, and their finding statuses are updated by
`execute verify` when corrections land. A finding never changes status without
evidence, and never disappears.

The rest of this section is the per-unit-of-work checklist for the modes that
write code (`execute`, `task`, `bug`).

After **every** unit of work (a sub-phase, a task, a bug fix), update:

1. **`STATE.md`** — §1 position, §4 ledger row, §5 files touched, §6 in-flight
   (`none` when clean), §7 verification results, §8 runtime deviations, §9
   blockers, header timestamp.
2. **`resume.md`** — phase/test/docs status tables and the `Next:` pointer.
3. **The ad-hoc ledgers** — `tasks.md` for `task` mode, `bugs.md` for `bug`
   mode, in the plan folder. Every out-of-plan change gets an entry with a
   stable ID (`T-A001`, `B-A001`) — this is what tells a later audit that a diff
   was intentional. Templates: `references/output-template.md` §6 and §7.
4. **`README.md`** — whenever user-visible behavior changed (flags, commands,
   config, defaults, limits, error messages). User guide only, no implementation
   detail; same rules as the per-phase README deliverable.
5. **`verify/index.md`** — when the work closes, reopens, or invalidates a
   finding from a previous audit, update its status (`FIXED` with evidence,
   still `OPEN`, `ACCEPTED`, `OBSOLETE`) and mirror it in the report file. Work
   that silently fixes a known finding without recording it makes the register
   lie.
6. **The plan itself, when the change invalidates it** — this is the step that
   is usually skipped and the one that breaks later phases:
   - a `D*` decision superseded → add a new `D*` row in `overview.md` marked as
     superseding the old one, with the reason and the date; never edit history
     away
   - an `I-*` invariant added, dropped, or reinterpreted → update it and name
     the regression test that now guards it
   - a not-yet-executed sub-phase whose files, anchors, symbols, or assumptions
     no longer hold → update that phase file so it stays executable by a weak
     implementer with no context, and note the edit in `STATE.md` §8
   - work that made a planned sub-phase unnecessary → mark it `SKIPPED` in
     `resume.md` with the reason, never delete it
   - new work that the plan should own going forward → add it as a sub-phase in
     the right phase file rather than leaving it only in a ledger
   - a test ID (`T-*`) added, renamed, or removed → update `resume.md`'s test
     table and the phase file that names it

**Consistency rule:** after any of these modes finishes, running
`/plan-execute-verify verify` must produce **no finding caused by the work just done**.
If the audit would flag it, the coherence updates are incomplete — finish them
before reporting done.

**Ledger IDs.** `T-A<NNN>` for tasks, `B-A<NNN>` for bugs, zero-padded, assigned
by reading the highest existing ID in the ledger and adding one. IDs are never
reused, even after a revert.

---

## Execute mode

`/plan-execute-verify execute [<plan>] [<phase|sub-phase>]` — implements an existing
plan. This is the mode that writes production code.

### E1 — Load and verify the starting point
Read `STATE.md` first, then `resume.md`, then only the phase file to execute.
Re-run the gates from `STATE.md` §3 before touching anything: if the tree is not
in the state the file claims, reconcile first and say so. If `STATE.md` §6 shows
in-flight work, finish or revert it before starting anything new.

### E2 — Pick the unit of work
Default: the sub-phase in `STATE.md` §1 `Next action:`, then continue in order.
A phase or sub-phase selector narrows execution to it; refuse (and say why) when
its preconditions are not `DONE`.

### E3 — Execute, sub-phase by sub-phase
- Do exactly what the sub-phase's **Change** field says. Follow its assignment:
  delegate to the tagged agent, and honor the `agent-1` review gates.
- Write the named unit and e2e tests with the stated assertions. A sub-phase
  whose tests do not exist is not done.
- Run the phase gates. Never mark work done on a red gate.
- **Do not improvise scope.** Something the plan did not foresee is either a
  deviation recorded in `STATE.md` §8 with its reason, or a question to the
  user — never a silent extra change.
- Stop and ask when the plan is ambiguous, contradicts the code, or a decision
  outside the plan's `D*` set is needed. Cheaper than an unwinding.
- Apply the **coherence contract** after every sub-phase, before starting the
  next one. At the end of each phase, the README sub-phase runs like any other.

### E4 — Executing a correction plan (`/plan-execute-verify execute verify [<VNNN>]`)
The correction plan of a verify report is executable work like any other, and it
lives on disk precisely so it can be run later or in a fresh session.

- Default target: the newest report in `<plan-folder>/verify/`; a `V<NNN>`
  selector picks an older one. Read `verify/index.md` first, then that report.
- Work through the correction plan in order, blockers first, treating each item
  like a sub-phase: exact change, the test it requires, gates green.
- **Re-verify each item before closing it.** A finding is `FIXED` only when the
  condition it described no longer holds and the evidence is recorded.
- Update `verify/index.md` for every item: status `FIXED` (with the date and how
  it was closed), or `OPEN` still with the reason it could not be closed, or
  `ACCEPTED` when the user decides to live with it. Mirror the status in the
  report file itself so the two never disagree.
- Corrections that reopen a phase already marked `DONE` set that phase back to
  `IN_PROGRESS` in `resume.md` until its done-criterion holds again.
- Apply the full **coherence contract** after each correction, exactly as for a
  sub-phase; a correction that changes user-visible behavior updates `README.md`
  too, and one that proves a plan file wrong reconciles that plan file.
- Close by saying which findings are now `FIXED`, which remain `OPEN`, and
  recommend a fresh `/plan-execute-verify verify` when blockers were touched.

### E5 — Close
Terse chat summary: sub-phases completed, gate results, deviations recorded,
files touched, next action. State plainly what failed or was skipped and why —
never report a phase done when part of it is not.

---

## Task mode

`/plan-execute-verify task <description>` — one small, well-understood change that does
not deserve a plan folder: a flag, a message, a small refactor, a doc fix.

1. **Mini-plan in memory, not on disk.** Restate the goal in one line, list the
   files to touch with anchors, the change, the tests, and the done-criterion.
   Keep it in chat, terse — no plan folder, no phase files.
2. **Show it before executing** when the change touches public behavior, data,
   or more than a couple of files; otherwise proceed and show the result. If the
   task turns out to be bigger than a handful of sub-steps, stop and say it
   needs a plan (`/plan-execute-verify <feature>`) instead of growing silently.
3. **Implement**, with at least one named test asserting the new behavior
   (or an explicit one-line reason why a test is impossible).
4. **Run the gates** from `STATE.md` §3, or the repo's own if there is no plan.
5. **Apply the coherence contract**: append a `T-A<NNN>` entry to `tasks.md`,
   update `STATE.md` and `resume.md`, update `README.md` if the change is
   user-visible, and reconcile the plan files if the task invalidated anything.
6. Close with: what changed, `T-A<NNN>`, files, tests, gate results.

---

## Bug mode

`/plan-execute-verify bug <description>` — diagnose and fix one defect. Same
lightweight shape as `task`, with a mandatory diagnosis step.

1. **Reproduce first.** Establish the failing behavior concretely (a command, an
   input, an assertion). If it cannot be reproduced, say so and stop with what
   you tried — do not "fix" a bug you cannot see.
2. **Find the root cause**, not the symptom. State it in one line with
   `path:line` evidence. If the cause is a plan decision (`D*`) or a missing
   invariant (`I-*`), say that explicitly — it changes the fix and the plan.
3. **Mini-plan in memory**: root cause, fix, blast radius (what else touches
   this code), the regression test, the done-criterion.
4. **Write the failing regression test first** (named, `B-A<NNN>`-tagged), watch
   it fail, then fix until it passes. A bug fix without a regression test is
   incomplete unless the test is genuinely impossible — then say why.
5. **Run the gates**, full suite, not just the touched area — bug fixes are
   where regressions hide.
6. **Apply the coherence contract**: append a `B-A<NNN>` entry to `bugs.md`
   (symptom, root cause, fix, regression test, affected phase), update
   `STATE.md` and `resume.md`, update `README.md` if user-visible behavior or a
   documented limit changed, and reconcile the plan when the bug proves a
   planned assumption wrong — including phases not yet executed that share the
   faulty assumption.
7. Close with: symptom → root cause → fix → regression test → gate results,
   `B-A<NNN>`.

---

## Verify mode

`/plan-execute-verify verify [<plan>]` — a **hard review** of the work done so far
against the plan. It answers one question: *does the implementation match the
plan, completely and exactly?* It is **read-only**: it never writes production
code, never fixes what it finds, and never rewrites phase files. It reports.

Adversarial stance: assume the plan was followed sloppily and try to prove it.
A clean report must be earned by evidence, not by the absence of looking. Treat
`STATE.md` and `resume.md` as **claims**, never as proof — the repo is the truth.

### V1 — Load the claim
Resolve the plan folder (see "Modes"). Read `STATE.md`, then `resume.md`, then
`overview.md`, then the ad-hoc ledgers `tasks.md` and `bugs.md` when present.
Extract: phases/sub-phases marked `DONE`, `D*` decisions, `I-*`
invariants, `R<n>` external facts, gate commands, test IDs, README obligations,
and the `T-A*` / `B-A*` entries that explain out-of-plan changes.

Then read `verify/index.md` when it exists: the findings still `OPEN` from
earlier audits, and the ones marked `FIXED` (those must be re-checked — a fix
that regressed is worse than a fix that never happened). Do not re-read whole
old reports; the register carries what you need, and you open a single previous
report only when a finding's detail is required.
Read the phase files for every phase not marked `TODO` — those are the
specifications you audit against.

### V2 — Establish ground truth
Delegate evidence gathering to **one batched exploration agent** (or one per
phase group when the diff is large — never one per sub-phase). It returns
compact structured facts, no file dumps:
- what actually changed: `git log`/`git diff` since the plan started, files
  added/modified, and the current state of each file the plan named
- for each `DONE` sub-phase: do the named files, symbols, and anchors exist, and
  does the code do what the **Change** field describes
- do the named tests exist, with the asserted behavior, and are they wired into
  the suite
- README: were the sections that phase promised actually updated, and only with
  user-facing content

Then run the gates from `STATE.md` §3 (fmt, lint, unit, e2e) and record the real
results. If a gate cannot run, say so — never assume green.

### V3 — Audit dimensions
Check every one; report the ones that hold as verified, not silently.

1. **Completeness** — every sub-phase marked `DONE` is actually fully done; no
   silently dropped sub-phase, file, test, or done-criterion.
2. **Fidelity** — the code does what the **Change** field says, not something
   adjacent. Different data structure, different default, different error
   handling, renamed flag: all divergences.
3. **Tests** — named tests exist with the stated assertions, actually run, and
   pass. Tests weakened, skipped, marked ignore, or asserting less than the plan
   required are findings.
4. **Gates** — fmt/lint/test really pass now, on the current tree.
5. **Decisions and invariants** — every `D*` decision is respected in code; every
   `I-*` invariant still holds and has the regression test the plan required.
6. **External facts** — usage of third-party APIs matches the `R<n>` sources and
   the pinned version; no invented options or signatures.
7. **Rules of the plan** — existing project structure followed, no gratuitous new
   directories, professionalism standard respected (no emojis, no informal
   text), per-phase README updated and free of implementation detail.
8. **Scope creep** — behavior, dependencies, or files added that the plan never
   asked for, and that no `D*` row, `STATE.md` §8 deviation, or `T-A*` / `B-A*`
   ledger entry covers.
9. **Regressions** — previously passing behavior now broken; phases claimed
   "shippable alone" that are not.
10. **State accuracy** — `STATE.md` and `resume.md` match reality: statuses,
    `Next action:`, ledger, files touched, verification table, deviations. Stale
    or optimistic state is a finding, and a serious one — later sessions trust it.
11. **Ad-hoc work reconciliation** — the `task` / `bug` history and the plan
    still agree. Both directions:
    - every change in the diff that the plan does not explain is covered by a
      `T-A*` or `B-A*` entry (otherwise: scope creep / unexplained change)
    - every ledger entry is real in the tree, carries its test, and its README
      and state updates were made
    - every ledger entry that invalidated the plan left the plan updated: a
      superseding `D*` row, an adjusted `I-*`, an edited not-yet-executed phase
      file, a `SKIPPED` sub-phase with a reason. A ledger entry that silently
      contradicts a pending phase file is a `BLOCKER` — the next phase will be
      executed against a false specification.
    - bug fixes whose root cause is a plan assumption are reflected in the plan,
      not only in `bugs.md`
12. **Previous findings** — every finding still `OPEN` in `verify/index.md` is
    re-checked and either confirmed still open or closed as `FIXED` with
    evidence; every finding already `FIXED` is re-tested, and a broken fix is
    raised again as `unfixed-regression`. Findings never disappear silently:
    a finding that no longer applies is marked `OBSOLETE` with the reason, and
    one the user decided to live with is `ACCEPTED`, never quietly dropped.

### V4 — Report (always on disk)
The report is a **durable artifact**, not a chat message that scrolls away: its
correction plan is meant to be executed later, possibly in another session.

Write it to the plan folder's audit subfolder:

```
docs/plans/<NNN>_plan-<FeatureName>/verify/
├── index.md                          # audit register — every report, every finding, its status
├── verify_001_<YYYY-MM-DD>.md
├── verify_002_<YYYY-MM-DD>.md
└── …
```

- Create `verify/` on demand. `<VNNN>` is the next free zero-padded 3-digit
  report number in that folder — never overwrite or renumber an earlier report.
- **Finding IDs are global and stable**: `V<NNN>-F<n>` (e.g. `V002-F03`). They
  are referenced by later runs, by `execute verify`, by `STATE.md` §9, and by
  the ledgers — never reused for a different finding.
- `index.md` is the register a later session reads first: one row per report
  (number, date, verdict, counts) and one row per finding (ID, severity,
  category, one-line title, status `OPEN` / `FIXED` / `ACCEPTED` / `OBSOLETE`,
  where it was closed). Template: `references/output-template.md` §8.
- Print the same content in chat, complete — the file is the record, not a
  substitute for answering the user.

Structure:

1. **Verdict** — one line: `PASS` (no blocker, no major), `PASS WITH FINDINGS`,
   or `FAIL`, plus the phases audited and the commit range reviewed.
2. **Phase table** — phase · claimed status · verified status · findings count.
3. **Findings** — one block each, ordered by severity, each with:
   - `V<NNN>-F<n>` · status `OPEN` · severity `BLOCKER` / `MAJOR` / `MINOR`
   - category: missing · divergent · untested · failing-gate · rule-violation ·
     scope-creep · regression · stale-state · unfixed-regression
   - **where**: `path:line`, and the plan reference (`phase_02.md § 1.2`, `D3`,
     `I-1`, `T-RL1`, `R2`)
   - **expected** (quoted from the plan, one line) vs **actual** (evidence from
     the repo, one line)
   - **why it matters**, one line
   - **correction**: the concrete fix, scoped as an action someone can execute
4. **Ad-hoc work** — a table of the `T-A*` / `B-A*` entries in the audited
   range: ID · what it changed · reconciled with the plan? · findings. Plus any
   diff hunk explained by neither the plan nor a ledger entry.
5. **Verified clean** — the dimensions and sub-phases that were checked and hold,
   listed compactly. This is what makes the report trustworthy.
6. **Correction plan** — the findings turned into an ordered, actionable list:
   blockers first, each mapped to its finding ID and its phase/sub-phase, with
   the smallest change that closes it. Say explicitly which corrections belong
   to a phase already marked `DONE` (the phase must reopen). Write it so a cold
   session can execute it from this file alone: exact files, exact change,
   exact test to add or repair, exact done-criterion — the same standard as a
   phase file's sub-phase.
7. **State re-sync** — the exact edits `STATE.md`, `resume.md`, and the ledgers
   need to tell the truth again.
8. **Not verifiable** — anything that could not be checked, and why (gate could
   not run, missing credentials, external service). Never fill these gaps with
   assumptions.

Every finding must carry repo evidence. No finding on suspicion alone; if you
suspect but cannot prove, put it under "Not verifiable" as a flagged doubt.

### V5 — Close
- Do **not** apply the corrections. Offer: *"want me to apply the correction
  plan?"* — applying them is a separate run, `/plan-execute-verify execute verify`,
  which can happen later or in a fresh session because the plan is on disk.
- Update `verify/index.md`: add the report row, add every new finding as `OPEN`,
  and re-evaluate findings from earlier reports — mark `FIXED` the ones this
  audit proves closed, keep `OPEN` the ones still failing, and raise a new
  finding with category `unfixed-regression` when something previously marked
  `FIXED` broke again.
- Write the audit result into `STATE.md`: §7 verification table (real gate
  results, date), §9 blockers (every `OPEN` `BLOCKER` finding, by ID), and a §8
  row when the audit found a deviation the plan never recorded. `resume.md`
  statuses are corrected where they claim a phase is `DONE` and it is not.
  These are state-file corrections, not code changes; they keep the next session
  from trusting a false state.
- Beyond those, verify writes nothing: no production code, no phase-file
  rewrite, no ledger entry invented — missing ledger reconciliation is reported
  as a finding, and only appended to `tasks.md` / `bugs.md` if the user asks.
- Chat closing line stays terse: verdict, counts by severity, report path,
  count of findings still `OPEN` from previous audits.

### Token discipline in verify mode
Evidence gathering is batched into one agent, returning `path:line — fact`
lines. Never pull whole files or whole diffs into your context; ask for the
specific anchors the plan named. Read a phase file once. The report is the only
long output, and it is written once.

---

## Output contract

The contract below applies to **plan mode**. The other modes:

- **Verify** produces no plan folder. It writes the durable audit trail:
  `<plan-folder>/verify/verify_<VNNN>_<YYYY-MM-DD>.md` plus the
  `<plan-folder>/verify/index.md` register, and the state-file corrections that
  keep `STATE.md` / `resume.md` from lying. Never production code, never a
  phase-file rewrite. The same report is printed in chat in full.
- **Execute / task / bug** are the only modes that write production code. Their
  output contract is the **coherence contract**: code plus tests plus green
  gates plus `STATE.md`, `resume.md`, the affected plan files, `README.md` when
  user-visible, and a ledger entry (`tasks.md` / `bugs.md`) for out-of-plan
  work. Work is not done until those are written.

- **Folder, not a single file.** Always
  `docs/plans/<NNN>_plan-<FeatureName>/` under the repo root, creating `docs/`
  and `docs/plans/` if they do not exist; never the repo root itself. `<NNN>` is
  the next free zero-padded 3-digit sequence number (`001` for the first plan).
  Honor any path the user gives. Confirm the folder path in your closing
  message.
- Required files (all must be present):
  - `overview.md` — small routing doc (goal, decisions, phase table, reuse map)
  - `resume.md` — small LLM-readable progress tracker (all phases TODO at init)
  - `STATE.md` — detailed live state file, initialized by this skill; read
    first at every session start, updated after every sub-phase
  - `phase_01.md`, `phase_02.md`, … — one per phase, detailed, self-contained
- **Plan mode writes no production code.** It plans; `execute` / `task` / `bug`
  (or another implementer) code.
- Every sub-phase carries the exact configured assignment in its model tag;
  `overview.md` ends with the assignment summary table.
- Phase files must follow the template's per-sub-phase block format **exactly** —
  downstream automation keys off it.

## Token discipline (applies to your own execution)

- Recon goes to **one batched exploration agent**, returning structured facts — never
  pull whole large files into your own context. Add agents only if one can't
  hold the search.
- Don't re-read what a subagent already summarized. Trust the anchors.
- External doc research is **batched into the recon step and answers closed
  questions only**. One line per fact plus a URL — never pull documentation
  pages into your context, and never research an area the plan does not touch.
  The `References` table exists so nobody searches the same thing twice.
- Write the plan **once**. No verbose in-chat drafts; compose in the file.
- Conversational replies stay terse. Phase files are the only place allowed to
  be long — length there buys downstream token savings. overview.md and
  resume.md must stay small.
- `STATE.md` is medium-sized and **bounded**: one line per ledger entry, no code
  dumps, no narrative. The only verbatim text allowed is failing gate/test
  output. It buys back far more than it costs — a resumed session that reads it
  skips re-exploration entirely.

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
