# Task and Bug modes — small changes and single defects

Both write production code and both follow SKILL.md's **coherence contract**.
Both keep their mini-plan **in memory, not on disk** — no plan folder, no phase
files.

Both are **units of work**: opened in `STATE.md` §1 (`Type: task` / `Type: bug`,
`ID` = the ledger ID you are about to use) before any code is touched, closed
after the gates are green — and, when `STATE.md` §3 has WIP commits on, committed
at close as `task(T-A<NNN>): <intent>` / `bug(B-A<NNN>): <intent>`, with the sha
in the §4 row and the branch named in the closing line. A task or bug interrupted halfway is then resumable
from §1 and §6 like any sub-phase. In `000_adhoc` there is no `STATE.md`, so the
ledger entry is the only record — write it as soon as the fix is in place.

Ledger templates: `references/templates-ledger.md`.

Before reporting done, run the **Coherence checklist** in
`references/quality-checklist.md`.

---

## Task mode

`/plan-execute-verify task <description>` — one small, well-understood change
that does not deserve a plan folder: a flag, a message, a small refactor, a doc
fix.

1. **Mini-plan in memory.** Restate the goal in one line, list the files to touch
   with anchors, the change, the tests, the done-criterion. In chat, terse.
2. **Show it before executing** when the change touches public behavior, data, or
   more than a couple of files; otherwise proceed and show the result. If the task
   turns out bigger than a handful of sub-steps, stop and say it needs a plan
   (`/plan-execute-verify <feature>`) instead of growing silently.
3. **Open the unit** in `STATE.md` §1, then **implement**, with at least one
   named test asserting the new behavior (or an explicit one-line reason why a
   test is impossible).
4. **Run the gates** from `STATE.md` §3, or the repo's own if there is no plan.
5. **Apply the coherence contract**: append a `T-A<NNN>` entry to `tasks.md`,
   close the unit in `STATE.md` (§4 ledger row `Type: task`, §11 board where the
   task changed a test or a doc), update `README.md` if the change is
   user-visible, reconcile the plan files if the task invalidated anything. In
   `000_adhoc` there is no plan or state file: the ledger entry and the
   `README.md` update are the whole contract.
6. Close with: what changed, `T-A<NNN>`, files, tests, gate results, and the
   commit sha when one was made.

---

## Bug mode

`/plan-execute-verify bug <description>` — diagnose and fix one defect. Same
lightweight shape as `task`, with a mandatory diagnosis step.

1. **Reproduce first.** Establish the failing behavior concretely (a command, an
   input, an assertion). If it cannot be reproduced, say so and stop with what you
   tried — do not "fix" a bug you cannot see.
2. **Find the root cause**, not the symptom. State it in one line with
   `path:line` evidence. If the cause is a plan decision (`D*`) or a missing
   invariant (`I-*`), say so explicitly — it changes the fix and the plan.
3. **Mini-plan in memory**: root cause, fix, blast radius (what else touches this
   code), the regression test, the done-criterion.
4. **Open the unit** in `STATE.md` §1, then **write the failing regression test
   first** (named, `B-A<NNN>`-tagged), watch it fail, then fix until it passes. A
   bug fix without a regression test is incomplete unless the test is genuinely
   impossible — then say why.
5. **Run the gates**, full suite, not just the touched area — bug fixes are where
   regressions hide.
6. **Apply the coherence contract**: append a `B-A<NNN>` entry to `bugs.md`
   (symptom, root cause, fix, regression test, affected phase), close the unit in
   `STATE.md` (§4 ledger row `Type: bug`, §11 board for the new regression test),
   update `README.md` if user-visible behavior or a documented limit changed, and
   reconcile the plan when the bug proves a planned assumption wrong — **including phases not yet executed that share the faulty assumption**.
   In `000_adhoc` there is no plan or state file: the ledger entry and the
   `README.md` update are the whole contract.
7. Close with: symptom → root cause → fix → regression test → gate results,
   `B-A<NNN>`, and the commit sha when one was made.
