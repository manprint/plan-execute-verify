# Quality checklists — the pre-return gates

Run the checklist for the mode you are in, before declaring done. Fast, and not
optional: if an item fails, fix it before returning. An `agent-1` task, or a
self-review in single-agent mode.

- **Plan-mode checklist** — the phase-F gate.
- **Coherence checklist** — `execute` · `task` · `bug`.
- **Verify-mode checklist** — `verify`.

---

# Plan-mode checklist

## Completeness

- [ ] Every template section present, or explicitly N/A with a reason.
- [ ] The **reference scenario** in `overview.md` is concrete and observable, and
      maps one-to-one onto the acceptance tests named in the **Verification
      summary** and in the phase files' e2e fields.
- [ ] Every non-obvious design choice has a `D*` row with a *consequence*.
- [ ] The **clarification gate (D2) ran before any file was written**: the user saw
      the phase skeleton and one batched, grouped, numbered set of grey-area
      questions covering **every** phase, each with concrete options, a recommended
      default, and its blast radius (which phases/sub-phases the answer changes).
- [ ] Every user answer is a `D*` row tagged with its source (`D7 (user, Q3)`);
      no answer silently dropped. Defaults adopted because the user did not decide
      are stated in `overview.md` **Open questions** and mirrored in `STATE.md` §9
      — never applied silently.
- [ ] No phase file contains a guess that should have been a D2 question.
- [ ] The **reuse map** lists real `path:line` anchors, not "somewhere in X".
- [ ] External documentation was researched whenever the plan touches a third-party
      library, SDK, service, protocol, spec, version upgrade, or a
      security-sensitive area — or the plan states in one line why it was not
      needed (purely internal work).
- [ ] Every external API, option, header, or wire-format detail is backed by an
      `R<n>` source checked against the **version pinned in the repo**, not from
      memory; the **References** table carries source URLs and version/date; each
      phase file cites the `R<n>` entries it depends on.
- [ ] Anything unconfirmed is marked `UNVERIFIED` and raised as an open question —
      no invented APIs, flags, or signatures. No documentation pages pasted into
      the plan: one-line facts plus URLs, verbatim only for
      signatures/headers/wire formats to reproduce.
- [ ] `overview.md` **Interface** gives exact names, types, defaults, and conflict
      rules — or states no user-facing surface changes.
- [ ] `overview.md` **Protocol and data-structure changes** states the
      backward-compat strategy explicitly — or states nothing crosses a boundary.

## Decomposition

- [ ] Phase 0 is pure-additive / no-behavior-change where the design allows.
- [ ] Each phase is **independently shippable** and ordered so each builds on the
      last.
- [ ] Every sub-phase has all seven fields: Model · Assignment · Files · Change ·
      Unit tests · e2e tests · Done.
- [ ] **Files** carry line anchors. **Change** cites reuse anchors.
- [ ] Tests are **named** and each has a **checkable assertion** (no "add tests").
- [ ] Done-criteria are verifiable by someone who did not write the plan.
- [ ] Behavior changes (flipped defaults, edited existing tests) are called out
      loudly in the affected phase.
- [ ] **Every phase ends with an `Update README.md` sub-phase**, and the phase
      gates include the README item.
- [ ] Each README sub-phase names the exact sections that phase touches and
      documents **only shipped behavior** — a scaffolding-only phase says so
      explicitly instead of skipping the sub-phase.
- [ ] The README spec stays user-facing (what it does, install, run, commands /
      sub-commands / flags with examples, configuration and defaults, notes, known
      limits, troubleshooting) and asks for **no** implementation detail: no
      module, class, or function names, no file layout, algorithms, refactoring
      notes, phase or plan references, no unshipped roadmap.
- [ ] The README sub-phase says to preserve the existing README structure, tone,
      and language (edit, not rewrite), and its done-criterion is that a new user
      can install and use the feature from the README alone.
- [ ] Any opt-in / legacy / `N=1` path is asserted byte-identical with a regression
      test (invariant + test).
- [ ] Every sub-phase is written for a **weak implementer**: step-by-step, no
      ambiguity, exact symbol names, no assumed context from other phases.
- [ ] Sub-phases that add files instruct the implementer to follow the existing
      project structure; new directories only if no existing one serves the same
      purpose.
- [ ] No emojis or informal decorations in any plan file or deliverable spec.

## Agent assignment

- [ ] **Every** sub-phase has a model tag containing the exact configured
      assignment (`agent-N:name` or `agent:name`); legacy no-prefix plans may
      retain the Opus/Sonnet/Haiku aliases.
- [ ] `agent-1` owns architecture, acceptance assertions, and final review; in
      single-agent mode the plan labels the review as self-review.
- [ ] Exploration and mechanical work goes to `agent-3+` when present, otherwise
      `agent-2`; non-trivial implementation to `agent-2` when present, otherwise
      `agent-1`.
- [ ] The **Model-assignment summary** table is the last section of `overview.md`
      and is consistent with the per-sub-phase tags.

## Verification

- [ ] `overview.md` **Verification summary** names the exact gate commands
      (fmt / lint / unit / e2e), identical to `STATE.md` §3 and to the per-phase
      gate blocks — no drift between the three.
- [ ] Unit + e2e test locations and run instructions are stated, including any
      rebuild/permission caveats.
- [ ] Acceptance criteria list the `T-*` IDs that prove the reference scenario.

## Token discipline

- [ ] No large code blocks where a `path:line` anchor + a 2-line change would do.
- [ ] No invariant re-explained across phases — tagged once (`I-*`), referenced.
- [ ] The plan is self-contained: an implementer needs **only** the phase file plus
      the repo to execute any sub-phase without reading the others.

## Output — multi-file structure

- [ ] Folder `docs/plans/<NNN>_plan-<FeatureName>/` created under the repo root,
      with `docs/` and `docs/plans/` created if missing. No plan folder in the repo
      root. `<NNN>` is the highest existing plan number plus one (`001` if
      `docs/plans/` was empty), zero-padded, and no existing plan folder was reused
      or renumbered.
- [ ] `overview.md` present, with: goal and reference scenario, `D*` decisions,
      open questions, architecture summary, interface, protocol/data-structure
      changes, phase table with file links, reuse map, references, invariants, risk
      register, verification summary, model-assignment summary.
- [ ] One `phase_NN.md` per phase (1-indexed, zero-padded; phase 0 →
      `phase_01.md`), fully self-contained (readable cold, without `overview.md`).
- [ ] `overview.md` is **small** — detail belongs only in phase files.
- [ ] **No second status file was created.** `STATE.md` is the only place a status
      is recorded; nothing else claims phase, test, or doc progress.
- [ ] No production code was written by this skill.
- [ ] Closing message is terse: folder path + one-line phase/assignment summary.

## State file (STATE.md)

- [ ] Present and **initialized by this skill**, not left as a stub.
- [ ] §0 protocol present: read-first-on-session-start and
      update-after-every-sub-phase rules, written so an agent with no other context
      can follow them.
- [ ] §2 feature recap is self-contained — the first sub-phase is executable
      without opening `overview.md`.
- [ ] §3 lists the real build / fmt / lint / unit / e2e commands and setup caveats,
      identical to the phase gate commands and the `overview.md` verification
      summary (no drift), plus the **WIP commits** setting (`off` at init unless
      the invocation enabled it).
- [ ] §1 is a **claim**, shaped for the two-state resume: `Type`, `ID`, `Status`,
      `Intent`, `Next action:`, `Assigned`, `Repo state`. At init `Status` reads
      `none` and `Next action:` names an existing `phase_NN.md` and sub-phase.
- [ ] §0 states the **open-before / close-after** protocol explicitly, so an agent
      that reads only this file knows to claim a unit before editing code.
- [ ] §4–§10 exist and are empty-but-shaped at init (`none`, empty tables); §6
      reads `none — tree consistent`. Exception: §9 already carries every question
      the user deferred at the clarification gate, with the default applied and the
      sub-phase it affects.
- [ ] §4 ledger carries a `Type` column and accepts every unit type (`sub-phase`,
      `task`, `bug`, `verify`, `correction`), not only planned sub-phases.
- [ ] §11 progress board present and initialized: one row per phase (all `TODO`),
      one row per planned `T-*` test, one docs row per phase README sub-phase, and
      an audits table (empty at init).
- [ ] `overview.md` header and **every** phase file carry the state contract (read
      `STATE.md` first, finish or revert an `OPEN` §1, run the §3 gates to check
      §1/§7/§11, open the sub-phase before editing and close it after).
- [ ] Every sub-phase `Done` field requires the unit closed in `STATE.md`.
- [ ] No code dumps and no narrative — one line per ledger entry; verbatim text
      only for failing gate output.

---

# Coherence checklist (execute · task · bug)

Run after **every** sub-phase, task, or bug fix, before reporting it done. Single
purpose: a `/plan-execute-verify verify` run right now must produce no finding
caused by this work.

- [ ] Code does exactly what was specified (sub-phase `Change`, or the mini-plan
      shown to the user) — no silent extra scope.
- [ ] Named tests exist with the stated assertions and pass; for a bug, the
      regression test failed before the fix.
- [ ] Gates run and green (full suite for bug fixes); failures reported, never
      hidden.
- [ ] The unit was **opened** in `STATE.md` §1 before any code was touched, and
      §6 was set at that moment — not written retroactively after the fact.
- [ ] The unit is **closed**: §1 points at the next unit with `Status: none`, §4
      ledger row appended with the right `Type`, §5 files, §6 back to `none —
      tree consistent`, §7 verification, §8 deviations, §9 blockers, §10 dead
      ends, §11 board, header timestamp.
- [ ] `README.md` updated when user-visible behavior changed — user guide only, no
      implementation detail.
- [ ] Out-of-plan work has a ledger entry: `T-A<NNN>` in `tasks.md` or `B-A<NNN>`
      in `bugs.md`, with files, tests, gates, README, plan impact. IDs sequential
      and never reused.
- [ ] Plan reconciled where the work invalidated it: superseding `D*` row, adjusted
      `I-*`, edited **not-yet-executed** phase files whose anchors or assumptions
      changed, sub-phases marked `SKIPPED` with a reason, new sub-phases added
      where the plan should own the work. No pending phase file still states
      something this work made false.
- [ ] `verify/index.md` updated when the work closed, reopened, or invalidated a
      finding — status changed with evidence, mirrored in the report file. Nothing
      fixed silently.
- [ ] When applying a correction plan: each finding re-verified before being marked
      `FIXED`, findings that could not be closed left `OPEN` with the reason, and
      phases reopened (`IN_PROGRESS`) where a `DONE` phase was corrected.
- [ ] Ad-hoc work in `docs/plans/000_adhoc/` (no plan in the repo): only the ledger
      entry, the tests, the repo's own gates, and the `README.md` update are
      required — no `STATE.md` or plan files invented there, and the ledger's
      **Plan impact** reads `n/a — no plan`.
- [ ] Commits match the setting in `STATE.md` §3: with WIP commits **off**,
      nothing was committed and the `Commit` column says `uncommitted`; with them
      **on**, the closed unit has exactly one commit, its sha is in the §4 row,
      and an interruption left a `wip(<id>)` commit.
- [ ] Nothing was pushed. Only the unit's own files (§5) plus the plan files were
      staged — no `git add -A`, and unrelated dirty files were reported, not
      swept into the commit. The branch committed to was named in the closing
      line.
- [ ] Ambiguities were raised to the user instead of resolved by guessing.

---

# Verify-mode checklist

- [ ] The audited plan folder was resolved explicitly and named in the report, and
      it is a real plan (never `000_adhoc`, which holds no phases).
- [ ] Every phase not marked `TODO` was audited against its phase file.
- [ ] Ground truth came from the **repo and the gates**, not from `STATE.md`
      claims. The gate commands were actually run; anything that could not run is
      listed under **Not verifiable**, never assumed green.
- [ ] The resume guarantee was checked: no §1 left `OPEN` with an empty §6, and no
      §11 row disagreeing with §4 or with the repo. Either is a finding.
- [ ] All twelve audit dimensions were covered: completeness, fidelity, tests,
      gates, decisions/invariants, external facts, plan rules (structure,
      professionalism, per-phase README), scope creep, regressions, state accuracy,
      ad-hoc reconciliation, previous findings.
- [ ] `verify/index.md` was read first: every `OPEN` finding re-checked, every
      `FIXED` finding re-tested, a broken fix raised as `unfixed-regression`, and
      nothing dropped silently (`OBSOLETE` / `ACCEPTED` carry a reason).
- [ ] `tasks.md` and `bugs.md` were read: every unexplained diff hunk is a finding,
      every ledger entry is real in the tree with its test, and every entry that
      invalidated the plan left the plan updated (a ledger entry contradicting a
      pending phase file is a `BLOCKER`).
- [ ] Every finding has a stable ID `V<NNN>-F<n>`, a status, severity, category,
      `path:line`, the plan reference, expected vs actual, impact, and a concrete
      correction. No finding rests on suspicion — unprovable doubts go under **Not
      verifiable**.
- [ ] The **correction plan is executable from the report file alone** by a cold
      session (exact files, change, test, done-criterion per item — the same
      standard as a phase file's sub-phase), ordered by severity, mapped to
      phase/sub-phase, flagging corrections that reopen a phase already marked
      `DONE`.
- [ ] **Verified clean** lists what was checked and holds, so the report is
      trustworthy rather than merely short.
- [ ] **State re-sync** states the exact `STATE.md` edits needed, §11 included.
- [ ] The report was written to
      `<plan-folder>/verify/verify_<NNN>_<YYYY-MM-DD>.md`, `<NNN>` being the
      highest existing report number plus one, without overwriting or renumbering
      an earlier report.
- [ ] `verify/index.md` updated: report row added, new findings added as `OPEN`,
      carried-over findings re-statused with evidence, open blockers listed.
- [ ] The audit was closed as a unit in `STATE.md`: §4 row (`Type: verify`), §7,
      §9, the §11 audits row, and §11 statuses corrected wherever they claimed
      something the audit disproved.
- [ ] No production code changed, no phase file rewritten, no correction applied,
      no ledger entry invented, and nothing committed.
- [ ] Full report given in chat; closing line terse (verdict, counts by severity,
      report path, findings still `OPEN` from earlier audits) with an offer to run
      `/plan-execute-verify execute verify`.
