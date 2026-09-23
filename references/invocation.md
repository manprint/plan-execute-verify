# Invocation, settings, and selectors

Read when interpreting `/plan-execute-verify` command syntax. Options and the
agent prefix belong to the leading run of tokens, in any order. Stop parsing at
the first token that is neither; the remainder is the mode and its arguments.
Thus `task add a --json flag` keeps `--json` in the description.

| Leading option | Meaning | Default |
|----------------|---------|---------|
| `full-autonomous:true` | Continue selected scope; commit verified units locally | `false` |
| `full-autonomous:false` | Normal execution; no completion commits by this option | — |
| `--wip-commit` | Commit completed code units and interrupted WIP | off |
| `--no-wip-commit` | Disable WIP behavior; autonomous commits still apply | — |

Reject unknown leading options, invalid boolean values (including
`full-autonomous:yes`), duplicate autonomy options, conflicting WIP options,
and invalid agent prefixes before work starts. Each setting resolves separately:
explicit invocation > selected plan's STATE.md §3 > default. Store explicit
overrides in §3. Without a plan, task/bug settings apply only to that invocation
and are recorded in their ledger. Plan options preset later execution but never
authorize implementation or planning commits. Onboard options are inspection
only and never persist or authorize commits. WIP and autonomy precedence is
detailed in [execution-contract](execution-contract.md).

Agent prefix is `agent:<name>` or a contiguous comma-separated roster
`agent-1:<name>,agent-2:<name>,...`. Names are nonempty tokens without spaces or
commas, passed unchanged to the host. Numbered entries start at 1 without gaps;
reject mixed forms, duplicate indexes, or missing names. A roster with only
`agent-1` is one implementing agent that explicitly self-reviews. Resolve the
roster from explicit prefix > existing plan > legacy Opus/Sonnet/Haiku default.
Validate host availability before dispatch; never silently substitute or claim
a review that did not occur. See [agent-roster](agent-roster.md).

The first token after leading options/prefix selects a mode only if exactly
`onboard`, `plan`, `execute`, `task`, `bug`, or `verify`; otherwise the remainder
is an implicit Plan description. Use `plan task queue` if a feature name begins
with a reserved word. Missing required arguments and invalid selectors are errors,
not permission to fall back to another mode. Options alone do not select work.

Plan selectors are a three-digit number, feature name, or folder path. Execute
also accepts `phase_02`, `1.2`, `§ 1.2`, or `phase_02 § 1.2`. Logical phase 0 is
stored in `phase_01.md`; numeric sub-phase IDs refer to their heading, not the
file suffix. Reject mismatched file/ID selectors. Onboard accepts an optional
plan selector, never a phase/report selector; without one it inventories plans
and ad-hoc ledgers rather than choosing the highest number.

For execution/audit without a selector, use the highest numbered real plan,
ignoring `000_adhoc`; ask when multiple active plans are ambiguous. An explicit
path wins. `execute verify [<plan>] [V<NNN>]` applies corrections from the
selected/active plan's newest report unless an ID is given. V-prefixed report
IDs differ from three-digit plan IDs. A plan literally named `verify` needs its
number/path. Task/bug attaches to the unambiguous active plan, otherwise the
highest numbered plan, or `000_adhoc` when no real plan exists; resolve multiple
active plans before attaching work.

A selector limits scope even under full autonomy. A resume retains it; a new
explicit invocation can change it. Completing one selected sub-phase does not
start later sub-phases outside scope.
