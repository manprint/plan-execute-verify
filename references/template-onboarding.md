# Onboarding document template

Use for Onboard only. Default target: docs/onboarding.md at the repository root.
Replace placeholders with observed facts, explicitly labelled inferences, or a
specific unknown/N/A. Do not create a fake plan or STATE.md to fill this template.
Keep existing content outside the managed block. An existing unmarked document
needs an agreed merge/location, not wholesale replacement.

```markdown
<!-- plan-execute-verify:onboarding:begin -->
# Repository onboarding

> Context snapshot, not an execution plan, live progress board, or audit verdict.
> Recheck current sources and read the selected STATE.md/ledger before resuming.

## Observation and coverage
- Observed: <date/time and timezone>; inspector: <actual agent/reviewer or not reviewed>.
- Repository/worktree: <path>; branch: <name/detached/unavailable>; HEAD: <SHA/unavailable>.
- Relevant pre-existing changes: <paths and staged/unstaged/untracked state; ownership unknown unless evidenced>.
- Focus: <repository-wide orientation or selected plan/path>.
- Inspected: <source areas and state/ledger/report revisions or locators>.
- Not inspected / unavailable: <areas, tooling, environment and limits>.
- Inspection checkpoint: <complete for stated coverage, or next source/question>.

## Purpose and source map
<Documented purpose; inferred behavior clearly labelled; unknown user goals.>

| Component / entrypoint | Responsibility / principal flow | Source path and symbol |
|------------------------|---------------------------------|------------------------|
| <component> | <concrete behavior/boundary> | <locator> |

## Stack, conventions and constraints
- Versions: <manifest ranges, resolved versions and sources; installed versions only if checked>.
- Instructions/conventions: <paths and relevant rules>.
- Data/integrations: <public interfaces, schemas, ownership and compatibility limits>.
- Sensitive/generated areas: <paths, reason and applicable restrictions>.

## Command inventory
| Purpose | Command and cwd | Setup and definition source | Evidence / execution status |
|---------|-----------------|-----------------------------|-----------------------------|
| <build/test/run/lint> | <exact command and cwd> | <prerequisites and path> | <not run / historical result with revision / actual result and tested baseline> |

<Required variable names only, never secret values. No test-pass claim from inspection.>

## Work context — observed snapshot
- Discovered records: <links to real plan STATE/overview, ad-hoc ledgers, or none in inspected locations>.
- Selected focus / unresolved choice: <plan identity/revision or candidates with reason>.
- Recorded progress: <brief summary sourced to state/ledger; no copied phase board>.
- Evidence inspected: <specific artifacts/test/review/commit references and limits>.
- Current verification: <checks actually run or not rerun; not a verdict>.
- Open work / owner: <unit/attempt/step, pending closure or suspended audit; source reference>.
- Saved scope, roster and runtime settings: <source references and relevant effective values, or absent>.
- Next eligible work: <source reference and prerequisites; distinguish it from current invocation scope>.

## Uncertainty and handoff
| Question / discrepancy | Evidence / missing evidence | Impact and resolution owner |
|------------------------|-----------------------------|-----------------------------|
| <specific question or none> | <source> | <limitation and next action> |

## Recommended next action — not executed
- Recommendation: <action and why the observed evidence supports it>.
- Preconditions / user choice: <none, or exact outstanding question/authority>.
- Command or natural-language handoff: <actual supported syntax/paths/IDs; no invented selector>.
- Scope/settings consequences: <what it would resume/start and inherited commit behavior>.
- Read next: <ordered paths/sections/symbols needed by the next agent>.

<If the goal is unknown, ask for it instead of leaving a seemingly runnable placeholder.
If evidence is insufficient, provide the supervisor handoff rather than an execute command.>
<!-- plan-execute-verify:onboarding:end -->
```

The work summary and recommendation are observations at the stated baseline.
Only the original state/ledger/report owns progress; later modes never update
this document instead of their required records. Refresh relevant sources on
reuse, including dirty contents even when HEAD is unchanged.
