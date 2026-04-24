# rwang-workbench — Claude 세션 핸드오프

개인용 Claude Code 플러그인 마켓플레이스. 세션 시작 시 이 문서 먼저 읽고 현재 Phase 상태·다음 액션을 파악할 것.

---

## 현재 상태 (2026-04-24)

| Phase | 상태 | 비고 |
|---|---|---|
| 1–4 | ✅ 완료 | vendoring + 스캐폴드 + 44 컴포넌트 편입 |
| **5A** | ✅ 완료 (commit `7ed1575`) | Python hook A1 (`python3`→`python`) + README Prerequisites |
| **5B** | ✅ 완료 (commit `914befe`) | `/productivity-pack:check-recommended` + fixture 4종 + RECOMMENDED_PLUGINS.md 3항 + 12 cells pass |
| **5C** | ✅ 완료 (commit `bd5e16e`) | C-2 implement (a+b+d). `scripts/git-hooks/pre-commit` + README. C-1/C-3/C-4 drop 보존. 6 시나리오 전수 pass |
| **5D** | ✅ 완료 | 마감: CHANGELOG Phase 5 블록 + Known Issue "Resolved" + Accepted Limitations + MASTER_PLAN §8 + phase5-plan archive 이관 |
| **Phase 5** | ✅ **전체 완료** | Phase 6 대기 |

**Working tree**: Phase 5D 마감 커밋 직후 → clean 유지.

**Repo-local 훅 활성화 상태**: `core.hooksPath = scripts/git-hooks` 로컬에 설정됨 (이 PC). 다른 PC에서 클론 후 1회 실행 필요.

---

## 다음 액션 — Phase 6 착수

Phase 5 완료. 다음 세션은 Phase 6 실행 계획 작성으로 시작.

**Phase 6 예비 scope** (MASTER_PLAN v1.5 §5 참조):
- `scripts/validate-plugins.ps1` 본격화 (Phase 2에서 `Work/phase2-validate-plugins.ps1` 임시 버전 운용 중)
- Phase 4에서 이연된 gitleaks / 스캔 자동화 흡수
- game-design-pack 유예 상태 재검토(필요 시)

Phase 6 plan 착수 시 `docs/phase6-plan.md` 신규 생성 + MASTER_PLAN §8 업데이트 루틴 반복.

---

## 핵심 설계 문서

- **[docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md)** — 전체 설계. §5 Phase 계획 + §8 상태. **수정 금지** (역사적 기록). §8만 Phase 마감 시 업데이트
- **[docs/CHANGELOG.md](docs/CHANGELOG.md)** — Phase 5 블록 기록 완료. Phase 6부터 동일 패턴으로 추가
- **[docs/RECOMMENDED_PLUGINS.md](docs/RECOMMENDED_PLUGINS.md)** — 5B 보강 완료. 향후 추천 항목 추가 시 갱신
- **[docs/archive/](docs/archive/)** — 완료된 Phase 플랜·source-lock (`phase4-plan.md`, `phase4-source-lock.md`, `phase5-plan.md`)

---

## 환경 특이사항

### Python 3 **미설치** (이 PC)
- `python` / `python3` 둘 다 **Windows Store stub** (`C:\Users\code1412\AppData\Local\Microsoft\WindowsApps\`). 실행 시 Store 열림, exit 49.
- 5A A1 치환은 올바르게 적용됐으나 **실환경 검증은 Python 3 설치 후 가능**.
- 현 Claude Code 세션에서 훅이 조용히 스킵되는 graceful skip 동작이 실제로 확인됨 — hookify 공식 설계대로.

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
- **`validate-plugins.ps1`은 Phase 6 몫** — Phase 5 scope 외
- **game-design-pack 유예** — Phase 2 결정

---

## 대기 중인 사용자 결정

없음. Phase 5 전체 완료. Phase 6 착수 시점은 사용자 지시 대기.

---

## Pre-commit 훅 운영 노트 (5C 이후)

- 활성화: `git config core.hooksPath scripts/git-hooks` (레포 클론당 1회)
- 검사: (a) 시크릿 패턴 / (b) 개인 절대경로 `…Users/code1412/…` / (d) vendored `modified: none` 보호
- 스캔 범위: staged diff의 **added 라인만** — 기존 내용은 retroactive 트리거 없음
- 우회: `git commit --no-verify` (사유를 커밋 메시지에)
- 다른 PC에서 쓰려면: 클론 후 `core.hooksPath` 1회 설정 필요 (git config는 레포 로컬이라 자동 배포 안 됨)

---

## 트러블슈팅 힌트

- **훅 에러 체감 없는데 동작 중인가?** → graceful skip 정상. `pretooluse.py:22-29`의 ImportError 핸들러가 처리.
- **Windows에서 `bash` 훅이 WSL 스텁으로 해석됨** → Claude Code Issue [#37634](https://github.com/anthropics/claude-code/issues/37634). Phase 9에서 upstream 개선 후 재평가.
- **`plugin.json`에 prerequisite 필드 추가하고 싶다** → 공식 스키마 미지원 확정(2026-04-24 조사). 포기하고 README 고지로 대체.
