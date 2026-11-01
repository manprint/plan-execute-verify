# plan-execute-verify — skill repo

Markdown-only Claude skill. No build/tests; validation = read-through + consistency greps.

## Layout
- `SKILL.md` — entry point, routing table, shared boundaries.
- `references/mode-*.md` — one manual per mode (onboard, plan, execute, taskbug, verify, resume, handoff).
- `references/execution-contract.md` — core runtime rules: §1 settings, §3 work loop + autonomy loop + stop latch + PLAN closure, §6 commits (mandatory subjects table), §7 coherence, §8 STATE compaction/history.md.
- `references/output-template.md` — templates: overview, phase file, lean STATE.md, PROTOCOL.md, history.md.
- `README.md` / `README_IT.md` — bilingual user docs; keep both in sync.
- `install-claude.sh` — installs the skill into `~/.claude/skills`.

## Conventions
- STATE.md section numbers (§1–§12) are cited across files: never renumber.
- A rule change touches: contract/mode manual, `output-template.md` PROTOCOL, `quality-checklist.md`, both READMEs.
- Commit subjects for generated plans are fixed in execution-contract §6.
