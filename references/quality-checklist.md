# Quality checklist — the phase-F gate

Run this before declaring the plan done. It is fast and it is not optional. If
any item fails, fix it in the plan file before returning. This is an `agent-1`
task, or a self-review when one configured agent performs the whole plan.

This first checklist covers **plan mode**. The modes that write code and the
audit mode have their own checklists further down: **Coherence checklist
(execute · task · bug)** and **Verify-mode checklist**.

## Completeness

- [ ] Every template section is present (or explicitly marked N/A with a reason).
- [ ] The **reference scenario** in `overview.md` is concrete and observable, and
      maps one-to-one onto the acceptance tests named in the **Verification
      summary** and in the phase files' e2e fields.
- [ ] Every non-obvious design choice has a `D*` row with a *consequence*.
- [ ] The **clarification gate (D2) was run before any file was written**: the
      user saw the phase skeleton and one batched, grouped, numbered set of
      grey-area questions covering **every** phase.
- [ ] Each question offered concrete options, a recommended default, and its
      blast radius (which phases/sub-phases the answer changes).
- [ ] Every user answer is recorded as a `D*` row tagged with its source
      (`D7 (user, Q3)`); no answer was silently dropped.
- [ ] Defaults adopted because the user did not decide are stated explicitly in
      `overview.md` **Open questions** and mirrored in `STATE.md` §9 — never
      applied silently.
- [ ] No phase file contains a guess that should have been a D2 question.
- [ ] The **reuse map** lists real `path:line` anchors, not "somewhere in X".
- [ ] External documentation was researched whenever the plan touches a
      third-party library, SDK, service, protocol, spec, version upgrade, or a
      security-sensitive area — or the plan states in one line why it was not
      needed (purely internal work).
- [ ] Every external API, option, header, or wire-format detail in the plan is
      backed by a `R<n>` source, checked against the **version pinned in the
      repo** — not from memory.
- [ ] The **References** table is present with source URLs and version/date, and
      each phase file cites the `R<n>` entries it depends on.
- [ ] Anything that could not be confirmed is marked `UNVERIFIED` and raised as
      an open question — no invented APIs, flags, or signatures.
- [ ] No documentation pages are pasted into the plan; only one-line facts plus
      URLs (verbatim only for signatures/headers/wire formats to reproduce).
- [ ] The `overview.md` **Interface** table gives exact names, types, defaults,
      and conflict rules — or states that no user-facing surface changes.
- [ ] The `overview.md` **Protocol and data-structure changes** section states
      the backward-compat strategy explicitly — or states that nothing crosses a
      boundary.

## Decomposition

- [ ] Phase 0 is pure-additive / no-behavior-change where the design allows.
- [ ] Each phase is **independently shippable** and ordered so each builds on
      the last.
- [ ] Every sub-phase has all seven fields: Model · Assignment · Files · Change ·
      Unit tests · e2e tests · Done.
- [ ] **Files** carry line anchors. **Change** cites reuse anchors.
- [ ] Tests are **named** and each has a **checkable assertion** (no "add tests").
- [ ] Done-criteria are verifiable by someone who didn't write the plan.
- [ ] Behavior changes (flipped defaults, edited existing tests) are called out
      loudly in the affected phase.
- [ ] **Every phase ends with a `Update README.md` sub-phase**, and the phase
      gates include the README item.
- [ ] Each README sub-phase names the exact sections that phase touches and
      documents **only shipped behavior** — a scaffolding-only phase says so
      explicitly instead of skipping the sub-phase.
- [ ] The README spec stays user-facing: what it does, install, run, commands /
      sub-commands / flags with examples, configuration and defaults, notes,
      known limits, troubleshooting.
- [ ] No implementation detail is asked for in the README: no module, class, or
      function names, no file layout, algorithms, refactoring notes, phase or
      plan references, no unshipped roadmap.
- [ ] The README sub-phase says to preserve the existing README structure, tone,
      and language (edit, not rewrite), and its done-criterion is that a new user
      can install and use the feature from the README alone.
- [ ] Any opt-in / legacy / `N=1` path is asserted byte-identical with a
      regression test (invariant + test).
- [ ] Every sub-phase is written for a **weak implementer**: step-by-step, no
      ambiguity, exact symbol names, no assumed context from other phases.
- [ ] Sub-phases that add files explicitly instruct the implementer to follow
      the existing project structure; new directories only if no existing one
      serves the same purpose.
- [ ] No emojis or informal decorations in any plan file or deliverable
      specification.

## Agent assignment

- [ ] **Every** sub-phase has a model tag.
- [ ] Every new sub-phase model tag contains the exact configured assignment
      (`agent-N:name` or `agent:name`); legacy no-prefix plans may retain the
      Opus/Sonnet/Haiku aliases.
- [ ] `agent-1` owns architecture, acceptance assertions, and final review;
      in single-agent mode the plan labels the review as self-review.
- [ ] Exploration and mechanical work is assigned to `agent-3+` when present,
      otherwise `agent-2`; non-trivial implementation is assigned to `agent-2`
      when present, otherwise `agent-1`.
- [ ] The **Model-assignment summary** table is the last section of
      `overview.md` and is consistent with the per-sub-phase tags.

## Verification

- [ ] The `overview.md` **Verification summary** names the exact gate commands
      (fmt / lint / unit / e2e).
- [ ] Those commands are identical to `STATE.md` §3 and to the per-phase gate
      blocks — no drift between the three.
- [ ] Unit + e2e test locations and run instructions are stated, including any
      rebuild/permission caveats.
- [ ] Acceptance criteria list the `T-*` IDs that prove the reference scenario.

## Token discipline

- [ ] No large code blocks where a `path:line` anchor + 2-line change would do.
- [ ] No invariant re-explained across phases — tagged once (`I-*`), referenced.
- [ ] The plan is self-contained: an implementer needs **only** the phase file plus
      the repo to execute any sub-phase without reading the others.

## Output — multi-file structure

- [ ] Folder `docs/plans/<NNN>_plan-<FeatureName>/` created under the repo root,
      with `docs/` and `docs/plans/` created if they were missing. No plan
      folder in the repo root.
- [ ] `<NNN>` is the highest existing plan number plus one (`001` if
      `docs/plans/` was empty), zero-padded, and no existing plan folder was
      reused or renumbered.
- [ ] `overview.md` present, with: goal and reference scenario, `D*` decisions,
      open questions, architecture summary, interface, protocol/data-structure
      changes, phase table with file links, reuse map, references, invariants,
      risk register, verification summary, model-assignment summary.
- [ ] `resume.md` present: phase status table, test status table, per-phase docs
      table, open blockers, `Next:` pointer.
- [ ] One `phase_NN.md` per phase (1-indexed, zero-padded; phase 0 →
      `phase_01.md`).
- [ ] `overview.md` and `resume.md` are **small** — detail belongs only in phase
      files.
- [ ] Phase files are fully self-contained (can be read cold without
      `overview.md`).
- [ ] `resume.md` `Next:` pointer is accurate (first TODO sub-phase).
- [ ] No production code was written by this skill.
- [ ] Closing message is terse: folder path + one-line phase/assignment summary.

## State file (STATE.md)

- [ ] `STATE.md` present and **initialized by this skill**, not left as a stub.
- [ ] §0 protocol present: read-first-on-session-start and
      update-after-every-sub-phase rules, written so an agent with no other
      context can follow them.
- [ ] §2 feature recap is self-contained — the first sub-phase is executable
      without opening `overview.md`.
- [ ] §3 lists the real build / fmt / lint / unit / e2e commands and setup
      caveats, identical to the phase gate commands and to the `overview.md`
      verification summary (no drift).
- [ ] §1 `Next action:` names an existing `phase_NN.md` and sub-phase, and
      matches the `resume.md` `Next:` pointer.
- [ ] §4–§10 exist and are empty-but-shaped at init (`none`, empty tables);
      §6 in-flight reads `none — tree consistent`. The one exception is §9,
      which already carries every question the user deferred at the
      clarification gate, with the default applied and the sub-phase it affects.
- [ ] `overview.md` header and **every** phase file carry the state contract
      (read `STATE.md` first, run the §3 gates to check §1/§7, update after
      every sub-phase).
- [ ] Every sub-phase `Done` field requires `STATE.md` and `resume.md` updated.
- [ ] `STATE.md` has no code dumps and no narrative — one line per ledger entry;
      verbatim text only for failing gate output.

---

# Coherence checklist (execute · task · bug)

Run after **every** sub-phase, task, or bug fix, before reporting it done. Its
purpose is single: a `/plan-execute-verify verify` run right now must produce no
finding caused by this work.

- [ ] Code does exactly what was specified (sub-phase `Change`, or the mini-plan
      shown to the user) — no silent extra scope.
- [ ] Named tests exist with the stated assertions and pass; for a bug, the
      regression test failed before the fix.
- [ ] Gates run and green (full suite for bug fixes); failures reported, never
      hidden.
- [ ] `STATE.md` updated: §1 position, §4 ledger, §5 files, §6 in-flight,
      §7 verification, §8 deviations, §9 blockers, §10 dead ends, timestamp.
- [ ] `resume.md` updated: phase / test / docs tables and `Next:` pointer.
- [ ] `README.md` updated when user-visible behavior changed — user guide only,
      no implementation detail.
- [ ] Out-of-plan work has a ledger entry: `T-A<NNN>` in `tasks.md` or
      `B-A<NNN>` in `bugs.md`, with files, tests, gates, README, plan impact.
      IDs sequential and never reused.
- [ ] Plan reconciled where the work invalidated it: superseding `D*` row,
      adjusted `I-*`, edited **not-yet-executed** phase files whose anchors or
      assumptions changed, sub-phases marked `SKIPPED` with a reason, new
      sub-phases added where the plan should own the work.
- [ ] No pending phase file still states something this work made false.
- [ ] `verify/index.md` updated when the work closed, reopened, or invalidated a
      finding — status changed with evidence, and mirrored in the report file.
      Nothing was fixed silently.
- [ ] When applying a correction plan: each finding re-verified before being
      marked `FIXED`, findings that could not be closed left `OPEN` with the
      reason, and phases reopened (`IN_PROGRESS`) where a `DONE` phase was
      corrected.
- [ ] Ad-hoc work in `docs/plans/000_adhoc/` (no plan in the repo): only the
      ledger entry, the tests, the repo's own gates, and the `README.md` update
      are required — no `STATE.md`, `resume.md`, or plan files are invented
      there, and the ledger's **Plan impact** reads `n/a — no plan`.
- [ ] Nothing was committed unless the user asked; the ledger `Commit` column
      says `uncommitted` when that is the truth.
- [ ] Ambiguities were raised to the user instead of resolved by guessing.

---

# Verify-mode checklist

Run this before returning a `/plan-execute-verify verify` report.

- [ ] The audited plan folder was resolved explicitly and named in the report,
      and it is a real plan (never `000_adhoc`, which holds no phases).
- [ ] Every phase not marked `TODO` was audited against its phase file.
- [ ] Ground truth came from the **repo and the gates**, not from `STATE.md` /
      `resume.md` claims.
- [ ] The gate commands were actually run; anything that could not run is listed
      under **Not verifiable**, never assumed green.
- [ ] All twelve audit dimensions were covered: completeness, fidelity, tests,
      gates, decisions/invariants, external facts, plan rules (structure,
      professionalism, per-phase README), scope creep, regressions, state
      accuracy, ad-hoc reconciliation, previous findings.
- [ ] `verify/index.md` was read first: every `OPEN` finding re-checked, every
      `FIXED` finding re-tested, a broken fix raised as `unfixed-regression`,
      and nothing dropped silently (`OBSOLETE` / `ACCEPTED` carry a reason).
- [ ] `tasks.md` and `bugs.md` were read: every unexplained diff hunk is a
      finding, every ledger entry is real in the tree with its test, and every
      entry that invalidated the plan left the plan updated (a ledger entry
      contradicting a pending phase file is a `BLOCKER`).
- [ ] Every finding has a stable ID `V<NNN>-F<n>`, a status, severity, category,
      `path:line`, the plan reference, expected vs actual, impact, and a
      concrete correction.
- [ ] The **correction plan is executable from the report file alone** by a cold
      session: exact files, change, test, and done-criterion per item — written
      to the same standard as a phase file's sub-phase.
- [ ] No finding rests on suspicion — unprovable doubts are under **Not
      verifiable**.
- [ ] **Verified clean** lists what was checked and holds, so the report is
      trustworthy rather than merely short.
- [ ] The **correction plan** is ordered by severity, mapped to phase/sub-phase,
      and flags corrections that reopen a phase already marked `DONE`.
- [ ] **State re-sync** states the exact `STATE.md` / `resume.md` edits needed.
- [ ] The report was written to
      `<plan-folder>/verify/verify_<NNN>_<YYYY-MM-DD>.md`, where `<NNN>` is the
      highest existing report number plus one, without overwriting or
      renumbering an earlier report.
- [ ] `verify/index.md` updated: report row added, new findings added as `OPEN`,
      carried-over findings re-statused with evidence, open blockers listed.
- [ ] `STATE.md` §7 / §9 and `resume.md` corrected where they claimed something
      the audit disproved.
- [ ] No production code was changed, no phase file rewritten, no correction
      applied, no ledger entry invented.
- [ ] Full report given in chat; closing line terse (verdict, counts by
      severity, report path, findings still `OPEN` from earlier audits) with an
      offer to run `/plan-execute-verify execute verify`.
