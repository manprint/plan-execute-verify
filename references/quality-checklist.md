# Quality checklist — the phase-F gate

Run this before declaring the plan done. It is fast and it is not optional. If
any item fails, fix it in the plan file before returning. This is an `agent-1`
task, or a self-review when one configured agent performs the whole plan.

## Completeness

- [ ] Every template section is present (or explicitly marked N/A with a reason).
- [ ] The **reference scenario** (§1) is concrete and observable — it maps
      one-to-one to acceptance tests in §6/§9.
- [ ] Every non-obvious design choice has a `D*` row with a *consequence*.
- [ ] The **reuse map** lists real `path:line` anchors, not "somewhere in X".
- [ ] Interface (§4) gives exact names, types, defaults, and conflict rules.
- [ ] Protocol/schema changes (§5) state the backward-compat strategy explicitly.

## Decomposition

- [ ] Phase 0 is pure-additive / no-behavior-change where the design allows.
- [ ] Each phase is **independently shippable** and ordered so each builds on
      the last.
- [ ] Every sub-phase has all six fields: Model · Files · Change · Unit tests ·
      e2e tests · Done.
- [ ] **Files** carry line anchors. **Change** cites reuse anchors.
- [ ] Tests are **named** and each has a **checkable assertion** (no "add tests").
- [ ] Done-criteria are verifiable by someone who didn't write the plan.
- [ ] Behavior changes (flipped defaults, edited existing tests) are called out
      loudly in the affected phase.
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
- [ ] The assignment summary table is present and consistent with the
      per-sub-phase tags.

## Verification

- [ ] §9 names the exact gate commands (fmt / lint / test).
- [ ] Unit + e2e test locations and run instructions are stated, including any
      rebuild/permission caveats.
- [ ] Acceptance criteria list the T-IDs that prove the reference scenario.

## Token discipline

- [ ] No large code blocks where a `path:line` anchor + 2-line change would do.
- [ ] No invariant re-explained across phases — tagged once (`I-*`), referenced.
- [ ] The plan is self-contained: an implementer needs **only** the phase file plus
      the repo to execute any sub-phase without reading the others.

## Output — multi-file structure

- [ ] Folder `docs/plans/plan_<FeatureName>/` created (or `plan_<FeatureName>/` at repo root).
- [ ] `overview.md` present: goal, D* decisions, phase table with file links, reuse map, invariants, risks.
- [ ] `resume.md` present: phase status table, test status table, docs status, next pointer.
- [ ] One `phase_NN.md` per phase (1-indexed, zero-padded).
- [ ] `overview.md` and `resume.md` are **small** — detail belongs only in phase files.
- [ ] Phase files are fully self-contained (can be read cold without overview.md).
- [ ] `resume.md` `Next:` pointer is accurate (first TODO sub-phase).
- [ ] No production code was written by this skill.
- [ ] Closing message is terse: folder path + one-line phase/model summary.
