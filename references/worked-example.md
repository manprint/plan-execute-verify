# Worked example — multi-file plan

Feature: **add per-API-key rate limiting to an HTTP gateway** (`gw`).
Shows every file type produced (overview, resume, phase files, STATE) with the
configured assignment `agent-1:opus,agent-2:sonnet,agent-3:haiku`. Real plans are
longer; copy the *structure* and *per-sub-phase discipline*, not the content.

Folder: `docs/plans/001_plan-RateLimit/`

Note: the mandatory closing `Update README.md` sub-phase is present in **every**
phase, as the rules require; it is spelled out in full only in phase 3 to keep
this example short.

---

## File 1 — overview.md

````markdown
# Per-API-key Rate Limiting — Overview

> **Status:** planning | **Authored:** 2026-06-25 by `agent-1:opus`
> **Folder:** `docs/plans/001_plan-RateLimit/`
> **Executing this plan? Read [STATE.md](STATE.md) FIRST** — it holds the live
> position, environment, in-flight work, and the next action. Update it after
> every sub-phase.

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
| **D3** | Unlimited keys skip the map entirely | No lock/alloc for unconfigured keys |
| **D4 (user, Q1)** | `429` carries `Retry-After` in seconds | Clients can back off; header value is integer seconds (R1) |
| **D5 (user, Q2)** | Quota `0` means "reject all", not "unlimited" | Documented in the README; `zero_quota_parses` asserts it |

## Open questions

| # | Question | Assumed default in this plan | Affects |
|---|----------|------------------------------|---------|
| Q3 | Should limits reload on SIGHUP? | no — limits load at boot only; deferred to a later plan | phase 2 § 2.1 |

## Architecture summary
Middleware after auth: look up the key's quota; no quota → pass (D3); quota →
`bucket.try_take()` → pass or `429`. `RateConfig = HashMap<KeyId, Quota>` loaded
at boot; `Buckets = Arc<DashMap<KeyId, AtomicBucket>>` filled lazily.

## Interface

| Surface | Name | Type / values | Default | Notes |
|---------|------|---------------|---------|-------|
| CLI flag | `--rate-limit <PATH>` | path to a TOML file | absent = limiter off | absent flag keeps the current fast path (D2) |
| Config file | `[limits]` table | `<key> = <req/s>` (u32) | none | `0` rejects all requests for that key (D5) |

## Protocol and data-structure changes

| Change | Shape | Backward-compat strategy |
|--------|-------|--------------------------|
| Over-limit HTTP response | `429` + `Retry-After: <secs>` | New response only reachable when the flag is passed (D2); no existing status code changes |

## Phases

| Phase | File | Primary assignment | Shippable alone? |
|-------|------|--------------------|------------------|
| 0 — Config + error scaffolding | [phase_01.md](phase_01.md) | `agent-3:haiku` | yes |
| 1 — Limiter core (token bucket) | [phase_02.md](phase_02.md) | `agent-2:sonnet` | yes |
| 2 — Wire into middleware stack | [phase_03.md](phase_03.md) | `agent-2:sonnet` | yes |
| 3 — Hardening + docs + bench | [phase_04.md](phase_04.md) | `agent-2:sonnet` | yes |

## Reuse map
| Need | Reuse | Location |
|------|-------|----------|
| Key extraction | `ApiKey` extension | `src/mw/auth.rs:22` |
| Middleware wiring | `Layer` stack builder | `src/server.rs:55-70` |
| Config loader | `Config::from_file` | `src/config.rs:31` |
| Error→response | `into_response` for `GwError` | `src/error.rs:88` |

## References (external documentation consulted)

| # | What it settled | Source | Version / date |
|---|-----------------|--------|----------------|
| R1 | `Retry-After` accepts either an integer number of seconds or an HTTP-date | <https://www.rfc-editor.org/rfc/rfc9110#field.retry-after> | RFC 9110, 2022-06 |
| R2 | `DashMap::entry` returns a shard-locked entry; the guard must not be held across an await | <https://docs.rs/dashmap/5.5.3/dashmap/struct.DashMap.html> | dashmap 5.5.3 (pinned in `Cargo.toml:24`) |

## Invariants
- **I-1:** limiter off (no `--rate-limit`) → byte-for-byte current behavior; T-RL0.
- **I-2:** unlimited keys take no lock/alloc on the hot path (D3).
- **I-3:** the bucket never lets more than quota through per window under concurrency.

## Risk register
| Risk | Mitigation |
|------|-----------|
| Map contention under high key cardinality | `DashMap` sharding; bench in phase_04 § 3.1 |
| Clock skew breaks refill | monotonic clock only; `refills_at_rate` unit test |
| Default-off regression | T-RL0 + I-1 |
| Entry guard held across an await (R2) | `agent-1` review gate on § 1.1 and § 2.1 |

## Verification summary

| Gate | Command | Where it runs |
|------|---------|---------------|
| fmt | `cargo fmt --check` | every phase |
| lint | `cargo clippy -- -D warnings` | every phase |
| unit | `cargo test` | every phase |
| e2e | `cargo test --test e2e` | phase 2 onward |

**Acceptance:** the reference scenario is proven by T-RL1 (k1 at 20 req/s → ~10
pass, rest `429` with `Retry-After`) and T-RL2 (unlimited k2 → all pass), with
T-RL0 guarding I-1.
**Run caveats:** e2e binds port 8080 — run with `--test-threads=1`.
These commands are the same ones written into `STATE.md` §3; they must not drift.

## Model-assignment summary

| Phase | Sub-phases by assignment | Primary | `agent-1` review gates |
|-------|--------------------------|---------|------------------------|
| 0 | 0.1, 0.2, 0.3 → `agent-3:haiku` | `agent-3:haiku` | — |
| 1 | 1.1 → `agent-2:sonnet` · 1.2 → `agent-3:haiku` | `agent-2:sonnet` | 1.1 (hot path, concurrency) |
| 2 | 2.1 → `agent-2:sonnet` · 2.2 → `agent-3:haiku` | `agent-2:sonnet` | 2.1 (acceptance assertions) |
| 3 | 3.1 → `agent-2:sonnet` · 3.2, 3.3 → `agent-3:haiku` | `agent-2:sonnet` | 3.3 (final docs read) |
````

---

## File 2 — resume.md

````markdown
# RateLimit — Resume

> **Next:** phase_01.md § 0.1 — Add Quota/RateConfig/config parsing
> **Last updated:** 2026-06-25
> Status board only. Full execution state lives in [STATE.md](STATE.md); on any
> disagreement, STATE.md wins. Update both after every sub-phase.

## Phase status

| Phase | File | Status | Notes |
|-------|------|--------|-------|
| 0 — Config + error scaffolding | phase_01.md | `TODO` | — |
| 1 — Limiter core | phase_02.md | `TODO` | — |
| 2 — Wire middleware | phase_03.md | `TODO` | — |
| 3 — Hardening + docs + bench | phase_04.md | `TODO` | — |

Status values: `TODO` · `IN_PROGRESS` · `DONE` · `SKIPPED` · `BLOCKED`

## Tests

| ID | Type | Status | Notes |
|----|------|--------|-------|
| T-RL0 | e2e | `TODO` | no --rate-limit → all pass, latency == baseline |
| T-RL1 | e2e | `TODO` | k1@20req/s → ~10 pass, rest 429+Retry-After |
| T-RL2 | e2e | `TODO` | k2 unlimited → all pass |

## Docs

| Doc | Phase | Status | Notes |
|-----|-------|--------|-------|
| README.md | 0 | `TODO` | no user-visible change — verify still accurate |
| README.md | 1 | `TODO` | no user-visible change — verify still accurate |
| README.md | 2 | `TODO` | Usage: `--rate-limit`; Configuration: TOML limits |
| README.md | 3 | `TODO` | Notes: 429/Retry-After; Limitations: per-process counters |
| docs/CONFIG.md | 3 | `TODO` | operator reference for the limits file |
| docs/PERF.md | 3 | `TODO` | latency bench numbers |

## Open blockers
- none

## Decisions changed at runtime

One line per superseding `D*` row added during execution; the reason and the
impact live in `STATE.md` §8, not here.
- none
````

---

## File 3 — phase_01.md (Phase 0 — Config + error scaffolding)

````markdown
# Phase 0 — Config + error scaffolding

> **Intent:** Add config structs and error variant; no behavior change, no wiring.
> **Shippable alone?** yes — pure additive
> **Preconditions:** none

## State contract (mandatory)

1. Before touching anything: read [STATE.md](STATE.md) and confirm it points at
   a sub-phase in this phase. Run the gate commands in STATE.md §3 and check the
   result against what §1 and §7 claim; the repo wins.
2. After **every** sub-phase below: update `STATE.md` (position, ledger, files
   touched, in-flight work, verification, deviations, `Next action:`, timestamp)
   and sync `resume.md`. A sub-phase is not done until this is done.
3. If the session ends mid-sub-phase, write exactly what is half-finished into
   `STATE.md` §6 before stopping.

---

## Sub-phases

### 0.1 Add `Quota`, `RateConfig`, config parsing
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — mechanical, mirrors the existing `Config::from_file` pattern
- **Files:** `src/config.rs:31-60`
- **Change:** parse an optional `[limits]` table into `RateConfig`; absent → `None`. Mirror `Config::from_file` at `src/config.rs:31 — fn from_file`. Follow the existing module layout; add no new directory.
- **Unit tests:** `parses_limits_table` — `HashMap` populated from valid TOML; `absent_limits_is_none` — missing section yields `None`; `zero_quota_parses` — `0` is valid and means "reject all" (D5).
- **e2e tests:** none (no behavior change)
- **Done:** gates green (`cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test config::`) + existing `config::tests::*` unchanged and passing + `STATE.md` and `resume.md` updated

### 0.2 Add `GwError::RateLimited` + `429` mapping
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — additive enum variant
- **Files:** `src/error.rs:88`
- **Change:** additive enum variant `RateLimited { retry_after: u32 }`; extend `into_response` at `src/error.rs:88` → status `429` plus a `Retry-After` header carrying integer seconds. `R1 — Retry-After accepts an integer number of seconds (<https://www.rfc-editor.org/rfc/rfc9110#field.retry-after>)`.
- **Unit tests:** `rate_limited_maps_to_429_with_retry_after` — `GwError::RateLimited{retry_after:5}` → status 429, header `Retry-After: 5`.
- **e2e tests:** none (variant not reachable yet)
- **Done:** gates green + no existing error mapping changed + `STATE.md` and `resume.md` updated

### 0.3 Update README.md
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — documentation
- **Files:** `README.md` (repo root)
- **Change:** no user-visible change in this phase — verify the README is still accurate and leave it unchanged; record that verification in `STATE.md`.
- **Unit tests:** none (documentation)
- **e2e tests:** none
- **Done:** README confirmed still accurate, nothing added about unshipped behavior + `STATE.md` and `resume.md` updated

---

## Phase gates

- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test subset:** `cargo test config:: error::`
- **Regression guard:** existing `config::tests::*` must still pass
- **README:** verified still accurate (this phase ships nothing user-visible)

## Phase done criterion
Gates green. New structs compile. No existing test changed. README.md reflects
this phase's shipped behavior (nothing new).
````

---

## File 4 — phase_02.md (Phase 1 — Limiter core)

````markdown
# Phase 1 — Limiter core (token bucket)

> **Intent:** Implement `AtomicBucket` + `try_take`; no middleware wiring yet.
> **Shippable alone?** yes — new module, not wired
> **Preconditions:** phase_01 DONE

## State contract (mandatory)

1. Before touching anything: read [STATE.md](STATE.md) and confirm it points at
   a sub-phase in this phase. Run the gate commands in STATE.md §3 and check the
   result against what §1 and §7 claim; the repo wins.
2. After **every** sub-phase: update `STATE.md` and sync `resume.md`.
3. If the session ends mid-sub-phase, write what is half-finished into
   `STATE.md` §6 before stopping.

---

## Sub-phases

### 1.1 `AtomicBucket` + `try_take`
- **Model:** `agent-2:sonnet`
- **Assignment:** `agent-1:opus` review gate (hot path, concurrency) → `agent-2:sonnet` implements
- **Files:** new `src/ratelimit.rs` (module directory already exists — do not create a new one)
- **Change:** lock-free atomic token bucket; `try_take(now: Instant) -> Option<u32>` (`None` = allowed, `Some(secs)` = denied plus retry-after). Monotonic clock only. No `DashMap` here — just the per-key struct. `R2 — a DashMap entry guard must not be held across an await (<https://docs.rs/dashmap/5.5.3/dashmap/struct.DashMap.html>)` applies to § 2.1, not here.
- **Unit tests:** `refills_at_rate` — bucket at 0 tokens refills to quota after 1s; `denies_over_limit` — the 11th take on quota=10 returns `Some(_)`; `retry_after_correct` — returned seconds match the next refill window; `concurrent_takes_never_exceed_quota` — 4 threads × 100 takes on quota=10/s → at most 10 pass (I-3).
- **e2e tests:** none (not wired)
- **Done:** gates green (`cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test ratelimit::`) + `concurrent_takes_never_exceed_quota` passes + `agent-1:opus` signed off on the concurrency design + `STATE.md` and `resume.md` updated

### 1.2 Update README.md
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — documentation
- **Files:** `README.md`
- **Change:** no user-visible change in this phase (the module is not wired) — verify the README is still accurate and leave it unchanged; record that verification in `STATE.md`.
- **Unit tests:** none (documentation)
- **e2e tests:** none
- **Done:** README confirmed still accurate + `STATE.md` and `resume.md` updated

---

## Phase gates

- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test subset:** `cargo test ratelimit::`
- **Regression guard:** phase_01 tests still green
- **README:** verified still accurate (nothing user-visible yet)

## Phase done criterion
`cargo test ratelimit::` all pass, including the concurrency test. README.md
reflects this phase's shipped behavior (nothing new).
````

---

## File 5 — phase_03.md (Phase 2 — Wire middleware)

````markdown
# Phase 2 — Wire into middleware stack

> **Intent:** Insert the limiter layer after auth; wire the config flag.
> **Shippable alone?** yes — behind `--rate-limit` (D2)
> **Preconditions:** phase_01 DONE, phase_02 DONE

## State contract (mandatory)

1. Before touching anything: read [STATE.md](STATE.md) and confirm it points at
   a sub-phase in this phase. Run the gate commands in STATE.md §3 and check the
   result against what §1 and §7 claim; the repo wins.
2. After **every** sub-phase: update `STATE.md` and sync `resume.md`.
3. If the session ends mid-sub-phase, write what is half-finished into
   `STATE.md` §6 before stopping.

---

## Sub-phases

### 2.1 Limiter middleware after auth
- **Model:** `agent-2:sonnet`
- **Assignment:** `agent-1:opus` review gate (acceptance assertions) → `agent-2:sonnet` implements
- **Files:** `src/server.rs:55-70`, new `src/mw/ratelimit_mw.rs` (place it in the existing `src/mw/` directory)
- **Change:** insert the layer after auth at `src/mw/auth.rs:40` using the `Layer` stack builder at `src/server.rs:55`. Read the `ApiKey` extension (reuse `src/mw/auth.rs:22 — struct ApiKey`). No quota → pass without touching the map (D3, I-2); quota → `try_take` → pass or `GwError::RateLimited`. Build the layer only when `--rate-limit` is given (D2). Take and drop the `DashMap` entry guard inside a synchronous block: `R2 — the guard must not be held across an await`.
- **Unit tests:** `unlimited_key_skips_map` — a key with no quota never reaches `try_take`; `limited_key_throttled` — a key with quota=1 gets `429` on the second request.
- **e2e tests:**
  - **T-RL1:** k1 at 20 req/s → ~10/s pass, rest `429` + `Retry-After`. Proves the reference scenario in `overview.md`.
  - **T-RL2:** k2 unlimited → all pass.
  - **T-RL0 (regression, I-1):** no `--rate-limit` flag → all pass, latency within baseline ±5%.
- **Done:** T-RL0, T-RL1, T-RL2 pass + gates green (`cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`, `cargo test --test e2e`) + limiter-off path byte-identical + `STATE.md` and `resume.md` updated

### 2.2 Update README.md
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — documentation
- **Files:** `README.md`
- **Change:** update **Usage** (the `--rate-limit <PATH>` flag with a runnable example and its output) and **Configuration** (the TOML limits file, one `<key> = <req/s>` line per key, `0` rejects all, rate limiting off unless the flag is passed). No module names, no algorithm description, no phase references. Preserve the existing README structure and tone; edit only those sections.
- **Unit tests:** none (documentation)
- **e2e tests:** none — the README example was executed and produced the documented output
- **Done:** a new user can enable rate limiting from the README alone + no implementation detail present + `STATE.md` and `resume.md` updated

---

## Phase gates

- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test:** `cargo test` (full suite)
- **e2e:** `cargo test --test e2e`
- **Regression guard:** T-RL0 (invariant I-1)
- **README:** Usage and Configuration updated for the flag and the limits file

## Phase done criterion
T-RL0 + T-RL1 + T-RL2 all pass. Gates green. The reference scenario in
`overview.md` is fully exercised. README.md reflects this phase's shipped
behavior.
````

---

## File 6 — phase_04.md (Phase 3 — Hardening + docs + bench)

````markdown
# Phase 3 — Hardening + docs + bench

> **Intent:** Prove the latency target, write the operator docs, ship.
> **Shippable alone?** yes
> **Preconditions:** phase_03 DONE

## State contract (mandatory)

1. Before touching anything: read [STATE.md](STATE.md) and confirm it points at
   a sub-phase in this phase. Run the gate commands in STATE.md §3 and check the
   result against what §1 and §7 claim; the repo wins.
2. After **every** sub-phase: update `STATE.md` and sync `resume.md`.
3. If the session ends mid-sub-phase, write what is half-finished into
   `STATE.md` §6 before stopping.

---

## Sub-phases

### 3.1 Latency bench (hot-path guardrail)
- **Model:** `agent-2:sonnet`
- **Assignment:** `agent-2:sonnet` — implementation
- **Files:** new `benches/ratelimit_hot_path.rs` (the `benches/` directory already exists)
- **Change:** criterion bench comparing under-limit p99 against the baseline; assert within +50µs. Record the numbers in `docs/PERF.md`.
- **Unit tests:** none
- **e2e tests:** none (a bench is not a test)
- **Done:** bench runs + p99 within +50µs + numbers recorded in `docs/PERF.md` + `STATE.md` and `resume.md` updated

### 3.2 Operator reference
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — documentation
- **Files:** `docs/CONFIG.md`
- **Change:** document the TOML limits format (`[limits]` then `k1 = 10`), the `429` / `Retry-After` contract (integer seconds, R1), that `0` rejects all (D5), and the default-off note.
- **Unit tests:** none
- **e2e tests:** none
- **Done:** operator can configure limits from this file alone + gates green + `STATE.md` and `resume.md` updated

### 3.3 Update README.md
- **Model:** `agent-3:haiku`
- **Assignment:** `agent-3:haiku` — documentation; `agent-1:opus` reads it (final phase)
- **Files:** `README.md`
- **Change:** update **Notes** (over-limit requests get `429` with `Retry-After` in seconds) and **Limitations** (limits are per process, not shared across instances; counters reset on restart; limits load at boot and do not reload on SIGHUP — open question Q3). Re-check the Usage and Configuration sections written in phase 2 against the shipped behavior. No module names, no algorithm description, no phase or plan references, no unshipped roadmap. Keep the existing README structure and tone; edit the affected sections only.
- **Unit tests:** none (documentation)
- **e2e tests:** none — the README examples were executed and produced the documented output
- **Done:** a new user can install, enable, and operate rate limiting from the README alone, with no source reading + no implementation detail present + `agent-1:opus` signed off + gates green + `STATE.md` and `resume.md` updated

---

## Phase gates

- **Fmt:** `cargo fmt --check`
- **Lint:** `cargo clippy -- -D warnings`
- **Test:** `cargo test` (full suite)
- **Regression guard:** T-RL0 + T-RL1 + T-RL2 still pass
- **README:** updated for the `429` behavior and the known limits; free of
  implementation detail

## Phase done criterion
Latency bench p99 within +50µs. Both docs readable and accurate
(`agent-1:opus` signed off). All e2e tests still green. README.md reflects this
phase's shipped behavior.
````

---

## File 7 — STATE.md (as initialized by the planner, before any code)

````markdown
# Per-API-key Rate Limiting — Implementation State

> **READ THIS FILE FIRST at the start of every session, before any other plan
> file. UPDATE IT after every sub-phase and before any session ends.**
> **Last updated:** 2026-06-25 | **By:** `agent-1:opus` | **Session:** 1

## 0. Protocol

**Resume (cold start):**
1. Read this file end to end.
2. Run the gate commands listed in §3 and compare the result with what §1 and §7
   claim. The repo is the truth; correct this file if it drifted.
3. Open only the phase file named in §1 `Next action:`, at the named sub-phase.
   Read `overview.md` only if §2 is insufficient for the work at hand.
4. If §6 is non-empty, finish or revert that work before starting anything new.

**Update (after every sub-phase, mandatory):** rewrite §1, append to §4, update
§5 §6 §7, add §8 rows on any deviation, refresh §9 §10, bump the header
timestamp, then sync `resume.md`. A sub-phase is not `DONE` until this is
written.

## 1. Current position
- **Phase:** 0 — Config + error scaffolding (`phase_01.md`) — `TODO`
- **Sub-phase:** 0.1 — Add Quota/RateConfig/config parsing — `TODO`
- **Next action:** `phase_01.md` § 0.1 — add `Quota` and `RateConfig` to `src/config.rs`
- **Assigned:** `agent-3:haiku`
- **Repo state:** branch `main` | working tree `clean` | last commit `a1b2c3d init`

## 2. Feature context (self-contained recap)
Per-API-key rate limiting in the `gw` gateway. Opt-in via `--rate-limit <toml>`;
default off. Keys under their limit must not slow down; over-limit requests get
`429` plus `Retry-After`.

**Reference scenario:** 20 req/s against a 10 req/s key k1 → ~10 pass, rest 429.
**Hard constraints:** backward compatible; no new runtime deps; zero latency
regression when the flag is absent.
**Key decisions in force:** D1 token bucket per key; D2 flag-gated, default off;
D3 unlimited keys skip the map; D4 `429` + `Retry-After` in seconds; D5 quota `0`
rejects all.

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
- Q3 (deferred by the user): limits do not reload on SIGHUP; default applied,
  affects phase 2 § 2.1. Not a blocker.

## 10. Do-not-repeat
- none
````
