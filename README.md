# plan-execute-verify

[Italiano](README_IT.md) · [Usage examples](USAGE_EXAMPLE.md)

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
The option and roster are saved for execution. Without `executor-power`, the
plan targets `low` executors: the finest, most detailed decomposition, which
also costs the most planning effort. Pass `executor-power:medium` or
`executor-power:high` when every implementer is more capable
([below](#tell-the-planner-how-capable-the-executors-are)).

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
| `plan <feature>` or `<feature>` | Design a feature, refactor, or migration | Plan files only; options become plan defaults, and `executor-power` sets the plan's detail |
| `execute [plan] [phase or sub-phase]` | Implement an existing plan | Code, tests, docs, and plan state |
| `task <description>` | One small change | Requested change and its ledger |
| `bug <description>` | One defect | Reproduction, regression test, fix, and ledger |
| `verify [plan] [phase, sub-phase, or entry]` | Audit the whole plan or a narrower scope, including `000_adhoc` entries | Audit reports and state; no code fixes |
| `execute verify [plan] [report ID]` | Apply audit corrections | Selected corrections and affected plan state |
| `resume [plan] [unit ID]` | Continue interrupted or saved work exactly where it stopped | Whatever the resumed unit/scope changes; never its scope or settings |
| `handoff [--deadline=dd-mm-yyyy_hh_mm]` | Stop the running work gracefully, now or by a deadline | State checkpoint, one handoff commit for code work, and the resume command |

[USAGE_EXAMPLE.md](USAGE_EXAMPLE.md) shows every mode with no option, each
option alone, the four autonomy/WIP pairs, both agent-list forms, and a
deadline: the command, what it does, and the complete settings that run uses.
It is also available in Italian: [USAGE_EXAMPLE_IT.md](USAGE_EXAMPLE_IT.md).

The first word after options selects the mode when it is `onboard`, `plan`,
`execute`, `task`, `bug`, `verify`, `resume`, or `handoff`. Otherwise it starts
a planning description. For a feature whose name begins with a mode word, use
the explicit Plan form: `/plan-execute-verify plan task queue for background
jobs`. Missing arguments or invalid selectors never silently switch modes.
A request whose first word asks to continue recorded work, such as
`/plan-execute-verify continue 003`, is never a new plan: it runs as
`resume 003`, or the agent asks what you meant. Options go before the mode; if a
description contains an option, such as a trailing `--deadline=…`, the agent
asks before starting. Only `handoff` also accepts the deadline after it.

Task and bug take no selector. They attach to a plan only when the request names
it (number, feature name, or path) or clearly changes an active plan's scope,
contracts, or files; otherwise they use `docs/plans/000_adhoc/`. Several
candidate plans require your choice, and a completed plan is used only when
named. Neither mode changes the plan's saved execution scope.

Before any code edit, agent-1 writes or validates a short mini-plan in the
ledger entry; for a bug it comes after the reproduction and root cause. With
`full-autonomous:false`, the default, the run then stops with the entry
`PROPOSED` and shows the mini-plan. Edit it in the file if you want, then
approve it with a reply in the same session or with `/plan-execute-verify resume
000_adhoc T-A004`: the entry ID is required, and a bare `resume` never approves.
Changed files or your edits are revalidated before coding, and the run approves
only that entry. To reject a proposal, say so in the same session or set its
status to `WITHDRAWN` with a reason in the ledger file. With
`full-autonomous:true` there is no stop, but the validation still runs, so a
weak session that cannot reach agent-1 blocks before writing code. No setting
gives a task or bug with neither an approval stop nor completion commits:
`false` stops, `true` commits.

## Onboarding: first visit or returning project

Run from the target repository:

```text
/plan-execute-verify onboard
/plan-execute-verify onboard 003
/plan-execute-verify onboard docs/plans/003_plan-RateLimit
```

The optional selector focuses an existing plan by number, unique name or path;
it does not accept phase/report selectors or `000_adhoc`. Without it, Onboard
inventories the repository and discovered plans/ledgers. Multiple plausible work
streams require a choice; the highest plan number is not automatically the work
to resume.

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
and one next command or precise handoff. For example, a saved execution scope of
sub-phase 1.2 produces `/plan-execute-verify resume 003`, which continues that
scope, not a whole-plan `execute 003`.
If that scope or plan has saved `full-autonomous:true`, the recap explains that
resuming would inherit automatic completion commits. Onboard does not run that
command. For an interrupted ledger entry, audit, or draft it suggests `resume`
with the exact ID, such as `/plan-execute-verify resume 000_adhoc B-A002`, never
invented syntax such as `plan 003` or `bug B-A002`.

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
| `full-autonomous:false` | Continue through the current phase and stop after its closure (`resume` continues); Task and Bug stop once, for approval of the mini-plan; adds no completion commits |
| `--wip-commit` | Commit progress: completed code units, phase closures, and a rolling WIP commit at each recovery checkpoint |
| `--no-wip-commit` | Disable WIP behavior; does not disable completion commits enabled by full autonomy |
| `--deadline=dd-mm-yyyy_hh_mm` | Every mode: hand off gracefully by this local time; this run only ([Stop gracefully](#stop-gracefully-handoff)) |

Default: `full-autonomous:false`, WIP off. Booleans are literal `true` or
`false`; `full-autonomous:yes` is rejected.

Full autonomy can also be requested as the last token of an `execute`,
`execute verify`, `resume`, or `verify` command
(`/plan-execute-verify execute 003 full-autonomous:true`) or in plain words in
your message ("full autonomous", "in piena autonomia", "don't stop until
done"): both count as the explicit option. Under full autonomy the agent closes
a unit, prints one progress line, and opens the next one in the same turn. It
stops only when the scope is complete, at a real blocker, at your stop or
`handoff`, or when the host ends the session; it never stops after a sub-phase
to ask you to type `resume`. Permission modes such as bypass or yolo do not
change this.

Settings resolve independently:

1. An explicit option in the current invocation.
2. The option given with the saved execution scope, while that scope continues.
3. The plan default in STATE.md, set by Plan.
4. The default.

`executor-power` is not a runtime setting and does not follow this order: only
Plan accepts it, it is stored with the plan, and every other mode rejects it
([below](#tell-the-planner-how-capable-the-executors-are)).

Options given to Plan become plan defaults. Options given to Execute or Execute
verify belong to the scope they start: they survive resume and new sessions of
that scope and lapse when a different selector replaces it, so a one-off
autonomous run never changes later executions. To turn off all automatic
commits, specify both `full-autonomous:false --no-wip-commit`; only a handoff
still makes its one commit. Task, Bug,
Verify, and Resume use explicit options for that invocation only and record them
in their ledger entry, audit report, or resumed unit, even when attached to a
plan; they never change its saved settings. Onboard never persists options or
changes a plan's saved configuration. Both boolean values mean inspection only;
neither full autonomy nor WIP commits its context document or starts the
recommended next action.

### Which commits are created?

| Full autonomous | WIP | Completed code units | Completed phases | WIP at checkpoints | Completed audit |
|-----------------|-----|----------------------|------------------|------------------|-----------------|
| false | off | No | No | No | No |
| false | on | Yes | Yes | Yes | No |
| true | off | Yes | Yes | No | Yes, artifacts only |
| true | on | Yes | Yes | Yes | Yes, artifacts only |

A code unit is a sub-phase, task, bug fix, or audit correction. A phase gets its
own completion commit after all sub-phases, integration checks, documentation,
and strong-agent review, and the finished plan gets its own completion commit
after the last phase, once the final gates pass (the `PLAN` closure). Planning and Onboard never commit. When work or plan
files stay uncommitted, the final report says so and suggests the exact commit
command without running it: untracked plan files can be lost to `git clean` or a
branch switch.

Commit subjects are fixed, so `git log --oneline` shows which plan, phase, and
unit closed (plan 003 here):

```text
sub-phase(003/1.2): sub-phase 1.2 of phase 1 complete — quota validation
phase(003/P1): PHASE 1 COMPLETE — limiter integration; gates and review passed
plan(003): PLAN 003 COMPLETE — RateLimit; 3 phases, final gates passed
task(003/T-A004): task T-A004 complete — --json output
bug(000_adhoc/B-A002): bug B-A002 fixed — missing-config exit code
correction(003/V001-C1): correction V001-C1 complete — Retry-After assertion
verify(003/V001): audit V001 complete — verdict FAIL, 1 blockers
wip(003/1.2): WIP sub-phase 1.2 — at S3
handoff(request-by-user): 003/1.2 stopped before S3
```

The body holds at most six short lines (plan, phase, unit, gates, review, next)
before the PEV trailers.

A handoff makes one handoff commit for code work, whatever the settings in the
table above, whenever there is code work to commit; if a hook rejects it, the
work stays uncommitted and the report shows the commit command
([Stop gracefully](#stop-gracefully-handoff)).

If a hook or commitlint rejects the type, only the type is mapped to an allowed
one (for example `chore`); the scope and description stay. All commits are local
and use the current branch, including `main` if that is your current branch.
The skill does not create/switch branches or push. It preserves unrelated edits,
including changes in the same file, and checks staged content before committing.

An autonomous audit can commit a report with verdict FAIL: that records a
completed inspection, not completed or verified implementation. It never applies
its proposed code fixes automatically.

WIP commits are separately labelled incomplete: with WIP on, each recovery
checkpoint of an open unit updates one rolling `wip(<plan>/<unit>)` commit, so a crash
loses at most the work since that checkpoint. Full autonomy without WIP does not
commit broken or unreviewed work at interruption. Commits stage only the unit's
own hunks without interactive Git, keep repository hooks active (never
`--no-verify`; a failing hook blocks the unit like a failed gate), and put the
PEV identity trailers in the final trailer block beside any `Co-Authored-By`
lines.

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
does not authorize the executor to continue into 1.3 or to run the phase closure
P1; run P1 with a phase or plan selector. Dependencies still apply. The selected
scope is saved: `resume` continues it, and task, bug, or audit runs in between do
not replace it. An explicit `execute` or `execute verify` that would replace a
running or blocked saved scope with a different one asks you first.

Phase files are numbered from 01; logical phases start at 0. Thus
`phase_02.md` contains logical phase 1 and sub-phases such as 1.1 and 1.2.

Without a plan selector, Execute, Execute verify, and Verify use the only active
real plan, or the highest numbered one when none is active; with several active
plans, the agent asks. The reserved `000_adhoc` folder is never chosen by
default and is never an Execute or Execute verify target (its audit corrections
run as Task/Bug); Verify and Resume accept it only when named. Audit corrections
use the selected or unambiguous active plan and the newest report unless a
report ID is provided. To disambiguate, use `execute verify 003 V002` or replace
`003` with a plan path.

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

Opening the plan in another model does not silently change its assignments. In
Plan, Execute, and Execute verify an explicit prefix overrides the roster and
updates remaining assignments. In Task, Bug, Verify, and Resume it applies to
that run only; in Onboard it applies to the inspection and never changes
assignments.

If the assigned agent cannot run a unit, only an agent with an equal or lower
position number may substitute (agent-1 for agent-2, not the reverse), and the
substitution is recorded. Supervisor reviews and plan revisions belong to agent-1
alone; otherwise the unit is blocked with a handoff. A model outside the roster
can coordinate but not implement. A review by the unit's own implementer is
labelled self-review.

The weakest worker may implement complex logic, but the strong planner must
already specify the algorithm (unless executors are `high`, below), interfaces,
synchronization, boundary cases, tests, and acceptance criteria. Missing design
returns to the strong supervisor.

### Tell the planner how capable the executors are

`executor-power:low|medium|high` is a Plan-only option that describes the least
capable implementer that will receive the plan's units: agent-2 and later
positions, or the single agent of `agent:<name>`. It sets how many sub-phases
the supervisor writes, how much detail they carry, and what the executor may
decide on its own.

```text
/plan-execute-verify executor-power:high agent-1:opus,agent-2:opus <feature>
/plan-execute-verify executor-power:medium agent-1:opus,agent-2:sonnet <feature>
```

| Level | Typical executors (examples only) | Resulting plan |
|-------|-----------------------------------|----------------|
| `low` (default) | Haiku, Luna | Usually 3–6 elementary, individually testable sub-phases per phase; mechanical steps with exact locations; every architectural choice, pattern, and best practice explicit; supervisor-verified code snippets for complex parts. The executor decides only how to locate code and details the plan expressly leaves open |
| `medium` | Sonnet, Terra, DeepSeek | Usually 2–4 detailed, testable sub-phases per phase; snippets only where prose cannot state a contract precisely. The executor also fills routine detail that changes no decision |
| `high` | Fable, Opus, Astra, Sol, Kimi K3 | Usually 1–3 larger outcome sub-phases per phase. The executor plans its own steps and decides the internal implementation |

The default is `low`, so a plan created without the option gets the finest
decomposition, which costs the most planning effort; a legacy plan that predates
the option counts as `low`. The skill never infers the level from model names:
choose it for the weakest implementer you will assign.

At every level agent-1 fixes requirements, public interfaces, invariants,
acceptance tests, and gates; a lower level adds detail, never weaker acceptance.
At `high`, in successive sessions the executor records its expanded steps in
STATE.md before editing; with a coordinator, the worker returns them with its
result and the coordinator records them. Internal decisions are recorded the
same way for agent-1's review at phase closure, and any contract change still
goes to agent-1.

The level is stored with the plan. Execute cannot change it, and every mode
other than Plan rejects the option. Task and Bug follow the attached plan's
level (`low` in `000_adhoc`), and audit corrections are written for it. If you
later assign an implementer weaker than the recorded level, the supervisor
recalibrates its units before dispatch. Known limitation: no command changes
the level of an existing plan, since that requires a supervisor plan revision
of the remaining units; choose the level when planning.

## Continue in another session or model

Both execution styles use the same plan files. The style is not an option:
each run uses the coordinator style when the host can start subagents running
the roster's models, and successive sessions otherwise, and records which.

| Style | How it works |
|-------|--------------|
| Successive sessions/models (recorded as `handoff`) | Each session resumes from STATE.md and the named step; ownership transfers after the previous session stops |
| Coordinator with subagents (recorded as `delegated`) | The coordinator owns state, plan edits, reviews, and commits; workers receive bounded implementation assignments |

For orientation in a fresh session without starting work:

```text
/plan-execute-verify onboard 003
```

To request actual resumption instead:

```text
/plan-execute-verify resume 003
/plan-execute-verify resume 003 1.2
/plan-execute-verify resume 000_adhoc B-A002
```

Resume first recovers interrupted work (an open unit, a pending completion
commit, an interrupted audit, a planning draft), then continues the saved
execution scope. It never widens that scope or changes saved settings; a resumed
unit keeps the settings it was opened with, unless you override them for that
run. A unit ID must name open, pending, blocked, or suspended work, or a
proposed task or bug, which naming it approves; a TODO unit is new work for
`execute`.

The executor checks the real diff and tests before trusting a recorded checkpoint.
Each unit's base is HEAD plus a working-tree snapshot, so a resume can separate
its edits from earlier uncommitted units and your own changes. It records
sub-phase status, completed step IDs, exact next action, pending edits, and
verification evidence. Stable commit identities prevent a resumed session from
duplicating a completion commit.

If a crashed session still holds ownership of the plan, your explicit
invocation on that plan lets a new session take over, but only when the state
file and working tree stay unchanged during its inspection; the takeover is
recorded. Otherwise it asks.

The strong supervisor remains available for required reviews and unexpected
technical decisions. It may revise implementation details automatically while
preserving agreed requirements and scope. Changed product requirements or new
external authority still require you.

If the host cannot invoke that supervisor, the executor saves a precise handoff
for a strong-model session; it cannot manufacture that capability. Full autonomy
does not automatically launch a new host session after the current one ends.

## Stop gracefully: handoff

Send `handoff` to a running session when you need to stop, or give it a
deadline:

```text
/plan-execute-verify handoff
/plan-execute-verify handoff --deadline=31-10-2026_17_30
/plan-execute-verify --deadline=31-10-2026_17_30 execute 003
```

The deadline uses `dd-mm-yyyy_hh_mm`, 24-hour time, in the local time of the
machine running the agent; a past deadline means "now". As a leading option it
works with every mode and applies to that run only. A stop request is never
rejected: `handoff` ignores any other option, agent prefix, or selector and says
so, and an invalid deadline there means "now". This mode is unrelated to the
successive-sessions execution style, which is also recorded as `handoff`.

Sent during a run, `handoff` stops it now and cancels an earlier deadline, while
`handoff --deadline=…` lets the run continue and replaces the earlier deadline.
Sent to an idle session, it targets the plan or ledger that session last
changed, or else the only one with unfinished or uncommitted work that no other
live session owns; with several candidates it asks you to choose.

The agent then:

1. Sets a stop latch in STATE.md and starts nothing new. It finishes the open
   unit only if that takes about 10 minutes, including its checks and review,
   and never opens the next one; otherwise it stops at the next step boundary
   and records commands it did not run.
2. Saves a checkpoint with the exact next action, marks the run `HANDOFF`, and
   releases the ownership it holds, so the next session continues without a
   takeover.
3. For code work (Execute, Execute verify, Task, Bug, and Resume of them) it
   makes one local commit, even when commits are disabled:
   `handoff(request-by-user): <plan>/<unit> stopped <stop point>`. It contains the open unit
   and any finished units still uncommitted, so STATE.md never claims work the
   commit lacks. Each unit's changes are staged separately, so edits you made
   between units stay out of the commit. Later commits append after it. Hooks
   still run: if one fails, the work stays uncommitted and the report shows the
   commit command. With nothing to commit, no commit is made. Plan and Verify
   only save their checkpoint and warn that their files are uncommitted; Onboard
   is simply rerun.
4. Reports the command that continues exactly where it stopped, such as
   `/plan-execute-verify resume 003` or
   `/plan-execute-verify resume 003 T-A004`, and stops: no tool call follows
   the report, even with `full-autonomous:true` and in bypass/yolo permission
   modes. Host automation (auto-continue, loops, hooks, a subagent finishing)
   does not restart work; only your next explicit command clears the latch.

With a deadline, the agent checks the clock before each unit, step, and long
command, avoids starting work that would end after it, and bounds long commands
with `timeout`. This is best effort: the agent sees a message only between tool
calls, cannot interrupt its own running call, and an idle session does not wake
up at a deadline. Set the deadline before the moment you really need the
machine, for example 17:30 when you switch it off at 18:00.

## After every run: Continue or Stop

Every run, in every mode and however it ends, closes its report with a Next
block, for example after a phase closure with commits disabled:

```text
Next
- Continue: `/plan-execute-verify resume 003` — runs sub-phase 2.1, the next unit of the saved scope
- Stop: `/plan-execute-verify handoff` — commits 1.1, 1.2, and P1, still uncommitted, in one handoff commit; then close the session
```

Continue is one exact command with real IDs and no options: recorded settings
travel with `resume`, while a new `execute` scope starts from the plan defaults
and is labelled as new, with the settings it will use. After a rejected command,
the corrected command keeps your valid options. When a decision is missing it
reads "answer …, then …"; when nothing follows it says why. Stop suggests
`handoff` only when open or uncommitted code work, a pending closure, or
ownership held by this session remains; otherwise it says there is nothing to
save.
Files a handoff never commits, such as a plan draft, an audit report, a proposed
task, or docs/onboarding.md, are listed with a suggested commit command. Both
lines are suggestions: the agent never runs them, even with
`full-autonomous:true`. [next-step](references/next-step.md) lists which command
applies in each situation.

## What makes a plan ready?

Every sub-phase has seven fields (Agent, Assignment, Files, Change, Unit tests,
e2e tests, Done) holding exact prerequisites, files/symbols, local design
contracts, numbered steps and expected results (outcome-level at executor power
`high`), named focused tests with assertions, required reviews, and a completion
condition. A phase groups coherent sub-phases around one integration result;
their number follows `executor-power` (more and smaller at `low`, fewer and
larger at `high`). Shared design appears once per phase, and documentation may
be part of an implementation unit.

The strong planner checks the critical source contracts and performs a cold-read
validation before marking the plan READY. Unresolved design, contradictory
requirements, or an undefined acceptance test prevent READY. A blocked draft is
labelled as such and is not presented as an executable plan.

During execution, failed or unavailable mandatory checks prevent completion.
A zero-test run is not verification. Workers cannot weaken tests to get green.
Sub-phases run focused validation; full gates run at phase closure. If a phase
gate or review fails, the closure never patches code: the responsible sub-phase
is reopened as a new attempt, or the supervisor revises the plan, and the phase
closure runs again. State is
opened and closed for each unit, with interim checkpoints only at recovery
boundaries such as handoff, risky operations, or blockers.
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
decisions are explicit. Unless the environment already authorizes network
access, Plan asks once before browsing, listing the sanitized questions, and
records your answer. Unresolved required facts prevent READY unless you
explicitly accept one as a known risk (ACCEPTED, with its guarding test);
unavailable browsing is disclosed, not treated as successful verification.
Applicable local primary documentation/source can supply evidence, but cannot
establish freshness it does not have. Private code, secrets, and identifying
data stay out of queries.

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
  STATE.md          Live state only: current unit, settings, open phase, pending records
  PROTOCOL.md       Static cold-start protocol for agents without this skill
  history.md        Append-only record of closed units (never read to resume)
  tasks.md          Out-of-plan tasks, created when needed
  bugs.md           Defects and fixes, created when needed
  verify/
    index.md        Reports and current finding statuses
    verify_001_<date>.md
```

With no plan, task/bug work uses `docs/plans/000_adhoc/` and keeps its recovery
information in the ledger entry itself. There are no fake phase or STATE files.

STATE.md stays small: at each closure the agent appends the evidence to
history.md and removes it from STATE.md; at each phase closure the phase
collapses to one board row. STATE.md records its format (`Format: pev-state
2`). A plan written by an earlier skill version is migrated automatically by
the first run that takes ownership, before any work (format 1: protocol text
moves to PROTOCOL.md, history to history.md). A plan already finished under the
earlier rules counts as complete: it gets no new PLAN closure or commit unless
you ask for one. `onboard` shows a plan's format and pending migrations without
changing anything; a plan newer than the installed skill is refused until you
update the skill.

Audit verdicts are PASS, PASS WITH FINDINGS, FAIL, or INCOMPLETE. A scoped
audit's verdict covers only its phase, sub-phase, or entry, never the whole
plan. Missing required
evidence produces INCOMPLETE unless confirmed major/blocker findings already
justify FAIL. Severity levels BLOCKER, MAJOR, and MINOR are defined in
[mode-verify](references/mode-verify.md). Reports retain their historical
verdict after corrections, and each correction's progress is tracked in STATE.md.
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
[Invocation rules](references/invocation.md) ·
[Plan templates](references/output-template.md) ·
[Onboarding manual](references/mode-onboard.md) ·
[Onboarding template](references/template-onboarding.md) ·
[Research protocol](references/research.md) ·
[Worked example](references/worked-example.md) ·
[Quality checklist](references/quality-checklist.md)

### Validation scope

The end-to-end checks below date from 2026-09-22 and predate later protocol
revisions: recovery-boundary checkpoints, gate staging and phase sizing,
working-tree snapshot unit bases, stale-ownership takeover, the saved execution
scope, phase-closure failure handling, agent substitution, audit severity
definitions, the resume mode, scoped verify, rolling WIP commits, executor
power, the handoff mode with `--deadline`, the task/bug approval gate, and the
Next block. Those revisions have been checked statically only; they have not
been re-exercised end to end. The Git commands for owned-hunk staging, including
the `--3way` fallback and a multi-unit handoff commit staged one patch per unit
that keeps user edits made between units out, and the deadline parsing were
exercised in scratch repositories only.

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
