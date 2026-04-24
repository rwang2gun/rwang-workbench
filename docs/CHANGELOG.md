# Changelog

All notable changes to `rwang-workbench` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project will move to semantic versioning from v0.1.0 onward.

## [Unreleased]

### Phase 6 — 2026-04-24

**Phase 6A — `scripts/validate-plugins.ps1` (V-1~V-6)**

- PowerShell 5.1 호환 validator 추가. 검증 항목: V-1 `marketplace.json` 구조(필수 필드 `name`/`owner`/`plugins[]` + JSON array 타입) / V-2 각 팩 `plugin.json` 필수 필드(`name`/`description`) / V-3 unknown 필드(허용 8개: `name`/`description`/`version`/`author`/`keywords`/`homepage`/`icon`/`license`) / V-4 `recommends.json` 구조(`recommends[]` + 각 항목 `name`·`reason`, JSON array 타입 보장) / V-5 `THIRD_PARTY_NOTICES` 일관성(vendored-from URL unique plugin set ↔ NOTICES 첫 번째 표 Plugin 컬럼 비교) / V-6 `scripts/git-hooks/pre-commit` 파일 존재.
- 로컬 실행 결과: **7 PASS, 0 WARN, 0 FAIL, 1 INFO (exit 0)**. `V-5 11/11 plugins matched`.
- Codex 2-round review: 1차 Low 2건 반영(V-1/V-4 `-is [Array]` 타입 체크 추가로 false PASS 방지), 2차 No findings.
- Phase 2 exit gate 임시 스크립트(`Work/phase2-validate-plugins.ps1`) → 리포 내 정식 스크립트로 승격. Phase 8 배포 전 / 신규 컴포넌트 추가 시 재실행용.

**Phase 6B — 인터랙티브 로컬 설치 재검증 (B-0~B-8)**

- `claude plugin` CLI 전 단계 자동화. B-0 클린 확보 (원본 `hookify` 독립 설치 **not found** 확인, 두 팩 + GitHub-source marketplace 모두 제거) / B-1 `claude plugin marketplace add D:/claude/rwang-workbench` (Directory source로 재등록) / B-2·B-3 두 팩 install OK.
- B-2a hook 실 실행 검증: 임시 `.claude/hookify.phase6-smoke.local.md` (`event: bash`, `pattern: phase6-hook-smoke`, `action: warn`, body `SMOKE-OK`) → `echo phase6-hook-smoke` → **세션 jsonl의 PreToolUse+PostToolUse `hook_system_message` attachment로 `SMOKE-OK` 발화 확증** (exit 0, 158ms). 스모크 파일 삭제 완료.
- **Python 3 설치**: 이 PC에 Python 3 미설치 상태였음 → `winget install Python.Python.3.12 --scope user` 로 Python 3.12.10 설치, Claude Code 재시작 후 `python.exe` 리졸브가 `...Programs\Python\Python312\python.exe`로 전환됨 (기존 Windows Store stub은 PATH 후순위로 강등). CLAUDE.md 환경 특이사항 "Python 3 미설치" 해소.
- B-4 `productivity-pack:help` / B-4a `analysis-pack:playground` skill 로드·응답 생성 / B-5 `/productivity-pack:check-recommended` command load PASS (출력은 💡 `marketplace-not-found` — production 경로에서 local Directory source marketplace를 스크립트가 resolve하지 못하는 현상; plan §3.2 판단 기준상 non-blocking) / B-6·B-7 uninstall OK.
- B-8 (low-gate): filesystem uninstall 완료 (`installed_plugins.json` → codex만 잔존) 확인. 단 현재 세션 내 skill namespace 는 cache로 잔존 — Claude Code plugin lifecycle 공식 동작 (세션 재시작 시 해제). 투명 기록.
- **Phase 7 진입 대체성 조건 충족**: 원본 hookify 없이 새 pack만 설치된 상태에서 command 1개(check-recommended) + skill 2개(help/playground) + hook 실 실행(smoke rule) 모두 성공.
- **B-2a UI 렌더링 Known Issue**: Claude Code Desktop v2.1.111에서 `hook_system_message` attachment가 세션 jsonl에는 정확히 기록되지만 UI 채팅에는 노출되지 않음. 기능(hook 발화·실행·응답 전송)은 모두 정상. v6 원칙에 따라 한계 투명 기록.

**Phase 6C — Closure**

- 본 CHANGELOG Phase 6 블록 확장 (6A/6B/6C 통합).
- `docs/MASTER_PLAN_v1.5.md` §8: `⬜ Phase 6~8` → `✅ Phase 6 완료 (2026-04-24)` + `⬜ Phase 7~8`.
- `docs/phase6-plan.md` → `docs/archive/phase6-plan.md` (v5까지 Codex 4회 리뷰 이력 보존).

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
