# Worked example — a complex sub-phase for a weak implementer

This is an illustrative contract, not an audited real repository or a claim that
tests have run. It demonstrates the detail a strong planner supplies for complex
work assigned to the weakest worker. A real plan uses output-template.md for all
files and becomes READY only after its actual source contracts and gates are
validated. Do not copy these invented paths into a different project.

## Scenario and established repository facts

Assume recon has confirmed this Python repository:
- src/gw/limits.py contains the existing public exception InvalidLimit(ValueError).
- tests/unit/test_limits.py tests existing configuration validation.
- The pinned interpreter is Python 3.12; tests/conftest.py makes src/ importable.
  pytest and the standard library are
  available. Baseline command: python -m pytest tests/unit/test_limits.py.
- Existing request handling is synchronous. Wiring into HTTP is a later unit 1.1.
- No existing code exposes a quota primitive. No new third-party dependency is
  allowed. The new implementation stays in src/gw/limits.py.
- The roster is agent-1:opus, agent-2:sonnet, agent-3:haiku.
- Executor power is `low` (the default): units are elementary and fully
  specified.
- Execution uses handoff by default; the same unit can be delegated.

The approved design is a fixed-window quota counter, not an unspecified token
bucket. A user-visible rate limit can have different semantics; the supervisor
must select one explicitly before implementation.

## Local design context for phase_01.md

Logical phase 0 introduces an internal primitive; it changes no HTTP behavior.
Its single sub-phase is 0.1 (the primitive): one outcome with one contract and one
targeted check set. Because no public behavior changes, the README obligation is
an accuracy check owned by P0, not a separate documentation sub-phase.
Its reviewed closure is P0. Phase 1 may use the primitive only after P0 is DONE.

- D1: Each instance is one independent quota key and one fixed window counter.
- D2: Time is an injected nonnegative integer in nanoseconds; no wall-clock calls,
  sleeps, floats, or background refill thread inside the primitive.
- D3: Synchronization uses one threading.Lock per instance; all counter/window
  reads and writes involved in admission occur while that lock is held.
- D4: Capacity zero permanently denies; retry_after_ns is None because no finite
  retry can make the configuration allow a request.
- I-1: Within a fixed window at most capacity calls return allowed=True.
- I-2: Different instances do not share mutable counters or locks.
- I-3: Backward time does not reset or replenish a window.
- I-4: Imports and existing config validation retain their behavior.
- R: N/A for external research here; implementation uses established repository
  Python threading and integer arithmetic, with no new external API contract.

### 0.1 Implement the synchronized fixed-window primitive

- **Agent:** agent-3
- **Assignment:** implement the specified algorithm and tests. agent-1
  reviews the concurrency contract before work and the actual diff/test assertions
  before completion. In delegated mode the coordinator owns STATE.md and commits;
  in handoff mode the current session records progress and requests that review.
- **Files:** READ src/gw/limits.py — InvalidLimit; tests/unit/test_limits.py;
  tests/conftest.py. WRITE src/gw/limits.py and tests/unit/test_limits.py only.
  Add symbols to the existing module; create no directory and change no HTTP code.
- **Change:**

  Preconditions: G-BASE passed; no earlier implementation dependency; supervisor
  approved D1–D4. Confirm InvalidLimit is still the public exception before editing.

  Contract:
  - Add an immutable dataclass Admission with fields allowed: bool and
    retry_after_ns: int | None.
  - Add FixedWindowLimiter(capacity: int, window_ns: int, start_ns: int).
    Require exact integer inputs (bool is rejected), capacity >= 0,
    window_ns > 0, start_ns >= 0; otherwise raise InvalidLimit.
  - Add try_take(now_ns: int) -> Admission. Reject a non-integer, bool, or
    negative now_ns with InvalidLimit before changing shared state.
  - Initially remaining=capacity and window_start=start_ns.
  - Return Admission(True, None) after consuming one slot.
  - At positive capacity with no remaining slots, deny with the positive integer
    nanoseconds until the next window boundary.
  - At zero capacity, always return Admission(False, None).
  - For a valid time earlier than the current window_start, use
    effective_now=window_start for the entire decision; never move time backward.
  - Window boundaries are aligned to the original start, not to the latest
    request. An exact boundary belongs to the next window.

  S1 — Add Admission with @dataclass(frozen=True); validate each numeric input
  with type(value) is int and the stated range before storing it. Store capacity, window_ns,
  window_start, remaining, and a fresh per-instance threading.Lock.
  Expected: existing imports/config tests still pass; invalid constructor inputs
  raise InvalidLimit; instances do not share mutable state.

  S2 — Implement try_take. Validate now_ns, then acquire the instance lock with
  a context manager and perform this algorithm entirely inside it:
  1. If capacity == 0, return Admission(False, None).
  2. effective_now = max(now_ns, window_start).
  3. elapsed = effective_now - window_start.
  4. If elapsed >= window_ns, advance window_start by
     (elapsed // window_ns) * window_ns and set remaining = capacity.
  5. If remaining > 0, decrement remaining and return Admission(True, None).
  6. Otherwise return Admission(False, window_start + window_ns - effective_now).
  Expected: no negative remaining, retry delay strictly positive on finite denial,
  O(1) refill even after many windows, no unlocked admission state access.
  Do not invoke callbacks, I/O, sleep, or another lock while holding the lock.

  S3 — Add the exact tests below using injected integer time.
  Expected: all named tests discovered; assertions prove admission and denial,
  boundaries, backward time, independence, and concurrent exhaustion.

  S4 — Run G-U01, inspect the full owned diff, and request the supervisor's review
  with revision/diff identity and actual test output. The unit is IN_REVIEW while
  a dispatched or handed-off review is pending.
  Expected: required review records I-1 through I-4 and passes before closure.

  Recovery boundary: before dispatching or handing off the S4 review, record in
  STATE.md §6 the actual files, completed steps/postconditions, the G-U01 result,
  and the next action. S1–S3 edits and passing test runs need no separate state
  write. If interrupted earlier, compare a fresh working-tree snapshot with the
  unit's base tree and inspect existing symbols/tests before repeating an edit.

  Scope/failure handling: do not wire HTTP, add a new dependency, change quota
  semantics, replace the lock with atomics, or loosen a test. A changed baseline
  contract, missing design, or two failed fixes of the same error goes to agent-1.

- **Unit tests:** all live in tests/unit/test_limits.py and run through gate
  G-U01 (command in STATE.md §3). Confirm these named tests execute, in addition
  to the pre-existing suite. Unless stated otherwise, each test that needs an
  instance builds a fresh one with capacity=2, window_ns=100, start_ns=1000:
  - test_admission_immutable: Admission(True, None) exposes those exact fields;
    assigning allowed or retry_after_ns raises dataclasses.FrozenInstanceError.
  - test_constructor_validation: reject capacity=-1, capacity=True,
    window_ns=0, window_ns=1.5, start_ns=-1, and start_ns=False.
  - test_time_validation: try_take(-1), try_take(True), and try_take(1.5)
    raise InvalidLimit; afterwards two calls at 1000 still allow.
  - test_exact_window_boundary: calls at 1000 and 1000 allow; at 1050 deny with
    retry_after_ns=50; at 1100 allow; at 1100 allow; at 1100 deny with
    retry_after_ns=100.
  - test_large_time_jump: exhaust the instance with two calls at 1000; a call at
    1350 and another at 1350 allow, then a third at 1350 denies with
    retry_after_ns=50, proving alignment to 1300.
  - test_backward_time: two calls at 1100 allow, then a call at 1050 denies with
    retry_after_ns=100 and does not reopen an older window.
  - test_zero_capacity: capacity=0; calls at 1000, 1100, and 1_000_000 each
    return Admission(False, None).
  - test_instances_are_independent: two instances with capacity=1; after the
    first is exhausted at 1000, the second's first call at 1000 allows.
  - test_concurrent_window_exhaustion: capacity=10, window_ns=100,
    start_ns=1000, fixed now_ns=1000. Start four workers through a barrier; each
    calls try_take(1000)
    100 times, collecting thread-local results. Run this threaded scenario in a
    child process with a 5-second parent-enforced timeout and captured errors;
    terminate/reap only that owned child if it hangs. Fail on any worker exception
    or non-termination, then assert exactly 10
    allowed, 390 denied, and every denial retry_after_ns=100. No real-time window
    assumptions or sleeps. The parent must fail promptly even if a worker deadlocks;
    do not rely on unbounded thread joins or executor shutdown during cleanup.
- **e2e tests:** N/A — the primitive is not wired into request handling. Unit 1.1
  owns HTTP integration tests; they are not required before 0.1 exists.
- **Done:** S1–S4 postconditions hold; G-BASE and G-U01 pass with all listed tests
  executed; strong review of the actual diff passes; I-1–I-4 preserved; state
  closed. With full-autonomous:true or WIP completion enabled, the completion
  commit resolves before P0 starts.

## Phase gates and closure

- Required gate: G-P0 at P0, after 0.1 is DONE.
- README obligation, owned by P0: confirm README.md documents no public
  rate-limit feature and that phase 0 invalidated no existing statement; record
  the sections inspected. Correct only an actual inaccuracy.
- agent-1 reviews integration, invariants I-1–I-4, tests, and documentation.
- If G-P0 or the review fails, P0 edits no code: it closes that attempt as failed,
  agent-1 reopens 0.1 as attempt 2 (or revises the plan), and P0 reruns as
  attempt 2.

## STATE.md gate registry and progress initialization

G-BASE: existing configuration tests in tests/unit/test_limits.py, active at
baseline. G-U01: python -m pytest tests/unit/test_limits.py -v, after S3, now
also requiring the named new tests. G-P0: python -m pytest tests/unit, at P0
after 0.1. There is no requirement to run future HTTP tests during phase 0.

Initial sub-phase rows:
| ID | Phase file | Depends on | Status | Attempt | Evidence |
|----|------------|------------|--------|---------|----------|
| 0.1 | phase_01.md | none | TODO | 1 | — |

P0 additionally requires G-P0 and agent-1's phase review. When full autonomy or
WIP is enabled, its phase completion is a separate commit after the 0.1 commit.

## Example interruption and commit recovery

Suppose S1 and S2 were written but the process ended before S3:
- 0.1 remains OPEN; completed steps are S1/S2 only if their postconditions were
  checked. The next action is writing/running the named S3 tests.
- A resumed session (`/plan-execute-verify resume 003`) compares a fresh
  working-tree snapshot with the unit's base tree even if STATE.md still names
  S1 as the next step; it does not duplicate the class or reset the whole file.
- If the crashed session still holds `ownership: active`, the user's explicit
  invocation on this plan permits takeover once STATE.md and the snapshot stay
  unchanged during inspection; the takeover is recorded before recovery.
- No completion commit exists until tests, review, and coherence pass.
- If full autonomy is true and WIP is off, interruption requires a checkpoint,
  not a broken-code commit.
- With WIP on, the last recovery-boundary checkpoint, if any, is in one rolling
  `wip(0.1)` commit; the completion commit amends it while it is still owned,
  local-only, at HEAD, and the unit's only WIP commit on its base HEAD.

At verified completion, the ledger uses unit:0.1:1 and the commit carries:
PEV-Plan: 003_plan-RateLimit; PEV-Unit: 0.1; PEV-Attempt: 1;
PEV-Result: complete. These are separate trailer lines in the actual message.
A crash before that commit leaves an unresolved reference to finalize; a crash
after it is resolved from Git and must not create a duplicate commit.
