# Verify mode — hard review of the implementation against the plan

`/plan-execute-verify verify [<plan>]` answers one question: *does the
implementation match the plan, completely and exactly?* It **never writes
production code**, never fixes what it finds, never rewrites phase files. Its
only writes are the audit trail under `verify/` and the state-file corrections of
V5 — the report is the deliverable.

Adversarial stance: assume the plan was followed sloppily and try to prove it. A
clean report must be earned by evidence, not by the absence of looking. Treat
`STATE.md` as a **claim**, never as proof — the repo is the truth.

The audit is itself a **unit of work**: open it in `STATE.md` §1 as
`Type: verify`, `ID: V<NNN>`, `Status: OPEN` before gathering evidence, and close
it in V5. An audit interrupted halfway then resumes from §1 and §6 instead of
starting over.

---

## V1 — Load the claim

Resolve the plan folder (SKILL.md, "Plan selection"). Read `STATE.md`, then
`overview.md`, then the ad-hoc ledgers `tasks.md` and `bugs.md` when present.
Extract: the §11 board, the §4 ledger (every closed unit, planned or ad-hoc),
phases/sub-phases marked `DONE`, `D*` decisions, `I-*`
invariants, `R<n>` external facts, gate commands, test IDs, README obligations,
and the `T-A*` / `B-A*` entries that explain out-of-plan changes.

Then read `verify/index.md` when it exists: findings still `OPEN` from earlier
audits, and the ones marked `FIXED` (re-check those — a fix that regressed is
worse than a fix that never happened). Do not re-read whole old reports; the
register carries what you need. Open a single previous report only when a
finding's detail is required.

Read the phase files for every phase not marked `TODO` — those are the
specifications you audit against.

## V2 — Establish ground truth

Delegate evidence gathering to **one batched exploration agent** (or one per phase
group when the diff is large — never one per sub-phase). It returns compact
structured facts, no file dumps:

- what actually changed: `git log` / `git diff` since the plan started, files
  added/modified, the current state of each file the plan named. When WIP commits
  are on, the per-unit commits are primary evidence: each closed unit should have
  one, and its sha should match the §4 row.
- for each `DONE` sub-phase: do the named files, symbols, and anchors exist, and
  does the code do what the **Change** field describes
- do the named tests exist, with the asserted behavior, wired into the suite
- README: were the sections that phase promised actually updated, and only with
  user-facing content

Then run the gates from `STATE.md` §3 (fmt, lint, unit, e2e) and record the real
results. If a gate cannot run, say so — never assume green.

## V3 — Audit dimensions

Check every one; report the ones that hold as verified, not silently.

1. **Completeness** — every sub-phase marked `DONE` is actually fully done; no
   silently dropped sub-phase, file, test, or done-criterion.
2. **Fidelity** — the code does what the **Change** field says, not something
   adjacent. Different data structure, default, error handling, renamed flag: all
   divergences.
3. **Tests** — named tests exist with the stated assertions, actually run, and
   pass. Tests weakened, skipped, marked ignore, or asserting less than the plan
   required are findings.
4. **Gates** — fmt/lint/test really pass now, on the current tree.
5. **Decisions and invariants** — every `D*` decision is respected in code; every
   `I-*` invariant still holds and has the regression test the plan required.
6. **External facts** — third-party API usage matches the `R<n>` sources and the
   pinned version; no invented options or signatures.
7. **Rules of the plan** — existing project structure followed, no gratuitous new
   directories, professionalism standard respected (no emojis, no informal text),
   per-phase README updated and free of implementation detail.
8. **Scope creep** — behavior, dependencies, or files the plan never asked for and
   that no `D*` row, `STATE.md` §8 deviation, or `T-A*` / `B-A*` entry covers.
9. **Regressions** — previously passing behavior now broken; phases claimed
   "shippable alone" that are not.
10. **State accuracy** — `STATE.md` matches reality: §1 `Status` and
    `Next action:`, the §4 ledger, §5 files touched, §7 verification table, §8
    deviations, and the §11 board. Stale or optimistic state is a finding, and a
    serious one — later sessions trust it. A §1 left `OPEN` with an empty §6, or
    a §11 row disagreeing with §4, is a finding in its own right: the resume
    guarantee is broken. With WIP commits on: a §4 sha that does not exist, a
    closed unit with no commit, or a `wip:` commit still at `HEAD` while §1 reads
    `none` are all `stale-state` findings.
11. **Ad-hoc work reconciliation** — the `task` / `bug` history and the plan still
    agree, both directions:
    - every change in the diff the plan does not explain is covered by a `T-A*` or
      `B-A*` entry (otherwise: scope creep / unexplained change)
    - every ledger entry is real in the tree, carries its test, and its README and
      state updates were made
    - every ledger entry that invalidated the plan left the plan updated: a
      superseding `D*` row, an adjusted `I-*`, an edited not-yet-executed phase
      file, a `SKIPPED` sub-phase with a reason. A ledger entry that silently
      contradicts a pending phase file is a `BLOCKER` — the next phase would be
      executed against a false specification.
    - bug fixes whose root cause is a plan assumption are reflected in the plan,
      not only in `bugs.md`
12. **Previous findings** — every finding still `OPEN` in `verify/index.md` is
    re-checked and either confirmed open or closed as `FIXED` with evidence; every
    finding already `FIXED` is re-tested, and a broken fix is raised again as
    `unfixed-regression`. Findings never disappear silently: one that no longer
    applies is `OBSOLETE` with the reason, one the user decided to live with is
    `ACCEPTED`, never quietly dropped.

## V4 — Report (always on disk)

The report is a **durable artifact**, not a chat message that scrolls away: its
correction plan is meant to be executed later, possibly in another session.

```
docs/plans/<NNN>_plan-<FeatureName>/verify/
├── index.md                          # audit register — every report, every finding, its status
├── verify_001_<YYYY-MM-DD>.md
├── verify_002_<YYYY-MM-DD>.md
└── …
```

- Create `verify/` on demand. The report number is the highest existing report
  number in `verify/` plus one, zero-padded to 3 digits (`001` first). File:
  `verify_<NNN>_<YYYY-MM-DD>.md`. Report ID: `V<NNN>` — the `V` prefix belongs to
  the ID and the selector (`execute verify V002`), never to the filename. Earlier
  reports are never overwritten or renumbered.
- **Finding IDs are global and stable**: `V<NNN>-F<n>` (e.g. `V002-F03`).
  Referenced by later runs, by `execute verify`, by `STATE.md` §9, and by the
  ledgers — never reused for a different finding.
- `index.md` is the register a later session reads first: one row per report
  (number, date, verdict, counts) and one row per finding (ID, severity, category,
  one-line title, status `OPEN` / `FIXED` / `ACCEPTED` / `OBSOLETE`, where it was
  closed). Template: `references/templates-audit.md` §2.
- Print the same content in chat, complete — the file is the record, not a
  substitute for answering the user.

Structure (full template: `references/templates-audit.md` §1):

1. **Verdict** — one line: `PASS` (no blocker, no major), `PASS WITH FINDINGS`, or
   `FAIL`, plus the phases audited and the commit range reviewed.
2. **Phase table** — phase · claimed status · verified status · findings count.
3. **Findings** — one block each, ordered by severity, each with:
   - `V<NNN>-F<n>` · status `OPEN` · severity `BLOCKER` / `MAJOR` / `MINOR`
   - category: missing · divergent · untested · failing-gate · rule-violation ·
     scope-creep · regression · stale-state · unfixed-regression
   - **where**: `path:line`, plus the plan reference (`phase_02.md § 1.2`, `D3`,
     `I-1`, `T-RL1`, `R2`)
   - **expected** (quoted from the plan, one line) vs **actual** (repo evidence,
     one line)
   - **why it matters**, one line
   - **correction**: the concrete fix, scoped as an executable action
4. **Ad-hoc work** — table of the `T-A*` / `B-A*` entries in range: ID · what it
   changed · reconciled with the plan? · findings. Plus any diff hunk explained by
   neither the plan nor a ledger entry.
5. **Verified clean** — the dimensions and sub-phases checked and holding, listed
   compactly. This is what makes the report trustworthy.
6. **Correction plan** — findings turned into an ordered, actionable list, blockers
   first, each mapped to its finding ID and its phase/sub-phase, with the smallest
   change that closes it. Say explicitly which corrections belong to a phase
   already marked `DONE` (that phase must reopen). Write it so a cold session can
   execute it from this file alone: exact files, exact change, exact test to add or
   repair, exact done-criterion — the same standard as a phase file's sub-phase.
7. **State re-sync** — the exact edits `STATE.md` and the ledgers need to tell
   the truth again, §11 board included.
8. **Not verifiable** — anything that could not be checked, and why (gate could not
   run, missing credentials, external service). Never fill these gaps with
   assumptions.

Every finding must carry repo evidence. No finding on suspicion alone; a suspicion
you cannot prove goes under "Not verifiable" as a flagged doubt.

## V5 — Close

- Do **not** apply the corrections. Offer: *"want me to apply the correction
  plan?"* — that is a separate run, `/plan-execute-verify execute verify`, which
  can happen later or in a fresh session because the plan is on disk.
- Update `verify/index.md`: add the report row, add every new finding as `OPEN`,
  re-evaluate findings from earlier reports — `FIXED` where this audit proves them
  closed, `OPEN` where still failing, and a new `unfixed-regression` finding when
  something previously `FIXED` broke again.
- Close the audit unit in `STATE.md` and write its result there: §4 ledger row
  (`Type: verify`, `ID: V<NNN>`, verdict and finding counts), §7 verification
  table (real gate results, date), §9 blockers (every `OPEN` `BLOCKER` finding,
  by ID), a §8 row when the audit found a deviation the plan never recorded, the
  §11 audits row for this report, and §11 phase/test/docs statuses corrected
  wherever they claim something the audit disproved. §1 goes back to
  `Status: none` with `Next action:` naming what should happen next (typically
  `execute verify V<NNN>`). These are state-file corrections, not code changes;
  they keep the next session from trusting a false state.
- Beyond those, verify writes nothing: no production code, no phase-file rewrite,
  no invented ledger entry — missing ledger reconciliation is reported as a
  finding, and appended to `tasks.md` / `bugs.md` only if the user asks.
- Chat closing line stays terse: verdict, counts by severity, report path, count
  of findings still `OPEN` from previous audits.

Before returning, run the **Verify-mode checklist** in
`references/quality-checklist.md`.

## Verify-mode output contract

Verify never commits, whatever the WIP-commit setting says — it writes no
production code, so it has no unit to commit. It produces no plan folder. It
writes
`<plan-folder>/verify/verify_<NNN>_<YYYY-MM-DD>.md` plus the
`<plan-folder>/verify/index.md` register, and the `STATE.md` corrections that keep
it from lying. Never production code, never a phase-file rewrite. The same report
is printed in chat in full.

Token note: evidence gathering is batched into one agent returning
`path:line — fact` lines. Read a phase file once. The report is the only long
output, written once.
