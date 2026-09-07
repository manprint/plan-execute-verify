# Ledger templates — tasks.md and bugs.md

Append-only ledgers for out-of-plan work, created on demand in the plan folder by
the first `task` / `bug`. In `docs/plans/000_adhoc/` these are the only two files
present. Plan-file templates live in `output-template.md`; audit templates in
`templates-audit.md`.

`<angle brackets>` = replace. `…` = repeat the block as needed.

---

## 1. tasks.md — task ledger

Created on demand in the plan folder by the first `task`. Append-only; entries are
never edited away. This is what tells a later `verify` that an out-of-plan change
was intentional. In `docs/plans/000_adhoc/` this file and `bugs.md` are the only
files, and **Plan impact** reads `n/a — no plan`.

````markdown
# <Feature name> — Task ledger

> Out-of-plan changes made with `/plan-execute-verify task`. Append-only.
> IDs are never reused. Every entry must be reconciled with the plan.

## T-A<NNN> — <one-line title>
- **Date:** <date> | **Agent:** <agent-N:name>
- **Request:** <what the user asked for, one line>
- **Change:** <what was actually done, one line per file group>
- **Files:** `path:line`, …
- **Tests:** `<test name>` — <assertion>; or "none — <explicit reason>"
- **Gates:** `<cmd>` → pass | fail
- **README:** updated `<sections>` | not user-visible
- **Plan impact:** none | <what was reconciled: superseding `D<n>`, adjusted
  `I-<n>`, edited `phase_<NN>.md § <N.Y>`, sub-phase marked `SKIPPED`, new
  sub-phase added>
- **Related:** phase <N> § <N.Y> (or "outside any phase")
````

---

## 2. bugs.md — bug ledger

Same rules as `tasks.md`, plus the diagnosis. A bug entry without a root cause and
a regression test is incomplete. In `docs/plans/000_adhoc/`, **Plan impact** reads
`n/a — no plan`.

````markdown
# <Feature name> — Bug ledger

> Defects fixed with `/plan-execute-verify bug`. Append-only.
> IDs are never reused. Every entry must be reconciled with the plan.

## B-A<NNN> — <one-line title>
- **Date:** <date> | **Agent:** <agent-N:name> | **Severity:** <blocker|major|minor>
- **Symptom:** <observable failure: command/input → wrong result>
- **Reproduction:** `<command or test that showed it>`
- **Root cause:** <one line> — `path:line`
- **Fix:** <what changed, one line per file group>
- **Files:** `path:line`, …
- **Regression test:** `<test name>` — fails before the fix, passes after
- **Gates:** `<cmd>` (full suite) → pass | fail
- **README:** updated `<sections>` | not user-visible
- **Plan impact:** none | <a plan assumption proved wrong: superseding `D<n>`,
  adjusted `I-<n>`, edited pending `phase_<NN>.md § <N.Y>` that shared the faulty
  assumption>
- **Related:** phase <N> § <N.Y> (or "outside any phase")
````
