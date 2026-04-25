# rwang-workbench — Claude 세션 핸드오프

개인용 Claude Code 플러그인 마켓플레이스. 세션 시작 시 이 문서 먼저 읽고 현재 Phase 상태·다음 액션을 파악할 것.

---

## 현재 상태 (2026-04-25)

| Phase | 상태 | 비고 |
|---|---|---|
| 1–4 | ✅ 완료 | vendoring + 스캐폴드 + 44 컴포넌트 편입 |
| 5 | ✅ 완료 | 4배치 (5A~5D). Python hook cross-platform + check-recommended + pre-commit hook + 마감 |
| 6 | ✅ 완료 | 3배치 (6A/6B/6C). `validate-plugins.ps1` 승격 + 인터랙티브 재검증 + Python 3.12 설치로 환경 특이사항 해소 |
| **7A** | ✅ 완료 (commit `13ff93b`) | `scripts/check-orphan-originals.ps1` O-1~O-3 → 12 PASS / 0 WARN / 0 FAIL / 2 INFO (exit 0 clean). Codex 3-round (1차 High 2+Low 1, 2차 Low 2, 3차 No findings) |
| **7B** | ⏭️ skip | 7A clean으로 정리 대상 없음 |
| **7C** | ✅ 완료 (commit `7e38a38`) | 두 팩 재설치 + `claude plugin list` 3개 enabled + orphan-check 재확인 clean |
| **7D** | ✅ 완료 | 마감: CHANGELOG Phase 7 블록 + MASTER_PLAN §8 + phase7-plan archive + 본 CLAUDE.md 동기화 |
| **Phase 7** | ✅ **전체 완료** | Phase 8 대기 |

**Working tree**: Phase 7D 마감 커밋 직후 → clean 유지.

**현재 enabled 플러그인**: codex@openai-codex, productivity-pack@rwang-workbench, analysis-pack@rwang-workbench (3개).

**Repo-local 훅 활성화 상태**: `core.hooksPath = scripts/git-hooks` 로컬에 설정됨 (이 PC). 다른 PC에서 클론 후 1회 실행 필요.

---

## 다음 액션 — Phase 8 plan v5.4 → Codex 9차 리뷰 (다음 세션)

Phase 8 진행 중. plan v1 → v5.4 누적 패치. 가이드라인 v1.2 갱신 완료. Codex 8차까지 수렴 추세 정상.

**수렴 추세**: 12 → 11 → 8 → 9(역행) → v5 전면 재작성(13건 흡수) → 4 → 2 → 1(non-BLOCK) → 2 → ?(9차 대기)

**다음 세션 첫 액션**:
1. **`.claude/phase8-handoff.md` 읽기** — v5.4 시점 핸드오프 (8차 2건 흡수 결과 + 9차 prompt + working tree 상태)
2. 사용자 "이어서 진행" 확인
3. **Codex 9차 리뷰 호출** (Bash CLI, **Skill 호출 금지**):
   ```bash
   codex exec -C /d/claude/rwang-workbench -s read-only "$(cat /tmp/codex-9th-prompt.md)"
   ```
   prompt 본문은 `.claude/phase8-handoff.md` "9차 리뷰 prompt" 섹션 그대로 복사
4. 결과 분석 → 사용자 보고
   - **non-BLOCK / PASS**: G1 사용자 명시 승인 후 **Batch 8P** (Plan-fix seed commit) 착수
   - **BLOCK**: v5.5 minor patch + Codex 10차

**v5.4 누적 흡수 history**:
- v5 (전면 재작성, 13건 — Codex 4차 9 + Claude self 4)
- v5.1 — Codex 5차 BLOCK 4건
- v5.2 — Codex 6차 BLOCK 2건
- v5.3 — Codex 7차 non-BLOCK 1건 (자체정리)
- v5.4 — Codex 8차 BLOCK 2건 (§4.1.5 `$gitleaksVersion` 검증 추가 + §4.3.10→§4.3.11 smoke 오참조 정정)

**Working tree 상태** (다음 세션 진입 시):
```
 M CLAUDE.md
?? .claude/
?? docs/PLAN_DESIGN_GUIDELINES.md
?? docs/phase8-plan.md
```
미commit. 8P seed commit이 본격 작업의 첫 step (Codex 9차 수렴 후).

**주의**: Codex CLI background hang 현상 발견 — 9차 호출 시 5분 이상 출력 없으면 같은 명령 sync 재시도. 자세히는 핸드오프 노트 "미해결 / 주의 사항".

---

## 핵심 설계 문서

- **[docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md)** — 전체 설계. §5 Phase 계획 + §8 상태. **수정 금지** (역사적 기록). §8만 Phase 마감 시 업데이트
- **[docs/PLAN_DESIGN_GUIDELINES.md](docs/PLAN_DESIGN_GUIDELINES.md)** — phase plan 작성 5축(Public irreversibility / Atomic action / Repo 사실 확인 / 표현 일관성 / Scope 명시) + 메타 패턴(위상 변화 인지). **plan v1 초안 직후 self-review에 필수 적용**, Codex CLI 리뷰 호출 **전** 단계. phase8-plan v1 Codex 1차 BLOCK 회고에서 추출 (2026-04-25)
- **[docs/CHANGELOG.md](docs/CHANGELOG.md)** — Phase 5·6·7 블록 기록 완료. Phase 8부터 동일 패턴으로 추가
- **[docs/RECOMMENDED_PLUGINS.md](docs/RECOMMENDED_PLUGINS.md)** — 5B 보강 완료. 향후 추천 항목 추가 시 갱신
- **[docs/archive/](docs/archive/)** — 완료된 Phase 플랜·source-lock (`phase4-plan.md`, `phase4-source-lock.md`, `phase5-plan.md`, `phase6-plan.md`, `phase7-plan.md`)
- **[scripts/validate-plugins.ps1](scripts/validate-plugins.ps1)** — Phase 6A 승격 validator. Phase 8 배포 전 / 신규 컴포넌트 추가 시 재실행 (PS 5.1 호환)
- **[scripts/check-orphan-originals.ps1](scripts/check-orphan-originals.ps1)** — Phase 7A orphan-originals detector. 다른 PC에서 셋업 시 1회 실행하여 원본 11개 독립 설치·`~/.claude/skills/` 복제본 여부 검증 (PS 5.1 호환, exit 0=clean / 2=WARN / 1=FAIL)

---

## 환경 특이사항

### Python 3 설치됨 (Phase 6B에서 해소)
- **Python 3.12.10** — `~/AppData/Local/Programs/Python/Python312/python.exe`. `winget install Python.Python.3.12 --scope user`로 설치 (2026-04-24).
- PATH 우선순위: Python312 → WindowsApps stub. 즉 `python` 호출 시 실제 3.12 실행. Claude Code 재시작 후 반영됨.
- Phase 6B B-2a hook 실 실행 검증에서 정상 작동 확인 (세션 jsonl attachment). CLAUDE.md 이전판의 "Python 3 미설치" 한계는 해소.
- 단 **다른 PC에 클론 시 여전히 동일 설치 절차 필요** — README Prerequisites와 Accepted Limitations 그대로 유지 (Ubuntu ≤ 20.04 default 등은 미해소).

### Node.js 의존성 (5B에서 필요)
- `check-recommended.mjs`는 ESM → Node 16+ 필요. 설치 여부 `node --version`으로 확인.
- Node는 **수동 명령 경로에만** 의존. 훅 자동 경로(5A)는 Python만 요구.

### 상위 원칙 (v6 확립)
> **Anthropic 공식 패턴(hookify graceful skip) > Codex 완벽주의 권고**

Codex 추가 리뷰(8차 이후)는 **informational / non-blocking**. 플랫폼이 제공하지 않는 우회책 자체 개발보다 공식 패턴 따르기 + 한계 투명 문서화가 우선.

---

## 커밋 컨벤션

```
Phase <N><letter>: <한줄 요약>

- <변경 파일·내용>
- <근거·검증>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

- HEREDOC로 전달 (`git commit -m "$(cat <<'EOF' ... EOF )"`)
- **파일은 명시적으로 stage** (`git add <file>`). `git add -A` 금지
- `--amend` 금지 (새 커밋 선호)
- hooks 건너뛰기(`--no-verify`) 금지

---

## 확정된 결정사항 (변경 금지)

- **vendored 파일 `modified: none` 유지** — upstream 자동 머지 경로 보존. hookify `.py` 재작성 금지
- **C-1 `/sync-to-git` drop** — 자동 동기화 기능 불필요 (2026-04-24 사용자 결정)
- **C-3 draw.io MCP / C-4 GCP MCP drop** — 팩 번들 X. RECOMMENDED_PLUGINS.md MCP 서브섹션 한 줄만 (2026-04-24 사용자 결정)
- **`validate-plugins.ps1` Phase 6A에서 승격 완료** — `scripts/validate-plugins.ps1` (PS 5.1 호환, V-1~V-6)
- **game-design-pack 유예** — Phase 2 결정
- **phase plan 작성 흐름** — v1 초안 → `docs/PLAN_DESIGN_GUIDELINES.md` 5축 self-review → Codex CLI 리뷰 (`codex exec -C <repo> -s read-only ...`, **Skill 호출 금지**) → finding 통합 v2 패치 → 수렴까지 반복 → G1 사용자 승인. 2026-04-25 phase8-plan v1 BLOCK 회고로 정착

---

## 대기 중인 사용자 결정

없음. Phase 7 전체 완료. Phase 8 착수 시점은 사용자 지시 대기.

---

## Pre-commit 훅 운영 노트 (5C 이후)

- 활성화: `git config core.hooksPath scripts/git-hooks` (레포 클론당 1회)
- 검사: (a) 시크릿 패턴 / (b) 개인 절대경로 `…Users/code1412/…` / (d) vendored `modified: none` 보호
- 스캔 범위: staged diff의 **added 라인만** — 기존 내용은 retroactive 트리거 없음
- 우회: `git commit --no-verify` (사유를 커밋 메시지에)
- 다른 PC에서 쓰려면: 클론 후 `core.hooksPath` 1회 설정 필요 (git config는 레포 로컬이라 자동 배포 안 됨)

---

## 트러블슈팅 힌트

- **훅 에러 체감 없는데 동작 중인가?** → graceful skip 정상. `pretooluse.py:22-29`의 ImportError 핸들러가 처리. 이 PC는 이제 Python 3.12 실 설치됐으므로 실 실행 경로로 동작.
- **Windows에서 `bash` 훅이 WSL 스텁으로 해석됨** → Claude Code Issue [#37634](https://github.com/anthropics/claude-code/issues/37634). Phase 9에서 upstream 개선 후 재평가.
- **`plugin.json`에 prerequisite 필드 추가하고 싶다** → 공식 스키마 미지원 확정(2026-04-24 조사). 포기하고 README 고지로 대체.
- **hook systemMessage가 UI에 안 보이는데 실제로 발화하나?** → Claude Code Desktop v2.1.111의 UI 렌더링 이슈(2026-04-24 Phase 6B 확인). 세션 jsonl의 `hook_system_message` attachment로 실 발화 확증 가능. `~/.claude/projects/<project>/<sessionId>.jsonl` grep.
- **`claude plugin ...` CLI로 자동화 가능** — `/plugin ...` 슬래시 명령과 동일 효과. Phase 6B에서 B-0~B-8 전 단계 CLI로 자동화 경험.
