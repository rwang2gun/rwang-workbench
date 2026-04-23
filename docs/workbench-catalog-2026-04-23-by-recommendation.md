# Workbench 카탈로그 — 권장도별 분류

> 본 파일은 `workbench-catalog-2026-04-23.md`의 B/C/D 섹션을 **편입 권장도(🟢/🟡/🔴)** 기준으로 재정렬한 파생 뷰.
> 원본 카탈로그와 내용은 동일. Phase 2 "편입 대상 선별" 시 이 파일을 입력으로 사용.
> 생성일: 2026-04-23

---

## 총계

| 유형 | 🟢 | 🟡 | 🔴 | 총계 |
|---|---|---|---|---|
| Skills | 19 | 1 | 9 | 29 |
| Commands | 18 | 5 | 1 | 24 |
| Hooks | 8 | 3 | 0 | 11 |
| Agents (참고) | 14 | — | — | 14 (전부 세트 편입) |
| MCP 서버 (참고) | 0 | 2 | 14 | 16 |
| **합계** | **59** | **11** | **24** | **94** |

> 참고: Agents는 전부 "소속 플러그인 세트와 함께 이동" 전제로 🟢 표기. MCP 서버는 Phase 2에서 별도 판단(API 키·SaaS 의존성 때문에 🟡/🔴 비중 높음).

---

## Skills (29개)

### 🟢 그대로 편입 후보 (19)

| # | 플러그인 | 스킬 | L | 비고 |
|---|---|---|---|---|
| 1 | claude-code-setup | claude-automation-recommender | L0 | 코드베이스 분석 → Claude Code 자동화 추천 |
| 2 | claude-md-management | claude-md-improver | L0 | CLAUDE.md 감사·개선 |
| 3 | hookify | writing-hookify-rules | L0 | hookify 룰 작성 가이드 (hookify 세트) |
| 4 | mcp-server-dev | build-mcp-server | L0 | MCP 서버 신규 개발 진입점 |
| 5 | mcp-server-dev | build-mcp-app | L0 | MCP 앱(UI 위젯) 추가 |
| 6 | mcp-server-dev | build-mcpb | L0 | MCPB 런타임 번들 패키징 |
| 7 | playground | playground | L0 | 자립형 HTML 플레이그라운드 생성 |
| 8 | plugin-dev | plugin-structure | L0 | 플러그인 디렉토리 구조 가이드 |
| 9 | plugin-dev | skill-development | L0 | 스킬 작성 (⚠ skill-creator와 중복) |
| 10 | plugin-dev | command-development | L0 | 슬래시 명령 작성 |
| 11 | plugin-dev | agent-development | L0 | agent 작성 |
| 12 | plugin-dev | hook-development | L0 | Hook 이벤트·prompt-based hook |
| 13 | plugin-dev | mcp-integration | L0 | .mcp.json·MCP 서버 타입 통합 |
| 14 | plugin-dev | plugin-settings | L0 | `.claude/<plugin>.local.md` 설정 패턴 |
| 15 | session-report | session-report | L0 | 세션 트랜스크립트 → HTML 리포트 |
| 16 | skill-creator | skill-creator | L0 | 스킬 생성·eval·벤치마크 (⚠ plugin-dev/skill-development와 중복 — Phase 2 단일화 결정) |
| 17 | codex | codex-cli-runtime | L1 | codex 세트 내부용 (`user-invocable: false`) |
| 18 | codex | codex-result-handling | L1 | codex 세트 내부용 |
| 19 | codex | gpt-5-4-prompting | L1 | codex 세트 내부용 |

### 🟡 범용화 후 편입 검토 (1)

| 플러그인 | 스킬 | L | 이슈 |
|---|---|---|---|
| frontend-design | frontend-design | L1 | 프론트엔드 UI 도메인 종속. 본인 프로젝트가 frontend를 요구할 때만 유용 — Phase 2에서 필요성 재평가 |

### 🔴 편입 제외 (9)

| 플러그인 | 스킬 | 분류 | 사유 |
|---|---|---|---|
| example-plugin | example-command (skill format) | 데모 | 플러그인 시연용 샘플 |
| example-plugin | example-skill | 데모 | 플러그인 시연용 샘플 |
| math-olympiad | math-olympiad | L1 (도메인 불일치) | 수학 경시 전용, 본인 용도 X |
| discord | access | L2 | Discord 채널 access control, 본인 용도 X |
| discord | configure | L2 | Discord bot 토큰 설정 |
| imessage | access | L2 | macOS `chat.db` 전용, Windows 본인 환경 X |
| imessage | configure | L2 | 동일 |
| telegram | access | L2 | Telegram 채널 특정 |
| telegram | configure | L2 | Telegram bot 토큰 설정 |

---

## Commands (24개)

### 🟢 그대로 편입 후보 (18)

| # | 플러그인 | 명령어 | L | 비고 |
|---|---|---|---|---|
| 1 | claude-md-management | `/revise-claude-md` | L0 | 세션 학습 → CLAUDE.md 업데이트 |
| 2 | code-review | `/code-review` | L0 | PR 리뷰 (gh CLI) — ⚠ `/review-pr`와 중복 |
| 3 | commit-commands | `/clean_gone` | L0 | `[gone]` 마크 로컬 브랜치 정리 |
| 4 | commit-commands | `/commit` | L0 | git commit 작성 |
| 5 | commit-commands | `/commit-push-pr` | L0 | commit → push → PR 생성 |
| 6 | feature-dev | `/feature-dev` | L0 | 피처 개발 워크플로우 (+3 agents 세트) |
| 7 | hookify | `/hookify` | L0 | 대화 분석 → hook 자동 생성 |
| 8 | hookify | `/configure` | L0 | hookify 룰 활성/비활성 |
| 9 | hookify | `/list` | L0 | 등록된 룰 나열 |
| 10 | plugin-dev | `/create-plugin` | L0 | E2E 플러그인 생성 워크플로우 (+7 skills +3 agents) |
| 11 | pr-review-toolkit | `/review-pr` | L0 | 종합 PR 리뷰 (+6 agents) — ⚠ `/code-review`와 중복 |
| 12 | codex | `/codex:adversarial-review` | L1 | codex 세트 |
| 13 | codex | `/codex:cancel` | L1 | codex 세트 |
| 14 | codex | `/codex:rescue` | L1 | codex-rescue agent 위임 |
| 15 | codex | `/codex:result` | L1 | Codex job 결과 조회 |
| 16 | codex | `/codex:review` | L1 | **본인 일상 사용 중** |
| 17 | codex | `/codex:setup` | L1 | Codex CLI 준비 상태 확인 |
| 18 | codex | `/codex:status` | L1 | 활성/최근 jobs 조회 |

### 🟡 범용화/검토 (5)

| 플러그인 | 명령어 | L | 이슈 |
|---|---|---|---|
| agent-sdk-dev | `/new-sdk-app` | L1 | Claude Agent SDK 도메인 종속 — 본인 SDK 앱 개발 할 때만 |
| hookify | `/help` | — | 도움말 — hookify 세트 편입 시 포함, 단독 편입 가치 낮음 |
| ralph-loop | `/ralph-loop` | L0 | Ralph Wiggum self-referential while-true — bash 의존, 실험적 |
| ralph-loop | `/cancel-ralph` | L0 | bash 의존 |
| ralph-loop | `/help` | — | 도움말 |

### 🔴 편입 제외 (1)

| 플러그인 | 명령어 | 사유 |
|---|---|---|
| example-plugin | `/example-command` (legacy) | 데모 |

---

## Hooks (11개)

### 🟢 그대로 편입 후보 (8)

| # | 플러그인 | 이벤트 | 런타임 | 비고 |
|---|---|---|---|---|
| 1 | hookify | PreToolUse | Python3 | hookify 세트 |
| 2 | hookify | PostToolUse | Python3 | hookify 세트 |
| 3 | hookify | Stop | Python3 | hookify 세트 |
| 4 | hookify | UserPromptSubmit | Python3 | hookify 세트 |
| 5 | security-guidance | PreToolUse (`Edit\|Write\|MultiEdit`) | Python3 | 코드 편집 시 보안 패턴 경고 |
| 6 | codex | SessionStart | Node.js | codex 세트 (5s timeout) |
| 7 | codex | SessionEnd | Node.js | codex 세트 (5s timeout) |
| 8 | codex | Stop | Node.js | codex review-gate (900s timeout, 옵션) |

### 🟡 검토 (3)

| 플러그인 | 이벤트 | 런타임 | 이슈 |
|---|---|---|---|
| explanatory-output-style | SessionStart | bash | Windows git-bash/WSL 필요 — 편입 시 PowerShell 포팅 필요. 취향 hook |
| learning-output-style | SessionStart | bash | 동일 (Windows 호환성 이슈). 취향 hook |
| ralph-loop | Stop | bash | ralph-loop 세트 종료 조건 검사, bash 의존 |

### 🔴 편입 제외 (0)

없음.

---

## Agents (14개, 참고)

전부 소속 플러그인 세트와 함께 편입되는 **의존성 세트**.

| 플러그인 | agent | 모델 | 세트 권장도 |
|---|---|---|---|
| feature-dev | code-architect | sonnet | 🟢 (/feature-dev 세트) |
| feature-dev | code-explorer | sonnet | 🟢 (세트) |
| feature-dev | code-reviewer | sonnet | 🟢 (세트) |
| hookify | conversation-analyzer | inherit | 🟢 (/hookify 세트) |
| plugin-dev | agent-creator | (미지정) | 🟢 (세트) |
| plugin-dev | plugin-validator | (미지정) | 🟢 (세트) |
| plugin-dev | skill-reviewer | (미지정) | 🟢 (세트) |
| pr-review-toolkit | code-reviewer | opus | 🟢 (/review-pr 세트) |
| pr-review-toolkit | code-simplifier | inherit | 🟢 (세트) |
| pr-review-toolkit | comment-analyzer | inherit | 🟢 (세트) |
| pr-review-toolkit | pr-test-analyzer | inherit | 🟢 (세트) |
| pr-review-toolkit | silent-failure-hunter | inherit | 🟢 (세트) |
| pr-review-toolkit | type-design-analyzer | inherit | 🟢 (세트) |
| codex | codex-rescue | sonnet | 🟢 (codex 세트, tools: Bash만) |

---

## MCP 서버 (16개, 참고)

Phase 2에서 별도 판단. 대부분 SaaS·API 키 의존으로 🔴 경향.

### 🟡 검토 후보 (2)

| 플러그인 | 서버 | 타입 | 사유 |
|---|---|---|---|
| context7 | context7 | stdio (npx) | 범용 docs lookup, 공개 문서 조회 — Upstash 호스팅 의존은 있음 |
| playwright | playwright | stdio (npx) | 범용 브라우저 자동화, 토큰 불필요 |
| serena | serena | stdio (uvx) | 범용 semantic code analysis, python uvx 의존 |
| github | github | http | gh CLI와 중복 — 선택 시 둘 중 하나로 단일화 |

> 위 표는 4개지만 실질적으로 🟡 후보 (context7/playwright/serena/github 4개). 본 카탈로그 원본에는 "🟡 2개"로 기재되어 있으나 재검토 결과 4개까지 확장 가능. Phase 2에서 최종 판단.

### 🔴 편입 제외 경향 (12)

| 플러그인 | 서버 | 사유 |
|---|---|---|
| example-plugin | (데모 http) | 더미 URL |
| asana | asana | Asana SaaS 토큰 |
| discord | discord | `DISCORD_BOT_TOKEN` + bun |
| fakechat | fakechat | localhost 테스트용 |
| firebase | firebase | Firebase CLI 세션 |
| gitlab | gitlab | gitlab.com 고정 |
| greptile | greptile | `GREPTILE_API_KEY` |
| imessage | imessage | macOS 전용 |
| laravel-boost | laravel-boost | Laravel 앱 디렉토리 필요 |
| linear | linear | Linear SaaS |
| telegram | telegram | `TELEGRAM_BOT_TOKEN` + bun |
| terraform | terraform | Docker + `TFE_TOKEN` |

---

## 의존성 세트 (편입 시 함께 이동 필수)

| 세트명 | 구성 | 권장도 |
|---|---|---|
| **codex 세트** | 3 skills + 7 commands + 1 agent + 3 hooks + scripts/ + schemas/ + prompts/ + NOTICE | 🟢 최우선 |
| **plugin-dev 세트** | 7 skills + 1 command (`/create-plugin`) + 3 agents | 🟢 (self-hosting) |
| **hookify 세트** | 1 skill + 4 commands + 1 agent + 4 hooks (Python3 의존) | 🟢 |
| **feature-dev 세트** | 1 command + 3 agents | 🟢 |
| **pr-review-toolkit 세트** | 1 command + 6 agents | 🟢 (⚠ code-review와 중복 단일화 필요) |
| **mcp-server-dev 세트** | 3 skills (소프트 핸드오프) | 🟢 |
| **claude-md-management 세트** | 1 skill + 1 command | 🟢 |
| **ralph-loop 세트** | 3 commands + 1 hook + bash scripts | 🟡 |
| **discord/imessage/telegram 세트** | 각 2 skills + MCP 서버 + bun + 상태 디렉토리 | 🔴 |

---

## Phase 2 입력 체크리스트

이 파일을 Phase 2 시작 시 함께 열어놓고:

- [ ] 🟢 19 skills + 18 commands + 8 hooks = **45개 핵심 편입 후보** 리스트 확정
- [ ] 중복 단일화 결정:
  - skill-creator ↔ plugin-dev/skill-development
  - code-review ↔ pr-review-toolkit/review-pr
  - github MCP ↔ commit-commands (gh CLI)
- [ ] 🟡 4개 MCP 후보(context7/playwright/serena/github) 중 어느 팩에 할당할지
- [ ] 🟡 취향 훅 3개(explanatory/learning/ralph-loop) PowerShell 포팅 여부
- [ ] 각 🟢 항목의 팩(game-design-pack / analysis-pack / productivity-pack) 배치 결정
