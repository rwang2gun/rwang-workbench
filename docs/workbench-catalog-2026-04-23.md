# Workbench 카탈로그 2026-04-23

> **Phase 1 완료 (5/5)** — Batch 5 완료 시점, 분할 실행 종결
> 출처:
> - `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/` (공식 33개)
> - `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/` (외부 SaaS 15개)
> - `~/.claude/plugins/marketplaces/openai-codex/plugins/` (OpenAI 마켓플레이스 1개)
> - `~/.claude/skills/` (본인 제작 3개 → F 섹션)
> 진행 상태: **50/50 스캔 완료** (원래 "49개" 전제는 openai-codex 누락이었고 실제로는 50개)

---

## 요약 (최종, Batch 1+2+3+4+5)

- **플러그인 수:** 50 (+10: external 8 + openai-codex 1, 본인 제작 3은 별도 F 섹션)
  - claude-plugins-official: 33 (plugins) + 15 (external_plugins) = 48
  - openai-codex: 1 (codex)
  - 본인 제작 (~/.claude/skills/): 3 (F 섹션, 편입 대상 아님)
- **Skills 총계:** 28 (L0: 15, L1: 4, L2: 6, 데모/제외: 3)
- **Commands 총계:** 24 (L0: 12, L1: 9, 데모/보조: 3)
- **Agents 총계:** 14 (+1 codex-rescue)
- **Hooks 총계:** 11 entries (+3 codex: SessionStart/SessionEnd/Stop)
- **MCP 서버 정의:** 16 (데모 1 + Batch 4: 7 + Batch 5: 8)
- **라이선스 미표기 플러그인:** 0 (전부 Apache-2.0, 단 external_plugins 11개는 marketplace 루트 LICENSE 상속 — "확인 필요 #15" 참고)
- **편입 권장도 분포 (플러그인 레벨, 50개):** 🟢 14 / 🟡 12 / 🔴 24

---

## A. 플러그인 메타

| 플러그인 | 출처(homepage) | 버전 | 라이선스 | 크기(KB) | Skills/Cmds/Hooks |
|---|---|---|---|---|---|
| agent-sdk-dev | (homepage 없음 / Anthropic author) | (미표기) | Apache-2.0 | 35.5 | 0 / 1 / 0 |
| clangd-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.9 | 0 / 0 / 0 |
| claude-code-setup | (homepage 없음 / Anthropic author) | 1.0.0 | Apache-2.0 | 586.1 | 1 / 0 / 0 |
| claude-md-management | (homepage 없음 / Anthropic author) | 1.0.0 | Apache-2.0 | 1078 | 1 / 1 / 0 |
| code-review | (homepage 없음 / Anthropic author) | (미표기) | Apache-2.0 | 25.7 | 0 / 1 / 0 |
| code-simplifier | (homepage 없음 / Anthropic author) | 1.0.0 | Apache-2.0 | 14.4 | 0 / 0 / 0 |
| commit-commands | (homepage 없음 / Anthropic author) | (미표기) | Apache-2.0 | 20.3 | 0 / 3 / 0 |
| csharp-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.6 | 0 / 0 / 0 |
| example-plugin | (homepage 없음 / Anthropic author) | (미표기) | Apache-2.0 | 18.4 | 2 / 1 / 0 (+MCP 1) |
| explanatory-output-style | (homepage 없음 / Anthropic author) | 1.0.0 | Apache-2.0 | 15.5 | 0 / 0 / 1 |
| feature-dev | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 34.9 | 0 / 1 / 0 (+agents 3) |
| frontend-design | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 (+자체 LICENSE.txt) | 16.4 | 1 / 0 / 0 |
| gopls-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.6 | 0 / 0 / 0 |
| hookify | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 78.0 | 1 / 4 / 1 (+agent 1) |
| jdtls-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.9 | 0 / 0 / 0 |
| kotlin-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.4 | 0 / 0 / 0 |
| learning-output-style | (homepage 없음 / Anthropic) | 1.0.0 | Apache-2.0 | 19.8 | 0 / 0 / 1 |
| lua-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.8 | 0 / 0 / 0 |
| math-olympiad | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 74.7 | 1 / 0 / 0 |
| mcp-server-dev | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 116.1 | 3 / 0 / 0 |
| php-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.5 | 0 / 0 / 0 |
| playground | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 42.0 | 1 / 0 / 0 |
| plugin-dev | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 538.5 | 7 / 1 / 0 (+agents 3) |
| pr-review-toolkit | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 56.0 | 0 / 1 / 0 (+agents 6) |
| pyright-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.6 | 0 / 0 / 0 |
| ralph-loop | (homepage 없음 / Anthropic) | 1.0.0 | Apache-2.0 | 36.6 | 0 / 3 / 1 |
| ruby-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.6 | 0 / 0 / 0 |
| rust-analyzer-lsp | (plugin.json 없음) | — | Apache-2.0 | 11.8 | 0 / 0 / 0 |
| security-guidance | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 22.3 | 0 / 0 / 1 |
| session-report | (plugin.json 없음) | — | Apache-2.0 | 67.5 | 1 / 0 / 0 |
| skill-creator | (homepage 없음 / Anthropic) | (미표기) | Apache-2.0 | 266 | 1 / 0 / 0 |
| swift-lsp | (plugin.json 없음) | — | Apache-2.0 | 13 | 0 / 0 / 0 |
| typescript-lsp | (plugin.json 없음) | — | Apache-2.0 | 13 | 0 / 0 / 0 |
| asana | (homepage 없음 / Asana author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| context7 | (homepage 없음 / Upstash author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| discord | (homepage 없음 / author 없음) | 0.0.4 | Apache-2.0 | 112 | 2 / 0 / 0 (+MCP 1) |
| fakechat | (homepage 없음 / author 없음) | 0.0.1 | Apache-2.0 | 56 | 0 / 0 / 0 (+MCP 1) |
| firebase | (homepage 없음 / Google author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| github | (homepage 없음 / GitHub author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| gitlab | (homepage 없음 / GitLab author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| greptile | https://greptile.com/docs | (미표기) | Apache-2.0 (마켓 루트 상속) | 6 | 0 / 0 / 0 (+MCP 1) |
| imessage | (homepage 없음 / author 없음) | 0.1.0 | Apache-2.0 | 100 | 2 / 0 / 0 (+MCP 1) |
| laravel-boost | (homepage 없음 / Laravel author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| linear | (homepage 없음 / Linear author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| playwright | (homepage 없음 / Microsoft author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| serena | (homepage 없음 / Oraios author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| telegram | (homepage 없음 / author 없음) | 0.0.6 | Apache-2.0 | 108 | 2 / 0 / 0 (+MCP 1) |
| terraform | (homepage 없음 / HashiCorp author) | (미표기) | Apache-2.0 (마켓 루트 상속) | 2 | 0 / 0 / 0 (+MCP 1) |
| codex (openai-codex 마켓) | (homepage 없음 / OpenAI author) | 1.0.3 | Apache-2.0 (자체 LICENSE+NOTICE) | 299 | 3 / 7 / 1 (+agent 1) |

**메모:**
- LSP 8개(clangd/csharp/gopls/jdtls/kotlin/lua/php/pyright/ruby/rust-analyzer/swift/typescript-lsp, 실제 12개)는 `plugin.json` 없음 — marketplace.json 단일 정의로 추정. 컴포넌트 0개, 편입 대상 아님.
- session-report도 plugin.json 없는데 skill 있음 (특이 케이스).
- external_plugins 중 **MCP 전용 경량 플러그인 11개**(asana/context7/firebase/github/gitlab/greptile/laravel-boost/linear/playwright/serena/terraform)는 `.claude-plugin/plugin.json` + `.mcp.json`만. 개별 LICENSE 없고 마켓 루트 LICENSE 상속.
- external_plugins 중 **채널 플러그인 4개**(discord/fakechat/imessage/telegram)는 bun 런타임 + 자체 server.ts + 자체 LICENSE + skills 포함한 "풀스펙" 구조.
- **codex**는 별도 마켓플레이스(openai-codex)이며 유일하게 `installed_plugins.json`에 "설치됨"으로 등록된 플러그인. 나머지 49개는 마켓에 available 상태.

---

## B. Skills 상세 (초안 태깅)

| 플러그인 | 스킬명 | description (요약) | 외부 의존성 | 내부 참조 | L 태그 | 권장도 |
|---|---|---|---|---|---|---|
| claude-code-setup | claude-automation-recommender | 코드베이스 분석 후 Claude Code 자동화(hooks/skills/MCP/subagent) 추천 | 없음 (read-only) | 없음 | **L0** | 🟢 |
| claude-md-management | claude-md-improver | CLAUDE.md 파일 감사·평가·개선 | 없음 | 같은 플러그인 `/revise-claude-md` (의존 아님, 보완) | **L0** | 🟢 |
| example-plugin | example-command (skill format) | 데모용 — 슬래시 명령 frontmatter 옵션 시연 | 없음 | 없음 | (데모) | 🔴 |
| example-plugin | example-skill | 데모용 — 스킬 작성 템플릿 | 없음 | 없음 | (데모) | 🔴 |
| frontend-design | frontend-design | 프론트엔드 UI 컴포넌트·페이지 생성 (generic AI aesthetic 회피) | 없음 | 없음 | **L1** (프론트 도메인) | 🟡 |
| hookify | writing-hookify-rules | hookify 룰 작성 가이드 | `.claude/hookify.*.local.md` 패턴 파일 | hookify의 commands·hook 전체 | **L0** | 🟢 |
| math-olympiad | math-olympiad | 경쟁 수학 문제(IMO/Putnam/USAMO) 풀이 + adversarial 검증 | LaTeX (선택) | 없음 | **L1** (수학 도메인) | 🔴 |
| mcp-server-dev | build-mcp-server | MCP 서버 신규 개발 진입점(배포모델·툴디자인 인터뷰) | WebFetch (claude.com docs) | 같은 플러그인 다른 스킬로 핸드오프 | **L0** | 🟢 |
| mcp-server-dev | build-mcp-app | MCP 앱(인터랙티브 UI 위젯) 추가 | 없음 | `build-mcp-server` 후속 | **L0** | 🟢 |
| mcp-server-dev | build-mcpb | MCPB(런타임 번들 로컬 MCP) 패키징 | Node/Python runtime | 없음 | **L0** | 🟢 |
| playground | playground | 인터랙티브 HTML 플레이그라운드(자립형 단일 파일) 생성 | 없음 | 없음 | **L0** | 🟢 |
| plugin-dev | plugin-structure | 플러그인 디렉토리 구조·plugin.json·`${CLAUDE_PLUGIN_ROOT}` 가이드 | 없음 | 같은 플러그인 다른 스킬 | **L0** | 🟢 |
| plugin-dev | skill-development | 스킬 작성·progressive disclosure·description 개선 | 없음 | 같음 | **L0** | 🟢 |
| plugin-dev | command-development | 슬래시 명령 frontmatter·dynamic args·bash 실행 패턴 | 없음 | 같음 | **L0** | 🟢 |
| plugin-dev | agent-development | agent 작성·트리거 조건·tools 지정 | 없음 | 같음 + agents/agent-creator | **L0** | 🟢 |
| plugin-dev | hook-development | Hook 이벤트(PreToolUse 등) + prompt-based hook | 없음 | 같음 | **L0** | 🟢 |
| plugin-dev | mcp-integration | .mcp.json·MCP 서버 타입(SSE/stdio/HTTP/WS) 통합 | 없음 | 같음 | **L0** | 🟢 |
| plugin-dev | plugin-settings | `.claude/<plugin>.local.md` 패턴 설정 저장 | 없음 | 같음 | **L0** | 🟢 |
| session-report | session-report | `~/.claude/projects` 트랜스크립트 → 자립형 HTML 사용량 리포트 | Node.js (`analyze-sessions.mjs`) | 없음 | **L0** | 🟢 |
| skill-creator | skill-creator | 스킬 생성·개선·평가·벤치마크 전 과정 가이드 | `eval-viewer/generate_review.py` (명시) | 내부 스킬 없음 (별도 스크립트 의존) | **L0** | 🟢 (plugin-dev/skill-development와 중복 검토 — 확인 #18) |
| discord | access | Discord 채널 access control (pairing/allowlist/policy) | `~/.claude/channels/discord/access.json` 상태 파일 | discord MCP 서버 (server.ts) | **L2** (Discord 특정) | 🔴 |
| discord | configure | Discord bot 토큰 저장 + 정책 상태 조회 | `~/.claude/channels/discord/.env`, `DISCORD_BOT_TOKEN` | discord MCP 서버 | **L2** | 🔴 |
| imessage | access | iMessage 채널 access control (pairing/allowlist/policy) | `~/.claude/channels/imessage/access.json` | imessage MCP 서버 | **L2** (macOS chat.db 전용) | 🔴 |
| imessage | configure | iMessage 채널 설정 상태 조회 (read-only) | `~/.claude/channels/imessage/` | imessage MCP 서버 | **L2** | 🔴 |
| telegram | access | Telegram 채널 access control | `~/.claude/channels/telegram/access.json` | telegram MCP 서버 | **L2** (Telegram 특정) | 🔴 |
| telegram | configure | Telegram bot 토큰 저장 + 정책 안내 | `~/.claude/channels/telegram/.env`, `TELEGRAM_BOT_TOKEN` | telegram MCP 서버 | **L2** | 🔴 |
| codex | codex-cli-runtime | codex-rescue 서브에이전트 내부용 Codex runtime 호출 규약 | `user-invocable: false` — 에이전트 전용 | codex-rescue agent, scripts/codex-companion.mjs | **L1** (codex 도메인) | 🟢 (세트) |
| codex | codex-result-handling | Codex 출력 결과를 사용자에게 제시하는 내부 가이드 | `user-invocable: false` | codex-rescue agent | **L1** | 🟢 (세트) |
| codex | gpt-5-4-prompting | codex-rescue에서 Codex/GPT-5.4 워크플로우 호출 시 프롬프트 작성 가이드 | `user-invocable: false` | codex-rescue agent | **L1** | 🟢 (세트) |

---

## C. Commands 상세 (초안 태깅)

| 플러그인 | 명령어 | 한 줄 용도 | 외부 의존성 | L 태그 | 권장도 |
|---|---|---|---|---|---|
| agent-sdk-dev | `/new-sdk-app` | Claude Agent SDK 신규 앱 스캐폴드 | WebFetch (docs.claude.com) | **L1** (SDK 도메인) | 🟡 |
| claude-md-management | `/revise-claude-md` | 세션 학습 → CLAUDE.md 업데이트 | 없음 | **L0** | 🟢 |
| code-review | `/code-review` | PR 리뷰 | `gh` CLI (issue/pr/search) | **L0** | 🟢 |
| commit-commands | `/clean_gone` | `[gone]` 마크된 로컬 git 브랜치 정리 | git CLI | **L0** | 🟢 |
| commit-commands | `/commit` | git commit 작성 | git CLI | **L0** | 🟢 |
| commit-commands | `/commit-push-pr` | commit → push → PR 생성 | git, `gh` CLI | **L0** | 🟢 |
| example-plugin | `/example-command` (legacy) | 데모용 — 레거시 commands 포맷 시연 | 없음 | (데모) | 🔴 |
| feature-dev | `/feature-dev` | 가이디드 피처 개발 워크플로우(코드베이스 이해→아키텍처→구현) | 같은 플러그인의 3개 agent | **L0** | 🟢 |
| hookify | `/hookify` | 대화 분석으로 unwanted behavior에 대한 hook 자동 생성 | Python3, conversation-analyzer agent | **L0** | 🟢 |
| hookify | `/configure` | hookify 룰 활성/비활성 인터랙티브 | `.claude/hookify.*.local.md` | **L0** (보조) | 🟢 |
| hookify | `/list` | 등록된 hookify 룰 나열 | 같음 | **L0** (보조) | 🟢 |
| hookify | `/help` | hookify 사용법 안내 | 없음 | (도움말) | 🟡 |
| plugin-dev | `/create-plugin` | E2E 가이디드 플러그인 생성 워크플로우 | plugin-dev의 7개 스킬 + 3 agents | **L0** | 🟢 |
| pr-review-toolkit | `/review-pr` | 종합 PR 리뷰 (6개 specialized agent) | git, Task tool | **L0** | 🟢 (code-review와 비교 검토 필요) |
| ralph-loop | `/ralph-loop` | Ralph Wiggum 기법 self-referential while-true 루프 시작 | bash, `setup-ralph-loop.sh` | **L0** | 🟡 |
| ralph-loop | `/cancel-ralph` | 활성 Ralph 루프 취소 | bash | **L0** (보조) | 🟡 |
| ralph-loop | `/help` (ralph-loop) | Ralph 사용법 안내 | 없음 | (도움말) | 🟡 |
| codex | `/codex:adversarial-review` | 구현 접근·설계 선택을 adversarial로 도전하는 Codex 리뷰 | Node.js, Codex CLI, git | **L1** (codex 툴체인) | 🟢 |
| codex | `/codex:cancel` | 활성 백그라운드 Codex 작업 취소 | Node.js | **L1** | 🟢 (세트) |
| codex | `/codex:rescue` | 투입된 문제를 codex-rescue 서브에이전트로 위임 | Node.js, Codex CLI, AskUserQuestion | **L1** | 🟢 |
| codex | `/codex:result` | 완료된 Codex job 최종 결과 조회 | Node.js | **L1** (보조) | 🟢 |
| codex | `/codex:review` | 로컬 git state 대상 Codex 코드 리뷰 | Node.js, Codex CLI, git | **L1** | 🟢 (이미 일상 사용 중) |
| codex | `/codex:setup` | 로컬 Codex CLI 준비 상태 확인 + stop-time review gate 토글 | Node.js, npm | **L1** | 🟢 |
| codex | `/codex:status` | 활성/최근 Codex jobs + review-gate 상태 조회 | Node.js | **L1** (보조) | 🟢 |

---

## D. Hooks 상세 (초안 태깅)

| 플러그인 | 이벤트 | 실행 작업 요약 | 외부 의존성 | L 태그 | 권장도 |
|---|---|---|---|---|---|
| explanatory-output-style | SessionStart | bash 스크립트로 교육적 인사이트 지시문 추가 | bash (Windows에선 git-bash/WSL 필요 — **확인 필요**) | **L0** (취향) | 🟡 |
| hookify | PreToolUse | python3 pretooluse.py — 룰 매칭 검사 | Python3 | **L0** | 🟢 |
| hookify | PostToolUse | python3 posttooluse.py | Python3 | **L0** | 🟢 |
| hookify | Stop | python3 stop.py | Python3 | **L0** | 🟢 |
| hookify | UserPromptSubmit | python3 userpromptsubmit.py | Python3 | **L0** | 🟢 |
| learning-output-style | SessionStart | bash로 인터랙티브 러닝 모드 지시문 추가 | bash (Windows 환경 확인 필요) | **L0** (취향) | 🟡 |
| ralph-loop | Stop | bash `stop-hook.sh` — 루프 종료 조건 검사 | bash | **L0** | 🟡 |
| security-guidance | PreToolUse (matcher: Edit\|Write\|MultiEdit) | python3 `security_reminder_hook.py` — 코드 편집 시 보안 패턴 경고 | Python3 | **L0** | 🟢 |
| codex | SessionStart | `node session-lifecycle-hook.mjs SessionStart` (5s timeout) | Node.js | **L1** (codex 세트) | 🟢 |
| codex | SessionEnd | `node session-lifecycle-hook.mjs SessionEnd` (5s timeout) | Node.js | **L1** | 🟢 |
| codex | Stop | `node stop-review-gate-hook.mjs` (900s timeout — 옵션 게이트) | Node.js, Codex CLI | **L1** | 🟢 (세트 선택 사항) |

### D-2. Agents (Phase 1 스키마 외 — 확인 필요 항목 #6 참고)

| 플러그인 | agent명 | 용도 | 모델 | 권장도 |
|---|---|---|---|---|
| feature-dev | code-architect | 아키텍처 청사진 제공 | sonnet | 🟢 (feature-dev 세트) |
| feature-dev | code-explorer | 코드베이스 탐사·실행 경로 추적 | sonnet | 🟢 (세트) |
| feature-dev | code-reviewer | 코드 리뷰(confidence 기반 필터링) | sonnet | 🟢 (세트) |
| hookify | conversation-analyzer | 대화에서 prevent할 behavior 추출 | inherit | 🟢 (세트) |
| plugin-dev | agent-creator | agent 자동 생성 가이드 | (미지정) | 🟢 (세트) |
| plugin-dev | plugin-validator | plugin.json 및 구조 검증 | (미지정) | 🟢 (세트) |
| plugin-dev | skill-reviewer | 스킬 품질 리뷰 | (미지정) | 🟢 (세트) |
| pr-review-toolkit | code-reviewer | 프로젝트 가이드라인 기반 코드 리뷰 | opus | 🟢 (세트) |
| pr-review-toolkit | code-simplifier | 기능 보존하며 단순화 | inherit | 🟢 (세트) |
| pr-review-toolkit | comment-analyzer | 주석 정확도·완전성·기술부채 분석 | inherit | 🟢 (세트) |
| pr-review-toolkit | pr-test-analyzer | 테스트 커버리지·엣지케이스 분석 | inherit | 🟢 (세트) |
| pr-review-toolkit | silent-failure-hunter | silent failure·부적절 fallback 추출 | inherit | 🟢 (세트) |
| pr-review-toolkit | type-design-analyzer | 타입 설계(불변식·캡슐화) 분석 | inherit | 🟢 (세트) |
| codex | codex-rescue | Claude Code가 막혔을 때 Codex에 task 위임 forwarding wrapper | sonnet (tools: Bash만) | 🟢 (세트) |

### D-3. MCP 서버 정의 (Phase 1 스키마 외 — 확인 필요 #15 참고)

| 플러그인 | 서버명 | 타입 | 엔드포인트/실행 | 인증 | L 태그 | 권장도 |
|---|---|---|---|---|---|---|
| example-plugin | (데모) | http | `https://mcp.example.com/api` (더미) | 없음 | (데모) | 🔴 |
| asana | asana | sse | `https://mcp.asana.com/sse` | 원격(SSE OAuth 추정) | **L2** (SaaS) | 🔴 |
| context7 | context7 | stdio (npx) | `npx -y @upstash/context7-mcp` | 불명확 (범용 docs lookup) | **L1** (문서 lookup 범용) | 🟡 |
| discord | discord | stdio (bun) | `bun run --cwd ${CLAUDE_PLUGIN_ROOT} start` | `DISCORD_BOT_TOKEN` 필수 | **L2** | 🔴 |
| fakechat | fakechat | stdio (bun) | `bun run --cwd ${CLAUDE_PLUGIN_ROOT} start` | 없음 (localhost) | **L2** (테스트용) | 🔴 |
| firebase | firebase | stdio (npx) | `npx -y firebase-tools@latest mcp` | `firebase login` CLI 세션 | **L2** (Firebase 특정) | 🔴 |
| github | github | http | `https://api.githubcopilot.com/mcp/` | `GITHUB_PERSONAL_ACCESS_TOKEN` Bearer | **L1** (범용 Git 서비스) | 🟡 (확인 #20 — gh CLI 중복) |
| gitlab | gitlab | http | `https://gitlab.com/api/v4/mcp` | (plugin.json 인증 명시 없음) | **L2** (gitlab.com 고정) | 🔴 |
| greptile | greptile | http | `https://api.greptile.com/mcp` | `GREPTILE_API_KEY` Bearer | **L2** (Greptile SaaS) | 🔴 |
| imessage | imessage | stdio (bun) | `bun run --cwd ${CLAUDE_PLUGIN_ROOT} start` | macOS 전용 (chat.db + AppleScript) | **L2** | 🔴 |
| laravel-boost | laravel-boost | stdio | `php artisan boost:mcp` | Laravel 앱 디렉토리 필요 | **L2** (Laravel 특정) | 🔴 |
| linear | linear | http | `https://mcp.linear.app/mcp` | (plugin.json 명시 없음, OAuth 추정) | **L2** (Linear SaaS) | 🔴 |
| playwright | playwright | stdio (npx) | `npx @playwright/mcp@latest` | 없음 (npx 자동) | **L1** (범용 브라우저 자동화) | 🟡 |
| serena | serena | stdio (uvx) | `uvx --from git+https://github.com/oraios/serena serena start-mcp-server` | 없음 (git+python uvx) | **L1** (semantic code analysis 범용) | 🟡 |
| telegram | telegram | stdio (bun) | `bun run --cwd ${CLAUDE_PLUGIN_ROOT} start` | `TELEGRAM_BOT_TOKEN` 필수 | **L2** | 🔴 |
| terraform | terraform | stdio (docker) | `docker run hashicorp/terraform-mcp-server:0.4.0` | `TFE_TOKEN` + Docker Desktop | **L2** (IaC 특정) | 🔴 |

---

## E. 의존성 그래프

(Batch 1 범위 내에선 강한 내부 의존성 없음)

- `claude-md-management/skills/claude-md-improver` ↔ `claude-md-management/commands/revise-claude-md.md`
  - 별도 진입점이지만 동일 도메인. 편입 시 **세트로** 이동 권장.
- `example-plugin`은 데모용이라 모든 구성요소가 묶여 있지만 편입 대상 아님.
- **feature-dev 세트** (강한 의존):
  - `/feature-dev` → `code-architect`, `code-explorer`, `code-reviewer` 3개 agent 호출
  - 편입 시 4개 파일 **반드시 함께** 이동
- **hookify 세트** (강한 의존):
  - `/hookify` → `conversation-analyzer` agent 호출
  - `/configure`, `/list` → `writing-hookify-rules` skill 사전 로드 명시
  - 4개 hook(PreToolUse/PostToolUse/Stop/UserPromptSubmit) 모두 Python3 의존
  - 편입 시 commands 4 + agent 1 + skill 1 + hooks/*.py 전체 + python 런타임 확인 필요
- **mcp-server-dev 세트** (소프트 핸드오프):
  - `build-mcp-server` → `build-mcp-app` / `build-mcpb` 로 핸드오프
  - 같이 편입해야 사용자 흐름 끊기지 않음
- **plugin-dev 세트** (강한 의존, 거대):
  - `/create-plugin` → 7개 스킬 + 3 agents 모두 사용
  - 편입 시 11개 파일 + 본 워크벤치 자체 개발에 즉시 활용 가능 (self-hosting 효과)
- **pr-review-toolkit 세트** (강한 의존):
  - `/review-pr` → 6개 specialized agent를 Task로 호출
  - 편입 시 cmd 1 + agents 6 함께 이동
  - **`code-review`(Batch 1) 와 기능 중복 가능성** — Phase 2에서 결정
- **ralph-loop 세트**:
  - `/ralph-loop` → bash `setup-ralph-loop.sh` + Stop hook의 `stop-hook.sh`
  - cmd 3 + hooks 1 + scripts 전체 함께 이동, bash 의존
- **discord 세트** (강한 의존):
  - `access` + `configure` 2 skills + discord MCP 서버(`server.ts`) + `bun` 런타임 + `~/.claude/channels/discord/` 상태 디렉토리 + `DISCORD_BOT_TOKEN`
  - 5개 구성요소 전부 함께 이동해야 동작. **하지만 전체 🔴 (L2 Discord 특정).**
- **fakechat 세트**:
  - MCP 서버(`server.ts`) + `bun` 런타임 only. skills/commands 없음, 단독 MCP.
  - localhost 테스트 surface용 — 🔴
- **skill-creator 단독 vs plugin-dev 중복**:
  - `skill-creator/skill-creator` 스킬은 eval 스크립트(`eval-viewer/generate_review.py`) 참조. plugin-dev의 `skill-development` 스킬은 동명 역할. Phase 2에서 단일화 결정 (확인 #18).
- **swift-lsp / typescript-lsp**: 컴포넌트 0개 (LICENSE+README 뿐) — LSP 런타임 설정만. 편입 대상 아님.
- **codex 세트** (매우 강한 의존, 본 프로젝트 핵심):
  - `/codex:rescue` → `codex-rescue` agent → skills `codex-cli-runtime` + `gpt-5-4-prompting` 필수 로드
  - 7개 commands 전부 `scripts/codex-companion.mjs` 호출 (Node.js + Codex CLI 필수)
  - 3개 hooks (SessionStart/SessionEnd/Stop) 전부 `scripts/*.mjs` 의존
  - 편입 시 **3 skills + 7 cmds + 1 agent + 3 hooks + scripts/ 전체 + schemas/ + prompts/ + NOTICE**를 **세트로** 이동해야 동작.
  - user의 `/codex:review`, `/codex:rescue` 등 이미 일상 사용 중 → productivity-pack 또는 별도 편입 최우선.
- **imessage 세트** / **telegram 세트** (discord와 동형):
  - 각각 2 skills (access/configure) + bun 런타임 + server.ts + 상태 디렉토리 + bot token 환경변수
  - 전부 L2 🔴

---

## F. 본인 제작 자산 (참고용 — 편입 대상 아님)

### F-1. Skills (`~/.claude/skills/`)

| 스킬명 | description 요약 | 외부 의존성 | L 태그 | 처리 방침 |
|---|---|---|---|---|
| `claude-design-prompt` | Claude Design 초기 프롬프트 생성(5요소 공식, 5종 도메인 자동 분류) | 없음 | **L1** (디자인 도구 일반) | **Phase 2에서 편입 후보 검토** — 범용 디자인 프롬프트 툴로 productivity-pack 또는 analysis-pack 배치 고려 |
| `subculture-trend-report` | 서브컬처 6종 월간 캐릭터 트렌드 HTML 보고서(원신/스타레일/젠레스/명조/엔드필드/니케) | Fandom Wiki curl, iTunes Search API, Sensor Tower | **L2** (특정 보고서 포맷·특정 6종 종속) | **프로젝트 리포로 이관 예정** (MASTER_PLAN 3.2) |
| `zzz-skill-tagger` | ZZZ 스킬 DB 태그 생성·정규화 (`${CLAUDE_WORK_ROOT}/ZZZ_SNA/` CSV 연동) | 절대경로 하드코딩 있음 (수정 필요) | **L2** (ZZZ 특정) | **프로젝트 리포로 이관 예정** (MASTER_PLAN 3.2). 이관 시 `$env:CLAUDE_WORK_ROOT` 로 경로 치환 필수 |

### F-2. Commands (`~/.claude/commands/`)

**디렉토리 부재** — 본인 제작 사용자 레벨 커맨드 없음. `/codex:*` 명령어는 codex 플러그인 소속 (C 섹션 참고).

### F-3. MASTER_PLAN 3.2 편입 제외 목록 대조

| 예정 항목 | 실재 여부 | 실제 위치 | 비고 |
|---|---|---|---|
| combat-system-review | ❌ 없음 | — | ~/.claude/skills/에 없음. 과거 제작 후 제거되었거나 플러그인 쪽에 이관된 듯. Phase 2 전 확인 필요 |
| zzz-action-keyword-map | ❌ 없음 | 플러그인 내 `anthropic-skills:zzz-action-keyword-map`로만 존재 | 본인이 만들어 plugin 형태로 업로드했거나 구 자산. 본 F 섹션에선 대상 아님 |
| zzz-skill-tagger | ✅ 있음 | `~/.claude/skills/zzz-skill-tagger/` | F-1에 기재. 이관 예정 |
| subculture-trend-report | ✅ 있음 | `~/.claude/skills/subculture-trend-report/` | F-1에 기재. 이관 예정 |
| meeting-summary | ❌ 없음 | — | ~/.claude/skills/에 없음. Phase 2 전 확인 필요 |

### F-4. 기타 본인 제작 자산 스캔

- `~/.claude/agents/` — **디렉토리 부재**
- `~/.claude/hooks/` — **디렉토리 부재**
- `~/.claude/commands/` — **디렉토리 부재**
- `~/.claude/settings.json` — 5.3 KB (개인 설정, 편입 대상 아님)
- `~/.claude/CLAUDE.md` — 미확인 (현재 context에는 없음)
- `~/.claude/memory/MEMORY.md` — 존재 (사용자 auto-memory, 편입 대상 아님, **Public 전환 전 유출 주의** — Phase 8 게이트 #8 해당)
- `~/.claude/plans/`, `~/.claude/projects/`, `~/.claude/sessions/` — 개인 세션 아카이브, 편입 대상 아님, Public 유출 금지

---

## 확인 필요 항목

1. **clangd-lsp / csharp-lsp** — `plugin.json` 부재. marketplace.json에 메타 정의 있을 것으로 추정. 다음 배치 시작 전 `marketplaces/claude-plugins-official/.claude-plugin/marketplace.json` 확인 필요.
2. **code-simplifier / explanatory-output-style** — Skills/Commands/Hooks 없는데 디렉토리 크기는 있음. `agents/` 또는 `output-styles/` 폴더 가능성. 다음 배치에서 디렉토리 트리 확인.
3. **explanatory-output-style 의 SessionStart 훅** — `bash`로 실행. Windows 환경에서 git-bash·WSL 의존. 편입 시 PowerShell 포팅 필요할 수 있음.
4. **example-plugin/.mcp.json** — `https://mcp.example.com/api` 더미 URL. 편입 시 사용 여부 결정 필요(아마 🔴).
5. **homepage 보완** — 모든 plugin.json에 homepage 없음. `marketplace.json` 의 `repository` 필드로 보완해야 정확한 출처 기록 가능.
6. **agents 컴포넌트가 Phase 1 스키마에 없음** — phase1 프롬프트는 Skills/Commands/Hooks만 정의. feature-dev·hookify에서 agents/ 디렉토리 발견. Phase 2 진입 전 phase1-catalog-prompt-v2.md에 D-2 Agents 섹션 추가 권장.
7. **frontend-design SKILL.md frontmatter에 license 필드** — "Complete terms in LICENSE.txt" 명시. Apache-2.0 LICENSE 파일과 별도. 편입 전 LICENSE.txt 본문 확인 필요.
8. **hookify Python3 의존성** — Windows에서 `python3` 명령 vs `python`. Python 미설치 시 hook 전부 실패. 편입 시 .mcp.json 또는 plugin.json에 런타임 요구사항 명시 필요.
9. **mcp-server-dev/build-mcp-server 가 WebFetch로 외부 docs 강제 로드** — `https://claude.com/docs/llms-full.txt`. 오프라인 환경에서 동작 안 함. 편입 시 캐시 전략 검토.
10. **feature-dev/hookify의 agents tools 목록에 KillShell, BashOutput 포함** — Windows PS 환경 호환성 확인 필요.
11. **`code-review`(Batch 1) vs `pr-review-toolkit/review-pr`(Batch 3) 기능 중복** — 둘 다 PR 리뷰. 전자는 단일 명령, 후자는 6 agent 분산. Phase 2에서 둘 중 하나만 편입 또는 역할 분리 결정 필요.
12. **session-report에 plugin.json 없음** — Skill만 있는 특이 케이스. marketplace.json 정의 확인 필요. Node.js 의존(`analyze-sessions.mjs`).
13. **ralph-loop의 `hide-from-slash-command-tool: true` 옵션** — 슬래시 커맨드 자동완성에서 숨김. 편입 시 의도 파악 필요(자동 호출만 허용?).
14. **plugin-dev이 본 워크벤치 자체 개발에 매우 유용** — 우선순위 높게 편입하면 Phase 4~5 작업 효율 ↑. self-hosting 의미.
15. **external_plugins 5개 (asana/context7/firebase/github/gitlab) 개별 LICENSE 없음** — marketplace 루트 `claude-plugins-official/LICENSE` (Apache-2.0) 상속으로 기록했으나, 각 MCP 서버 구현체는 제3자(Asana/Upstash/Google/GitHub/GitLab) 소유. 재배포 시 **원격 MCP 엔드포인트 의존은 편입이 아닌 사용자 환경 설정 사항** — 코드가 우리 리포에 실제로 들어오는 게 아니라는 점 유의. Phase 2에서 "MCP 설정 가이드 문서만 vendoring" 옵션도 검토.
16. **discord·fakechat는 `bun` 런타임 필수** — Windows 기본 PATH에 bun 없음. 설치 확인 및 `.npmrc` (로컬 레지스트리 참조) 내용 검토 필요. bun 런타임 가정은 멀티 디바이스 포터빌리티 원칙과 충돌 가능.
17. **discord 플러그인은 `DISCORD_BOT_TOKEN` + `~/.claude/channels/discord/` 상태 디렉토리 + Discord Developer Portal 봇 등록** 전제 — L2 수준 세팅 비용. 현재 본인 용도에 해당 채널 없음 → 편입 제외.
18. **skill-creator vs plugin-dev/skill-development 기능 중복** — 전자는 eval·benchmark까지 포괄, 후자는 작성 가이드 중심. Phase 2에서 "skill-creator 단일 편입 + plugin-dev는 나머지 스킬만" 또는 "plugin-dev 세트 통째 편입 + skill-creator 제외" 양자택일 필요.
19. **swift-lsp·typescript-lsp는 구성요소 0개** — LICENSE+README만 있음. LSP 런타임 연결은 Claude Code 본체가 처리. 편입 대상 아니며, 필요 시 사용자 PATH에 각 언어서버 설치만 하면 됨.
20. **github MCP vs 기존 `gh` CLI** — `commit-commands` 플러그인이 이미 `gh` CLI 기반 PR 생성을 지원. github MCP는 추가로 `GITHUB_PERSONAL_ACCESS_TOKEN` 요구. Phase 2에서 둘 중 하나로 단일화 (productivity-pack 내 PR 워크플로우 기준).
21. **context7 MCP는 docs lookup 범용성 높음** — 사내/특정 SaaS 의존 없음. Upstash 호스팅이라 네트워크 의존은 있지만 공개 문서 조회용이라 비교적 덜 민감. Phase 2에서 🟡 재평가 가치 있음.
22. **gitlab MCP plugin.json에 인증 헤더 명시 없음** — `https://gitlab.com/api/v4/mcp` 엔드포인트가 실제 동작하려면 인증 필요할 텐데 `.mcp.json`에 Bearer 설정 없음. 현재 공개 데이터만 조회하는 read-only 엔드포인트인지 확인 필요. 어느 쪽이든 본인 용도에선 🔴.
23. **전체 플러그인 수 재계산** — 당초 "49개" 전제 오류. 실제로는 claude-plugins-official 48 + openai-codex 1 = **50개**. plugins/ 33 + external_plugins/ 15 = 48. MASTER_PLAN이나 staging 프롬프트에 숫자 박제되어 있으면 갱신 필요.
24. **codex 플러그인만 "installed"** — `installed_plugins.json`에 codex 단독 등록. 나머지 49개는 마켓 인덱스에서 available 상태로, Claude Code가 세션마다 동적 로드. 편입 시 이 구분이 **"vendoring 필요" vs "마켓 가이드 문서만"** 판단의 기준이 될 수 있음.
25. **imessage는 macOS 전용** — `chat.db` 직접 읽기 + AppleScript 발송 구조. Windows 환경에선 동작 불가 → 본인(Windows 사용자) 기준 자동 🔴.
26. **serena / playwright는 예외적으로 🟡 후보** — 범용 LSP 기반 semantic analysis, 범용 브라우저 자동화. Phase 2에서 game-design-pack(playwright) 또는 analysis-pack(serena) 편입 검토 가치 있음.
27. **codex 플러그인 편입은 "vendoring" 방식 주의** — OpenAI 제작 Apache-2.0이지만 `scripts/codex-companion.mjs` 같은 핵심 로직이 외부 `codex` CLI에 의존. 단순 복사해도 사용자 시스템에 codex CLI 없으면 무동작. README에 전제조건 명시 필수.
28. **F-1 zzz-skill-tagger 절대경로 하드코딩** — `${CLAUDE_WORK_ROOT}/ZZZ_SNA/` 경로가 SKILL.md description에 박혀 있음. 프로젝트 리포 이관 시 `$env:CLAUDE_WORK_ROOT\ZZZ_SNA\` 로 치환 필수 (멀티 디바이스 포터빌리티 원칙).
29. **F-3 미확인 자산 (combat-system-review, meeting-summary)** — MASTER_PLAN 3.2에 L2로 명시되어 있으나 현 시점 `~/.claude/skills/`에 부재. Phase 2 전에 "실재하지 않는다면 MASTER_PLAN 3.2에서 제거" 또는 "다른 위치에 있다면 명시" 결정 필요.
30. **상위 디렉토리 전체 Public 위험** — `~/.claude/memory/`, `~/.claude/plans/`, `~/.claude/projects/`, `~/.claude/sessions/`에 개인 정보·작업 히스토리 포함. rwang-workbench 리포와 독립 관리 필요. Phase 8 게이트 #8(공개 불가 자산 확인) 시 재검증.

---

## Phase 1 분할 실행 완료 (5/5)

- 스캔 대상 50개 전수 완료
- 후속 배치 예정 없음
- **다음 단계:** Phase 2 "편입 대상 선별" 진행 — `$env:CLAUDE_WORK_ROOT\Work\workbench-selection-2026-04-23.md` 작성

---

## Batch 1 채팅 출력 요약

(Phase 1 프롬프트 "채팅 출력" 규칙에 따라 채팅에는 다음만 표시:)

1. **카탈로그 파일:** `${CLAUDE_WORK_ROOT}\Work\workbench-catalog-2026-04-23.md`
2. **요약 섹션:** ↑ 위쪽 "요약" 절 참고
3. **확인 필요 항목:** ↑ 위쪽 "확인 필요 항목" 절 참고

## Batch 4 추가 노트

- 신규 스캔: 10개 (official 3 + external 7)
- **official 3개 핵심:** skill-creator(🟢, 단일 스킬, plugin-dev와 중복 검토), swift-lsp/typescript-lsp(컴포넌트 0, 편입 대상 아님)
- **external 7개 핵심:** 전부 MCP 전용 경량 플러그인. 대부분 원격 SaaS·토큰 의존으로 L2/🔴. 예외는 context7(🟡), github(🟡, gh CLI와 중복 검토).
- **새로 확인된 패턴:** MCP 서버만 있는 플러그인에서 license/homepage/version 메타가 부실함. marketplace.json이 루트에서 메타를 관리하는 구조 확정 → Phase 2 전에 marketplace.json 1회 훑어볼 가치 있음.

## Batch 5 추가 노트 (최종)

- 신규 스캔: 10개 (external_plugins 나머지 8 + openai-codex 마켓 1 + 본인 제작 F 섹션 3)
- **external 8개 핵심:**
  - 🟡 후보 2개 신규 발견: playwright(범용 브라우저 자동화), serena(범용 semantic code analysis). game-design-pack/analysis-pack 편입 검토 가치.
  - imessage는 macOS 전용이라 Windows 본인 환경에서 🔴 자동.
  - telegram/greptile/laravel-boost/linear/terraform는 전부 L2 🔴.
- **openai-codex 단일 플러그인 codex 핵심:**
  - 현재 유일하게 "installed" 상태. 본인이 이미 `/codex:review`, `/codex:rescue` 일상 사용 중.
  - 3 skills + 7 commands + 1 agent + 3 hooks + scripts/ 전체 의존 세트. Phase 4 편입 시 **단일 플러그인 세트로** 이동.
  - 내부 skills 전부 `user-invocable: false` — 사용자 직접 호출용이 아닌 에이전트 내부 로드용. SKILL.md 포맷상 특이 패턴.
  - 라이선스: Apache-2.0 + 자체 NOTICE. 재배포 시 NOTICE 보존 의무.
- **F 섹션 스캔 결과:**
  - 본인 제작 Skills 3개만 존재 (claude-design-prompt, subculture-trend-report, zzz-skill-tagger).
  - 나머지 본인 Commands/Agents/Hooks 디렉토리는 전부 부재.
  - MASTER_PLAN 3.2 편입 제외 목록 5개 중 실재하는 건 2개뿐 → MASTER_PLAN 갱신 필요 (확인 #29).
  - claude-design-prompt는 L2가 아니라 **L1 편입 후보**로 재분류 — Phase 2에서 처리.
- **최종 이슈 카운트:** 확인 필요 항목 22개 → 30개 (8개 신규 추가).
- **스캐폴드 건강도:** 모든 49개 non-codex 플러그인이 Apache-2.0 확인. 라이선스 미표기 0건 → Phase 8 LICENSE 검토 부담 ↓.
