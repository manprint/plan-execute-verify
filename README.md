# plan-analize

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
git clone https://github.com/<you>/plan-analize.git
cd plan-analize
./install.sh            # symlinks this repo into ~/.claude/skills/plan-analize
```

### Option B — copy

```bash
git clone https://github.com/<you>/plan-analize.git
cp -r plan-analize ~/.claude/skills/plan-analize
```

### Option C — per-project

```bash
mkdir -p <your-repo>/.claude/skills
cp -r plan-analize <your-repo>/.claude/skills/plan-analize
```

Verify: in Claude Code run `/` and look for `plan-analize`, or just ask Claude to
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

You can also invoke it explicitly: **`/plan-analize`**.

### Configure agents explicitly

The assignment prefix is optional and must appear before the feature request:

```text
/plan-analize agent-1:opus,agent-2:sonnet,agent-3:haiku add OAuth authentication
/plan-analize agent-1:gpt5-6-sol,agent-2:gpt5-6-terra,agent-3:gpt5-6-luna add OAuth authentication
/plan-analize agent:deepseek add OAuth authentication
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
> `docs/plans/plan_RateLimit/`."*

> *"Analyze how to add multi-tenant support to this service and produce a phased
> handoff plan with phases, sub-phases, tests and quality gates, splitting work
> across a supervisor, implementer, and explorer."*

> *"/plan-analize a migration from the v1 auth tokens to v2, zero downtime,
> backward compatible during rollout."*

### What you get back
A folder at the agreed path (default `docs/plans/plan_<FeatureName>/`) with:
- `overview.md` — routing doc: goal, decisions, phase table, reuse map (small)
- `resume.md` — LLM-readable progress tracker, all phases TODO at init (small)
- `phase_01.md`, `phase_02.md`, … — one per phase, detailed, self-contained
- A terse chat summary: the folder path, phase count, and assignment split.
- **No code is written** — this skill plans; implementers execute phase by phase.

### Driving the implementation afterward
The plan is built to be executed by subagents. A natural follow-up:
> *"Read `docs/plans/plan_RateLimit/overview.md`, then implement Phase 0
> (phase_01.md). Use the model tagged on each sub-phase. Run the gates and
> show me the results."*

Each phase file is fully self-contained — an implementer can cold-start from it
without reading the others. `resume.md` tracks progress so the agent always knows
what's done, what's next, and where to resume after a context reset.

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
8. Invariants to preserve / add (`I-*`)
9. Risk register
10. Verification summary — gates, unit, e2e, acceptance
11. Model-assignment summary table

---

## Repository layout

```
plan-analize/
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
