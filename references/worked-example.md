# Worked example — multi-file plan

Feature: **add per-API-key rate limiting to an HTTP gateway** (`gw`).
Shows every file type produced (overview, resume, phase files, STATE). Real
plans are longer; copy the *structure* and *per-sub-phase discipline*, not the
content.

Folder: `docs/plans/001_plan-RateLimit/`

Note: the mandatory closing `Update README.md` sub-phase of each phase is shown
only in phase 3 below to keep this example short. Real plans carry it at the end
of **every** phase.

---

## File 1 — overview.md

````markdown
# Per-API-key Rate Limiting — Overview

> **Status:** planning | **Opus authored:** 2026-06-25
> **Folder:** `docs/plans/001_plan-RateLimit/`

## Goal
Reject requests from a key that exceeds its configured rate with `429`, without
measurably slowing keys under their limit.

```
config: key "k1" → 10 req/s, key "k2" → unlimited
drive 20 req/s on k1  → ~10/s pass, rest 429 with Retry-After
drive 20 req/s on k2  → all pass
under-limit p99 latency within +50µs of baseline
```

## Design decisions

| # | Decision | Consequence |
|---|----------|-------------|
| **D1** | Token-bucket per key, in-process | No external store v1; one `DashMap<KeyId, Bucket>` |
| **D2** | Limiter opt-in via `--rate-limit` (default off) | Off = current behavior byte-for-byte |
| **D3** | Unlimited keys skip map entirely | No lock/alloc for unconfigured keys |
| **D4** | `429` carries `Retry-After` seconds | Clients can back off |

## Architecture summary
Middleware after auth: look up key's quota; no quota → pass (D3); quota →
`bucket.try_take()` → pass or `429`. `RateConfig = HashMap<KeyId, Quota>` loaded
at boot; `Buckets = Arc<DashMap<KeyId, AtomicBucket>>` filled lazily.

## Phases

| Phase | File | Model | Shippable alone? |
|-------|------|-------|-----------------|
| 0 — Config + error scaffolding | [phase_01.md](phase_01.md) | Haiku | yes |
| 1 — Limiter core (token bucket) | [phase_02.md](phase_02.md) | Sonnet | yes |
| 2 — Wire into middleware stack | [phase_03.md](phase_03.md) | Sonnet | yes |
| 3 — Hardening + docs + bench | [phase_04.md](phase_04.md) | Sonnet/Haiku | yes |

## Reuse map
| Need | Reuse | Location |
|------|-------|----------|
| Key extraction | `ApiKey` extension | `src/mw/auth.rs:22` |
| Middleware wiring | `Layer` stack builder | `src/server.rs:55-70` |
| Config loader | `Config::from_file` | `src/config.rs:31` |
| Error→response | `into_response` for `GwError` | `src/error.rs:88` |

## Invariants
- **I-1:** limiter off (no `--rate-limit`) → byte-for-byte current behavior; T-RL0.
- **I-2:** unlimited keys take no lock/alloc on hot path (D3).
- **I-3:** bucket never lets more than quota through per window under concurrency.

## Risk register
| Risk | Mitigation |
|------|-----------|
| Map contention under high key cardinality | `DashMap` sharding; bench in phase_04 §3.1 |
| Clock skew breaks refill | monotonic clock only; `refills_at_rate` unit test |
| Default-off regression | T-RL0 + I-1 |

## Model-assignment summary
| Phase | Sub-phases by model | Primary | Opus gate |
|-------|---------------------|---------|-----------|
| 0 | 0.1, 0.2 Haiku | Haiku | — |
| 1 | 1.1 Sonnet | Sonnet | 1.1 (hot-path/concurrency) |
| 2 | 2.1 Sonnet | Sonnet | — |
| 3 | 3.1 Sonnet · 3.2 Haiku | Sonnet/Haiku | 3.2 (final docs) |

> Start Sonnet, drop to Haiku for mechanical sub-phases, escalate to Opus for
> review gates above. Print model used per sub-task.
````

---

## File 2 — resume.md

````markdown
# RateLimit — Resume

> **Next:** phase_01.md § 0.1 — Add Quota/RateConfig/config parsing
> **Last updated:** 2026-06-25

## Phase status

| Phase | File | Status | Notes |
|-------|------|--------|-------|
| 0 — Config + error scaffolding | phase_01.md | `TODO` | — |
| 1 — Limiter core | phase_02.md | `TODO` | — |
| 2 — Wire middleware | phase_03.md | `TODO` | — |
| 3 — Hardening + docs + bench | phase_04.md | `TODO` | — |

## Tests

| ID | Type | Status | Notes |
|----|------|--------|-------|
| T-RL0 | e2e | `TODO` | no --rate-limit → all pass, latency == baseline |
| T-RL1 | e2e | `TODO` | k1@20req/s → ~10 pass, rest 429+Retry-After |
| T-RL2 | e2e | `TODO` | k2 unlimited → all pass |

## Docs
| File | Status | Notes |
|------|--------|-------|
| README.md | `TODO` | --rate-limit flag + TOML format |
| docs/CONFIG.md | `TODO` | 429/Retry-After, default-off |
| docs/PERF.md | `TODO` | latency bench numbers |

## Open blockers
- none

## Decisions changed at runtime
- none
````

---

## File 3 — phase_01.md (Phase 0 — Config + error scaffolding)

````markdown
# Phase 0 — Config + error scaffolding

> **Intent:** Add config structs and error variant; no behavior change, no wiring.
> **Shippable alone?** yes — pure additive
> **Preconditions:** none

---

## Sub-phases

### 0.1 Add `Quota`, `RateConfig`, config parsing
- **Model:** Haiku (mirrors existing `Config::from_file` at `src/config.rs:31`)
- **Files:** `src/config.rs:31-60`
- **Change:** parse optional `[limits]` table into `RateConfig`; absent → `None`. Mirror `Config::from_file` pattern at `:31`.
- **Unit tests:** `parses_limits_table` — `HashMap` populated from valid TOML; `absent_limits_is_none` — missing section yields `None`; `zero_quota_parses` — `0` is valid (documents "reject all").
- **e2e tests:** none (no behavior change)
- **Done:** gates green; existing config tests unchanged.

### 0.2 Add `GwError::RateLimited` + `429` mapping
- **Model:** Haiku
- **Files:** `src/error.rs:88`
- **Change:** additive enum variant; extend `into_response` at `:88` → `429` + `Retry-After` header.
- **Unit tests:** `rate_limited_maps_to_429_with_retry_after` — `GwError::RateLimited{retry_after:5}` → status 429, `Retry-After: 5`.
- **e2e tests:** none (variant not reachable yet)
- **Done:** gates green; no existing error mappings changed.

---

## Phase gates
- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test subset:** `cargo test config:: error::`
- **Regression guard:** existing `config::tests::*` must still pass

## Phase done criterion
Gates green. New structs compile. No existing test changed.
````

---

## File 4 — phase_02.md (Phase 1 — Limiter core)

````markdown
# Phase 1 — Limiter core (token bucket)

> **Intent:** Implement `AtomicBucket` + `try_take`; no middleware wiring yet.
> **Shippable alone?** yes — new module, not wired
> **Preconditions:** phase_01 DONE

---

## Sub-phases

### 1.1 `AtomicBucket` + `try_take`
- **Model:** Opus design review (hot-path, concurrency) → Sonnet implements
- **Files:** new `src/ratelimit.rs`
- **Change:** lock-free atomic token bucket; `try_take(now) -> Option<u32>` (None = allowed, Some(secs) = denied+retry-after). Monotonic clock. No `DashMap` here — just the per-key struct.
- **Unit tests:** `refills_at_rate` — bucket at 0 tokens refills to quota after 1s; `denies_over_limit` — 11th take on quota=10 returns `Some(_)`; `retry_after_correct` — returned seconds matches next refill window; `concurrent_takes_never_exceed_quota` — loom or stress: 4 threads × 100 takes on quota=10 per second → ≤ 10 pass.
- **e2e tests:** none (not wired)
- **Done:** gates green; `concurrent_takes_never_exceed_quota` passes.

---

## Phase gates
- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test subset:** `cargo test ratelimit::`
- **Regression guard:** phase_01 tests still green

## Phase done criterion
`cargo test ratelimit::` all pass including concurrency test.
````

---

## File 5 — phase_03.md (Phase 2 — Wire middleware)

````markdown
# Phase 2 — Wire into middleware stack

> **Intent:** Insert limiter layer after auth; wire config flag.
> **Shippable alone?** yes — behind `--rate-limit` flag (D2)
> **Preconditions:** phase_01 DONE, phase_02 DONE

---

## Sub-phases

### 2.1 Limiter middleware after auth
- **Model:** Sonnet
- **Files:** `src/server.rs:55-70`, new `src/mw/ratelimit_mw.rs`
- **Change:** insert layer after auth at `src/mw/auth.rs:40` using `Layer` stack builder at `src/server.rs:55`. Read `ApiKey` extension (reuse `src/mw/auth.rs:22`). No quota → pass (D3); quota → `try_take` → pass or `GwError::RateLimited`. Build layer only when `--rate-limit` given (D2).
- **Unit tests:** `unlimited_key_skips_map` — key with no quota: `try_take` never called; `limited_key_throttled` — key with quota=1: second request returns 429.
- **e2e tests:**
  - **T-RL1:** k1@20req/s → ~10/s pass, rest `429`+`Retry-After`. Asserts §1 acceptance.
  - **T-RL2:** k2 unlimited → all pass.
  - **T-RL0 (regression/I-1):** no `--rate-limit` flag → all pass, latency == baseline ±5%.
- **Done:** T-RL0, T-RL1, T-RL2 pass; gates green; limiter-off path byte-identical.

---

## Phase gates
- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test:** `cargo test` (full suite)
- **e2e:** `cargo test --test rate_limit_e2e`
- **Regression guard:** T-RL0 (I-1 invariant)

## Phase done criterion
T-RL0 + T-RL1 + T-RL2 all pass. Gates green. Reference scenario in overview.md is fully exercised.
````

---

## File 6 — phase_04.md (Phase 3 — Hardening + docs + bench)

````markdown
# Phase 3 — Hardening + docs + bench

> **Intent:** Prove latency target, write docs, ship.
> **Shippable alone?** yes
> **Preconditions:** phase_03 DONE

---

## Sub-phases

### 3.1 Latency bench (hot-path guardrail)
- **Model:** Sonnet
- **Files:** new `benches/ratelimit_hot_path.rs`
- **Change:** criterion bench: under-limit p99 vs baseline; assert within +50µs. Record result in `docs/PERF.md`.
- **Unit tests:** none
- **e2e tests:** none (bench is not a test)
- **Done:** bench runs; numbers ≤ +50µs p99; recorded in `docs/PERF.md`.

### 3.2 Operator reference
- **Model:** Haiku (with Opus final read)
- **Files:** `docs/CONFIG.md`
- **Change:** document the TOML limits file format (`[limits]\n k1 = 10`), the `429`/`Retry-After` contract, and the default-off note.
- **Unit tests:** none
- **e2e tests:** none
- **Done:** Opus reads it; gates green.

### 3.3 Update README.md
- **Model:** Haiku (with Opus final read — last phase)
- **Files:** `README.md`
- **Change:** update **Usage** (`--rate-limit <PATH>`, with a runnable example and its output), **Configuration** (TOML limits file, defaults, rate limiting off unless the flag is passed), **Notes** (over-limit requests get `429` with `Retry-After` in seconds), **Limitations** (limits are per process, not shared across instances; counters reset on restart). No module names, no algorithm description, no phase references. Keep the existing README structure and tone; edit the affected sections only.
- **Unit tests:** none (documentation)
- **e2e tests:** none — the README example was executed and produced the documented output
- **Done:** a new user can enable and use rate limiting from the README alone, with no source reading; no implementation detail present; Opus signed off; `STATE.md` and `resume.md` updated.

---

## Phase gates
- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test:** `cargo test` (full suite)
- **Regression guard:** T-RL0 + T-RL1 + T-RL2 still pass
- **README:** updated for the flag, config file, `429` behavior, and limits; free of implementation detail

## Phase done criterion
Latency bench ≤ +50µs p99. Both docs readable and accurate (Opus signed off). All e2e tests still green. README.md reflects this phase's shipped behavior.
````

---

## File 7 — STATE.md (as initialized by the planner, before any code)

````markdown
# Per-API-key Rate Limiting — Implementation State

> **READ THIS FILE FIRST at the start of every session, before any other plan
> file. UPDATE IT after every sub-phase and before any session ends.**
> **Last updated:** 2026-06-25 | **By:** agent-1:opus | **Session:** 1

## 0. Protocol

**Resume (cold start):**
1. Read this file end to end.
2. Re-run §3 gates to verify the repo matches §1 and §7. The repo is the truth.
3. Open only the phase file in §1 `Next action:`, at the named sub-phase.
4. If §6 is non-empty, finish or revert that work before starting anything new.

**Update (after every sub-phase):** rewrite §1, append to §4, update §5 §6 §7,
add §8 rows on any deviation, refresh §9 §10, bump the timestamp, sync
`resume.md`. A sub-phase is not `DONE` until this is written.

## 1. Current position
- **Phase:** 0 — Config + error scaffolding (`phase_01.md`) — `TODO`
- **Sub-phase:** 0.1 — Add Quota/RateConfig/config parsing — `TODO`
- **Next action:** `phase_01.md` § 0.1 — add `Quota` and `RateConfig` to `src/config.rs`
- **Assigned:** `agent-2:sonnet`
- **Repo state:** branch `main` | working tree `clean` | last commit `a1b2c3d init`

## 2. Feature context
Per-API-key rate limiting in the `gw` gateway. Opt-in via `--rate-limit <toml>`;
default off. Keys under their limit must not slow down; over-limit requests get
429 + `Retry-After`.

**Reference scenario:** 20 req/s against a 10 req/s key k1 → ~10 pass, rest 429.
**Hard constraints:** backward compatible; no new runtime deps; zero latency
regression when the flag is absent.
**Key decisions in force:** D1 token bucket per key; D2 flag-gated, default off;
D3 429 + Retry-After header.

## 3. Environment and commands
- **Repo root:** `./gw`
- **Build:** `cargo build` · **Fmt:** `cargo fmt --check` · **Lint:** `cargo clippy -- -D warnings`
- **Unit tests:** `cargo test` · **E2E:** `cargo test --test e2e`
- **Setup / caveats:** e2e binds port 8080; run serially with `--test-threads=1`.

## 4. Work ledger
| # | Phase.Sub | Agent | What changed | Files | Gates | Commit |
|---|-----------|-------|--------------|-------|-------|--------|
| — | — | — | not started | — | — | — |

## 5. Files touched
| Path | What was done | Phase.Sub |
|------|---------------|-----------|
| — | — | — |

## 6. In-flight work
none — tree consistent

## 7. Verification state
| Gate / test | Command | Last result | When |
|-------------|---------|-------------|------|
| fmt | `cargo fmt --check` | `not-run` | — |
| lint | `cargo clippy -- -D warnings` | `not-run` | — |
| unit | `cargo test` | `not-run` | — |
| T-RL0/1/2 | `cargo test --test e2e` | `not-run` | — |

**Failing output (verbatim, trimmed to the error):**
```
none
```

## 8. Runtime deviations from the plan
| # | Plan said | What was done | Why | Impact on later phases |
|---|-----------|---------------|-----|------------------------|

## 9. Blockers and open questions
- none

## 10. Do-not-repeat
- none
````
