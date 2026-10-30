# Invocation, settings, and selectors

Read when interpreting `/plan-execute-verify` command syntax. Options and the
agent prefix belong to the leading run of tokens, in any order. Stop parsing at
the first token that is neither; the remainder is the mode and its arguments.
Thus `task add a --json flag` keeps `--json` in the description.

| Leading option | Meaning | Default |
|----------------|---------|---------|
| `full-autonomous:true` | Continue selected scope; commit verified units locally | `false` |
| `full-autonomous:false` | Continue through the current phase; stop after its closure; no completion commits by this option | — |
| `--wip-commit` | Commit progress: completed code units, phase closures, and a rolling WIP commit at each checkpoint | off |
| `--no-wip-commit` | Disable WIP behavior; autonomous commits still apply | — |

Reject unknown leading options, invalid boolean values (including
`full-autonomous:yes`), duplicate autonomy options, conflicting WIP options, and
invalid agent prefixes before work starts. Each setting resolves separately:
explicit invocation > saved execution scope override (only while continuing that
scope) > selected plan's STATE.md §3 > default. Plan stores explicit options in
§3 as plan defaults. Execute and Execute verify store them with the saved
execution scope they set (execution-contract §1): they last through resume and
handoff of that scope, lapse when a different selector replaces it, and never
change §3. Task, Bug, Verify, and Resume use explicit options for that
invocation only and record the effective values in their ledger entry, audit
report, or resumed unit, also when attached to a real plan; they never rewrite a
plan's saved settings. A resumed unit keeps the effective settings and roster
recorded on it (ledger entry, audit report, or §1 invocation record); the scope
overrides and §3 apply when Resume continues the saved execution scope, and
explicit Resume options override either for that invocation only. Plan options
preset later execution but never authorize implementation or planning commits.
Onboard options are inspection only and never persist or authorize commits. WIP
and autonomy precedence is detailed in
[execution-contract](execution-contract.md).

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
`onboard`, `plan`, `execute`, `task`, `bug`, `verify`, or `resume`; otherwise
the remainder is an implicit Plan description. Use `plan task queue` or
`plan resume uploads` if a feature name begins with a reserved word. Missing
required arguments and invalid selectors are errors, not permission to fall back
to another mode. Options alone do not select work. A request that only asks to
continue, resume, or finish recorded work, such as `continue 003`, is never a
new plan: treat it as `resume` with that target, or ask when the target is
unclear.

Plan selectors are a three-digit number, feature name, or folder path. Execute
and Verify also accept `phase_02`, `1.2`, `§ 1.2`, or `phase_02 § 1.2`. Verify
further accepts a `T-A<NNN>` or `B-A<NNN>` ledger entry, and `000_adhoc` as its
plan, alone or with an entry ID. An entry ID without a plan resolves to the
unique ledger that records it, including `000_adhoc`; several matches require a
choice. Logical phase 0 is stored in `phase_01.md`; numeric sub-phase IDs refer
to their heading, not the file suffix. Reject mismatched file/ID selectors.
Onboard accepts an optional plan selector, never a phase/report selector;
without one it inventories plans and ad-hoc ledgers rather than choosing the
highest number.

An active plan is a real plan whose STATE.md records an OPEN or pending-closure
unit, or any sub-phase, correction, or phase that is not DONE or SKIPPED.
For execution/audit without a selector, use the highest numbered real plan,
ignoring `000_adhoc`; ask when multiple active plans are ambiguous. An explicit
path wins. `execute verify [<plan>] [V<NNN>]` applies corrections from the
selected/active plan's newest report unless an ID is given. V-prefixed report
IDs differ from three-digit plan IDs. A plan literally named `verify` needs its
number/path.

Task/bug take no leading selector. They attach to a real plan only when the
request names that plan (number, feature name, or path) or clearly changes an
active plan's approved scope, contracts, or files; otherwise they use
`000_adhoc`. Several candidate plans require a user choice. A completed plan
receives task/bug work only when the request names it. Record the attachment
and its reason in the ledger entry.

`resume [<plan>] [<unit-id>]` continues recorded work (mode-resume.md). Its plan
selector may also be `000_adhoc`; its unit ID names OPEN, pending-closure,
BLOCKED, or suspended work (`N.M`, `P<N>`, `V<NNN>`, `V<NNN>-C<n>`, `T-A<NNN>`,
`B-A<NNN>`), never a TODO unit. A single argument matching the unit-ID grammar
is a unit ID; select a plan named like one by number or path. Without a plan, a
unit ID resolves to the unique plan or ledger that records it as resumable;
several matches require a choice. Its options and prefix apply to that
invocation only.

A selector limits scope even under full autonomy. Only Execute and Execute
verify set the saved execution scope; Task, Bug, and Verify run their own unit
without replacing it (execution-contract §1). Resume continues the saved
execution scope. A different explicit Execute selector replaces it and its
overrides; the same selector on a RUNNING or BLOCKED scope continues it. When an
explicit Execute or Execute verify selector would replace a RUNNING or BLOCKED
saved execution scope with a different one, ask the user before replacing it.
Completing one selected sub-phase does not start later sub-phases outside scope.
A sub-phase scope ends at that sub-phase's closure and never includes its phase
closure P<N>; P<N> runs under a phase or plan scope, for example
`execute 003 phase_02` once its sub-phases are DONE.
