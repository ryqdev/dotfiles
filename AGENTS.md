# AGENTS.md

> Purpose: This document defines how an AI coding agent (e.g., CodeX/Codex) should operate in this repository.
> Goals: correctness, maintainability, performance, and safe changes with verifiable outcomes.

## 0) Operating Principles (Non-Negotiable)

1. **Make changes that compile and pass tests.**  
   If you cannot run tests, explain what you validated and why.

2. **Small, reviewable diffs > big refactors.**  
   Prefer minimal changes that solve the requested problem.

3. **No silent behavior changes.**  
   Any change in output/format/API behavior must be documented in the PR summary.

4. **No secrets.**  
   Never print, log, or request real tokens/keys. Use env vars placeholders.

5. **Be deterministic.**  
   Avoid non-deterministic tests, time-based flakes, and random outputs without seeding.

---

## 1) Communication Contract

When responding, always structure as:

- **Plan** (short bullet list)
- **Changes** (what files and why)
- **Validation** (commands run + results; if not run, state reason)
- **Notes/Risks** (edge cases, follow-ups, tradeoffs)

If requirements are ambiguous, make a reasonable assumption and proceed; document assumptions explicitly.

---

## 2) Change Workflow (Step-by-step)

1. **Read existing code and conventions** before writing new code.
2. **Add/modify tests first** when possible (especially for bugfixes).
3. Implement solution with **clean abstractions** and **explicit error handling**.
4. Run:
   - format
   - lint
   - unit/integration tests
5. Provide a **final summary + commands** for the user to reproduce.

---

## 3) Repository Hygiene

### 3.1 File & Module Organization
- Keep public API surfaces small and stable.
- Prefer cohesive modules; avoid “utils dumping ground”.
- New code should be placed near its domain (not a generic folder).

### 3.2 Naming
- Use domain-driven naming: `orderbook`, `execution`, `risk`, `signal`, `pipeline`.
- Avoid ambiguous abbreviations unless standard (`cfg`, `ctx`, `dto`).

### 3.3 Documentation
- Any non-trivial module should have:
  - a short `///` doc comment (Rust)
  - or module docstring (Python)
  - or package-level comment (Go)
- Update README if behavior or setup changes.

---

## 4) Code Quality Standards

### 4.1 Error Handling
- **No panics in runtime paths** (unless truly unrecoverable and justified).
- Prefer typed errors and context:
  - Rust: `anyhow::Context`, `thiserror`
  - Python: raise specific exceptions; wrap external errors with context
  - Go: wrap errors with `%w`

### 4.2 Logging
- Logs must be actionable and structured.
- Avoid logging sensitive data (keys, PII, full payloads).
- Prefer:
  - Rust: `tracing` or `log`
  - Python: `structlog` or stdlib `logging`
  - Go: `zap` or stdlib `log` (project dependent)

### 4.3 Concurrency / Async
- Tokio: avoid blocking in async tasks. If needed use `spawn_blocking`.
- Avoid unbounded queues unless justified. Prefer bounded channels + backpressure.
- Always consider cancellation and shutdown.

### 4.4 Performance
- Don’t optimize prematurely, but:
  - avoid accidental O(n^2)
  - avoid unnecessary allocations/copies in hot paths
  - measure before/after if you claim perf gains
- Prefer data-oriented layout when obvious (SoA for tight loops).

### 4.5 Security
- Validate external input.
- Avoid shell injection; use safe APIs.
- Default to least privilege and safe defaults.

---

## 5) Language-specific Rules

### 5.1 Rust
**Style**
- `rustfmt` + `clippy` must pass.
- Prefer explicit lifetimes only when needed.
- Avoid `unsafe` unless performance-critical + documented.

**Crates**
- Prefer widely adopted crates.
- If adding a dependency:
  - justify it
  - keep feature flags minimal

**Patterns**
- Use `Result<T, E>` everywhere for fallible ops.
- Use `Arc<..>` only when needed.
- Prefer `BTreeMap` when order matters; `HashMap` when it doesn’t.

**Validation commands (typical)**
- `cargo fmt`
- `cargo clippy --all-targets --all-features -D warnings`
- `cargo test --all --all-features`

### 5.2 Python
**Style**
- Keep modules import-clean; no heavy work at import time.
- Prefer type hints; keep interfaces explicit.

**Tooling**
- Format: `ruff format` (or `black` if repo uses it)
- Lint: `ruff check`
- Tests: `pytest -q`

**Rules**
- Avoid implicit timezone issues; use UTC explicitly where possible.
- Prefer pure functions for signal logic; isolate I/O.

### 5.3 Go
**Style**
- `gofmt` is mandatory.
- Prefer explicit interfaces at boundaries.
- Avoid global mutable state.

**Validation commands (typical)**
- `go test ./...`
- `go vet ./...`

### 5.4 TypeScript / Node (Bun)
**Style**
- Prefer ESM unless repo requires CJS.
- Avoid `any`; prefer precise types.
- Add runtime validation for external inputs (`zod` etc.) when needed.
- Keep Node/Bun runtime compatibility in mind (filesystem, streams, fetch).

**Validation**
- `bun lint`
- `bun test`
- `bun run typecheck`

---

## 6) Testing Strategy

### 6.1 Required for Bugfixes
- Add a regression test that fails before the fix and passes after.

### 6.2 Determinism
- Avoid time-based flakes:
  - freeze time or inject clock
  - seed randomness
- Prefer pure unit tests for logic.

### 6.3 Trading / Market Data (If applicable)
- Separate:
  - market data parsing
  - state updates (order book)
  - signal generation
  - execution/risk controls
- Add tests for:
  - out-of-order updates
  - partial snapshots
  - duplicate events
  - empty book / zero size levels

---

## 7) Git & PR Conventions

### 7.1 Commits
- Keep commits atomic.
- Use conventional commits when possible:
  - `feat: ...`
  - `fix: ...`
  - `refactor: ...`
  - `test: ...`
  - `docs: ...`

### 7.2 PR Description Template
Include:
- What changed
- Why
- How to test (commands)
- Risks / edge cases
- Follow-ups

---

## 8) Dependency & Build Discipline

- Do not introduce new dependencies casually.
- Prefer standard library solutions first.
- If adding a dependency:
  - explain the tradeoff
  - pin versions via lockfile
  - ensure license is compatible (best-effort)

---

## 9) Environment Assumptions

- Developer uses:
  - Linux (often Arch) and macOS
  - VS Code / Vim
  - zsh + powerlevel10k
- Prefer cross-platform commands and paths.
- Use absolute paths in systemd examples; avoid brittle assumptions.

---

## 10) Safe Defaults for Config & Secrets

- All secrets are read from environment variables:
  - `API_KEY`, `DATABASE_URL`, `REDIS_URL` etc.
- Provide `.env.example` when adding new variables.
- Never commit real secrets or test tokens.

---

## 11) Output Expectations for the Agent

When delivering changes, provide:

1. **Files changed** (with brief rationale)
2. **Exact commands to run**
3. **Expected output / checks**
4. **Rollback strategy** if change is risky

Example commands section:
```bash
# Rust
cargo fmt
cargo clippy --all-targets --all-features -D warnings
cargo test --all --all-features

# Python
ruff format .
ruff check .
pytest -q

