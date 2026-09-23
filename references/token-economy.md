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
- Keep overview.md compact. Put operative design and test oracles once in each
  relevant phase's local context; sub-phases cite IDs and add only unit details.
- Use stable IDs and concise evidence references. Open/close writes are mandatory;
  checkpoint only when recovery needs information that the diff cannot reveal.
- At sub-phases run focused validation. Run complete gates at phase closure and
  final gates at final closure, repeating only after invalidating changes/failures.
- Use fewer well-scoped workers when sufficient, but do not retain a confused
  context solely to save a new agent's setup cost.
- Read the selected mode manual and only the sections of supporting references
  relevant to the current artifact or decision. After context loss, recover the
  applicable contract rather than loading every reference speculatively.

## Detail that is worth its cost

Complex work for a weak model needs an explicit algorithm, state representation,
input/output/error contracts, boundary cases, synchronization/lifecycle decisions,
ordered steps with postconditions, and a test oracle the worker did not invent.
Use pseudocode or exact signatures where those remove real ambiguity.

A short instruction such as “implement a lock-free token bucket” is not a
self-contained plan. Nor are “handle errors”, “add tests”, or an invariant ID
without its meaning. Split work or specify the missing decisions before dispatch.

Checkpoint at a recovery boundary, not for every completed step or test. Keep the
live state easy to scan with concise evidence references. Historical ledgers can grow; do
not delete recovery/audit evidence to satisfy an arbitrary size target.
