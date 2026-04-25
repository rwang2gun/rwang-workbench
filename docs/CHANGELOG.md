# Changelog

All notable changes to `rwang-workbench` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project will move to semantic versioning from v0.1.0 onward.

## [0.1.0] — 2026-04-25 — First public release

Phase 3 alpha(0.1.0-alpha) 이후 Phase 4~8 누적 산출물의 첫 stable release.
Vendoring 11 plugins · 44 components · 2 packs · 1 external recommend(codex).

### Phase 8 — 2026-04-25

**Phase 8P — Plan-fix seed**
- phase8-plan v5 + PLAN_DESIGN_GUIDELINES v1.2 + CLAUDE.md sync 변경분을 본 phase 본 작업 전 별도 commit으로 고정. plan 본문 자기참조 sanitize 적용 (절대경로/사용자명/email은 placeholder + `$repo` 변수, P-2 Anthropic noreply 명시 면죄). 8A retroactive grep scope에 plan/guidelines 포함, 8D git mv 작동 보장.

**Phase 8A — §4.5 Public 게이트 통과**
- gitleaks 8.30.1 (`dir`/`git` syntax): 양 모드 0 finding (2026-04-25 21:24:32 +09:00).
- Retroactive 절대경로·계정명 grep (P-1~P-4 strict 자연어 ↔ 검사 코드 1:1): 0 finding. allowlist line 단위 (hook PATH_PATTERNS 정의 line + Anthropic noreply footer line).
- `.gitignore` 보강: `.claude/` 일반화 → 8A 후 ignored.
- `.env.example`: 사용자 설정 env 0건으로 미작성 결정.
- `docs/release-checklist-v0.1.0.md` 작성 — §4.5 8/8 PASS + Release-time 5종 drop. 본문은 변수 치환 후 specific 값 박힘 (placeholder 잔존 0건). **8A commit 상태 그대로 release까지 유지**.

**Phase 8B — GitHub source 재설치 검증 (§3.1 wrapper inline + try/finally)**
- preflight snapshot → Directory source 제거 → `claude plugin marketplace add rwang2gun/rwang-workbench` (GitHub source) → 두 팩 install → V-1~V-4 검증 → finally restore (Directory source 복원).
- V-1 list / V-2 source.source `github` / V-3 installPath ∉ repo / V-4 orphan-check exit 0 / V-restore source.source `directory` 모두 PASS. dev 환경 정상 복원.

**Phase 8C — Release commit + tag (prepared)**
- 두 팩 `plugin.json` version `0.1.0-alpha` → `0.1.0`.
- README L5 status: `v0.1.0-alpha (scaffolded)` → `v0.1.0 (Phase 8 release)`.
- 본 CHANGELOG 전환 (`[Unreleased]` → `[0.1.0]`).
- `docs/MASTER_PLAN_v1.5.md` §8: 8C release commit/tag prepared. push/smoke/Release object 결과는 8D 블록.
- annotated tag `v0.1.0` 생성 (push는 G5 승인 후 8C-post에서).

(8C-post 단계 — atomic push, release 후 GitHub source smoke, GitHub Release object 생성 — 결과는 아래 **Phase 8D** 블록에 8D commit 시 변수 치환으로 채워짐. 8C commit 시점에는 변수 placeholder만 잔존 — 8D commit 전 grep BLOCK으로 잔존 0건 보장)

**Phase 8D — Closure + post-release 결과**
- phase8-plan archive (`git mv` 작동, 8P seed 덕분).
- CLAUDE.md Phase 9 (지속 운영) 전환.
- MASTER_PLAN §8: 🔶 → ✅ Phase 8 완료 (8P/8A/8B/8C/8C-post/8D 흡수).
- **8C-post 결과 (8D commit 시 변수 치환)**:
  - atomic push: {{ATOMIC_RESULT}}
  - release 후 GitHub source smoke: {{SMOKE_RESULT}} — 두 팩 version 0.1.0 + source.source `github` + installPath ∉ repo 확인. Directory source 복원 try/finally 보장.
  - GitHub Release page: {{RELEASE_URL}}

### Phase 7 — 2026-04-25

**Phase 7A — `scripts/check-orphan-originals.ps1` (O-1~O-3)**

- PowerShell 5.1 호환 orphan-originals detector 추가. 검증 항목: O-1 11개 편입 원본 (`hookify`, `claude-code-setup`, `claude-md-management`, `mcp-server-dev`, `playground`, `plugin-dev`, `session-report`, `commit-commands`, `feature-dev`, `pr-review-toolkit`, `security-guidance`)의 user-scope 독립 설치 여부 (generic key enumerate + `scope=='user'` 필터 + `<name>` 정확 일치 or `<name>@*` prefix 일치, 모두 case-sensitive `-ceq`/`-clike`) / O-2 `~/.claude/skills/` orphan (편입 skill 이름 = 디렉토리명 ∪ `SKILL.md` frontmatter `name:` 합집합, 인라인 YAML 코멘트 스트립) / O-3 `known_marketplaces.json` `.source.repo` 필드 조회 (`anthropics/claude-plugins-official`, `anthropics/claude-plugins-public` 기준, INFO only).
- 실패 분류 (plan §4.1.2): `installed_plugins.json` 부재 = PASS (설치 전무) / parse-failed·unexpected-schema·IO 실패 = FAIL / 매칭 key의 `entries` non-Array = FAIL / entry element malformed(non-object · `scope` 필드 부재·string 아님) = FAIL.
- Exit code 규칙 (plan §4.1.3): 0=clean / 2=WARN (7B 진행) / 1=FAIL (게이트 블록).
- 로컬 실행 결과: **12 PASS, 0 WARN, 0 FAIL, 2 INFO (exit 0 clean)**. 11개 원본 모두 user-scope 미설치 확인, `~/.claude/skills/` 부재, `anthropics/claude-plugins-official`만 known (vendoring source이므로 무방).
- Codex 3-round review: 1차 High 2건 (`plugins` 필드 case-sensitive 타입 체크 강화 + `<name>`/`<name>@*` 매칭을 `-ceq`/`-clike`로 case-sensitive화) + Low 1건 (O-3을 `.source.repo` 필드 매칭으로 교체). 2차 Low 2건 (entry `scope` property case-sensitive lookup + 값 `-ceq`, frontmatter `name:` 파싱 시 인라인 YAML 코멘트 스트립). 3차 No findings.
- Plan §5 Phase 7 의무 이행의 자동 검증 루틴으로 정착. Phase 8 이후 신규 PC에서도 동일 스크립트 1회 실행으로 검증 가능.

**Phase 7B — skip (clean 상태)**

- 7A exit 0 (0 WARN)으로 plan §4.2 실행 조건 미충족. `claude plugin disable` / `~/.claude/skills/` 제거 작업 없음.
- Phase 6B B-0에서 확인된 "원본 hookify 부재"가 나머지 10개 원본까지 확장 확인된 상태.

**Phase 7C — 두 팩 최종 재설치**

- `claude plugin install productivity-pack@rwang-workbench` + `analysis-pack@rwang-workbench` 실행 → `claude plugin list`에 3개 enabled (codex + 두 팩) 확인.
- 재설치 직후 `check-orphan-originals.ps1` 재실행도 12 PASS / 0 WARN / 0 FAIL (exit 0) 유지. 재설치가 편입된 skill 이름과 `~/.claude/skills/` 디렉토리 생성을 유발하지 않음 확인.

**Phase 7D — Closure**

- 본 CHANGELOG Phase 7 블록 확장 (7A/7B skip/7C/7D 통합).
- `docs/MASTER_PLAN_v1.5.md` §8: `⬜ Phase 7~8` → `✅ Phase 7 완료 (2026-04-25)` + `⬜ Phase 8`.
- `docs/phase7-plan.md` → `docs/archive/phase7-plan.md` (v6까지 Codex 6회 리뷰 이력 보존: 1차 4건·2차 3건·3차 3건·4차 3건·5차 2건·6차 0건 수렴).
- `CLAUDE.md` 상태 표 Phase 7 반영 + 다음 액션을 Phase 8 착수로 전환.

### Phase 6 — 2026-04-24

**Phase 6A — `scripts/validate-plugins.ps1` (V-1~V-6)**

- PowerShell 5.1 호환 validator 추가. 검증 항목: V-1 `marketplace.json` 구조(필수 필드 `name`/`owner`/`plugins[]` + JSON array 타입) / V-2 각 팩 `plugin.json` 필수 필드(`name`/`description`) / V-3 unknown 필드(허용 8개: `name`/`description`/`version`/`author`/`keywords`/`homepage`/`icon`/`license`) / V-4 `recommends.json` 구조(`recommends[]` + 각 항목 `name`·`reason`, JSON array 타입 보장) / V-5 `THIRD_PARTY_NOTICES` 일관성(vendored-from URL unique plugin set ↔ NOTICES 첫 번째 표 Plugin 컬럼 비교) / V-6 `scripts/git-hooks/pre-commit` 파일 존재.
- 로컬 실행 결과: **7 PASS, 0 WARN, 0 FAIL, 1 INFO (exit 0)**. `V-5 11/11 plugins matched`.
- Codex 2-round review: 1차 Low 2건 반영(V-1/V-4 `-is [Array]` 타입 체크 추가로 false PASS 방지), 2차 No findings.
- Phase 2 exit gate 임시 스크립트(`Work/phase2-validate-plugins.ps1`) → 리포 내 정식 스크립트로 승격. Phase 8 배포 전 / 신규 컴포넌트 추가 시 재실행용.

**Phase 6B — 인터랙티브 로컬 설치 재검증 (B-0~B-8)**

- `claude plugin` CLI 전 단계 자동화. B-0 클린 확보 (원본 `hookify` 독립 설치 **not found** 확인, 두 팩 + GitHub-source marketplace 모두 제거) / B-1 `claude plugin marketplace add <repo absolute path>` (Directory source로 재등록) / B-2·B-3 두 팩 install OK.
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
- `scripts/git-hooks/pre-commit` 3 scenarios pass: secret-pattern block (AKIA…), personal-path block (Windows 사용자 홈 형태 절대경로), vendored `modified: none` protection block.
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
- Portability: fresh `git clone` into a local Windows absolute path + full install flow passed. No absolute-path or personal-identifier dependencies detected.
- `recommends.json` raises no `plugin.json` schema warnings (separate file).

### Notes
- `game-design-pack` is deferred (MASTER_PLAN §2.3.1 gate: vendored 0 + new-authored 1 < 2). Not registered in `marketplace.json`.
- Vendored content lands in Phase 4. Self-authored workflows in Phase 5.
- `/productivity-pack:check-recommended` command is planned for Phase 5.
