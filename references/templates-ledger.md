# Ledger templates — tasks and bugs

Append entries with stable T-A<NNN> / B-A<NNN> IDs before implementation.
Never erase entries; update their checkpoint/outcome, preserving changes in
intent as revisions. In a real plan STATE.md owns live status; the ledger links
to it and carries the durable mini-plan/evidence. In 000_adhoc the entry itself
owns live status because there is no STATE.md.

Use execution-contract.md for ownership, settings, recovery, reviews, and commits.

## Shared entry

````markdown
## <T-A/B-A><NNN> — <title>

- Date / actual agent: <value>
- Request: <observable requested outcome>
- State owner: <STATE.md unit link, or this entry in 000_adhoc>
- Plan impact: <affected decisions/units, or n/a — no plan>
- Related findings: <IDs or none>
- Settings: full-autonomous:<true|false>; WIP commits:<on|off>
- Identity: plan <folder ID or 000_adhoc>; unit <ID>; attempt <n>
- Baseline / branch: <starting HEAD, branch, pre-existing changes to preserve>
- Assignment/reviewer: <configured worker, required supervisor>
- Files: <read/write paths, symbols, owned changes>
- Contract: <inputs, outputs, errors, preserved behavior, exclusions>
- Preconditions: <concrete prerequisites>
- Steps:
  1. S1 — <action>; expected <postcondition>.
  2. S2 — <action>; expected <postcondition>.
- Tests: <names/paths/fixtures/assertions/commands/discovery; justified N/A if applicable>
- Done: <checkable result, gates/review, docs/reconciliation, configured commit>

### Checkpoint
<In a real plan link STATE.md §6; do not duplicate live state here.
In 000_adhoc: OPEN|DONE|BLOCKED, owner, completed steps, actual changes, next step,
last checks, pending resources, and stop reason. Persist before handoff.>

### Outcome and evidence
- Changes: <actual changes>
- Gates: <commands, actual results/discovery, tested revision/diff>
- Review: <reviewer, inspected change, checks, verdict>
- README: <affected sections, or no user-visible change>
- Plan reconciliation: <decisions/contracts/tests updated, or N/A>
- Commit: <uncommitted or unit:ID:attempt; resolve with PEV identity trailers>
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
