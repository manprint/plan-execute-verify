# Worked example — multi-file plan

Feature: **add per-API-key rate limiting to an HTTP gateway** (`gw`).
Shows all four files produced. Real plans are longer; copy the *structure* and
*per-sub-phase discipline*, not the content.

Folder: `docs/plans/plan_RateLimit/`

---

## File 1 — overview.md

````markdown
# Per-API-key Rate Limiting — Overview

> **Status:** planning | **Opus authored:** 2026-06-25
> **Folder:** `docs/plans/plan_RateLimit/`

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

### 3.2 Docs
- **Model:** Haiku (with Opus final read)
- **Files:** `README.md`, `docs/CONFIG.md`
- **Change:** document `--rate-limit <PATH>`, TOML format (`[limits]\n k1 = 10`), `429`/`Retry-After` behavior, default-off note.
- **Unit tests:** none
- **e2e tests:** none
- **Done:** Opus reads both docs; gates green.

---

## Phase gates
- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test:** `cargo test` (full suite)
- **Regression guard:** T-RL0 + T-RL1 + T-RL2 still pass

## Phase done criterion
Latency bench ≤ +50µs p99. Both docs readable and accurate (Opus signed off). All e2e tests still green.
````
