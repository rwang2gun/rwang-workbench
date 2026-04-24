# Changelog

All notable changes to `rwang-workbench` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project will move to semantic versioning from v0.1.0 onward.

## [Unreleased]

### Phase 6 — 2026-04-24 (in progress)

- Phase 6B interactive verification passed (2026-04-24): B-0 clean state + hookify not-found (no standalone install) / B-1 marketplace add (Directory source) / B-2·B-3 installs / B-2a hook real execution confirmed via session-log attachments (PreToolUse+PostToolUse `hook_system_message` = `SMOKE-OK`; UI render not observed) / B-4·B-4a skill loads / B-5 `check-recommended` command load PASS (💡 `marketplace-not-found` non-blocking) / B-6·B-7 uninstalls / B-8 filesystem uninstall OK, in-session skill namespace cache persists until session restart (Claude Code plugin lifecycle, low-gate).

### Phase 5 — 2026-04-24

**Phase 5A — Python hook cross-platform fix + README Prerequisites**

- Python hook cross-platform fix: A1 (`python3` → `python`, 5 `hooks.json` commands). `hooks/*.py` · `core/*.py` unchanged (vendored `modified: none` preserved).
- `plugins/productivity-pack/README.md`: Prerequisites section added with transparent platform limitation notice (upstream Claude Code Issues #37634, #18527).
- Source-lock §3.1.1 updated (`docs/phase5-plan.md` → archived in 5D).

**Phase 5B — §4.6 v0.1 recommends system**

- `/productivity-pack:check-recommended` command shipped: `scripts/check-recommended.mjs` (Node 16+ ESM) + `commands/check-recommended.md` (with `INSTALLED_PLUGINS_PATH` env override subsection).
- `docs/RECOMMENDED_PLUGINS.md`: 3-item polish (initial-install one-liner + `/check-recommended` guidance + MCP subsection).
- `plugins/productivity-pack/.claude-plugin/recommends.json`: schema-aligned reference (`codex` external dependency).
- Verification: 12 cells pass (Git Bash + PowerShell 5.1 + production + `import.meta.url` fallback). Cell 11 md5 unchanged before/after (`64819c38…a79e`).

**Phase 5C — Self-authored assets (C-2 only; C-1/C-3/C-4 dropped)**

- `scripts/git-hooks/pre-commit` (C-2 implement, realistic combo a+b+d):
  - (a) secret-pattern scan on staged added lines
  - (b) personal absolute-path detection (`…Users/code1412/…`)
  - (d) vendored `modified: none` protection (blocks edits to files declared `modified: none` in source-lock)
  - Scope: staged diff added lines only (no retroactive trigger)
  - Bypass: `git commit --no-verify` (reason required in commit message)
- `plugins/productivity-pack/README.md`: "Git hooks (optional)" section added (activation: `git config core.hooksPath scripts/git-hooks` — one-time per clone).
- Verification: 6 scenarios pass (clean / secret / path / vendored-M / vendored-A / --no-verify).
- **Dropped by user decision (2026-04-24)**: C-1 `/sync-to-git` (unnecessary automation), C-3 draw.io MCP bundle, C-4 GCP MCP bundle (pack-level MCP bundling out of scope; one-line reference in `RECOMMENDED_PLUGINS.md` MCP subsection only).

**Phase 5D — Closure**

- This CHANGELOG block.
- `docs/MASTER_PLAN_v1.5.md` §8: Phase 5 completion status line.
- `docs/phase5-plan.md` → `docs/archive/phase5-plan.md` (source-lock appendix preserved).

**Phase 5 local verification — 2026-04-24**

- `git pull origin main` after PR #1 merge; 15 files updated, local main at `2dc0941`.
- `check-recommended.mjs` 5 fixture scenarios pass: installed-codex (✅), installed-no-codex (❌), bad-json (parse-failed warning), unexpected-schema (warning), file-missing (warning).
- `scripts/git-hooks/pre-commit` 3 scenarios pass: secret-pattern block (AKIA…), personal-path block (`C:/Users/code1412/…`), vendored `modified: none` protection block.
- `hooks.json` all 5 commands confirmed `python` (not `python3`); `recommends.json` codex entry structure valid.

**Phase 4 Known Issue resolution**

- Python hook `Failed with status code: Python` issue: **Resolved in Phase 5** (A1 `python3` → `python` + graceful skip on Python-2-default systems via hookify's existing ImportError handler; see Accepted Limitations below).

**Accepted Limitations (platform)**

- On systems where `python` points to Python 2 (e.g., Ubuntu ≤ 20.04 default), hookify Python hooks gracefully skip via the existing ImportError handler (`pretooluse.py:22-29`). Main Claude Code operation is not impacted. Workaround: install Python 3 and ensure `python` resolves to it on PATH (see `plugins/productivity-pack/README.md` Prerequisites).
- Windows: `bash`-declared hooks may be intercepted by the WSL `bash` stub when WSL is not provisioned (upstream Claude Code Issue #37634). Python hooks ship with command `python …` to sidestep this path. Not fully platform-agnostic — revisit in Phase 9 after upstream resolution of #37634, #18527.
- Rationale: **Anthropic official pattern (hookify graceful skip) > Codex perfectionism**. Self-developing platform workarounds (e.g., `launch-python.mjs`, `plugin.json` `prerequisites` field) rejected in plan v6 after confirming Claude Code official schema does not support them (2026-04-24 research).

### Phase 4 vendoring — 2026-04-23

- Phase 4 vendoring: 11 plugins, 44 components
- Source: `docs/archive/phase4-source-lock.md`
- Plugins: 11 (blocked: 0)
- Components final: 44 (productivity-pack: 42, analysis-pack: 2)
- Modified: minor=5, major=0, none=(remainder)
- Scan: 0 finding (manual multi-pattern grep per `docs/archive/phase4-plan.md §5`; gitleaks deferred to Phase 6, `scripts/phase4-scan.ps1` not authored — Phase 6 absorbs this into `validate-plugins.ps1`)
- Runtime verification (§6.5, 2026-04-23): `/reload-plugins` loaded 3 plugins · 18 skills · 19 agents · 8 hooks. `Skill(productivity-pack:plugin-structure)` and `Skill(analysis-pack:session-report)` both triggered successfully in desktop app; session-report launched `node analyze-sessions.mjs` from the vendored cache path.

## [0.1.0-alpha] — 2026-04-23 — Phase 3 scaffold

### Added
- Initial repo scaffold: `.claude-plugin/marketplace.json`, two packs (`analysis-pack`, `productivity-pack`) with standard `plugin.json`.
- `plugins/productivity-pack/.claude-plugin/recommends.json` with the `codex` external dependency.
- `LICENSE` (MIT), `THIRD_PARTY_NOTICES.md` (placeholder values filled in Phase 4).
- `docs/`: `ARCHITECTURE.md`, `INSTALL.md`, `RECOMMENDED_PLUGINS.md`, `MASTER_PLAN_v1.5.md`, Phase 1 catalog, Phase 2 selection.
- `.gitignore` covering `.env`, `dist/`, personal notes/archives.

### Verified (Phase 3 Acceptance — 2026-04-23)
- `/plugin marketplace add rwang2gun/rwang-workbench` → success.
- `/plugin install analysis-pack@rwang-workbench` → success.
- `/plugin install productivity-pack@rwang-workbench` → success.
- `/plugin uninstall` + reinstall cycle → success.
- Portability: fresh `git clone` into `D:/claude/rwang-workbench` + full install flow passed. No absolute-path or personal-identifier dependencies detected.
- `recommends.json` raises no `plugin.json` schema warnings (separate file).

### Notes
- `game-design-pack` is deferred (MASTER_PLAN §2.3.1 gate: vendored 0 + new-authored 1 < 2). Not registered in `marketplace.json`.
- Vendored content lands in Phase 4. Self-authored workflows in Phase 5.
- `/productivity-pack:check-recommended` command is planned for Phase 5.
