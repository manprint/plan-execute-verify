# Token economy — reduce repetition, preserve correctness

Optimize successful completion cost, including failed attempts and recovery.
Correctness, adequate detail for the weakest worker, and verifiable reviews have
priority over minimizing the initial plan or supervisor context.

## Useful savings

- Batch related recon questions; ask for paths, symbols, contracts, and evidence.
- Inspect focused source slices, relevant callers, and tests rather than entire
  unrelated files. The strong planner directly checks correctness-sensitive code.
- Reuse recorded facts while their revision remains valid. Re-check changed
  contracts; a previous summary is not permanently authoritative.
- Keep overview.md compact. Put detailed algorithms, edge cases, steps, and test
  oracles in phase files, where the implementer needs them.
- Include the meaning of relevant decisions/invariants in each phase's local
  context. A small amount of deliberate repetition avoids dangerous assumptions.
- Use stable IDs, unit checkpoints, and actual evidence to avoid repeated work.
- Run gates appropriate to the stage; do not repeatedly run unrelated expensive
  suites without a reason, or demand tests that have not been introduced yet.
- Use fewer well-scoped workers when sufficient, but do not retain a confused
  context solely to save a new agent's setup cost.
- Read references when needed, and again after context loss or a relevant change
  if their instructions are no longer available. Cache behavior is not a reason
  to act without the operating contract.

## Detail that is worth its cost

Complex work for a weak model needs an explicit algorithm, state representation,
input/output/error contracts, boundary cases, synchronization/lifecycle decisions,
ordered steps with postconditions, and a test oracle the worker did not invent.
Use pseudocode or exact signatures where those remove real ambiguity.

A short instruction such as “implement a lock-free token bucket” is not a
self-contained plan. Nor are “handle errors”, “add tests”, or an invariant ID
without its meaning. Split work or specify the missing decisions before dispatch.

Checkpoint after meaningful work, not just at session end. Keep the live state
easy to scan with concise evidence references. Historical ledgers can grow; do
not delete recovery/audit evidence to satisfy an arbitrary size target.
