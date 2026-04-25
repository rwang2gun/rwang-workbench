# rwang-workbench — Claude 세션 핸드오프

개인용 Claude Code 플러그인 마켓플레이스. 세션 시작 시 이 문서 먼저 읽고 현재 Phase 상태·다음 액션을 파악할 것.

---

## 현재 상태 (v0.1.0 release 완료)

| Phase | 상태 | 비고 |
|---|---|---|
| 1–4 | ✅ 완료 | vendoring + 스캐폴드 + 44 컴포넌트 편입 |
| 5 | ✅ 완료 | 4배치 (5A~5D) |
| 6 | ✅ 완료 | 3배치 (6A/6B/6C) |
| 7 | ✅ 완료 | 3배치 (7A/7C/7D, 7B skip) |
| 8 | ✅ 완료 | v0.1.0 첫 public release. 8P/8A-pre/8A/8B/8C/8C-post/8D |
| **Phase 9** | ⬜ **지속 운영** | 트리거 기반(신규 자산·릴리스 전 점검·실패 제보) |

**v0.1.0 release**: <https://github.com/rwang2gun/rwang-workbench/releases/tag/v0.1.0>
**marketplace add**: `claude plugin marketplace add rwang2gun/rwang-workbench`

---

## 현재 운영 단계 — Phase 9 (지속 운영)

Phase 9는 trigger-driven 운영 모드. 정기 일정 없음. 다음 trigger 발생 시에만 작업:

- **신규 컴포넌트 추가** → `scripts/validate-plugins.ps1` 재실행 + `docs/CHANGELOG.md` 갱신 + 새 phase plan 작성 (`docs/PLAN_DESIGN_GUIDELINES.md` 5축 self-review → Codex CLI 리뷰)
- **다음 릴리스 (v0.1.1, v0.2.0 등)** → 신규 phase plan + §4.5 Public 게이트 재실행 (gitleaks 양 모드 0 finding) + GitHub source smoke
- **새 PC에서 셋업** → `scripts/check-orphan-originals.ps1` 1회 실행 + `git config core.hooksPath scripts/git-hooks` 1회 설정
- **실패 제보 / 사용자 issue** → 재현 → 회고 → patch phase

**Plan v5.x post-release patch 후보**: `docs/archive/phase8-plan.md` Issue § 또는 다음 phase plan 도입부에 [부수 발견](#이번-세션-부수-발견-plan-v5x-post-release-patch-후보) 흡수.

---

## Phase 8 plan v5.5 수렴 history (참고)

- v1~v4: 1~4차 BLOCK 누적, v4에서 9건 역행
- v5 전면 재작성 (Codex 4차 9 + Claude self 4 = 13건 흡수)
- v5.1~v5.4: Codex 5~8차 흡수 (4 → 2 → 1(non-BLOCK) → 2건)
- **v5.5: Codex 9차 non-BLOCK 2건 (L-1 표 제목 / N-1 정규식 trailing `$`) 흡수**
- **Codex 10차 PASS (Findings 0건)** → G1 승인 → 8P 진행

---

## 이번 세션 부수 발견 (plan v5.x post-release patch 후보)

1. **§4.1.2 `$pid` 자동변수 충돌** — `foreach ($pid in $allPatterns.Keys)`은 PS5.1 read-only 자동변수와 충돌. `$patternId` rename으로 우회.
2. **§4.3.6 / §4.4.4 PS 5.1 인코딩 bug** — `Get-Content -Raw` (default ANSI) + `Out-File -Encoding utf8` (BOM 포함) → 한글 깨짐. .NET API로 우회.
3. **§4.1.1 winget install 직후 PATH 미반영** — registry-derived PATH refresh 코드 추가 필요.
4. **CLAUDE.md `core.hooksPath` stale** — "설정됨" 표기지만 실제 unset. 8P 직전 `git config core.hooksPath scripts/git-hooks` 1회 set으로 회복.

---

## 핵심 설계 문서

- **[docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md)** — 전체 설계. §5 Phase 계획 + §8 상태. **수정 금지** (역사적 기록). §8만 Phase 마감 시 업데이트
- **[docs/PLAN_DESIGN_GUIDELINES.md](docs/PLAN_DESIGN_GUIDELINES.md)** — phase plan 작성 5축(Public irreversibility / Atomic action / Repo 사실 확인 / 표현 일관성 / Scope 명시) + 메타 패턴(위상 변화 인지). **plan v1 초안 직후 self-review에 필수 적용**, Codex CLI 리뷰 호출 **전** 단계. phase8-plan v1 Codex 1차 BLOCK 회고에서 추출 (2026-04-25)
- **[docs/CHANGELOG.md](docs/CHANGELOG.md)** — Phase 5·6·7·8 블록 기록 완료. v0.1.0 release. 다음 릴리스 시 동일 패턴으로 추가
- **[docs/RECOMMENDED_PLUGINS.md](docs/RECOMMENDED_PLUGINS.md)** — 5B 보강 완료. 향후 추천 항목 추가 시 갱신
- **[docs/archive/](docs/archive/)** — 완료된 Phase 플랜·source-lock (`phase4-plan.md`, `phase4-source-lock.md`, `phase5-plan.md`, `phase6-plan.md`, `phase7-plan.md`, `phase8-plan.md`)
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

없음. Phase 8 v0.1.0 release 완료. Phase 9는 trigger 발생 시점까지 대기.

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
