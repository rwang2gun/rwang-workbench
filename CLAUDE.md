# rwang-workbench — Claude 세션 핸드오프

개인용 Claude Code 플러그인 마켓플레이스. 세션 시작 시 이 문서 먼저 읽고 현재 Phase 상태·다음 액션을 파악할 것.

---

## 현재 상태 (2026-04-24)

| Phase | 상태 | 비고 |
|---|---|---|
| 1–4 | ✅ 완료 | vendoring + 스캐폴드 + 44 컴포넌트 편입 |
| **5A** | ✅ 완료 (commit `7ed1575`) | Python hook A1 (`python3`→`python`) + README Prerequisites |
| **5B** | ✅ 완료 | `/productivity-pack:check-recommended` + fixture 4종 + RECOMMENDED_PLUGINS.md 3항 + 12 cells pass |
| **5C** | 🔶 **다음 착수 대상** | C-2 Git pre-commit hook G2 pre-step 결정. C-1/C-3/C-4는 drop 확정 |
| 5D | ⬜ 대기 | 마감 (CHANGELOG + MASTER_PLAN §8 + archive 이관) |

**Working tree**: 5B 커밋 직후 → clean 유지 (5B 내용은 커밋됨).

---

## 다음 액션 — Batch 5C

**목표**: C-2 (Git pre-commit hook) G2 pre-step 질문지 실행 → rationale 확정 → implement / defer / drop 결정.

**서브태스크** (phase5-plan.md §3.3):

1. 아래 C-2 질문지 Q1–Q4를 사용자에게 제시하고 응답 받기
2. 응답 바탕으로 결정표 C-2 TBD 해소 (rationale 2–3줄)
3. G2 승인 요청
4. implement이면 스펙 확정 → 파일 작성 → 검증 → 자산당 1 커밋
5. defer / drop이면 결정표만 기록하고 5D로 이행

---

## 핵심 설계 문서

- **[docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md)** — 전체 설계. §5 Phase 계획 + §8 상태. **수정 금지** (역사적 기록). §8만 Phase 마감 시 업데이트
- **[docs/phase5-plan.md](docs/phase5-plan.md)** — 현재 Phase 5 실행 계획 v6. §9 실행 현황이 체크포인트
- **[docs/CHANGELOG.md](docs/CHANGELOG.md)** — Phase 5 블록은 5D 마감 시 일괄 추가
- **[docs/RECOMMENDED_PLUGINS.md](docs/RECOMMENDED_PLUGINS.md)** — 5B 보강 대상
- **[docs/archive/](docs/archive/)** — 완료된 Phase 플랜·source-lock

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

**C-2 Git pre-commit hook (Batch 5C G2 pre-step 질문지 필요):**

```
Q1. 이 자산의 주 사용 빈도는? (매일 / 주 1–2회 / 월 수 회 / 특정 이벤트)
Q2. 지금 Phase 5에서 구현하면 즉시 개선되는 작업?
Q3. 연기 시 영향?
Q4. "불필요" 판정 가능한 이유?
```

5C 착수 시점에 위 4문항을 사용자에게 제시하고 응답 받아 rationale 작성 → G2 승인 → implement/defer/drop 결정.

---

## 트러블슈팅 힌트

- **훅 에러 체감 없는데 동작 중인가?** → graceful skip 정상. `pretooluse.py:22-29`의 ImportError 핸들러가 처리.
- **Windows에서 `bash` 훅이 WSL 스텁으로 해석됨** → Claude Code Issue [#37634](https://github.com/anthropics/claude-code/issues/37634). Phase 9에서 upstream 개선 후 재평가.
- **`plugin.json`에 prerequisite 필드 추가하고 싶다** → 공식 스키마 미지원 확정(2026-04-24 조사). 포기하고 README 고지로 대체.
