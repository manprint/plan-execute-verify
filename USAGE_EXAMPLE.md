# plan-execute-verify — usage examples

[Italiano](USAGE_EXAMPLE_IT.md) · [README](README.md)

This guide shows every mode of `/plan-execute-verify` with every option, one
case at a time. Each case gives the command, what it does, what to expect, and
the complete settings that run uses, including the ones you did not type.

## How to read this guide

- **Modes** say what to do: `onboard`, `plan`, `execute`, `execute verify`,
  `task`, `bug`, `verify`, `resume`, `handoff`.
- **Options** go before the mode and change how it runs:
  `full-autonomous:true|false`, `--wip-commit`, `--no-wip-commit`,
  `executor-power:low|medium|high`, a list of agents, and
  `--deadline=dd-mm-yyyy_hh_mm`.
- Every mode has the same 15 cases: no option, each option alone, the four
  autonomy × WIP pairs (together they decide the commits), the three
  executor-power levels, the two forms of the agent list, and a deadline.
  Options combine freely: see [Combining options](#combining-options).
- Each case ends with **Settings for this run**: every setting, its value, and
  where the value comes from: *from your command*, *default*, *from plan 003*,
  or *from the resumed work*.

## The example setup

Every case starts from this same situation; no case changes it for the next one. All examples assume:

- Plan `003` (`docs/plans/003_plan-RateLimit/`) was created with no options, so
  its saved settings are the defaults: `full-autonomous:false`, WIP off,
  `executor-power:low`, and the default agents agent-1 Opus, agent-2 Sonnet,
  agent-3 Haiku.
- Plan 003 is being executed: an earlier `execute 003`, run with no options,
  stopped after a phase, so `resume 003` has work to continue.
- Plan 003 has one audit report, `V001`, with corrections ready to apply; a new
  audit gets `V002`.
- A new plan gets number `004`.
- The example tasks and bugs name no plan, so they go to the ad-hoc ledger
  `docs/plans/000_adhoc/`. It already holds tasks up to `T-A003` and bug
  `B-A002`, left open by an earlier session, so a new task gets `T-A004` and a
  new bug `B-A003`.
- `opus`, `sonnet`, `haiku`, and `my-model` stand for model names your host
  supports.
- `--deadline=31-10-2026_17_30` means 31 October 2026 at 17:30, local time.

## Words used in this guide

- **Plan**: a folder in `docs/plans/` that describes a feature step by step and
  records its progress in `STATE.md`.
- **Phase, sub-phase, unit**: a phase is a group of related steps; a sub-phase
  is one small piece of it; each phase ends with a check called its closure
  (`P1`, `P2`, …). Any piece the agent works on at once is a unit.
- **Execution**: the part of a plan that an `execute` run was asked to do.
  `resume` continues it; a different `execute` replaces it.
- **Task, bug, ledger**: small changes and fixes outside a plan's phases. Each
  gets an ID (`T-A004`, `B-A002`) and an entry in a list called a ledger:
  `tasks.md` or `bugs.md`, in the plan's folder or in `docs/plans/000_adhoc/`.
- **Mini-plan**: the short plan of a task or bug fix, written in its ledger
  entry before any code changes.
- **Agents, supervisor, self-review**: the models that do the work. agent-1 is
  the supervisor: it designs, reviews, and approves. When a model reviews its
  own work, the review is labelled a self-review.
- **Checkpoint**: a saved note of where the work stands and what to do next, so
  another session can continue.
- **WIP commit**: a "work in progress" commit that saves unfinished work at a
  checkpoint and is updated as the work goes on.
- **Audit, correction**: `verify` checks finished work and writes a report
  (`V001`, `V002`, …); each fix it proposes is a correction, applied later with
  `execute verify`.
- **Handoff**: a graceful stop that saves everything needed to continue later.

## Options and their defaults

| Option | What it does | Default | Accepted by |
|---|---|---|---|
| `full-autonomous:true` / `:false` | `true`: keeps going until the selected work is done and commits each finished piece locally. `false`: stops after each phase (Task and Bug: once, to let you approve the mini-plan) and makes no completion commits | `false` | Every mode; Plan saves it for later runs; Onboard and Handoff ignore it |
| `--wip-commit` / `--no-wip-commit` | Commits progress: finished units, closed phases, and a rolling "work in progress" commit at checkpoints. `--no-wip-commit` turns this off | off | Every mode; Plan saves it for later runs; no effect in Onboard and Verify; Handoff ignores it |
| `executor-power:low` / `medium` / `high` | Tells the planner how capable the implementing models are: `low` gives small units with detailed instructions; `high` gives larger units whose internal design the implementer decides | `low` | Plan only |
| `agent-1:<model>,agent-2:<model>,…` | Chooses the model for each role: agent-1 is the supervisor (designs, reviews, approves); the others implement | The plan's saved list, else agent-1 Opus, agent-2 Sonnet, agent-3 Haiku | Every mode; Handoff ignores it |
| `agent:<model>` | One model does everything and reviews its own work | As above | Every mode; Handoff ignores it |
| `--deadline=dd-mm-yyyy_hh_mm` | Stops gracefully by that local time: saves the state, commits code work, and shows the resume command. Set it a little before you really need to stop | none | Every mode |

Where your options are kept:

- **Plan** saves them as the plan's defaults for later runs.
- **Execute** and **Execute verify** keep them for that execution: `resume`
  reuses them, and they never change the plan's defaults.
- **Task**, **Bug**, **Verify**, and **Resume** use them for that run only.
- **Onboard** never saves anything; **Handoff** ignores everything except a
  deadline.
- A **deadline** always applies to its own run only.

## What gets committed

| `full-autonomous` | WIP | Finished code units and phases | WIP commit at checkpoints | Finished audit |
|---|---|---|---|---|
| `false` | off | No | No | No |
| `false` | on | Yes | Yes | No |
| `true` | off | Yes | No | Yes, audit files only |
| `true` | on | Yes | Yes | Yes, audit files only |

Plan and Onboard never commit. A handoff makes one commit for code work even
when commits are off, unless there is nothing to commit or a commit hook rejects
it, in which case the report shows the commit command. Commits are always local,
on the current branch: nothing is ever pushed.

## Summary matrix

Each cell gives the case ID and its effect in a few words.

| # | Options | Onboard | Plan | Execute | Execute verify | Task | Bug | Verify | Resume | Handoff |
|---|---|---|---|---|---|---|---|---|---|---|
| 01 | no option | ON-01 inspect only | PL-01 defaults saved | EX-01 stop per phase, no commit | EV-01 stop per phase, no commit | TA-01 approval, no commit | BU-01 approval, no commit | VE-01 no commit | RE-01 stop per phase, no commit | HA-01 stop now |
| 02 | `full-autonomous:true` | ON-02 no effect | PL-02 defaults saved | EX-02 all, commit | EV-02 all, commit | TA-02 no stop, commit | BU-02 no stop, commit | VE-02 report committed | RE-02 all, commit | HA-02 ignored, stop now |
| 03 | `full-autonomous:false` | ON-03 no effect | PL-03 defaults saved | EX-03 stop per phase, no commit | EV-03 stop per phase, no commit | TA-03 approval, no commit | BU-03 approval, no commit | VE-03 no commit | RE-03 stop per phase, no commit | HA-03 ignored, stop now |
| 04 | `--wip-commit` | ON-04 no effect | PL-04 defaults saved | EX-04 stop per phase, commit + WIP | EV-04 stop per phase, commit + WIP | TA-04 approval, commit + WIP | BU-04 approval, commit + WIP | VE-04 no commit | RE-04 stop per phase, commit + WIP | HA-04 ignored, stop now |
| 05 | `--no-wip-commit` | ON-05 no effect | PL-05 defaults saved | EX-05 stop per phase, no commit | EV-05 stop per phase, no commit | TA-05 approval, no commit | BU-05 approval, no commit | VE-05 no commit | RE-05 stop per phase, no commit | HA-05 ignored, stop now |
| 06 | `full-autonomous:true --wip-commit` | ON-06 no effect | PL-06 defaults saved | EX-06 all, commit + WIP | EV-06 all, commit + WIP | TA-06 no stop, commit + WIP | BU-06 no stop, commit + WIP | VE-06 report committed | RE-06 all, commit + WIP | HA-06 ignored, stop now |
| 07 | `full-autonomous:false --wip-commit` | ON-07 no effect | PL-07 defaults saved | EX-07 stop per phase, commit + WIP | EV-07 stop per phase, commit + WIP | TA-07 approval, commit + WIP | BU-07 approval, commit + WIP | VE-07 no commit | RE-07 stop per phase, commit + WIP | HA-07 ignored, stop now |
| 08 | `full-autonomous:true --no-wip-commit` | ON-08 no effect | PL-08 defaults saved | EX-08 all, commit | EV-08 all, commit | TA-08 no stop, commit | BU-08 no stop, commit | VE-08 report committed | RE-08 all, commit | HA-08 ignored, stop now |
| 09 | `full-autonomous:false --no-wip-commit` | ON-09 no effect | PL-09 defaults saved | EX-09 stop per phase, no commit | EV-09 stop per phase, no commit | TA-09 approval, no commit | BU-09 approval, no commit | VE-09 no commit | RE-09 B-A002 only, no commit | HA-09 ignored, stop now |
| 10 | `executor-power:low` | ON-10 rejected | PL-10 small detailed units | EX-10 rejected | EV-10 rejected | TA-10 rejected | BU-10 rejected | VE-10 rejected | RE-10 rejected | HA-10 ignored, stop now |
| 11 | `executor-power:medium` | ON-11 rejected | PL-11 medium units | EX-11 rejected | EV-11 rejected | TA-11 rejected | BU-11 rejected | VE-11 rejected | RE-11 rejected | HA-11 ignored, stop now |
| 12 | `executor-power:high` | ON-12 rejected | PL-12 outcome units | EX-12 rejected | EV-12 rejected | TA-12 rejected | BU-12 rejected | VE-12 rejected | RE-12 rejected | HA-12 ignored, stop now |
| 13 | `agent-1:opus,agent-2:sonnet,agent-3:haiku` | ON-13 these inspectors | PL-13 list saved | EX-13 replaces list | EV-13 replaces list | TA-13 this run only | BU-13 this run only | VE-13 this run only | RE-13 this run only | HA-13 ignored, stop now |
| 14 | `agent:my-model` | ON-14 one model | PL-14 one model | EX-14 one model | EV-14 one model | TA-14 one model | BU-14 one model | VE-14 one model | RE-14 one model | HA-14 ignored, stop now |
| 15 | `--deadline=31-10-2026_17_30` | ON-15 stops by deadline | PL-15 draft saved at deadline | EX-15 handoff at deadline | EV-15 handoff at deadline | TA-15 handoff at deadline | BU-15 handoff at deadline | VE-15 audit paused at deadline | RE-15 handoff at deadline | HA-15 stop by the deadline |

## At the end of every run

Every run, in every mode and however it ends, closes its report with two
suggestions: the command to continue, and how to stop. They are only
suggestions: the agent never runs them by itself, even with
`full-autonomous:true`.

```text
Next
- Continue: `/plan-execute-verify resume 003` — continues with sub-phase 2.1
- Stop: `/plan-execute-verify handoff` — commits 1.1, 1.2, and P1, still uncommitted; then close the session
```

- **Continue** is one exact command, ready to copy, with no options: the
  settings already recorded travel with `resume`. A brand-new run is marked as
  new, with the settings it will use. If a decision is missing, it reads "answer
  …, then …". If nothing follows, it says so.
- **Stop** suggests `handoff` only when there is code work left uncommitted;
  otherwise it says there is nothing to save and you can close the session. Plan
  drafts, audit reports, proposed tasks, and `docs/onboarding.md` are never
  committed by a handoff: they are listed with a suggested commit command.

## Rejected commands

These commands are refused before anything runs, in every mode except `handoff`.
A refusal never switches to another mode; the report suggests the corrected
command when the fix is clear.

| Command | Why |
|---|---|
| `/plan-execute-verify full-autonomous:yes execute 003` | Only `true` or `false` |
| `/plan-execute-verify full-autonomous:true full-autonomous:false execute 003` | Autonomy given twice |
| `/plan-execute-verify --wip-commit --no-wip-commit execute 003` | Conflicting WIP options |
| `/plan-execute-verify executor-power:max plan add CSV export` | Not a valid level |
| `/plan-execute-verify executor-power:low executor-power:high plan add CSV export` | Level given twice |
| `/plan-execute-verify executor-power:high execute 003` | Only Plan accepts it (cases 10–12 of the other modes) |
| `/plan-execute-verify --deadline=31-10-26_17_30 execute 003` | Wrong format: `dd-mm-yyyy_hh_mm` |
| `/plan-execute-verify --deadline=31-02-2026_17_30 execute 003` | That date does not exist |
| `/plan-execute-verify --deadline=31-10-2026_17_30 --deadline=31-10-2026_18_00 execute 003` | Deadline given twice |
| `/plan-execute-verify --fast execute 003` | Unknown option |
| `/plan-execute-verify agent:opus,agent-2:sonnet execute 003` | The two agent-list forms mixed |
| `/plan-execute-verify agent-1:opus,agent-3:haiku execute 003` | Numbers must start at 1 with no gaps |
| `/plan-execute-verify agent-1:opus,agent-1:sonnet execute 003` | Same number twice |
| `/plan-execute-verify agent-1:opus,agent-2: execute 003` | Missing model name |

Two more rules protect you from typing mistakes. An option written after the
mode, inside a description, such as `task fix the export
--deadline=31-10-2026_17_30`, is not applied: the agent asks before starting
whether you meant it as an option, which belongs before the mode. A command that
only asks to continue, such as `/plan-execute-verify continue 003`, never
creates a plan: it runs as `resume 003`, or the agent asks what you meant.

Options alone, such as `/plan-execute-verify full-autonomous:true`, select no
work. Missing arguments or invalid selectors are errors too. `handoff` is the
exception: it never refuses a stop request, it ignores and reports what it does
not use, and an invalid or duplicate deadline there means "stop now".

## Onboard

```text
/plan-execute-verify [<options>] onboard [<plan>]
```

Onboard reads the repository and any existing plans, then tells you where the
work stands and what to do next. It writes only `docs/onboarding.md`: no code,
no plan changes, no commits, and it starts nothing by itself. Add a plan number
to focus on that plan.

### ON-01 · no option

```text
/plan-execute-verify onboard
```

**What it does:** Maps the repository and its plans, shows where the work
stands, and suggests the next command.

**What to expect:** It writes only `docs/onboarding.md`, left uncommitted. It
changes no code or plan and starts nothing.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; no effect: Onboard
  only inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; no effect: Onboard
  only inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: on (from your command; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (from your command; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; no effect: Onboard
  only inspects)
- WIP commits: on (from your command; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; no effect: Onboard
  only inspects)
- WIP commits: on (from your command; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; no effect: Onboard
  only inspects)
- WIP commits: off (from your command; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit onboard
```

**What it does:** Same as without options: the option is accepted but changes
nothing.

**What to expect:** Onboard never commits and never starts work, so autonomy and
WIP have no effect, and nothing is saved.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; no effect: Onboard
  only inspects)
- WIP commits: off (from your command; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low onboard
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses each plan's own level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium onboard
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses each plan's own level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high onboard
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses each plan's own level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku onboard
```

**What it does:** Inspects with the agents you list; agent-1 does the
architectural reading.

**What to expect:** The list is used for this inspection only; the plans' saved
lists do not change. The report says which agent actually inspected.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command; this
  inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model onboard
```

**What it does:** One model, my-model, does the whole inspection.

**What to expect:** Nothing is saved. Uncertain architectural readings are
marked as not reviewed by a stronger model.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; this inspection only)
- Deadline: none (default)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work
- Commits made by this run: none: this mode never commits

### ON-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 onboard
```

**What it does:** Normal onboarding that stops by 17:30.

**What to expect:** Onboarding is short and read-only. At the deadline it simply
stops without writing more; run `onboard` again later.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; no effect: Onboard only
  inspects)
- WIP commits: off (default; no effect)
- Executor power: not used: each plan keeps its own level
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; inspection only)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: every plan and ad-hoc ledger, as an inventory (no plan given)
- Where it stops: after the report; it never starts the suggested work; in any
  case by 17:30
- Commits made by this run: none: this mode never commits

## Plan

```text
/plan-execute-verify [<options>] plan <description>
```

Plan designs a feature before any code is written: it studies the repository,
researches open questions, and writes a phased plan in
`docs/plans/<NNN>_plan-<Name>/` (overview, phase files, `STATE.md`). It writes
no production code and never commits. Options given here become the plan's
defaults for later runs. You can also skip the word `plan`: a description alone
starts a plan.

### PL-01 · no option

```text
/plan-execute-verify plan add per-user rate limits
```

**What it does:** Creates the plan with all defaults.

**What to expect:** Later `execute` runs stop after each phase and make no
commits, unless you choose otherwise when you run them. Plan itself writes no
code and never commits; the report suggests the command to commit the plan
files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** A later `execute 004` with no options runs the whole plan
and commits each finished unit. Plan itself writes no code and never commits;
the report suggests the command to commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; saved as plan 004
  default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs stop after each phase and make no completion
commits (this is also the default). Plan itself writes no code and never
commits; the report suggests the command to commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; saved as plan 004
  default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs commit finished units, phases, and progress
checkpoints, and still stop after each phase. Plan itself writes no code and
never commits; the report suggests the command to commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: on (from your command; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs make no WIP commits (this is also the default).
Plan itself writes no code and never commits; the report suggests the command to
commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (from your command; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs go all the way and commit everything: finished
units and checkpoints. Plan itself writes no code and never commits; the report
suggests the command to commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; saved as plan 004
  default)
- WIP commits: on (from your command; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs stop after each phase, but commit finished work
and checkpoints. Plan itself writes no code and never commits; the report
suggests the command to commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; saved as plan 004
  default)
- WIP commits: on (from your command; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs go all the way, committing each finished unit,
without WIP commits. Plan itself writes no code and never commits; the report
suggests the command to commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; saved as plan 004
  default)
- WIP commits: off (from your command; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit plan add per-user rate limits
```

**What it does:** Creates the plan and saves this choice as its default.

**What to expect:** Later runs stop after each phase and make no commits at all.
Plan itself writes no code and never commits; the report suggests the command to
commit the plan files.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; saved as plan 004
  default)
- WIP commits: off (from your command; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low plan add per-user rate limits
```

**What it does:** Writes the plan for less capable implementing models (the
default).

**What to expect:** Many small units with step-by-step instructions, and worked
snippets for the hard parts.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (from your command; saved in plan 004; only a plan
  revision changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium plan add per-user rate limits
```

**What it does:** Writes the plan for mid-level implementing models.

**What to expect:** Fewer units with precise contracts and steps; the
implementer fills in routine details.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `medium` (from your command; saved in plan 004; only a plan
  revision changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high plan add per-user rate limits
```

**What it does:** Writes the plan for strong implementing models.

**What to expect:** Larger units described by their outcome; the implementer
decides the internal design and records it, while interfaces, tests, and rules
stay fixed by the supervisor. Use it only when every implementing model is
strong.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `high` (from your command; saved in plan 004; only a plan
  revision changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku plan add per-user rate limits
```

**What it does:** Creates the plan and saves this agent list in it.

**What to expect:** agent-1 (opus) designs, reviews, and approves; units are
assigned to agent-2 (sonnet) and agent-3 (haiku). Later runs use this list
unless you give another.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command; saved
  in plan 004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model plan add per-user rate limits
```

**What it does:** Creates the plan with one model for every role.

**What to expect:** my-model plans, implements, and reviews its own work;
reviews are marked as self-reviews.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; saved in plan 004)
- Deadline: none (default)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer
- Commits made by this run: none: this mode never commits

### PL-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 plan add per-user rate limits
```

**What it does:** Plans normally; at 17:30 it saves the draft and stops.

**What to expect:** The draft stays uncommitted; continue later with `resume
004`. If the plan is ready earlier, it ends normally. The deadline is not saved
in the plan.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default; saved as plan 004 default)
- WIP commits: off (default; saved as plan 004 default)
- Executor power: `low` (default; saved in plan 004; only a plan revision
  changes it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default; saved in plan
  004)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: a new plan, number 004, in `docs/plans/004_plan-<Name>/`
- Where it stops: when the plan is ready, or at a question only you can answer;
  in any case by 17:30
- Commits made by this run: none: this mode never commits

## Execute

```text
/plan-execute-verify [<options>] execute [<plan>] [<phase or sub-phase>]
```

Execute implements an existing plan unit by unit, with tests and reviews, and
keeps `STATE.md` up to date. Without a phase it runs the whole plan; with one
(`execute 003 phase_02`, `execute 003 1.2`) it stays inside it. Options given
here are kept for this execution: `resume` reuses them, and they never change
the plan's defaults.

### EX-01 · no option

```text
/plan-execute-verify execute 003
```

**What it does:** Runs plan 003 with plan 003's saved settings.

**What to expect:** It stops after the first phase it closes and makes no
commits; continue with `resume 003`.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute 003
```

**What it does:** Runs plan 003, without pausing between phases, and commits
each finished piece, with no WIP commits.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. `resume` keeps these options for
this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; kept by `resume` for
  this execution)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: when the whole selected work is done, or at a real blocker
- Commits made by this run: each finished unit and phase

### EX-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute 003
```

**What it does:** Runs plan 003, stopping after each phase, and commits nothing:
you commit when you want.

**What to expect:** Only a handoff still makes its one commit. `resume` keeps
these options for this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; kept by `resume` for
  this execution)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute 003
```

**What it does:** Runs plan 003, stopping after each phase, and still commits
each finished piece and a WIP commit at checkpoints.

**What to expect:** Commits are local and never pushed. `resume` keeps these
options for this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: on (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: each finished unit and phase, plus a rolling WIP
  commit at each checkpoint

### EX-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute 003
```

**What it does:** Runs plan 003, stopping after each phase, and commits nothing:
you commit when you want.

**What to expect:** Only a handoff still makes its one commit. `resume` keeps
these options for this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute 003
```

**What it does:** Runs plan 003, without pausing between phases, and commits
each finished piece and a WIP commit at checkpoints.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. `resume` keeps these options for
this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; kept by `resume` for
  this execution)
- WIP commits: on (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: when the whole selected work is done, or at a real blocker
- Commits made by this run: each finished unit and phase, plus a rolling WIP
  commit at each checkpoint

### EX-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute 003
```

**What it does:** Runs plan 003, stopping after each phase, and still commits
each finished piece and a WIP commit at checkpoints.

**What to expect:** Commits are local and never pushed. `resume` keeps these
options for this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; kept by `resume` for
  this execution)
- WIP commits: on (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: each finished unit and phase, plus a rolling WIP
  commit at each checkpoint

### EX-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute 003
```

**What it does:** Runs plan 003, without pausing between phases, and commits
each finished piece, with no WIP commits.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. `resume` keeps these options for
this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; kept by `resume` for
  this execution)
- WIP commits: off (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: when the whole selected work is done, or at a real blocker
- Commits made by this run: each finished unit and phase

### EX-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute 003
```

**What it does:** Runs plan 003, stopping after each phase, and commits nothing:
you commit when you want.

**What to expect:** Only a handoff still makes its one commit. `resume` keeps
these options for this execution; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; kept by `resume` for
  this execution)
- WIP commits: off (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

**What it does:** Runs plan 003 with the agents you list.

**What to expect:** agent-1 (opus) reviews and approves; the other agents
implement the units assigned to them. This list replaces plan 003's saved one.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command;
  replaces plan 003's saved list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute 003
```

**What it does:** Runs plan 003 with one model for everything.

**What to expect:** my-model implements and reviews its own work; reviews are
marked as self-reviews. It replaces plan 003's saved list.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; replaces plan 003's saved list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### EX-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute 003
```

**What it does:** Runs plan 003 until 17:30 at the latest, then stops
gracefully.

**What to expect:** Before 17:30 it finishes or pauses the current unit, saves
the state, makes one handoff commit for the code, and shows the resume command.
If the work ends earlier, it ends normally. A later `resume` does not inherit
the deadline.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: the whole plan 003 (no phase given)
- Where it stops: after each phase is closed; in any case by 17:30
- Commits made by this run: none: changes stay uncommitted; at the deadline, one
  handoff commit for unfinished code

## Execute verify

```text
/plan-execute-verify [<options>] execute verify [<plan>] [<report>]
```

Execute verify applies the corrections listed in an audit report (by default the
plan's newest report) and rechecks the phases they touch. It applies only those
corrections, not new plan work. Give a report ID, such as `execute verify 003
V002`, to pick another report. In this example plan 003 is still being executed,
so the agent first asks whether to replace that running execution with the
corrections; the cases below assume you answer yes, and `resume 003` then
continues the corrections.

### EV-01 · no option

```text
/plan-execute-verify execute verify 003
```

**What it does:** Applies the corrections of the newest audit report with plan
003's saved settings.

**What to expect:** It stops after the first phase it closes and makes no
commits; continue with `resume 003`.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, without
pausing between phases, and commits each finished piece, with no WIP commits.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. These options are kept while these
corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then when all corrections are done, or at a real blocker
- Commits made by this run: each finished correction and rechecked phase

### EV-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, stopping
after each phase, and commits nothing: you commit when you want.

**What to expect:** Only a handoff still makes its one commit. These options are
kept while these corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, stopping
after each phase, and still commits each finished piece and a WIP commit at
checkpoints.

**What to expect:** Commits are local and never pushed. These options are kept
while these corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: on (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: each finished correction and rechecked phase, plus a
  rolling WIP commit at each checkpoint

### EV-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, stopping
after each phase, and commits nothing: you commit when you want.

**What to expect:** Only a handoff still makes its one commit. These options are
kept while these corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, without
pausing between phases, and commits each finished piece and a WIP commit at
checkpoints.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. These options are kept while these
corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command)
- WIP commits: on (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then when all corrections are done, or at a real blocker
- Commits made by this run: each finished correction and rechecked phase, plus a
  rolling WIP commit at each checkpoint

### EV-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, stopping
after each phase, and still commits each finished piece and a WIP commit at
checkpoints.

**What to expect:** Commits are local and never pushed. These options are kept
while these corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command)
- WIP commits: on (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: each finished correction and rechecked phase, plus a
  rolling WIP commit at each checkpoint

### EV-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, without
pausing between phases, and commits each finished piece, with no WIP commits.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. These options are kept while these
corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command)
- WIP commits: off (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then when all corrections are done, or at a real blocker
- Commits made by this run: each finished correction and rechecked phase

### EV-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit execute verify 003
```

**What it does:** Applies the corrections of the newest audit report, stopping
after each phase, and commits nothing: you commit when you want.

**What to expect:** Only a handoff still makes its one commit. These options are
kept while these corrections continue; the plan defaults do not change.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command)
- WIP commits: off (from your command; kept by `resume` for this execution)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low execute verify 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium execute verify 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high execute verify 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku execute verify 003
```

**What it does:** Applies the corrections of the newest audit report with the
agents you list.

**What to expect:** agent-1 (opus) reviews and approves; the other agents
implement the units assigned to them. This list replaces plan 003's saved one.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command;
  replaces plan 003's saved list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model execute verify 003
```

**What it does:** Applies the corrections of the newest audit report with one
model for everything.

**What to expect:** my-model implements and reviews its own work; reviews are
marked as self-reviews. It replaces plan 003's saved list.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; replaces plan 003's saved list)
- Deadline: none (default)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed
- Commits made by this run: none: changes stay uncommitted

### EV-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 execute verify 003
```

**What it does:** Applies the corrections of the newest audit report until 17:30
at the latest, then stops gracefully.

**What to expect:** Before 17:30 it finishes or pauses the current unit, saves
the state, makes one handoff commit for the code, and shows the resume command.
If the work ends earlier, it ends normally. A later `resume` does not inherit
the deadline.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: the corrections of V001, plan 003's newest audit report (no report
  given)
- Where it stops: first it asks before replacing the running execution of plan
  003; then after each reopened phase is closed; in any case by 17:30
- Commits made by this run: none: changes stay uncommitted; at the deadline, one
  handoff commit for unfinished code

## Task

```text
/plan-execute-verify [<options>] task <description>
```

Task makes one small change. Before touching code, agent-1 writes or checks a
short plan of the change (the mini-plan) and saves it in
`docs/plans/000_adhoc/tasks.md`, or in the plan's own ledger when your request
names a plan. With `full-autonomous:false`, the default, it then stops so you
can read it: approve by replying in the same session or with `resume 000_adhoc
T-A004`; reject by saying so or by marking the entry `WITHDRAWN`. With
`full-autonomous:true` there is no stop. Everything after `task` is the
description, even text like `--json`; only text shaped like one of this skill's
options, such as `--deadline=…`, makes the agent ask first.

### TA-01 · no option

```text
/plan-execute-verify task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, waits for your approval, then implements it with tests.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, and implements it with tests.

**What to expect:** One local commit for the change once tests and reviews pass.
No approval stop, but agent-1 still checks the mini-plan first. These options
apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: no approval stop; at the end of the change
- Commits made by this run: the finished task

### TA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, waits for your approval, then implements it with tests.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, waits for your approval, then implements it with tests.

**What to expect:** Commits the change and a WIP commit at checkpoints, even
without full autonomy. To approve, reply in the same session or run the `resume`
command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: the finished task, plus a rolling WIP commit at each
  checkpoint

### TA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, waits for your approval, then implements it with tests.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, and implements it with tests.

**What to expect:** Commits the change and a WIP commit at checkpoints. No
approval stop, but agent-1 still checks the mini-plan first. These options apply
to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: no approval stop; at the end of the change
- Commits made by this run: the finished task, plus a rolling WIP commit at each
  checkpoint

### TA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, waits for your approval, then implements it with tests.

**What to expect:** Commits the change and a WIP commit at checkpoints, even
without full autonomy. To approve, reply in the same session or run the `resume`
command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: the finished task, plus a rolling WIP commit at each
  checkpoint

### TA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, and implements it with tests.

**What to expect:** One local commit for the change once tests and reviews pass.
No approval stop, but agent-1 still checks the mini-plan first. These options
apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: no approval stop; at the end of the change
- Commits made by this run: the finished task

### TA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit task add a --json option to the export command
```

**What it does:** Writes a short plan of the change (mini-plan), has agent-1
check it, waits for your approval, then implements it with tests.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low task add a --json option to the export command
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses the attached plan's level, `low` in 000_adhoc.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium task add a --json option to the export command
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses the attached plan's level, `low` in 000_adhoc.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high task add a --json option to the export command
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses the attached plan's level, `low` in 000_adhoc.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku task add a --json option to the export command
```

**What it does:** Handles the change with the agents you list.

**What to expect:** agent-1 (opus) checks the mini-plan and reviews the result.
The list applies to this run only and is saved nowhere else.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command; this
  run only)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model task add a --json option to the export command
```

**What it does:** One model, my-model, handles the change alone.

**What to expect:** It writes and checks its own mini-plan and reviews its own
work; both are marked as self-reviews. With the default autonomy it still stops
for your approval.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; this run only)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change
- Commits made by this run: none: changes stay uncommitted

### TA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 task add a --json option to the export command
```

**What it does:** Handles the change and stops gracefully by 17:30.

**What to expect:** If it is already waiting for your approval, nothing more
happens. If it is implementing, it pauses, commits the work in one handoff
commit, and shows the resume command.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: ad-hoc ledger `docs/plans/000_adhoc/tasks.md`, because the request
  names no plan
- Where it stops: once, after the mini-plan, for your approval; then at the end
  of the change; in any case by 17:30
- Commits made by this run: none: changes stay uncommitted; at the deadline, one
  handoff commit for unfinished code

## Bug

```text
/plan-execute-verify [<options>] bug <description>
```

Bug fixes one defect: it reproduces the problem, finds the root cause, writes a
test that fails, fixes the code, and runs the tests again. If it cannot
reproduce the bug, it records what it tried instead of guessing a fix. With
`full-autonomous:false` it stops for your approval after the diagnosis and the
mini-plan, before the test and the fix. Entries go to
`docs/plans/000_adhoc/bugs.md` unless your request names a plan.

### BU-01 · no option

```text
/plan-execute-verify bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, waits for your approval, then writes a failing test, fixes the
code, and runs the tests again.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, and writes a failing test, fixes the code, and runs the tests
again.

**What to expect:** One local commit for the fix once tests and reviews pass. No
approval stop, but agent-1 still checks the mini-plan first. These options apply
to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: no approval stop; at the end of the change
- Commits made by this run: the finished fix

### BU-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, waits for your approval, then writes a failing test, fixes the
code, and runs the tests again.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, waits for your approval, then writes a failing test, fixes the
code, and runs the tests again.

**What to expect:** Commits the fix and a WIP commit at checkpoints, even
without full autonomy. To approve, reply in the same session or run the `resume`
command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: the finished fix, plus a rolling WIP commit at each
  checkpoint

### BU-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, waits for your approval, then writes a failing test, fixes the
code, and runs the tests again.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, and writes a failing test, fixes the code, and runs the tests
again.

**What to expect:** Commits the fix and a WIP commit at checkpoints. No approval
stop, but agent-1 still checks the mini-plan first. These options apply to this
run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: no approval stop; at the end of the change
- Commits made by this run: the finished fix, plus a rolling WIP commit at each
  checkpoint

### BU-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, waits for your approval, then writes a failing test, fixes the
code, and runs the tests again.

**What to expect:** Commits the fix and a WIP commit at checkpoints, even
without full autonomy. To approve, reply in the same session or run the `resume`
command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: the finished fix, plus a rolling WIP commit at each
  checkpoint

### BU-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, and writes a failing test, fixes the code, and runs the tests
again.

**What to expect:** One local commit for the fix once tests and reviews pass. No
approval stop, but agent-1 still checks the mini-plan first. These options apply
to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: no approval stop; at the end of the change
- Commits made by this run: the finished fix

### BU-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit bug export exits with code 0 when the configuration is missing
```

**What it does:** Reproduces the bug, finds its cause, writes a mini-plan, has
agent-1 check it, waits for your approval, then writes a failing test, fixes the
code, and runs the tests again.

**What to expect:** No commits: the change stays uncommitted and the report
suggests the commit command. To approve, reply in the same session or run the
`resume` command the report shows. These options apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low bug export exits with code 0 when the configuration is missing
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses the attached plan's level, `low` in 000_adhoc.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium bug export exits with code 0 when the configuration is missing
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses the attached plan's level, `low` in 000_adhoc.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high bug export exits with code 0 when the configuration is missing
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses the attached plan's level, `low` in 000_adhoc.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku bug export exits with code 0 when the configuration is missing
```

**What it does:** Handles the fix with the agents you list.

**What to expect:** agent-1 (opus) checks the mini-plan and reviews the result.
The list applies to this run only and is saved nowhere else.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command; this
  run only)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model bug export exits with code 0 when the configuration is missing
```

**What it does:** One model, my-model, handles the fix alone.

**What to expect:** It writes and checks its own mini-plan and reviews its own
work; both are marked as self-reviews. With the default autonomy it still stops
for your approval.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; this run only)
- Deadline: none (default)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change
- Commits made by this run: none: changes stay uncommitted

### BU-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 bug export exits with code 0 when the configuration is missing
```

**What it does:** Handles the fix and stops gracefully by 17:30.

**What to expect:** If it is already waiting for your approval, nothing more
happens. If it is implementing, it pauses, commits the work in one handoff
commit, and shows the resume command.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: ad-hoc ledger `docs/plans/000_adhoc/bugs.md`, because the request
  names no plan
- Where it stops: once, after the diagnosis and mini-plan, for your approval;
  then at the end of the change; in any case by 17:30
- Commits made by this run: none: changes stay uncommitted; at the deadline, one
  handoff commit for unfinished code

## Verify

```text
/plan-execute-verify [<options>] verify [<plan>] [<phase, sub-phase, or entry>]
```

Verify audits a plan, or a part of it (`verify 003 phase_02`, `verify 003 1.2`,
`verify 000_adhoc T-A004`), against its specification: behavior, tests, reviews,
state, and commits. It writes a dated report with findings and ready-to-run
corrections, but never changes code. Apply corrections with `execute verify`.

### VE-01 · no option

```text
/plan-execute-verify verify 003
```

**What it does:** Audits the whole plan 003 against its specification.

**What to expect:** It writes a dated report with findings and ready-to-run
corrections, and changes no code. The report stays uncommitted; the end of the
report shows the command to apply corrections, if any.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true verify 003
```

**What it does:** Audits plan 003 and commits the report and the plan state.

**What to expect:** Only audit files are committed, never code. WIP settings add
nothing for an audit. Corrections are never applied automatically.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: the audit report and plan state, never code

### VE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false verify 003
```

**What it does:** Audits plan 003 without committing.

**What to expect:** An audit is committed only with `full-autonomous:true`; WIP
settings never commit audits.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit verify 003
```

**What it does:** Audits plan 003 without committing.

**What to expect:** An audit is committed only with `full-autonomous:true`; WIP
settings never commit audits.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: on (from your command; no effect: audits never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit verify 003
```

**What it does:** Audits plan 003 without committing.

**What to expect:** An audit is committed only with `full-autonomous:true`; WIP
settings never commit audits.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from your command; no effect: audits never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit verify 003
```

**What it does:** Audits plan 003 and commits the report and the plan state.

**What to expect:** Only audit files are committed, never code. WIP settings add
nothing for an audit. Corrections are never applied automatically.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: on (from your command; no effect: audits never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: the audit report and plan state, never code

### VE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit verify 003
```

**What it does:** Audits plan 003 without committing.

**What to expect:** An audit is committed only with `full-autonomous:true`; WIP
settings never commit audits.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: on (from your command; no effect: audits never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit verify 003
```

**What it does:** Audits plan 003 and commits the report and the plan state.

**What to expect:** Only audit files are committed, never code. WIP settings add
nothing for an audit. Corrections are never applied automatically.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (from your command; no effect: audits never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: the audit report and plan state, never code

### VE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit verify 003
```

**What it does:** Audits plan 003 without committing.

**What to expect:** An audit is committed only with `full-autonomous:true`; WIP
settings never commit audits.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (from your command; no effect: audits never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low verify 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium verify 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high verify 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku verify 003
```

**What it does:** Audits plan 003 with the agents you list.

**What to expect:** agent-1 (opus) checks the critical points. The list applies
to this audit only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command; this
  run only)
- Deadline: none (default)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model verify 000_adhoc B-A002
```

**What it does:** One model audits the ad-hoc bug entry B-A002.

**What to expect:** Every review is a self-review, for this audit only.
Corrections come out as ready `task` or `bug` commands.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (default)
- WIP commits: off (default; no effect: audits never get WIP commits)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; this run only)
- Deadline: none (default)
- Target: ad-hoc bug entry B-A002
- Where it stops: when the audit is complete
- Commits made by this run: none: the report stays uncommitted

### VE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 verify 003
```

**What it does:** Audits plan 003 and pauses by 17:30 if it is not finished.

**What to expect:** At the deadline the audit stays open with a checkpoint and
no commit; continue with the `resume` command shown, such as `resume 003 V002`.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from plan 003, which uses the default)
- WIP commits: off (from plan 003, which uses the default; no effect: audits
  never get WIP commits)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from plan 003, which uses
  the default list)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: the whole plan 003 (no phase or entry given)
- Where it stops: when the audit is complete; in any case by 17:30
- Commits made by this run: none: the report stays uncommitted

## Resume

```text
/plan-execute-verify [<options>] resume [<plan>] [<unit>]
```

Resume continues work that was interrupted or saved. First it finishes
recovering anything left half-done (an open unit, a pending commit, an open
audit, a plan draft), then it continues the plan's saved execution. Name a unit
to continue only that one (`resume 003 1.2`, `resume 000_adhoc T-A004`); naming
a proposed task or bug approves it. Options given here apply to this run only;
otherwise the work keeps the settings it was started with.

### RE-01 · no option

```text
/plan-execute-verify resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running with the settings recorded on that work.

**What to expect:** It stops after the first phase it closes and makes no
commits; continue with `resume 003`.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, without pausing between phases, and commits each finished piece,
with no WIP commits.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. These options apply to this run
only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: when the whole selected work is done, or at a real blocker
- Commits made by this run: each finished unit, as in its own mode

### RE-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, stopping after each phase, and commits nothing: you commit when
you want.

**What to expect:** Only a handoff still makes its one commit. These options
apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, stopping after each phase, and still commits each finished piece
and a WIP commit at checkpoints.

**What to expect:** Commits are local and never pushed. These options apply to
this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: each finished unit, as in its own mode, plus a
  rolling WIP commit at each checkpoint

### RE-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, stopping after each phase, and commits nothing: you commit when
you want.

**What to expect:** Only a handoff still makes its one commit. These options
apply to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, without pausing between phases, and commits each finished piece
and a WIP commit at checkpoints.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. These options apply to this run
only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: when the whole selected work is done, or at a real blocker
- Commits made by this run: each finished unit, as in its own mode, plus a
  rolling WIP commit at each checkpoint

### RE-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, stopping after each phase, and still commits each finished piece
and a WIP commit at checkpoints.

**What to expect:** Commits are local and never pushed. These options apply to
this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: on (from your command; this run only)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: each finished unit, as in its own mode, plus a
  rolling WIP commit at each checkpoint

### RE-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running, without pausing between phases, and commits each finished piece,
with no WIP commits.

**What to expect:** Commits are local and never pushed. It stops early only at a
real blocker, a stop request, or a deadline. These options apply to this run
only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true` (from your command; this run only)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: when the whole selected work is done, or at a real blocker
- Commits made by this run: each finished unit, as in its own mode

### RE-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit resume 000_adhoc B-A002
```

**What it does:** Continues only the ad-hoc bug B-A002, with no commits, and
stops after it.

**What to expect:** These options apply to this run only, even if the entry was
recorded with commits on; next time its recorded settings apply again.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from your command; this run only)
- WIP commits: off (from your command; this run only)
- Executor power: `low` (default for 000_adhoc; a task or bug on a plan follows
  that plan)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (default)
- Deadline: none (default)
- Target: ad-hoc bug entry B-A002 only
- Where it stops: after entry B-A002
- Commits made by this run: none: changes stay uncommitted

### RE-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low resume 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium resume 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high resume 003
```

**What it does:** Rejected: only Plan accepts `executor-power`.

**What to expect:** Nothing runs. Run the same command without the option; the
run uses plan 003's saved level.

**Settings for this run:**

None: the command is rejected before anything runs.

Without that option, the same command uses:

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running with the agents you list.

**What to expect:** agent-1 (opus) reviews and approves; the other agents
implement the units assigned to them. The list applies to this run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 opus, agent-2 sonnet, agent-3 haiku (from your command; this
  run only)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running with one model for everything.

**What to expect:** my-model implements and reviews its own work; reviews are
marked as self-reviews. This run only.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: my-model in every role; it reviews its own work (self-review) (from
  your command; this run only)
- Deadline: none (default)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed
- Commits made by this run: none: changes stay uncommitted

### RE-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify --deadline=31-10-2026_17_30 resume 003
```

**What it does:** Continues the interrupted work of plan 003, then the execution
it was running until 17:30 at the latest, then stops gracefully.

**What to expect:** Before 17:30 it finishes or pauses the current unit, saves
the state, makes one handoff commit for the code, and shows the resume command.
If the work ends earlier, it ends normally. A later `resume` does not inherit
the deadline.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false` (from the resumed work, started without
  options)
- WIP commits: off (from the resumed work)
- Executor power: `low` (plan 003's level; only Plan sets it)
- Agents: agent-1 Opus, agent-2 Sonnet, agent-3 Haiku (from the resumed work)
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: plan 003: first any interrupted work, then the execution it was
  running
- Where it stops: after each phase is closed; in any case by 17:30
- Commits made by this run: none: changes stay uncommitted; at the deadline, one
  handoff commit for unfinished code

## Handoff

```text
/plan-execute-verify handoff [--deadline=dd-mm-yyyy_hh_mm]
```

Handoff stops the work gracefully. It starts nothing new, finishes the current
unit only if that takes about 10 minutes, saves the state, makes one commit for
the code work (even when commits are off), shows the command to resume, and
stops. Send it during a run, or give a deadline. It is best effort: the agent
reads your message only between two of its steps, so set a deadline a little
before you really need to stop, for example 17:30 if you switch off at 18:00.

### HA-01 · no option

```text
/plan-execute-verify handoff
```

**What it does:** Stops the work now, gracefully.

**What to expect:** It starts nothing new and finishes the current unit only if
that takes about 10 minutes. It saves the state, makes one handoff commit for
the code, shows the resume command, and stops. Sent during a run, it also
cancels an earlier deadline. Sent to an idle session, it saves the work that
session last changed, never work another live session owns.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-02 · `full-autonomous:true`

```text
/plan-execute-verify full-autonomous:true handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true`, ignored by Handoff, which says so
- WIP commits: not used
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-03 · `full-autonomous:false`

```text
/plan-execute-verify full-autonomous:false handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false`, ignored by Handoff, which says so
- WIP commits: not used
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-04 · `--wip-commit`

```text
/plan-execute-verify --wip-commit handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: on, ignored by Handoff, which says so
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-05 · `--no-wip-commit`

```text
/plan-execute-verify --no-wip-commit handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: off, ignored by Handoff, which says so
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-06 · `full-autonomous:true --wip-commit`

```text
/plan-execute-verify full-autonomous:true --wip-commit handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true`, ignored by Handoff, which says so
- WIP commits: on, ignored by Handoff, which says so
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-07 · `full-autonomous:false --wip-commit`

```text
/plan-execute-verify full-autonomous:false --wip-commit handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false`, ignored by Handoff, which says so
- WIP commits: on, ignored by Handoff, which says so
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-08 · `full-autonomous:true --no-wip-commit`

```text
/plan-execute-verify full-autonomous:true --no-wip-commit handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): `true`, ignored by Handoff, which says so
- WIP commits: off, ignored by Handoff, which says so
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-09 · `full-autonomous:false --no-wip-commit`

```text
/plan-execute-verify full-autonomous:false --no-wip-commit handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): `false`, ignored by Handoff, which says so
- WIP commits: off, ignored by Handoff, which says so
- Executor power: unchanged
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-10 · `executor-power:low`

```text
/plan-execute-verify executor-power:low handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: `low`, ignored by Handoff, which says so
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-11 · `executor-power:medium`

```text
/plan-execute-verify executor-power:medium handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: `medium`, ignored by Handoff, which says so
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-12 · `executor-power:high`

```text
/plan-execute-verify executor-power:high handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: `high`, ignored by Handoff, which says so
- Agents: unchanged
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-13 · `agent-1:opus,agent-2:sonnet,agent-3:haiku`

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet,agent-3:haiku handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: unchanged
- Agents: agent list ignored by Handoff, which says so
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-14 · `agent:my-model`

```text
/plan-execute-verify agent:my-model handoff
```

**What it does:** The option is ignored and reported; the stop starts now.

**What to expect:** A stop request is never refused. The handoff commit for code
work happens whatever this option says, and no saved setting changes.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: unchanged
- Agents: agent list ignored by Handoff, which says so
- Deadline: none (default)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: as soon as possible
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

### HA-15 · `--deadline=31-10-2026_17_30`

```text
/plan-execute-verify handoff --deadline=31-10-2026_17_30
/plan-execute-verify --deadline=31-10-2026_17_30 handoff
```

**What it does:** Lets the current run continue and stops it gracefully by
17:30. Both forms are the same.

**What to expect:** It replaces any earlier deadline. At 17:30 it does what
plain `handoff` does. A past or invalid deadline means "stop now"; so does a
deadline sent to an idle session.

**Settings for this run:**

- Autonomy (`full-autonomous`): not used
- WIP commits: not used
- Executor power: unchanged
- Agents: unchanged
- Deadline: 31 October 2026 at 17:30 local time, this run only (from your
  command)
- Target: the run in progress; in an idle session, the plan or ledger it last
  changed
- Where it stops: by 17:30
- Commits made by this run: one handoff commit for code work, even if commits
  are off (none when there is nothing to commit); none for Plan, Verify, or
  Onboard

## Combining options

Options combine freely, in any order, before the mode; each one keeps the effect
described in its own case. Only `executor-power` is limited: Plan alone accepts
it.

```text
/plan-execute-verify full-autonomous:true --wip-commit executor-power:medium agent-1:opus,agent-2:sonnet plan add CSV export
```

PL-06 + PL-11 + PL-13: the new plan saves autonomy true, WIP on, level `medium`,
and this agent list.

```text
/plan-execute-verify agent-1:opus,agent-2:sonnet full-autonomous:true --no-wip-commit execute 003 phase_02
```

EX-08 + EX-13, limited to the phase in `phase_02.md` (logical phase 1,
sub-phases 1.1, 1.2, and its closure P1).

```text
/plan-execute-verify agent:my-model full-autonomous:false --no-wip-commit task fix the login error message
```

TA-09 + TA-14: one model, an approval stop, no commits, nothing saved in any
plan.

```text
/plan-execute-verify full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku resume 003
```

RE-02 + RE-13: everything applies to this run only.

```text
/plan-execute-verify --deadline=31-10-2026_17_30 full-autonomous:true agent-1:opus,agent-2:sonnet,agent-3:haiku execute 003
```

EX-15 + EX-02 + EX-13: the whole plan, autonomously, with this agent list, and a
graceful stop by 17:30.
