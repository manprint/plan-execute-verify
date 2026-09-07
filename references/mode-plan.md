# Plan mode — the A → F workflow

Operating manual for the default mode. Produces a plan folder; **writes no
production code** (`execute` / `task` / `bug` do that), and never commits — a
`--wip-commit` on a plan invocation only pre-sets `STATE.md` §3 for the later
`execute` runs, it does not commit the plan folder.

`agent-1` drives A → B → C → D → D2 → E → F and approves the result. **D2 is a
blocking user checkpoint: no plan file is written before the user answers the
grey-area questions.** Delegate recon to `agent-3` when available, else
`agent-2`; in single-agent mode the configured agent does everything. Prefer
**one batched recon agent over many small ones** — every extra agent re-pays
context-load and re-reads overlapping files.

The archetype output is `references/output-template.md` (the three plan-file
skeletons). Follow it.

---

## A — Scope (`agent-1`, inline)

1. Restate the goal in one paragraph. Define the **reference scenario** that is
   the final acceptance test — concrete, observable ("host-A reaches X, not Y").
2. List open questions / ambiguities. If any materially change the design, ask
   now — cheaper than replanning. Otherwise pick sensible defaults and record
   them as decisions.
3. Locate the target: which repo/dir, the gates command (`cargo test`, `pytest`,
   `npm test`, …), and **resolve the plan folder now** — list `docs/plans/` from
   the repo root, take the highest number plus one, fix the path per SKILL.md's
   plan-folder convention. One cheap listing; do not recompute it later.

---

## B — Recon (one batched exploration agent)

### B1 — Codebase recon

Spawn **one configured exploration agent with a multi-part structured task** to
gather all facts in a single call. Consolidating fact-finding into one agent cuts
API calls and avoids re-reading the same files. Split into 2+ parallel agents
**only** when the repo is too large for one agent's context — not by default.

It returns **compact structured output only**: file:line anchors, signatures,
existing patterns, the test harness, the gates command, reuse candidates. **No
file dumps.** This fills the plan's *reuse map*, so implementers never
re-explore. Example tasking:

> "In repo X, find: (1) where feature Y is currently wired (file:line), (2) the
> existing test harness + how to run it, (3) 5 reuse candidates for Z with exact
> paths and signatures. Return a terse bullet list of `path:line — what`. No code
> dumps, no prose."

One configured implementation agent is allowed for a single
correctness-sensitive probe ("does this lock get held across an await?").
Default `agent-2`, otherwise `agent-1`.

### B2 — External documentation research (when needed)

The repo does not always contain the truth. When the feature depends on
something outside it, **research the external documentation before designing** —
a design built on a misremembered API is the most expensive kind of replanning.

**Trigger when any of these hold:**
- a third-party library, framework, SDK, cloud service, or CLI is involved and
  the plan will touch its API, configuration, or migration path
- a standard, protocol, spec, or file format must be implemented or respected
  (OAuth/OIDC, HTTP semantics, JWT, WebSocket, OpenTelemetry, wire formats, …)
- version-specific behavior matters: the repo pins a version whose API you are
  not certain about, or the plan implies an upgrade/migration
- known best practices or security implications where guessing is unacceptable
  (auth, crypto, payments, PII, rate limiting, concurrency)
- your own knowledge may be stale, or you find yourself hedging

**Skip when** the work is purely internal (refactor, rename, internal test
coverage) and no external contract is touched. Say so in one line rather than
researching for form's sake.

**How to run it:**
- Prefer the **host's documentation tools** (a docs-lookup MCP server such as
  Context7, then web search/fetch). Official docs for the **exact pinned
  version** beat blog posts; check the manifest or lockfile for the version
  first.
- **Batch it into the same recon step** — give the exploration agent both parts,
  or one additional agent when the search is large. Never one agent per question.
- Ask **closed questions**, not "read the docs for X". Example tasking:
  > "Library `<lib>` version `<X.Y>` (pinned in `package.json:23`). Answer only:
  > (1) exact signature and options of `<api>`; (2) the documented way to do
  > `<task>`; (3) anything deprecated or changed since `<X.Y-1>`; (4) documented
  > error/retry semantics. One bullet per answer, each with the source URL and
  > the doc's version. No prose, no page dumps."
- Returned output must be **compact and sourced**: one line per fact with a URL.

**Use of the findings:**
- Facts that constrain the design become `D*` rows in `overview.md`.
- Uncertainty that survives research becomes a **D2 question**, not a silent
  assumption.
- Every source used goes in the `overview.md` **References** table (what it
  settled · URL · version/date) so nobody re-searches it. Copy the entries a
  phase depends on into that phase file so it stays self-contained.
- **Never quote large documentation blocks into the plan.** Cite the URL, state
  the fact in one line. Exception: an exact signature, header, or wire format the
  implementer must reproduce verbatim.
- Mark anything unconfirmed as `UNVERIFIED` — an invented API is worse than an
  open question.

---

## C — Design (`agent-1`, inline)

Synthesize recon into: **approved design decisions** (table `D1..Dn` with
consequences — every non-obvious choice gets a row), **target architecture**
(data model, mechanisms, a diagram if it helps, the **reuse map** table), the
**interface** (CLI/API/config), and any **protocol/data-structure** changes with
backward-compat notes.

---

## D — Decompose (`agent-1`, inline)

Break the work into **phases → sub-phases**. Ordering rules:

- Phase 0 is **pure-additive, no behavior change** when possible (scaffolding
  that lands safely on its own).
- Each phase **independently shippable**; **zero regressions** tolerated.
- Each sub-phase is a self-contained block with **exactly** these seven fields:
  **Model** · **Assignment** (responsibility, plus the `agent-1` review gate when
  one applies) · **Files** (with line anchors) · **Change** · **Unit tests** ·
  **e2e tests** · **Done**.
- Tag the exact configured assignment per sub-phase. Mark **agent-1 review
  gates** explicitly: hot-path refactors, concurrency/lifecycle, data-model
  design, acceptance assertions, final docs read.
- Name tests with stable IDs (`T-FOO1`, unit test names) so they are
  referenceable.
- Every sub-phase's **Done** ends with the unit closed in `STATE.md` — state
  tracking is part of the definition of done, not a suggestion.
- **Every phase ends with a README sub-phase** (see below).

**Write for a weak implementer.** Always assume the model executing a sub-phase
is less capable and has no surrounding context. Phase files must let a weak model
execute correctly with no ambiguity: precise file paths and line anchors, exact
symbol names, the full change step by step, explicit assertions for every test,
done-criteria requiring no judgment. If a step could be misread, rewrite it.

**README deliverable (mandatory, once per phase).** The final sub-phase of every
phase is `<N.last> Update README.md`, assigned to the lowest-capability agent
that can do it (`agent-3+` when present, else `agent-2`), with an `agent-1` read
on the last phase. It is a **user guide, not a design document**:

- **Include:** what the application does and who it is for; install /
  requirements; how to run it; the full command / sub-command / flag surface with
  realistic examples and expected output; configuration and environment variables
  with defaults; notes and caveats; **known limits and limitations**;
  troubleshooting for common failure modes; where to get more help.
- **Exclude:** implementation detail — internal module/class/function names, file
  layout, algorithms, data structures, refactoring notes, phase or plan
  references, roadmaps of unshipped work. If a sentence only makes sense to
  someone reading the source, it does not belong in the README.
- **Only shipped behavior.** Each phase documents what that phase actually made
  usable; nothing planned-but-absent. A phase that ships nothing user-visible
  (pure scaffolding) says so explicitly and limits itself to keeping the existing
  README accurate — never silently skipped.
- **Update, don't rewrite.** Preserve the project's existing README structure,
  tone, and language; edit the affected sections. No emojis, no informal
  language.
- The sub-phase states which README sections that phase touches; its
  done-criterion is that a new user can install and use the phase's feature from
  the README alone, with no source reading.

**Follow existing project structure.** Every sub-phase that creates or modifies
code, tests, scripts, or documentation must instruct the implementer to follow
the repo's pre-existing folder/file conventions. New directories only when no
existing directory serves the same purpose or semantics. State this explicitly
per sub-phase when new files are added.

---

## D2 — Clarification gate (`agent-1`, inline, **blocking**)

**Mandatory. Never skip, never merge into E.** After the decomposition exists but
**before writing any plan file**, present a compact overview plus the **grey
areas of every phase**, and let the user decide. Detailed phase files written on
unresolved ambiguity are expensive to rewrite; a question here costs a few
hundred tokens.

1. **Show the skeleton first** — in chat, terse: goal, reference scenario, the
   `D*` decisions already taken, and the phase → sub-phase list (titles only, one
   line each). No file written yet.
2. **Sweep every phase for grey areas.** Walk phase by phase, sub-phase by
   sub-phase; collect every point where more than one reasonable implementation
   exists or where you had to guess. Typical sources:
   - naming, module/file placement, public vs internal API surface
   - data model and schema shape, defaults, nullability, migration strategy
   - error handling, failure modes, retry/timeout policy
   - backward compatibility, feature flags, opt-in vs opt-out defaults
   - concurrency, ordering, idempotency, transaction boundaries
   - test depth and boundaries: what is unit vs e2e, what gets mocked
   - scope edges: what is explicitly out of scope for this plan
   - performance/limits targets, observability (logs, metrics)
   - dependency choices: new dependency vs hand-rolled vs existing utility
3. **Ask them all in one batch, grouped by phase.** No drip-feeding across turns.
   Format each as `Q<n> [phase N]` — the question, the concrete options, and your
   **recommended default** with a one-line reason. Every question answerable by
   picking an option; no open essays. Number them so the user can answer
   `Q1:a, Q2:b, Q3: <custom>`.
4. **State the blast radius** per question: which phases/sub-phases change
   depending on the answer. This is what tells the user which questions matter.
5. **Wait for the answers.** Do not start §E until the user replies. If the user
   answers only some, or says "use your judgment", adopt the recommended default
   for the rest and say explicitly which defaults you took.
6. **Record every answer as a `D*` decision row** (decision + consequence) in
   `overview.md`, and let the answers drive the phase-file detail. Questions the
   user deferred become `Open questions` in `overview.md` and blockers in
   `STATE.md` §9 — never silent guesses.

Keep it proportional: one batch, highest blast radius first. If a phase genuinely
has no grey area, say so in one line rather than inventing a question.

---

## E — Write (`agent-1` authors directly)

**Professionalism standard:** all generated content — code, tests, scripts,
documentation — is professional and production-grade. No emojis, no decorative
symbols, no informal language in any generated file. Plain, precise, technical
prose only.

Emit the plan as a **folder** using `references/output-template.md`, at the path
given by SKILL.md's plan-folder convention. Write in this order:

1. **`overview.md`** — small routing doc: goal, reference scenario, `D*`
   decisions, open questions, architecture summary, phase list with file links,
   reuse map, the interface (exact names, types, defaults, conflict rules),
   protocol/data-structure changes with backward-compat strategy, references,
   invariants, risks, the verification summary (gate commands plus the `T-*` IDs
   that prove the reference scenario), and — as its **last** section — the
   model-assignment summary table. State near the top that `STATE.md` is read
   first at every session start. Must stay small: one table or a few lines per
   section. If detail creeps in, push it to the phase file.

2. **`phase_01.md`, `phase_02.md`, …** — one per phase (1-indexed, zero-padded).
   Each fully self-contained: sub-phases with all seven fields, phase gates, done
   criterion. `agent-1` writes these directly because it holds the design
   context; delegate prose to a lower-priority agent only when phases are many
   and purely mechanical, then spot-check. **These files are the only place
   allowed to be long.** Every phase file opens with the **state contract** block
   (read `STATE.md` first; if §1 is `OPEN`, finish or revert it; run the §3 gates
   against the §1/§7/§11 claims; open the sub-phase in §1 before editing, close
   it after) and every sub-phase `Done` ends with the unit closed in `STATE.md`.

3. **`STATE.md`** — written last, **initialized at plan creation** (never left
   for the implementer to create). The **single live state file**: the one entry
   point that lets a cleared or brand-new session resume execution correctly with
   full working context. Self-describing — it carries its own resume, open, and
   close protocol, so an agent that reads nothing else still knows what to do. At
   init it holds the protocol (§0), §1 with `Status: none` and `Next action:`
   pointing at the first sub-phase, the self-contained feature recap (§2), the
   environment and gate commands plus the **WIP commits** setting (§3), an empty
   work ledger (§4), §6 reading
   `none — tree consistent`, any deferred clarification question in §9, and the
   §11 progress board with every phase `TODO`, every planned `T-*` test `TODO`,
   and one docs row per phase README sub-phase. See
   `references/output-template.md` §3.

The session protocol in SKILL.md is what gets baked into `STATE.md` §0, the phase
files' state contract, and the `overview.md` header.

---

## F — Quality gate (`agent-1`, inline)

Before declaring done, run the plan-mode checklist in
`references/quality-checklist.md`. Do not skip. If anything fails, fix it before
returning.

---

## Plan-mode output contract

- **Folder, not a single file**, per SKILL.md's plan-folder convention. Confirm
  the folder path in your closing message.
- Required files, all present:
  - `overview.md` — small routing doc with every section listed in §E step 1
  - `phase_01.md`, `phase_02.md`, … — one per phase, detailed, self-contained
  - `STATE.md` — the single live state file, initialized by this skill (§11 board
    included); read first at every session start, with every unit opened and
    closed in it. **No second status file is written.**
- **Plan mode writes no production code.**
- Every sub-phase carries the exact configured assignment in its model tag;
  `overview.md` ends with the assignment summary table.
- Phase files follow the template's per-sub-phase block format **exactly** —
  downstream automation keys off it.
- Closing message is terse: folder path plus a one-line phase/assignment summary.
