# Ledger templates — tasks and bugs

Append entries with stable T-A<NNN> / B-A<NNN> IDs before implementation,
allocated as the highest existing number in that ledger plus one and never reused.
Never erase entries; update their checkpoint/outcome, preserving changes in
intent as revisions. In a real plan STATE.md owns live status; the ledger links
to it and carries the durable mini-plan/evidence. In 000_adhoc the entry itself
owns live status because there is no STATE.md. A PROPOSED or WITHDRAWN entry was
never opened in STATE.md, so it owns its status in the ledger also in a real
plan (mode-taskbug.md approval gate).

Use execution-contract.md for ownership, settings, recovery, reviews, and commits.

## Shared entry

````markdown
## <T-A/B-A><NNN> — <title>

- Date / actual agent: <value>
- Request: <observable requested outcome>
- State owner: <STATE.md unit link, or this entry in 000_adhoc>
- Attachment: <plan named in the request or whose scope/contracts/files it changes,
  with reason; or 000_adhoc>
- Plan impact: <affected decisions/units, or n/a — no plan>
- Related findings: <IDs or none>
- Settings: full-autonomous:<true|false>; WIP commits:<on|off>; roster: <saved
  or invocation prefix>; executor power: <attached plan's level, or low>;
  deadline: <dd-mm-yyyy_hh_mm, or none> — this
  invocation only; never written to a plan's §3
- Identity: plan <folder ID or 000_adhoc>; unit <ID>; attempt <n>
- Approval: mini-plan <written|validated> by agent-1:<name>, or self-review;
  user <approved at time | not required: full-autonomous:true | pending:
  PROPOSED | rejected: WITHDRAWN, reason>; proposal snapshot tree <tree ID>
- Baseline / branch: <starting HEAD, working-tree snapshot tree, branch,
  pre-existing changes to preserve>
- Assignment/reviewer: <assigned → actual worker, required supervisor;
  self-review when they are the same>
- Files: <read/write paths, symbols, owned changes>
- Contract: <inputs, outputs, errors, preserved behavior, exclusions>
- Preconditions: <concrete prerequisites>
- Research: <applicable plan R IDs, or in 000_adhoc the question, source/version/
  dates, supported fact, labelled inference/local result and decision impact;
  justified N/A when not needed. Required UNVERIFIED claims block implementation
  unless the user ACCEPTED them with risk and guard.>
- Steps:
  1. S1 — <action>; expected <postcondition>.
  2. S2 — <action>; expected <postcondition>.
- Tests: <names/paths/fixtures/assertions/commands/discovery; justified N/A if applicable>
- Done: <checkable result, gates/review, docs/reconciliation, configured commit>

### Checkpoint
<In a real plan link STATE.md §6; do not duplicate live state here, except in a
PROPOSED or WITHDRAWN entry. In 000_adhoc, and in such an entry:
PROPOSED|OPEN|IN_REVIEW|DONE|BLOCKED|WITHDRAWN, owner, completed steps, actual
changes, next step, last checks, pending resources, and stop reason (`handoff`
with trigger user|deadline, time, and released ownership when Handoff mode
stopped it; mode-handoff.md). If research is active, retain inspected sources,
unanswered questions, and next lookup. Persist before handoff.>

### Outcome and evidence
- Changes: <actual changes>
- Gates: <commands, actual results/discovery, tested revision/diff>
- Review: <reviewer, inspected change, checks, verdict>
- README: <affected sections, or no user-visible change>
- Plan reconciliation: <decisions/contracts/tests updated, or N/A>
- Commit: <uncommitted base-tree..closure-tree, unit:ID:attempt, or
  handoff:ID:attempt once a handoff commit holds it; resolve with PEV identity
  trailers>
````

For a bug, additionally require:
- Symptom and reproduction command/input, expected vs actual.
- Root cause with source evidence.
- Regression test's before-fix failure and after-fix pass, or an explicitly
  approved alternative verification.
- Affected plan assumptions and future units requiring correction.

In 000_adhoc, the completion commit contains the finished entry itself. Use the
stable commit reference, never its own SHA. An unresolved required reference means
the completion transaction is pending and must be recovered before another unit.
