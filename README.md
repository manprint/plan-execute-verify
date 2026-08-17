# plan-execute-verify

> A planning skill that turns a feature request into a **rigorous,
> agent-assigned implementation plan** — phases and
> sub-phases, internal + e2e tests, quality gates, and documentation
> deliverables — using the **fewest tokens possible** to produce it.

It supports either one configured agent or a small ordered team:

| Assignment | Role |
|------------|------|
| `agent-1:<name>` | Architect and supervisor — owns scope, architecture, decisions, decomposition, review gates, and final read. |
| `agent-2:<name>` | Implementer — implements features/refactors and tests. |
| `agent-3:<name>` and later | Explorer — gathers facts, writes docs, and performs mechanical work. |
| `agent:<name>` | Single agent — performs the complete workflow and self-reviews. |

The output is a **self-contained plan folder** that any downstream agent can
execute with zero re-exploration, with **every sub-phase tagged with the cheapest
model that can do it correctly**.

---

## Why

Two problems this solves at once:

1. **Token cost.** Re-exploration is where tokens go to die. A plan whose every
   sub-phase names the exact files, line anchors, change, tests, and
   done-criteria means the implementer never re-reads the codebase. Recon is
   delegated to lower-priority agents; the supervisor context stays lean. You
   pay the exploration cost once and save repeated downstream re-exploration.
2. **Plan quality.** Vague plans produce vague code. This skill enforces a
   battle-tested structure: design-decision table, reuse map, additive Phase 0,
   independently-shippable phases, named tests with checkable assertions,
   explicit quality gates, invariants, a risk register, and a model-assignment
   summary.

---

## Install

The skill is a directory containing `SKILL.md` plus `references/`. Claude Code
discovers skills under `~/.claude/skills/` (personal) or a project's
`.claude/skills/`.

### Option A — symlink (recommended; tracks the repo)

```bash
git clone https://github.com/<you>/plan-execute-verify.git
cd plan-execute-verify
./install.sh            # symlinks this repo into ~/.claude/skills/plan-execute-verify
```

### Option B — copy

```bash
git clone https://github.com/<you>/plan-execute-verify.git
cp -r plan-execute-verify ~/.claude/skills/plan-execute-verify
```

### Option C — per-project

```bash
mkdir -p <your-repo>/.claude/skills
cp -r plan-execute-verify <your-repo>/.claude/skills/plan-execute-verify
```

Verify: in Claude Code run `/` and look for `plan-execute-verify`, or just ask Claude to
"plan a feature" and it should consult the skill.

> **Tip:** when no assignment prefix is supplied, the existing Claude default
> remains available. For explicit control, put the agents in priority order at
> the start of the invocation.

---

## How to invoke it well

### It triggers automatically on planning intent
You don't need to name it. It fires on phrasing like:
- "plan this feature / make a work plan / break this into phases"
- "design doc / implementation plan / handoff plan / spec this out"
- "analyze X and produce phases and sub-phases"
- "split the work across a supervisor, implementer, and explorer"

You can also invoke it explicitly: **`/plan-execute-verify`**.

### Modes

| Invocation | Mode | Result |
|------------|------|--------|
| `/plan-execute-verify <feature>` | **Plan** | Produces the plan folder. Writes no code. |
| `/plan-execute-verify execute [<plan>] [<phase>]` | **Execute** | Implements the plan sub-phase by sub-phase, keeping every plan and state file coherent. |
| `/plan-execute-verify task <description>` | **Task** | One small change, planned in memory, logged in `tasks.md`. |
| `/plan-execute-verify bug <description>` | **Bug** | One defect: reproduce, root cause, regression test, fix, logged in `bugs.md`. |
| `/plan-execute-verify verify [<plan>]` | **Verify** | Audits everything built so far against the plan and reports what is missing, divergent, or broken. Read-only. |

### Configure agents explicitly

The assignment prefix is optional and must appear before the feature request:

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku add OAuth authentication
/plan-execute-verify agent-1:gpt5-6-sol,agent-2:gpt5-6-terra,agent-3:gpt5-6-luna add OAuth authentication
/plan-execute-verify agent:deepseek add OAuth authentication
```

`agent-1` is the supervisor, `agent-2` is the implementer, and `agent-3` and
later are used for exploration and mechanical work. In `agent:<name>` mode the
same agent performs every stage and self-review. Names are passed unchanged to
the host. A valid prefix without a feature request asks for the feature; no
prefix preserves the existing default behavior.

### Give it what makes a good plan
The plan is only as good as the scope it starts from. The strongest invocations
include:

1. **The goal**, in plain terms — the end state you want.
2. **A reference scenario** — a concrete, observable acceptance test
   ("user A can reach X but not Y", "20 req/s on key k1 → ~10 pass"). This
   becomes the plan's acceptance criterion. If you don't give one, the skill
   will define one and ask you to confirm.
3. **The repo / area** to target, and where the plan folder should land.
4. **Hard constraints** — "must stay backward-compatible", "no new
   dependencies", "the existing fast path must not regress".

### Example prompts

> *"Plan adding per-API-key rate limiting to the `gw` gateway in `./gw`. Must be
> opt-in and not slow down keys that are under their limit. Reference test: 20
> req/s on a 10 req/s key → ~10 pass, rest 429. Write the plan to
> `docs/plans/001_plan-RateLimit/`."*

> *"Analyze how to add multi-tenant support to this service and produce a phased
> handoff plan with phases, sub-phases, tests and quality gates, splitting work
> across a supervisor, implementer, and explorer."*

> *"/plan-execute-verify a migration from the v1 auth tokens to v2, zero downtime,
> backward compatible during rollout."*

### External documentation research

When the feature depends on something the repo does not define — a third-party
library or SDK, a cloud service, a protocol or spec, a version upgrade, or a
security-sensitive area — the skill researches the **official documentation for
the version pinned in your repo** before designing, using the host's docs tools
and web search. Findings come back as one-line sourced facts, land in the
`overview.md` **References** table (fact · URL · version/date), and are cited
per sub-phase as `R<n>`. Anything that cannot be confirmed is marked
`UNVERIFIED` and becomes a question instead of an invented API. Purely internal
work (refactors, renames, test coverage) skips this step.

### The clarification checkpoint

Before writing any file, the skill stops and asks. You get the phase skeleton
(goal, reference scenario, decisions taken, phase → sub-phase list) plus **one
batched set of numbered questions covering the grey areas of every phase** —
naming, data model, defaults, error handling, backward compatibility, test
boundaries, scope edges, dependencies. Each question comes with concrete
options, a recommended default, and the phases its answer changes, so you can
reply compactly (`Q1:a, Q2:b, Q3: <your call>`).

Answers become `D*` decision rows and drive the detail of the phase files.
Anything you defer is applied as a stated default and listed under **Open
questions**, never guessed silently. Say "use your judgment" and the skill takes
its recommended defaults and tells you which ones it took.

### What you get back
A folder at `docs/plans/<NNN>_plan-<FeatureName>/` — always under `docs/plans/`
(created if missing, never the repo root), numbered with the next free 3-digit
sequence so the listing shows plan order (`001_plan-RateLimit`,
`002_plan-Multitenancy`, …). It contains:
- `overview.md` — routing doc: goal, decisions, phase table, reuse map (small)
- `resume.md` — LLM-readable progress tracker, all phases TODO at init (small)
- `STATE.md` — detailed live execution state: current position, self-contained
  feature recap, environment and gate commands, work ledger, files touched,
  in-flight work, verification results, runtime deviations, blockers, dead ends
- `phase_01.md`, `phase_02.md`, … — one per phase, detailed, self-contained
- A terse chat summary: the folder path, phase count, and assignment split.

The other modes add to the same folder as they run: `tasks.md` and `bugs.md`
(out-of-plan work ledgers) and `verify/` (audit register plus one durable report
per audit).
- **No code is written** — this skill plans; implementers execute phase by phase.

### Documentation keeps pace with the code

Every phase in the generated plan ends with a mandatory `Update README.md`
sub-phase, so your project's README is never behind the shipped behavior. It is
specified as a **user guide**: what the app does, install and requirements, how
to run it, the command / sub-command / flag surface with realistic examples,
configuration and defaults, notes, known limits, troubleshooting.

Implementation detail is explicitly excluded — no module or function names, no
file layout, no algorithms, no phase or plan references, no unshipped roadmap.
Phases that ship nothing user-visible say so and just verify the README is still
accurate. The done-criterion is that a new user can install and use that phase's
feature from the README alone.

### Implementing the plan — `/plan-execute-verify execute`

```text
/plan-execute-verify execute                  # continue the newest plan from STATE.md
/plan-execute-verify execute 003              # a specific plan
/plan-execute-verify execute 003 phase_02     # only that phase
/plan-execute-verify execute 003 § 1.2        # only that sub-phase
```

It reads `STATE.md` first, re-runs the gates to confirm the recorded state is
real, finishes any in-flight work, then executes sub-phases in order: the exact
change specified, the named tests, the phase gates, and the README sub-phase
that closes each phase. It never improvises scope — anything the plan did not
foresee is either a recorded deviation or a question to you — and it stops and
asks when the plan is ambiguous or contradicts the code. After every sub-phase
it applies the coherence contract below.

### Small changes and bugs — `/plan-execute-verify task` and `/plan-execute-verify bug`

```text
/plan-execute-verify task add a --json flag to the status command
/plan-execute-verify bug the CLI exits 0 when the config file is missing
```

Neither creates a plan folder: they build a **mini-plan in memory** (goal,
files, change, tests, done-criterion), show it when the change is non-trivial,
then implement it with at least one named test — for `bug`, a regression test
written first, watched failing, then made to pass, after reproducing the defect
and stating the root cause with `path:line` evidence.

Each is then logged in an append-only ledger inside the plan folder —
`tasks.md` (`T-A001`, `T-A002`, …) or `bugs.md` (`B-A001`, …) — with files,
tests, gate results, README impact, and **plan impact**. Repos with no plan yet
use `docs/plans/000_adhoc/`.

### The coherence contract

**Whatever command you invoke, the plan folder keeps telling the truth about the
repository.** `plan` creates it, `execute` / `task` / `bug` keep it in sync with
the code they write, `verify` records what it found and the status of every
finding. Every unit of work updates

- `STATE.md` (position, ledger, files, in-flight, verification, deviations),
- `resume.md` (statuses, `Next:`),
- `tasks.md` / `bugs.md` for out-of-plan changes,
- `verify/index.md` when a known finding is closed, reopened, or made obsolete,
- `README.md` when user-visible behavior changed,
- **and the plan itself when the work invalidated it** — a superseding `D*`
  decision row, an adjusted `I-*` invariant, an edited phase file that has not
  been executed yet, a sub-phase marked `SKIPPED` with its reason, or a new
  sub-phase where the plan should own the work.

That last point is what keeps the flow honest: after a handful of tasks and bug
fixes, `/plan-execute-verify verify` still lines up. The rule is explicit in the skill —
a verify run immediately after any of these modes must produce **no finding
caused by the work just done**, and a ledger entry that silently contradicts a
phase file not yet executed is reported as a blocker.

### Verifying the implementation — `/plan-execute-verify verify`

Run it from the repository at any point during implementation:

```text
/plan-execute-verify verify                                  # newest plan in docs/plans/
/plan-execute-verify verify 003                              # by sequence number
/plan-execute-verify verify docs/plans/003_plan-Multitenancy # by path
/plan-execute-verify agent-1:opus verify                     # pick the auditing agent
```

It hard-reviews what has actually been built against the plan, treating
`STATE.md` and `resume.md` as claims to be disproved rather than evidence. It
checks, per audited phase:

- **completeness** — sub-phases, files, tests, and done-criteria that were
  marked done but are missing or partial
- **fidelity** — code that does something different from the sub-phase `Change`
  field: different defaults, structures, error handling, renamed flags
- **tests** — named tests exist, assert what the plan required, run, and pass;
  weakened, skipped, or ignored tests are findings
- **gates** — fmt / lint / unit / e2e actually run and pass on the current tree
- **decisions and invariants** — every `D*` respected, every `I-*` still holding
  with its regression test
- **external facts** — third-party API usage matches the `R<n>` sources and the
  pinned version
- **plan rules** — project structure followed, professionalism standard,
  per-phase README updated and free of implementation detail
- **scope creep**, **regressions**, and **state accuracy**
- **ad-hoc reconciliation** — every diff hunk is explained by the plan or by a
  `T-A*` / `B-A*` ledger entry, every ledger entry is real and tested, and every
  entry that invalidated the plan left the plan updated

You get a complete report in chat **and on disk**, in the plan's audit folder:

```
docs/plans/003_plan-Multitenancy/verify/
├── index.md                    # register: every report, every finding, its status
├── verify_001_2026-08-10.md
└── verify_002_2026-08-17.md
```

Each report carries the verdict (`PASS` / `PASS WITH FINDINGS` / `FAIL`), a
per-phase table, and every finding with a **stable ID** (`V002-F03`), status,
severity, `path:line`, plan reference, expected vs actual, impact, and the
concrete correction — plus what was **verified clean**, the **ad-hoc work**
table, the **correction plan**, the **state re-sync** needed, and anything
**not verifiable**.

The correction plan is written to be executed later, from the file alone, in a
fresh session:

```text
/plan-execute-verify execute verify        # apply the newest report's correction plan
/plan-execute-verify execute verify V002   # apply an older one
```

Findings are tracked across audits in `index.md`: a new run re-checks everything
still `OPEN`, re-tests what was marked `FIXED` (a fix that regressed is raised
again), and nothing is dropped silently — a finding that no longer applies
becomes `OBSOLETE` with its reason, one you decide to live with becomes
`ACCEPTED`. Applying corrections updates those statuses with evidence and
reopens any `DONE` phase it had to touch.

Verify itself never changes production code and never applies its own
corrections: it ends by offering to. Reports are never overwritten or
renumbered.

### Driving the implementation afterward
Normally `/plan-execute-verify execute` — but the plan is also built to be executed by
any agent, so a plain prompt works too:
> *"Read `docs/plans/001_plan-RateLimit/STATE.md`, then continue from the next
> action. Use the model tagged on each sub-phase. Run the gates and show me the
> results."*

Each phase file is fully self-contained — an implementer can cold-start from it
without reading the others. Note that a hand-driven implementer will not apply
the coherence contract for you: `execute` is what keeps the state files, the
ledgers, and the plan itself in sync.

### Resuming after `/clear` or in a new session

`STATE.md` is the resume point. It is created with the plan and rewritten after
every sub-phase, and it carries its own protocol, so an agent with an empty
context can open it alone and continue correctly:

- **§0** — how to resume and what to update (self-describing).
- **§1** — current phase / sub-phase, `Next action:`, branch and commit.
- **§2 §3** — feature recap and the exact build / test / lint commands, so no
  re-exploration is needed.
- **§4 §5** — what has already been done and which files were touched.
- **§6** — in-flight work: exactly what is half-finished after an interruption.
- **§7 §8 §9 §10** — verification results (with failing output verbatim),
  runtime deviations from the plan, blockers, and dead ends not to retry.

`resume.md` stays the compact status board; `STATE.md` is the deep state. Both
are updated after every sub-phase, and `STATE.md` wins if they disagree. A
sub-phase counts as done only when the gates are green **and** the state files
are updated — so just say *"resume the plan"* in a fresh session.

---

## What the plan contains

Every plan follows this structure (see `references/output-template.md`):

1. Header — status, authoring/implementation models, target (incl. token goal)
2. Context & problem — current state with `file:line` anchors, goal, **reference
   scenario** (the acceptance test)
3. Approved design decisions — `D1..Dn` table with consequences
4. Target architecture — data model, mechanisms, diagrams, **reuse map**
5. New interface — CLI/API/config, exact names/types/defaults
6. New protocol / data structures — with backward-compat strategy
7. Implementation phases — each sub-phase: **Model · Files · Change · Unit tests
   · e2e tests · Done**
8. References — external documentation consulted (`R-*`), with URL and version
9. Invariants to preserve / add (`I-*`)
10. Open questions — deferred clarifications and the defaults applied
11. Risk register
12. Verification summary — gates, unit, e2e, acceptance
13. Model-assignment summary table

---

## Repository layout

```
plan-execute-verify/
├── SKILL.md                        # the skill (frontmatter + workflow)
├── README.md                       # this file
├── LICENSE                         # MIT
├── install.sh                      # symlink into ~/.claude/skills/
└── references/
    ├── output-template.md          # the canonical plan skeleton
    ├── agent-roster.md             # model roles + delegation + dispatch
    ├── token-economy.md            # token-minimization tactics
    ├── quality-checklist.md        # the pre-return quality gate
    └── worked-example.md           # a compact, project-agnostic filled plan
```

---

## Design notes

- **Phase files are intentionally long.** That is front-loaded work (once, on
   the supervisor) that prevents repeated re-exploration spend (many times, across every
  implementation turn). Optimize total tokens across the whole feature, not the
  size of individual files. overview.md and resume.md stay small by design.
  See `references/token-economy.md`.
- **Progressive disclosure.** `SKILL.md` stays lean; detail lives in
  `references/` and is loaded only when needed.
- **Project-agnostic.** The examples use generic stacks; the skill works on any
  codebase and any test/lint/gate toolchain.

## License

MIT — see [LICENSE](LICENSE).
