# Changelog

All notable changes to `rwang-workbench` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project will move to semantic versioning from v0.1.0 onward.

## [Unreleased]

### Phase 4 vendoring — 2026-04-23

- Phase 4 vendoring: 11 plugins, 44 components
- Source: `docs/archive/phase4-source-lock.md`
- Plugins: 11 (blocked: 0)
- Components final: 44 (productivity-pack: 42, analysis-pack: 2)
- Modified: minor=5, major=0, none=(remainder)
- Scan: 0 finding (manual multi-pattern grep per `docs/archive/phase4-plan.md §5`; gitleaks deferred to Phase 6, `scripts/phase4-scan.ps1` not authored — Phase 6 absorbs this into `validate-plugins.ps1`)
- Runtime verification (§6.5, 2026-04-23): `/reload-plugins` loaded 3 plugins · 18 skills · 19 agents · 8 hooks. `Skill(productivity-pack:plugin-structure)` and `Skill(analysis-pack:session-report)` both triggered successfully in desktop app; session-report launched `node analyze-sessions.mjs` from the vendored cache path.
- Known issue deferred to Phase 5: Python-based hookify hooks emit non-blocking `Failed with status code: Python` on UserPromptSubmit / PreToolUse:Skill / PostToolUse:Skill (Windows `python3` vs `python` — Phase 4 plan §4 Risk #4 manifestation). Does not block skill execution.

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
