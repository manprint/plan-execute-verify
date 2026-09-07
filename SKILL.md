---
name: plan-execute-verify
description: >
  Phased, agent-assigned implementation plans at minimum token cost. Use
  whenever the user wants to plan, scope, design, break down, or analyze a
  feature/refactor/migration before coding: "plan this", "make a work plan",
  "break this into phases", "design doc", "implementation plan", "handoff
  plan", "spec this out", "architecture for X". Produces a resumable plan
  folder (overview.md, phase_NN.md, and a single STATE.md). Sub-commands:
  `execute` implements the plan sub-phase by sub-phase, `task` one small
  change, `bug` one defect fix, `verify` audits the implementation against the
  plan. Every mode keeps the plan folder coherent with the code.
---

# plan-execute-verify

Produce one artifact: a **self-contained, phased implementation plan** that any
downstream agent can execute with **zero re-exploration**, with **every
sub-phase assigned to the configured agent that can do it correctly**.

Two goals, equally hard:

1. **Minimize tokens** — both the tokens *you* spend writing the plan and the
   tokens the *implementers* spend executing it. A self-contained sub-phase is
   itself a token-minimization device: the downstream agent never re-reads the
   codebase. See `references/token-economy.md`.
2. **Maximize plan quality** — correct architecture, exhaustive phase/sub-phase
   decomposition, formal internal + e2e tests, explicit quality gates, doc
   deliverables, clean division of labor across the configured agents.

---

## Invocation

```text
/plan-execute-verify [<flags>] [<agent-prefix>] [<mode>] <args>
```

Flags and the agent prefix are recognized **only in the leading run of tokens**,
in any order. Parsing stops at the first token that is neither, and everything
from there on is the mode plus its arguments. So a `--` inside a description is
never mistaken for a flag: in `task add a --json flag to the status command`,
`--json` is part of the description. An **unknown leading flag is rejected**, not
absorbed into the feature text.

### Flags (optional)

| Flag | Effect |
|------|--------|
| `--wip-commit` | Commit every closed unit of work, and commit half-done work when a session is interrupted. Applies to the modes that write production code: `execute`, `task`, `bug`, `execute verify`. |
| `--no-wip-commit` | Turn it off again. |

The setting **persists**, because a flag you have to remember produces a
half-committed history: on first use it is written to `STATE.md` §3 and every
later session reads it from there. Precedence: an explicit flag in the invocation
> the `STATE.md` §3 setting > **off** (the default). In `docs/plans/000_adhoc/`
there is no `STATE.md`, so there it is per-invocation only.

### Agent prefix (optional)

Accepted forms: `agent:<name>`, or a comma-separated contiguous list of
`agent-N:<name>` entries.

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku <feature>
/plan-execute-verify agent-1:gpt5-6-sol,agent-2:gpt5-6-terra <feature>
/plan-execute-verify agent:deepseek <feature>
```

Names are opaque, non-empty tokens without whitespace or commas, passed to the
host unchanged. Numbered entries must start at `1`, be unique, and have no gaps.
**Reject before starting work:** mixed forms, duplicate indexes, missing names,
invalid numbering.

Valid prefix but no feature description → ask what to plan. No prefix and no
description → ask for the feature.

### Modes

The first token after the optional prefix may select the mode. **Resolve the
mode first, then read that mode's reference file and follow it — it is the
operating manual for the run. Read only that one.**

| Token | Mode | Operating manual | What it does |
|-------|------|------------------|--------------|
| `verify` | **Verify** | `references/mode-verify.md` | Hard review of the implementation against an existing plan. Writes no production code; produces a findings report plus state-file corrections. |
| `execute` | **Execute** | `references/mode-execute.md` | Implements an existing plan, sub-phase by sub-phase, keeping every plan file coherent. `execute verify` applies a stored verify report's correction plan. |
| `task` | **Task** | `references/mode-taskbug.md` | Implements one small change with an in-memory mini-plan; logged in the task ledger. |
| `bug` | **Bug** | `references/mode-taskbug.md` | Diagnoses and fixes one defect with an in-memory mini-plan; logged in the bug ledger. |
| anything else | **Plan** (default) | `references/mode-plan.md` | The A → F planning workflow. |

```text
/plan-execute-verify verify
/plan-execute-verify verify 003
/plan-execute-verify verify docs/plans/003_plan-Multitenancy
/plan-execute-verify agent-1:opus,agent-2:sonnet verify

/plan-execute-verify execute
/plan-execute-verify execute 003
/plan-execute-verify execute 003 phase_02
/plan-execute-verify execute 003 § 1.2
/plan-execute-verify execute verify          # newest verify report's correction plan
/plan-execute-verify execute verify V002     # an older report's correction plan

/plan-execute-verify task add a --json flag to the status command
/plan-execute-verify bug the CLI exits 0 when the config file is missing
```

**Mode-token disambiguation.** A leading `verify` / `execute` / `task` / `bug`
selects a mode **only when what follows is mode-shaped**: nothing, a plan
selector, a phase/sub-phase selector, or — for `task` and `bug` — a change or
defect in code that already exists. When the token reads instead as part of a
feature to build (`verify the login flow before refactoring`, `task queue for
background jobs`, `bug reporting dashboard`), it belongs to the feature
description and the invocation is **Plan**. State in one line which reading you
took; ask only when the two readings produce materially different work.

**Plan selection.** For `verify` and `execute`, the next token optionally
selects the plan: a 3-digit number, a feature name, or a folder path. For
`execute`, a further token narrows to one phase (`phase_02`) or one sub-phase
(`1.2`, `§ 1.2`, `phase_02 § 1.2` — all accepted). Without a selector, use the
plan folder with the highest `NNN` in `docs/plans/`, **ignoring `000_adhoc`**
(no phases, never a valid `verify` / `execute` target); if several plans are in
progress, list them and ask which. `execute verify` always means "apply a verify
report" — a plan literally named `verify` must be selected by number or path.

For `task` and `bug`, everything after the mode token is the description. They
attach to the **active plan** (the one `STATE.md` shows in progress, else the
highest `NNN`) so the ledgers live with it. With no plan folder in the repo they
use `docs/plans/000_adhoc/`, created on demand (`000` is reserved for work with
no plan) — see "Ad-hoc work without a plan" below.

---

## Agent assignment

One agent or an ordered list. Position determines responsibility, independently
of the model or provider name. Full rules: `references/agent-roster.md`.

| Assignment | Responsibility |
|------------|----------------|
| `agent-1:<name>` | Architect, supervisor, orchestrator, phase approver. |
| `agent-2:<name>` | Primary implementer. In two-agent mode, also exploration and mechanical work. |
| `agent-3:<name>` and later | Exploration, scaffolding, documentation, mechanical work. |
| `agent:<name>` | The same agent performs every stage and explicitly self-reviews. |

With no prefix, retain the Opus/Sonnet/Haiku assignment as a backward-compatible
default; those names are not required for configured assignments. Tag every
sub-phase with the exact configured assignment, e.g. `agent-2:gpt5-6-terra`.

---

## Plan folder convention (all modes)

Always `docs/plans/<NNN>_plan-<FeatureName>/`, resolved from the **repo root**
(the target repo's root, not the cwd).

- Create `docs/` and `docs/plans/` when missing. **Never** write a plan folder in
  the repo root.
- `<NNN>` is zero-padded 3-digit: list `docs/plans/`, take the highest leading
  `NNN`, use `NNN + 1` — never the lowest unused number, so a gap left by a
  deleted plan is never refilled. First plan is `001` (`000_adhoc`, when
  present, counts as `000`). Ignore entries without a numeric prefix when
  computing the maximum. Never reuse or renumber an existing plan folder.
- `<FeatureName>`: short, PascalCase or kebab-case, no spaces.
  E.g. `docs/plans/001_plan-RateLimit/`, then `docs/plans/002_plan-Multitenancy/`.
- Honor any path the user gives explicitly; given only a name, still apply the
  `docs/plans/<NNN>_plan-` convention.

---

## Session protocol

`STATE.md` is the **single** execution-state file: position, progress board,
ledger, in-flight work, deviations, blockers, audit history. Nothing outside it
may claim a status, so nothing can disagree with it.

These rules are **written into the plan files themselves** (`STATE.md` §0, the
state-contract block at the top of every phase file, one line near the top of
`overview.md`) so they survive a `/clear`, a new session, or a handoff to an
agent that never saw this skill. Every mode that executes plan work follows
them.

**Unit of work.** One sub-phase, one `task`, one `bug`, one `verify` audit, or
one correction from a verify report. Every unit is **opened** in `STATE.md` §1
before any code is touched and **closed** after its gates are green. This is what
makes an interruption recoverable: there are only two readable states, never a
third.

**Session start (any agent, any context state):**
1. Read `STATE.md` **first**, before any other plan file.
2. Read §1 `Status`:
   - `OPEN` — a unit was claimed and may be half-written. Read §6, then finish or
     revert it before starting anything new. When WIP commits are on and `HEAD`
     is a `wip:` commit, that commit *is* the in-flight work: its diff is the
     authoritative record of what got written, §6 says why it stopped.
   - `none` — nothing in flight. Open the unit named in §1 `Next action:`.
3. Verify reality before editing: run the gate commands in `STATE.md` **§3** and
   compare with what §1, §7, and §11 claim. The file describes intent; the repo
   is the truth. Fix the file when they disagree.
4. Read only the file §1 points at: the phase file at the named sub-phase, or the
   verify report for a correction. Read `overview.md` only when `STATE.md` flags
   missing design context.

**Open a unit — before touching code, mandatory:** set `STATE.md` §1 `Type`,
`ID`, `Status: OPEN`, `Intent`, `Next action:`, `Assigned`; set §6 to `claimed —
nothing written yet`; bump the header timestamp. Only then edit anything.

**Close a unit — after its gates are green, mandatory:** append the §4 ledger
row; reset §6 to `none — tree consistent`; update §5 files touched, §7
verification results, §8 runtime deviations, §9 blockers, §10 dead ends worth not
retrying, and the §11 progress board; set §1 to the next unit with
`Status: none`; bump the timestamp. When WIP commits are on, commit the closed
unit now — code, tests, state, docs, ledger in one commit — and record its sha in
the §4 row instead of `uncommitted`. Only then start the next unit.

**Interrupted mid-unit — a session ending or context about to be cleared:** leave
§1 `OPEN` and flush §6 with exactly what is half-done — files written, edits
still pending, temporary code to remove. `OPEN` with an empty §6 is an execution
bug. When WIP commits are on, also commit that half-done state as
`wip(<id>): <what remains>` so the next session inherits an inspectable diff
rather than a description of one.

A unit is not `DONE` until gates are green **and** it is closed in `STATE.md`.

---

## Coherence contract (every mode, no exceptions)

The plan folder must always tell the truth about the repository. **Whatever
command is invoked, it leaves the folder coherent**: `plan` creates it,
`execute` / `task` / `bug` keep it in sync with the code they write, `verify`
records what it found and the status of every finding. A later `verify` reads
only these files: whatever is not written here becomes an unexplained diff and
is reported as a finding. Updating them is part of the work, not paperwork after
it.

The audit trail is part of the contract: `verify/index.md` and its reports are
written by `verify`, their statuses updated by `execute verify` when corrections
land. A finding never changes status without evidence, and never disappears.

When **every** unit of work closes — a sub-phase, a task, a bug fix, an audit, a
correction — update:

1. **`STATE.md`** — close the unit per the session protocol: §1 set to the next
   unit with `Status: none`, §4 ledger row appended with the unit's `Type` and
   `ID`, §5 files touched, §6 back to `none — tree consistent`, §7 verification
   results, §8 runtime deviations, §9 blockers, §10 dead ends worth not retrying,
   §11 progress board, header timestamp.
2. **The ad-hoc ledgers** — `tasks.md` for `task`, `bugs.md` for `bug`, in the
   plan folder. Every out-of-plan change gets an entry with a stable ID
   (`T-A001`, `B-A001`) — this is what tells a later audit that a diff was
   intentional, and it carries the detail the one-line §4 ledger row cannot.
   Templates: `references/templates-ledger.md`.
3. **`README.md`** — whenever user-visible behavior changed (flags, commands,
   config, defaults, limits, error messages). User guide only, no implementation
   detail; same rules as the per-phase README deliverable.
4. **`verify/index.md`** — when the work closes, reopens, or invalidates a
   finding from a previous audit, update its status (`FIXED` with evidence,
   still `OPEN`, `ACCEPTED`, `OBSOLETE`) and mirror it in the report file. Work
   that silently fixes a known finding makes the register lie.
5. **The plan itself, when the change invalidates it** — usually skipped, and
   the one that breaks later phases:
   - a `D*` decision superseded → add a new `D*` row in `overview.md` marked as
     superseding the old one, with reason and date; never edit history away
   - an `I-*` invariant added, dropped, or reinterpreted → update it and name the
     regression test that now guards it
   - a not-yet-executed sub-phase whose files, anchors, symbols, or assumptions
     no longer hold → update that phase file so it stays executable by a weak
     implementer with no context, and note the edit in `STATE.md` §8
   - work that made a planned sub-phase unnecessary → mark it `SKIPPED` in
     `STATE.md` §11 with the reason, never delete the row
   - new work the plan should own going forward → add it as a sub-phase in the
     right phase file rather than leaving it only in a ledger
   - a test ID (`T-*`) added, renamed, or removed → update the `STATE.md` §11
     test table and the phase file that names it

**Consistency rule:** after any of these modes finishes, running
`/plan-execute-verify verify` must produce **no finding caused by the work just
done**. If the audit would flag it, the coherence updates are incomplete —
finish them before reporting done.

**Ledger IDs.** `T-A<NNN>` for tasks, `B-A<NNN>` for bugs, zero-padded, assigned
by reading the highest existing ID in the ledger and adding one. Never reused,
even after a revert.

**Ad-hoc work without a plan (`docs/plans/000_adhoc/`).** With no plan folder in
the repo, `task` and `bug` write into `000_adhoc`, a **ledger-only folder**:
`tasks.md` and `bugs.md` and nothing else — no `overview.md`, `STATE.md`, or
phase files. There the checklist reduces to items **2** (ledger entry) and **3**
(`README.md` when behavior is user-visible), plus the tests and the repo's own
gate commands. Items 1, 4, 5 do not apply: there is no plan or
state file to keep in sync, and `verify` never audits `000_adhoc` because it is
not a plan. Once a real plan exists, new `task` / `bug` work attaches to that
plan folder and the full checklist applies again; existing `000_adhoc` entries
stay where they are.

**Commits.** By default no mode commits on its own: gates run on the working tree,
the work is reported, and committing is the user's call. The ledger and
`STATE.md` §4 `Commit` column record the sha when one exists and `uncommitted`
otherwise — a truthful `uncommitted` is never a defect, a stale sha is.

**With `--wip-commit` enabled** the modes that write production code commit at
two points, and only locally:

| Point | Message | Gates |
|-------|---------|-------|
| unit **closed** | `<type>(<id>): <intent>` — e.g. `sub-phase(1.1): add tenant column`, `task(T-A004): add --json flag`, `bug(B-A002): fix exit code on missing config`, `correction(V001-C2): assert Retry-After` | green |
| session **interrupted** mid-unit | `wip(<id>): <what remains>` | **red or not run** |

- **The commit is the unit.** Close the unit first — code, tests, `STATE.md`,
  `README.md`, the ledger — then commit all of it together. One commit therefore
  contains a complete, gate-green unit, and the `wip:` variant contains a
  self-describing interruption (§1 still `OPEN`, §6 spelling out what is pending).
- **Stage explicitly, never `git add -A` or `commit -a`.** Stage only the files
  the unit touched (`STATE.md` §5) plus the plan files it updated. Unrelated dirty
  files in the tree are left alone and reported, never swept into the unit.
- **Never push.** Local commits only; pushing stays the user's call, always.
- **Commit on the current branch, whatever it is** — no branch check, no branch
  creation. State in one line which branch you are committing to, so the user
  sees it when it is the default branch.
- **A `wip:` commit holds code that does not pass the gates.** On resume, if
  `HEAD` is a `wip:` commit, that *is* the in-flight work: finish it and `amend`
  into the proper close commit, or revert it. Amend only while the commit exists
  nowhere but locally; if it already reached a remote, add a new commit instead
  and say so.
- Follow the repository's existing commit-message convention when it has one;
  the shapes above are the fallback.

---

## Token discipline (your own execution, every mode)

- Recon and evidence gathering go to **one batched exploration agent** returning
  `path:line — fact` lines — never whole files, whole diffs, or file dumps into
  your own context. Ask for the specific anchors the plan named. Add agents only
  when one cannot hold the search.
- Don't re-read what a subagent already summarized. Trust the anchors.
- External doc research is **batched into the recon step and answers closed
  questions only**: one line per fact plus a URL, never documentation pages, and
  never an area the plan does not touch. The `References` table exists so nobody
  searches the same thing twice.
- Write the plan **once**, in the file. No verbose in-chat drafts.
- Conversational replies stay terse. Phase files and the verify report are the
  only long outputs, and each is written once; `overview.md` must stay small.
- `STATE.md` is medium-sized and **bounded**: one line per ledger entry, no code
  dumps, no narrative. The only verbatim text allowed is failing gate/test
  output. It buys back far more than it costs — a resumed session that reads it
  skips re-exploration entirely.

### Cache discipline

- Read each reference **at most once**, early; never re-read mid-run — re-reads
  bust the cached prefix and re-bill the file.
- Read only the reference files this run needs: the mode's operating manual, and
  the others when that manual calls for them.
- Prefer **fewer, larger agents** over many small ones: each agent is a fresh
  context, so every spawn re-pays setup.
- **Do NOT read `references/worked-example.md` during a run.** Learning aid only;
  `output-template.md` already gives the skeleton you write from.

---

## Reference files

Per-mode operating manuals — read the one for the resolved mode:
- `references/mode-plan.md` — the A → F planning workflow and plan-mode output
  contract.
- `references/mode-execute.md` — E1 → E5, including `execute verify`.
- `references/mode-taskbug.md` — `task` and `bug`.
- `references/mode-verify.md` — V1 → V5 and the report contract.

File skeletons — **always** open the one for the files you are about to write:
- `references/output-template.md` — the three plan files (`overview.md`,
  `phase_NN.md`, `STATE.md`). Plan mode.
- `references/templates-ledger.md` — `tasks.md` and `bugs.md`. Task and bug modes.
- `references/templates-audit.md` — the verify report and `verify/index.md`.
  Verify mode, and `execute verify` when it re-statuses findings.

Shared, read when the mode's manual calls for them:
- `references/agent-roster.md` — positional responsibilities, delegation rules,
  dispatch and recon tasking patterns for configured agents.
- `references/token-economy.md` — concrete token-minimization tactics.
- `references/quality-checklist.md` — the pre-return gate for every mode. Run it.
- `references/worked-example.md` — learning aid only. **Do not read during a
  run.**
