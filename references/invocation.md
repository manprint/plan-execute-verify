# Invocation, settings, and selectors

Read when interpreting `/plan-execute-verify` command syntax. Options and the
agent prefix belong to the leading run of tokens, in any order. Stop parsing at
the first token that is neither; the remainder is the mode and its arguments.
Thus `task add a --json flag` keeps `--json` in the description. When a
description contains a token shaped like a leading option of this table or an
agent prefix, such as a trailing `--deadline=…`, ask before starting whether it
was meant as an option, which belongs before the mode. Two tokens are read even
there: a deadline after `handoff`, which accepts it, and a
`full-autonomous:true|false` token that ends the command (below). When the
autonomy the command resolves to is `true`, do not
ask: a valid trailing `--deadline=…` is taken as the deadline, since stopping
earlier never loses work; any other such token stays literal text; the report
states the reading (execution-contract §4).

| Leading option | Meaning | Default |
|----------------|---------|---------|
| `full-autonomous:true` | Continue selected scope without stopping or asking (user decisions become autonomous decisions); commit verified units locally | `true` where no value is recorded |
| `full-autonomous:false` | Continue through the current phase; stop after its closure (Task and Bug: once, for approval of the mini-plan); ask the user where a manual says so; no completion commits by this option | — |
| `--wip-commit` | Commit progress: completed code units, phase closures, and a rolling WIP commit at each checkpoint | on where no value is recorded |
| `--no-wip-commit` | Disable WIP behavior; autonomous commits still apply | — |
| `executor-power:<level>` | Plan only: `low`, `medium`, or `high` executor capability; sets plan granularity, detail, and executor latitude | `low` |
| `--deadline=dd-mm-yyyy_hh_mm` | Every mode: hand off gracefully by this local time ([mode-handoff](mode-handoff.md)); this invocation only | none |

Full autonomy may also be requested explicitly in two more forms, recorded
with source `explicit (prompt)` and treated exactly like the leading option:
`full-autonomous:true|false` as the last token of an `execute`, `execute
verify`, `verify`, `resume`, `task`, or `bug` command (for a task or bug, the
last token of its description, where that exact form is never meaningful
product text), or a clear natural-language request in the user's message to
run without stopping, such as "full autonomous", "in piena autonomia", "senza
fermarti fino alla fine". Other text that describes product behavior inside a
task or bug description stays literal. Never ask whether such a request was
meant: asking is itself a stop. A leading autonomy option together with a
trailing token, or with a natural-language request of the opposite value, is a
duplicate autonomy option and is rejected (below), whatever the values.

Reject unknown leading options, invalid boolean values (including
`full-autonomous:yes`), duplicate autonomy options (a leading option repeated,
or combined with a trailing token or a contrary natural-language request), an
invalid or duplicate
`executor-power` value or that option outside Plan, an invalid or duplicate
`--deadline`, conflicting WIP options, and invalid agent prefixes before work
starts. Handoff is the exception: it never rejects a stop request, reports what
it ignores, and treats an invalid deadline as an immediate handoff
(mode-handoff.md H1). A rejection still ends with the Next block (next-step.md),
suggesting the corrected command when the fix is unambiguous. Each setting
resolves separately: explicit invocation > saved execution scope override (only
while continuing that scope) > selected plan's STATE.md §3 > default
(`full-autonomous:true`, WIP on). Plan stores the resolved values in §3 as
plan defaults, so every new plan records `true` and WIP on unless the
invocation says otherwise; a value already recorded is never rewritten to the
new default. Execute stores
them with the saved execution scope it sets (execution-contract §1): they last
through resume and handoff of that scope, lapse when a different selector
replaces it, and never change §3. Execute verify, Task, Bug, Verify, and Resume
use explicit options for that invocation only and record the effective values
in the §1 invocation record and in their ledger entry, audit report, or resumed
unit, also when attached to a real plan; they never rewrite a plan's saved
settings or its saved execution scope. A resumed unit keeps the effective
settings and roster recorded on it (ledger entry, audit report, or §1 invocation
record); the scope overrides and §3 apply when Resume continues the saved
execution scope, and explicit Resume options override either for that invocation
only. Plan options preset later execution but never authorize implementation or
planning commits. Onboard options are inspection only and never persist or
authorize commits. WIP and autonomy precedence is detailed in
[execution-contract](execution-contract.md).

`executor-power:low|medium|high` describes the least capable implementer that
will receive the plan's units (mode-plan D). Plan stores it in §3; the default
is `low`, and a legacy plan without it is `low`. It shapes the plan itself, so
no other mode accepts it, and neither a user edit of §3 nor an Execute option
changes it: a different level requires a supervisor plan revision that
recalibrates the remaining units. Task and Bug follow the attached plan's level,
`low` in `000_adhoc`.

`--deadline=dd-mm-yyyy_hh_mm` is a real date with 24-hour time in the local time
zone of the machine running the agent. It belongs to its invocation only: it is
recorded with that invocation, never saved as a scope override or in §3, and
never inherited by a later Resume. A past deadline means an immediate handoff.
The deadline is binding under every autonomy setting and permission mode: the
run finishes its handoff, report included, by that time (mode-handoff.md H2).

Agent prefix is `agent:<name>` or a contiguous comma-separated roster
`agent-1:<name>,agent-2:<name>,...`. Names are nonempty tokens without spaces or
commas, passed unchanged to the host. Numbered entries start at 1 without gaps;
reject mixed forms, duplicate indexes, or missing names. A roster with only
`agent-1` is one implementing agent that explicitly self-reviews. Resolve the
roster from explicit prefix > existing plan > legacy Opus/Sonnet/Haiku default.
Only Plan, Execute, and Execute verify save an explicit roster to the plan; in
Task, Bug, Verify, Resume, and Onboard it applies to that invocation only and is
recorded with it. Validate host availability before dispatch; substitute an
agent only under the recorded rule in [agent-roster](agent-roster.md), and never
claim a review that did not occur.

The first token after leading options/prefix selects a mode only if exactly
`onboard`, `plan`, `execute`, `task`, `bug`, `verify`, `resume`, or `handoff`;
otherwise the remainder is an implicit Plan description. Use `plan task queue`,
`plan resume uploads`, or `plan handoff notes` if a feature name begins with a
reserved word. Missing required arguments and invalid selectors are errors, not
permission to fall back to another mode. Options alone do not select work. A
remainder whose first word asks to continue recorded work (`continue`,
`finish`, or the same in the user's language) is never a new plan: followed
only by an existing plan or unit selector, such as `continue 003`, treat it as
`resume` with that target; otherwise ask whether a resume or a new plan is
meant, or, when the resolved autonomy is `true`, decide (execution-contract §4):
a resume when exactly one resumable target matches, else a new plan.

Wherever this file says a user choice is required (several active plans,
candidate plans, resume targets, or a scope replacement), that applies with
`full-autonomous:false`; with `true` it is an autonomous decision
(execution-contract §4). Handoff never chooses among targets: it hands off
each one (mode-handoff.md H1).

Plan selectors are a three-digit number, feature name, or folder path. Execute
(not Execute verify, which takes only a report ID) and Verify also accept
`phase_02`, `1.2`, `§ 1.2`, or `phase_02 § 1.2`. Verify
further accepts a `T-A<NNN>` or `B-A<NNN>` ledger entry, and `000_adhoc` as its
plan, alone or with an entry ID. An entry ID without a plan resolves to the
unique ledger that records it, including `000_adhoc`; several matches require a
choice. Logical phase 0 is stored in `phase_01.md`, so `phase_02` selects
logical phase 1; numeric sub-phase IDs refer to their heading, not the file
suffix. Reject mismatched file/ID selectors.
Onboard accepts an optional plan selector, never a phase/report selector;
without one it inventories plans and ad-hoc ledgers rather than choosing the
highest number.

An active plan is a real plan whose STATE.md records an OPEN or pending-closure
unit, or any sub-phase, correction, or phase that is not DONE or SKIPPED.
Execute, Execute verify, and Verify without a plan selector use the unique
active real plan, ignoring `000_adhoc`; with no active plan, the highest
numbered real plan. Several active plans require a user choice, never the
highest number. An explicit path wins. `execute verify [<plan>] [V<NNN>]`
applies corrections from the selected/active plan's newest report unless an ID
is given, as its own invocation that never sets or replaces the saved execution
scope (execution-contract §1). V-prefixed report IDs differ from three-digit
plan IDs. A plan literally named `verify` needs its number/path.

Task/bug take no leading selector. They attach to a real plan only when the
request names that plan (number, feature name, or path) or clearly changes an
active plan's approved scope, contracts, or files; otherwise they use
`000_adhoc`. Several candidate plans require a user choice. A completed plan
receives task/bug work only when the request names it. Record the attachment
and its reason in the ledger entry.

`resume [<plan>] [<unit-id>]` continues recorded work (mode-resume.md). Its plan
selector may also be `000_adhoc`; its unit ID names OPEN, pending-closure,
BLOCKED, or suspended work (`N.M`, `P<N>`, `PLAN`, `V<NNN>`, `V<NNN>-C<n>`,
`T-A<NNN>`, `B-A<NNN>`), or a PROPOSED task or bug, which only its explicit entry ID resumes
and thereby approves; never a TODO unit. A single argument matching the unit-ID
grammar is a unit ID; select a plan named like one by number or path. Without a
plan, a unit ID resolves to the unique plan or ledger that records it as
resumable; several matches require a choice. Its options and prefix apply to
that invocation only.

`handoff [--deadline=dd-mm-yyyy_hh_mm]` (mode-handoff.md) uses only a deadline,
given after it or as a leading option; it ignores other options, an agent
prefix, or a selector, and says so. Sent during a run in progress, including
one waiting for a worker or background command, it applies to that run, which
with a deadline continues until the cutoff; sent to an idle session (no run in
progress, mode-handoff.md H1) it applies to the plan or ledger that session last
wrote, else every one with unfinished or uncommitted work that no other live
session owns, each handed off in turn.

A selector limits scope even under full autonomy. Only Execute sets the saved
execution scope; Execute verify, Task, Bug, and Verify run their own units
without replacing it (execution-contract §1). Resume continues the saved
execution scope. A different explicit Execute selector replaces it and its
overrides; the same selector on a RUNNING or BLOCKED scope continues it. When an
explicit Execute selector would replace a RUNNING or BLOCKED
saved execution scope with a different one, ask the user before replacing it
(with `true`, replace it as recorded in execution-contract §1).
Completing one selected sub-phase does not start later sub-phases outside scope.
A sub-phase scope ends at that sub-phase's closure and never includes its phase
closure P<N>; P<N> runs under a phase or plan scope, for example
`execute 003 phase_02` once its sub-phases are DONE. The plan closure `PLAN`
runs under a plan scope or the last phase's scope, right after its P<N>.
