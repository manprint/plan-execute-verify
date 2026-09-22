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
- Execution uses handoff by default; the same unit can be delegated.

The approved design is a fixed-window quota counter, not an unspecified token
bucket. A user-visible rate limit can have different semantics; the supervisor
must select one explicitly before implementation.

## Local design context for phase_01.md

Logical phase 0 introduces an internal primitive; it changes no HTTP behavior.
Its sub-phases are 0.1 (the primitive) and 0.2 (README accuracy check).
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

- **Model:** agent-3:haiku
- **Assignment:** implement the specified algorithm and tests. agent-1:opus
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
  with revision/diff identity and actual test output.
  Expected: required review records I-1 through I-4 and passes before closure.

  Checkpoints: after S1, S2, S3, and the S4 test run, record actual files,
  completed steps/postconditions, failed checks, and the next unverified step.
  If interrupted, inspect existing symbols/tests before repeating an edit.

  Scope/failure handling: do not wire HTTP, add a new dependency, change quota
  semantics, replace the lock with atomics, or loosen a test. A changed baseline
  contract, missing design, or two failed fixes of the same error goes to agent-1.

- **Unit tests:** all live in tests/unit/test_limits.py; G-U01 is
  python -m pytest tests/unit/test_limits.py -v. Confirm these named tests execute,
  in addition to the pre-existing suite:
  - test_admission_immutable: Admission(True, None) exposes those exact fields;
    assigning allowed or retry_after_ns raises dataclasses.FrozenInstanceError.
  - test_constructor_validation: reject capacity=-1, capacity=True,
    window_ns=0, window_ns=1.5, start_ns=-1, and start_ns=False.
  - test_time_validation: try_take(-1), try_take(True), and try_take(1.5)
    raise InvalidLimit and leave the two slots of a fresh capacity=2 instance.
  - test_exact_window_boundary: capacity=2, window_ns=100, start_ns=1000.
    Calls at 1000 and 1000 allow; at 1050 deny with retry_after_ns=50;
    at 1100 allow; at 1100 allow; at 1100 deny with retry_after_ns=100.
  - test_large_time_jump: the same exhausted initial instance at 1350 allows
    exactly twice, then denies with retry_after_ns=50, proving alignment to 1300.
  - test_backward_time: exhaust two slots at 1100, then call at 1050;
    deny with retry_after_ns=100 and do not reopen an older window.
  - test_zero_capacity: capacity=0 at start and many future windows always
    yields Admission(False, None).
  - test_instances_are_independent: exhausting one capacity=1 instance does not
    deny the first request to another instance at the same time.
  - test_concurrent_window_exhaustion: capacity=10, fixed now_ns=1000 and
    window_ns=100. Start four workers through a barrier; each calls try_take(1000)
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
  commit resolves before 0.2 starts.

### 0.2 Check README accuracy

- **Model:** agent-3:haiku
- **Assignment:** inspect user-facing documentation; supervisor checks at P0.
- **Files:** READ README.md and the owned phase-0 diff. WRITE README.md only if
  phase 0 actually invalidated an existing statement.
- **Change:** prerequisite 0.1 DONE. S1 — compare current documented usage/defaults
  with unchanged public behavior; expected: no new public rate-limit feature
  documented. S2 — correct only an actual inaccuracy, otherwise leave the README
  unchanged; expected: record sections inspected and result. Checkpoint before
  handing off to P0. Escalate unexpected public behavior to agent-1.
- **Unit tests:** N/A — documentation inspection; no examples changed.
- **e2e tests:** N/A — no request behavior changed.
- **Done:** README remains accurate, verification recorded, unit closed. In commit
  modes the state/evidence change supplies the nonempty completion commit even
  when README itself did not change.

## Gates and progress initialization

G-BASE: existing configuration tests in tests/unit/test_limits.py, active at
baseline. G-U01: the same test command after S3, now also requiring the named
new tests. G-P0: python -m pytest tests/unit, at P0 after both sub-phases.
There is no requirement to run future HTTP tests during phase 0.

Initial sub-phase rows:
| ID | Phase file | Depends on | Status | Attempt | Evidence |
|----|------------|------------|--------|---------|----------|
| 0.1 | phase_01.md | none | TODO | 1 | — |
| 0.2 | phase_01.md | 0.1 | TODO | 1 | — |

P0 additionally requires G-P0 and agent-1's phase review. When full autonomy is
true, its phase completion is a separate commit after the two sub-phase commits.

## Example interruption and commit recovery

Suppose S1 and S2 were written but the process ended before S3:
- 0.1 remains OPEN; completed steps are S1/S2 only if their postconditions were
  checked. The next action is writing/running the named S3 tests.
- A resumed session inspects the current diff even if the last checkpoint still
  says S1; it does not duplicate the class or reset the whole file.
- No completion commit exists until tests, review, and coherence pass.
- If full autonomy is true and WIP is off, interruption requires a checkpoint,
  not a broken-code commit.

At verified completion, the ledger uses unit:0.1:1 and the commit carries:
PEV-Plan: 003_plan-RateLimit; PEV-Unit: 0.1; PEV-Attempt: 1;
PEV-Result: complete. These are separate trailer lines in the actual message.
A crash before that commit leaves an unresolved reference to finalize; a crash
after it is resolved from Git and must not create a duplicate commit.
