# Token economy — spend the fewest tokens, lose no quality

Two budgets to protect: the tokens spent **producing** the plan, and the tokens
the **implementers** spend executing it. A good plan slashes both. The headline
insight:

> **A self-contained sub-phase is a token-minimization device.** If the
> implementer can act from the plan alone — exact files, line anchors, the
> precise change, the tests, the done-criteria — they never re-explore the
> codebase. Re-exploration is where downstream tokens go to die.

---

## Producing the plan cheaply (your own execution)

1. **Recon on one configured exploration agent, structured-output only.** Push
   all fact-finding to it in a **single multi-part task**. Demand `path:line —
   what` bullets, not file dumps. One agent over many: every extra agent
   re-pays context-load and re-reads overlapping files. Split into parallel
   agents only if one cannot hold the search.
2. **Never pull a large file into the supervisor context to "look around".**
   Ask the exploration agent for the 5–10 anchors you actually need. Keep the
   supervisor context small.
3. **Trust the anchors; don't re-read.** Once an agent reports a signature and
   line, cite it. Re-reading to "double-check" doubles the cost for ~no gain;
   reserve re-reads for things a correctness gate genuinely depends on.
4. **Write the plan once, in the file.** No long in-chat drafts you then rewrite.
   Compose directly in the artifact; iterate with targeted edits.
5. **Author phase files on `agent-1` directly.** The supervisor already holds
   the design context. Delegate prose only when phases are many and purely
   mechanical, and then spot-check rather than full-reread.
6. **Keep conversational replies terse.** The only thing allowed to be long is
   the plan file, because its length buys downstream savings.
7. **Favor the available context cache.** Read each reference at most once,
   early, in a stable order; never re-read mid-run. Prefer fewer, larger agents
   because each spawn is a fresh context. Never read `worked-example.md` during
   a run.

## Designing the plan so implementation is cheap

8. **Anchors over prose.** `src/foo.rs:120-145 — splice loop, reuse for X` lets
   the implementer open exactly that range. A paragraph forces them to go
   re-find it.
9. **The reuse map is a token cache.** Every "reuse `Y` at `path:line`" row is a
   search the implementer doesn't run. Make it exhaustive.
10. **Right-size the configured agent per sub-phase.** Tag mechanical
   sub-phases `agent-3+` when available, implementation `agent-2`, and
   architecture/review `agent-1`. With one configured agent, keep all work on
   that agent and mark the final review as self-review.
11. **Phase for small diffs and small test runs.** Independently shippable
    phases mean each implementation turn touches few files and runs a focused
    test subset — less context loaded, fewer tokens per turn.
12. **Name tests with IDs.** `T-HUB1`, `vpn_pool_alloc_*`. Referenceable test
    names mean later phases say "T-HUB1 still passes" instead of re-describing
    the whole test.
13. **State invariants once, reference them by tag.** `I-MC1` instead of
    re-explaining the legacy-path guarantee in every phase.

## Anti-patterns (these silently burn tokens)

- Asking a subagent to "explain the codebase" → pages of prose you don't need.
- Reading whole files in the architect context for orientation.
- Re-deriving facts already in the conversation or already in a subagent report.
- Vague sub-phases ("update the server logic") → the implementer must re-explore
  to discover what you already knew but didn't write down.
- Pasting large code blocks into the plan when a `path:line` anchor + a 2-line
  description of the change would do.

## The tradeoff, stated honestly

Phase files are intentionally **long and detailed**. That is not a token waste —
it is front-loaded work (once, on the supervisor) that prevents repeated re-exploration
spend (many times, across every implementation turn and every implementer).
Optimize total tokens across the whole feature, not the size of any one file.
Keep overview.md small — its value is fast cold-start, not detail.

`STATE.md` follows the same logic one level down: it is medium-sized and
bounded (one line per ledger entry, no code dumps, verbatim text only for
failing gate output), and it is the single file a cleared session reads to
resume — there is no second status file to keep in sync. Opening a unit in it
before the work and closing it after costs a few lines; skipping either costs a
full re-exploration plus the risk of redoing or clobbering in-flight work.
