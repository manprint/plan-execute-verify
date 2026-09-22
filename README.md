# plan-execute-verify

A skill for onboarding repositories, planning, implementing, and checking work across phases
and sub-phases. A strong agent specifies the design and reviews the result;
less capable agents can implement even complex changes from explicit contracts,
numbered steps, and test expectations.

Plans carry their own state, so work can continue in a new session or with a
different model. Reliability and recoverability take priority over saving tokens.

## Quick start

On an unfamiliar repository, or when returning after a break, start with:

```text
/plan-execute-verify onboard
```

It maps the project, summarizes any existing work, and suggests the next command
without running it. This step is optional when you already have enough context.

To start a new development, ask the strong agent to create a plan. Replace agent
names with identifiers supported by your host:

```text
/plan-execute-verify full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku add per-user rate limits; preserve existing behavior when disabled
```

Planning creates a numbered folder such as
`docs/plans/003_plan-RateLimit/`. It does not implement or commit anything.
The option and roster are saved for execution.

Then execute that plan:

```text
/plan-execute-verify execute 003
```

The saved `full-autonomous:true` applies. The executor progresses through the
plan, obtains required strong-agent reviews, and commits every completed
sub-phase and phase locally on the current branch.

Audit the result separately:

```text
/plan-execute-verify verify 003
```

If the audit finds problems, apply its correction plan explicitly:

```text
/plan-execute-verify execute verify
```

The examples use slash-command notation. If your host invokes skills through a
different interface, select this skill and pass the same options and arguments.

## Choose the mode

| Command after the skill name | Use it for | What it changes |
|------------------------------|------------|-----------------|
| `onboard [plan]` | Understand an existing repository or recover context and the next step | Only docs/onboarding.md; no code, plan-state changes or commits |
| `plan <feature>` or `<feature>` | Design a feature, refactor, or migration | Plan files only |
| `execute [plan] [phase or sub-phase]` | Implement an existing plan | Code, tests, docs, and plan state |
| `task <description>` | One small change | Requested change and its ledger |
| `bug <description>` | One defect | Reproduction, regression test, fix, and ledger |
| `verify [plan]` | Audit implementation against the plan | Audit reports and state; no code fixes |
| `execute verify [plan] [report ID]` | Apply audit corrections | Selected corrections and affected plan state |

The first word after options selects the mode when it is `onboard`, `plan`,
`execute`, `task`, `bug`, or `verify`. Otherwise it starts a planning description.
For a feature whose name begins with a mode word, use the explicit Plan form:
`/plan-execute-verify plan task queue for background jobs`.
Missing arguments or invalid selectors never silently switch modes.

## Onboarding: first visit or returning project

Run from the target repository:

```text
/plan-execute-verify onboard
/plan-execute-verify onboard 003
/plan-execute-verify onboard docs/plans/003_plan-RateLimit
```

The optional selector focuses an existing plan by number, unique name or path;
it does not accept phase/report selectors. Without it, Onboard inventories the
repository and discovered plans/ledgers. Multiple plausible work streams require
a choice; the highest plan number is not automatically the work to resume.

**First visit, no skill history:** the agent maps the project's purpose,
components, entrypoints, stack/resolved versions, conventions, principal flows,
test locations, command definitions and relevant existing changes. It identifies
uncertainty and provides an ordered reading path for the next agent. Existing
software is not recreated, and TODOs are not converted into an approved roadmap.
Without a stated next goal, the agent asks what you want to achieve.

**Returning project:** the agent reads authoritative state, phase contracts,
task/bug ledgers and relevant audits, then compares the checkpoint with the actual
repository. The recap distinguishes recorded completion, evidence inspected and
tests actually rerun. It identifies open work, pending commits, blockers, saved
scope/settings and the next eligible step. Partial or legacy plans are reported
as such, not treated as a fresh project or silently repaired.

The output is a short recap, a source-backed context map in docs/onboarding.md,
and one next command or precise handoff. For example, a saved scope of sub-phase
1.2 can produce `/plan-execute-verify execute 003 § 1.2`, not a whole-plan command.
If that plan has saved `full-autonomous:true`, the recap explains that execution
would inherit automatic completion commits. Onboard does not run that command.
For an existing draft or interrupted ledger entry without a supported ID selector,
it gives a natural-language handoff with the exact path/ID rather than inventing
syntax such as `plan 003` or `bug B-A002`.

The map records observation date, branch/commit, coverage, source locators and
limitations. It is a dated orientation aid, not a second STATE.md or an audit.
Later modes recheck relevant sources and still perform their own recon/recovery;
Onboard is not mandatory before every command. Existing user content outside its
managed section is preserved; an unmarked file at the destination needs an agreed
merge/location rather than being overwritten.

Onboard never edits code, plans, runtime settings or rosters; rebuilds search indexes;
claims units; repairs state; switches branches; or commits. It inventories project
commands without executing scripts, installing dependencies or starting services
by default. Tests not run are explicitly labelled. Full-autonomous and WIP options
are accepted but do not change these boundaries and are not saved for later work.
An agent prefix selects the inspector only; it does not reassign an existing plan.
Prefer a strong agent for the first architecture map; ordinary refreshes can reuse
it, escalating uncertain interpretation. Internet research remains targeted,
usually during Plan, not a compulsory onboarding survey.

## Configure autonomy and commits

Options go **before the mode or feature description**, in any order with the
agent prefix:

```text
/plan-execute-verify full-autonomous:true execute 003
/plan-execute-verify full-autonomous:false execute 003
/plan-execute-verify full-autonomous:true --wip-commit execute 003
/plan-execute-verify full-autonomous:false --no-wip-commit execute 003
```

| Option | Effect |
|--------|--------|
| `full-autonomous:true` | Continue until the selected scope is complete or genuinely blocked; commit verified operational completions |
| `full-autonomous:false` | Normal execution; may hand off at a clean unit boundary; adds no completion commits |
| `--wip-commit` | Commit completed code units and save interrupted units as WIP commits |
| `--no-wip-commit` | Disable WIP behavior; does not disable completion commits enabled by full autonomy |

Default: `full-autonomous:false`, WIP off. Booleans are literal `true` or
`false`; `full-autonomous:yes` is rejected.

Settings resolve independently:

1. An explicit option in the current invocation.
2. The selected plan's saved setting in STATE.md.
3. The default.

Both settings persist across sessions. To turn off all automatic commits, specify
both `full-autonomous:false --no-wip-commit`. Without a plan, task/bug options
apply only to that invocation and are recorded in the ad-hoc ledger.
Exception: Onboard never persists options or changes a plan's saved configuration.
Both boolean values mean inspection only; neither full autonomy nor WIP commits
its context document or starts the recommended next action.

### Which commits are created?

| Full autonomous | WIP | Completed code units | Completed phases | Interrupted work | Completed audit |
|-----------------|-----|----------------------|------------------|------------------|-----------------|
| false | off | No | No | No | No |
| false | on | Yes | No separate phase commit | Yes | No |
| true | off | Yes | Yes | No | Yes, artifacts only |
| true | on | Yes | Yes | Yes | Yes, artifacts only |

A code unit is a sub-phase, task, bug fix, or audit correction. A phase gets its
own completion commit after all sub-phases, integration checks, documentation,
and strong-agent review. Planning and Onboard never commit.

Examples of commit subjects:

```text
sub-phase(1.2): complete quota validation
phase(1): complete limiter integration and review
task(T-A004): complete --json output
bug(B-A002): fix missing-config exit code
correction(V001-C1): complete Retry-After assertion
verify(V001): complete audit; FAIL, 1 blocker
```

The repository's commit-message convention is respected. All commits are local
and use the current branch, including `main` if that is your current branch.
The skill does not create/switch branches or push. It preserves unrelated edits,
including changes in the same file, and checks staged content before committing.

An autonomous audit can commit a report with verdict FAIL: that records a
completed inspection, not completed or verified implementation. It never applies
its proposed code fixes automatically.

WIP commits are separately labelled incomplete. Full autonomy without WIP does
not commit broken or unreviewed work at interruption.

## Select exactly what should run

```text
/plan-execute-verify execute 003
/plan-execute-verify execute RateLimit
/plan-execute-verify execute docs/plans/003_plan-RateLimit
/plan-execute-verify full-autonomous:true execute 003 phase_02
/plan-execute-verify full-autonomous:true execute 003 § 1.2
/plan-execute-verify execute verify V002
/plan-execute-verify execute verify 003 V002
```

A phase/sub-phase selector is a limit, even with full autonomy. Selecting 1.2
does not authorize the executor to continue into 1.3. Dependencies still apply.

Phase files are numbered from 01; logical phases start at 0. Thus
`phase_02.md` contains logical phase 1 and sub-phases such as 1.1 and 1.2.

For execution/audit selection without a plan selector, the skill uses the highest
numbered real plan unless multiple active plans make the target ambiguous. The reserved `000_adhoc`
folder is never an execute/verify target. Audit corrections use the selected or
unambiguous active plan and the newest report unless a report ID is provided.
To disambiguate, use `execute verify 003 V002` or replace `003` with a plan path.

## Configure the agents

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku <feature>
/plan-execute-verify agent-1:gpt5-6-sol,agent-2:gpt5-6-luna <feature>
/plan-execute-verify agent:my-model <feature>
```

| Position | Responsibility |
|----------|----------------|
| agent-1 | Strong planner and supervisor; resolves technical surprises and reviews every phase |
| agent-2 | Primary implementer |
| agent-3 and later | Recon and assigned implementation, including complex work when fully specified |
| agent:<name> | One agent performs everything; review is explicitly self-review |

Names are host-specific identifiers, not guaranteed available models. Numbered
assignments must start at 1 without gaps or duplicates. Without an explicit
prefix, reuse the saved roster; a new plan defaults to Opus/Sonnet/Haiku for
compatibility. Use an explicit roster on other hosts.
A single numbered entry (`agent-1:<name>`) is equivalent to `agent:<name>`.

Opening the plan in another model does not silently change its assignments.
An explicit prefix overrides the roster and updates remaining assignments.
In Onboard only, a prefix applies to the inspection and never changes assignments.

The weakest worker may implement complex logic, but the strong planner must
already specify the algorithm, interfaces, synchronization, boundary cases,
tests, and acceptance criteria. Missing design returns to the strong supervisor.

## Continue in another session or model

Both execution styles use the same plan files:

| Style | How it works |
|-------|--------------|
| Successive sessions/models | Each session resumes from STATE.md and the named step; ownership transfers after the previous session stops |
| Coordinator with subagents | The coordinator owns state, plan edits, reviews, and commits; workers receive bounded implementation assignments |

For orientation in a fresh session without starting work:

```text
/plan-execute-verify onboard 003
```

To request actual resumption instead:

```text
Use plan-execute-verify to resume docs/plans/003_plan-RateLimit.
Read STATE.md first and preserve its scope, settings, roster, and checkpoint.
```

The executor checks the real diff and tests before trusting a recorded checkpoint.
It records sub-phase status, completed step IDs, exact next action, pending edits,
and verification evidence. Stable commit identities prevent a resumed session
from duplicating a completion commit.

The strong supervisor remains available for required reviews and unexpected
technical decisions. It may revise implementation details automatically while
preserving agreed requirements and scope. Changed product requirements or new
external authority still require you.

If the host cannot invoke that supervisor, the executor saves a precise handoff
for a strong-model session; it cannot manufacture that capability. Full autonomy
does not automatically launch a new host session after the current one ends.

## What makes a plan ready?

Every sub-phase contains exact prerequisites, files/symbols, local design
contracts, numbered steps and expected results, checkpoints, named tests with
assertions, required reviews, and a completion condition.

The strong planner checks the critical source contracts and performs a cold-read
validation before marking the plan READY. Unresolved design, contradictory
requirements, or an undefined acceptance test prevent READY. A blocked draft is
labelled as such and is not presented as an executable plan.

During execution, failed or unavailable mandatory checks prevent completion.
A zero-test run is not verification. Workers cannot weaken tests to get green.
The supervisor resolves technical plan defects and records revisions and affected
dependencies. These checks reduce ambiguity; they do not replace actual testing
and review of the resulting software.

## Internet research: where it fits

Plan first inspects the repository, then performs targeted internet research
before choosing the design and writing implementation sub-phases. The strong
planner investigates concrete questions: API behavior, compatible versions,
architectural alternatives, migration constraints, and security assumptions.
Entirely internal, established changes can record that research is not needed.

No new option is required. To request a particular focus, include it in the
planning description, for example:

```text
/plan-execute-verify plan add resumable uploads; investigate the existing storage provider's official guarantees and compare retry strategies before choosing the design
```

The planner checks primary sources for the versions actually used and records
questions, URLs/provenance, version/dates, conclusions, and decision impact in
overview.md. Facts, inferences, and local experiments are labelled separately.
The phase files contain the resulting concrete rules and tests: workers do not
receive only links they must interpret or design questions they must settle.

Research stops when the necessary questions are answered and the resulting
decisions are explicit. Unresolved required facts prevent READY; unavailable
browsing is disclosed, not treated as successful verification. Applicable local
primary documentation/source can supply evidence, but cannot establish freshness
it does not have. Private code, secrets, and identifying data stay out of queries.

During Execute, Task or Bug, research is reopened only for relevant new evidence,
changed versions, or missing/contradictory assumptions; design revisions stay with
the supervisor. Verify checks relevant claims and records evidence or limitations
without redesigning or fixing the code. `full-autonomous:true` changes neither
these boundaries nor the requirement for sufficient evidence.

## Files you will see

Onboard writes the repository-level docs/onboarding.md, separate from numbered
plans. It creates neither a plan folder nor an ad-hoc ledger just to store context.
Implementation progress continues to live only in the relevant STATE.md/ledger.

```text
docs/plans/003_plan-RateLimit/
  overview.md       Goal, decisions, research evidence, interfaces, phase map
  phase_01.md       Detailed sub-phases for logical phase 0
  phase_02.md       Detailed sub-phases for logical phase 1
  STATE.md          Readiness, scope, settings, checkpoints, evidence, progress
  tasks.md          Out-of-plan tasks, created when needed
  bugs.md           Defects and fixes, created when needed
  verify/
    index.md        Reports and current finding statuses
    verify_001_<date>.md
```

With no plan, task/bug work uses `docs/plans/000_adhoc/` and keeps its recovery
information in the ledger entry itself. There are no fake phase or STATE files.

Audit verdicts are PASS, PASS WITH FINDINGS, FAIL, or INCOMPLETE. Missing required
evidence produces INCOMPLETE unless confirmed major/blocker findings already
justify FAIL. Reports retain their historical verdict after corrections.
An audit may finish while its correction plan is BLOCKED by a missing decision;
those corrections cannot execute until their contracts are validated as READY.

## Install or update

Clone this repository into a stable location:

```bash
git clone https://github.com/manprint/plan-execute-analyze.git plan-execute-verify
cd plan-execute-verify
```

For the included Claude installation helper:

```bash
./install-claude.sh
```

It links this checkout into `~/.claude/skills/plan-execute-verify`.
To use another destination, set `CLAUDE_SKILLS_DIR` to the desired skills
directory. The helper refuses to overwrite an existing non-symlink directory.

For another skill-capable host, register the complete folder using that host's
installation mechanism. Keep SKILL.md and references/ together. A symlink tracks
this checkout; a copied installation must be refreshed after updates. Model
availability and the mechanism for starting subagents come from the host.

## Maintainer references

[Skill entrypoint](SKILL.md) · [Execution contract](references/execution-contract.md) ·
[Plan templates](references/output-template.md) ·
[Onboarding manual](references/mode-onboard.md) ·
[Onboarding template](references/template-onboarding.md) ·
[Research protocol](references/research.md) ·
[Worked example](references/worked-example.md) ·
[Quality checklist](references/quality-checklist.md)

### Validation scope (2026-09-22)

Skill structure validation, static local-link checks, and `git diff --check` pass.
These checks include onboarding and the research protocol/templates; the research
workflow has not yet been exercised end-to-end with live sources.
Onboard has not yet undergone an independent end-to-end agent evaluation.

The execution protocol was checked separately before the research addition:
An independent scenario review checked scope limits, interrupted completion,
disabled commits, audit suspension, and missing-design escalation.

An isolated CLI exercise produced two sub-phase commits and one phase-closure
commit, with 10 passing tests and 4 checked documentation examples. Repeating
execution left HEAD and STATE.md unchanged, with no duplicate commit. Another
agent authored its draft; after a service usage limit interrupted that agent,
the primary agent cold-started from the files and completed execution locally.

This validates the protocol on a small fixture, not the performance of Luna,
Sonnet, or Haiku on complex projects. Those models have not been benchmarked
here; detailed contracts and review gates cannot guarantee error-free output.

## License

MIT — see [LICENSE](LICENSE).
