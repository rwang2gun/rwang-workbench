# Phase 4 Source Lock

> **역할**: Phase 4 vendoring 대상 11개 플러그인의 원본 메타데이터 + 45개 컴포넌트 매핑 + 내부 의존성 표.
> **수명**: Phase 4 진행 중 참조. 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: [phase4-plan.md](phase4-plan.md) §1.1–1.3 + MASTER_PLAN v1.5 §3.5.
> **업데이트 이력**: 2026-04-23 §1.3 resolve 완료, Components/Dependencies/Aliases 작성 중.

---

## 0. Resolve 요약

- **11개 전부 §1.3 단계 2 (marketplaces cache 직접 탐색)로 resolve 성공.** 단계 3/4 진입 사례 없음.
- **LICENSE 전수 Apache-2.0 확인** — 11개 각 플러그인 루트 `LICENSE` 파일의 2번째 라인 "Apache License" + 3번째 라인 "Version 2.0, January 2004".
- **마켓플레이스 체크아웃 sha**: `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` (`~/.claude/plugins/marketplaces/claude-plugins-official/.gcs-sha`, 2026-04-23 기준)
- **두 upstream 리포로 분산 표기** — homepage 기준:
  - `anthropics/claude-plugins-official` 5개: claude-code-setup, claude-md-management, mcp-server-dev, playground, session-report
  - `anthropics/claude-plugins-public` 6개: commit-commands, feature-dev, hookify, plugin-dev, pr-review-toolkit, security-guidance
  - 실로컬 resolve 경로는 **둘 다 `claude-plugins-official` 마켓플레이스 캐시**에 있음 (public 내용을 official이 흡수한 것으로 추정). `vendored-from`에는 marketplace.json의 `homepage` 값을 그대로 사용.
- **Blocked 플러그인**: 0개.

---

## 1. Source Lock Table (§1.3)

| # | Plugin | Resolve 단계 | Local Path (`~/.claude/plugins/marketplaces/claude-plugins-official/plugins/<name>/`) | `plugin.json` version | LICENSE Evidence Path | Apache-2.0 확인 | Homepage (vendored-from) |
|---|---|---|---|---|---|---|---|
| 1 | `claude-code-setup` | 2 | `plugins/claude-code-setup/` | `1.0.0` | `plugins/claude-code-setup/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup` |
| 2 | `claude-md-management` | 2 | `plugins/claude-md-management/` | `1.0.0` | `plugins/claude-md-management/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management` |
| 3 | `commit-commands` | 2 | `plugins/commit-commands/` | _(unset)_ | `plugins/commit-commands/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-public/tree/main/plugins/commit-commands` |
| 4 | `feature-dev` | 2 | `plugins/feature-dev/` | _(unset)_ | `plugins/feature-dev/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-public/tree/main/plugins/feature-dev` |
| 5 | `hookify` | 2 | `plugins/hookify/` | _(unset)_ | `plugins/hookify/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-public/tree/main/plugins/hookify` |
| 6 | `mcp-server-dev` | 2 | `plugins/mcp-server-dev/` | _(unset)_ | `plugins/mcp-server-dev/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev` |
| 7 | `playground` | 2 | `plugins/playground/` | _(unset)_ | `plugins/playground/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/playground` |
| 8 | `plugin-dev` | 2 | `plugins/plugin-dev/` | _(unset)_ | `plugins/plugin-dev/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-public/tree/main/plugins/plugin-dev` |
| 9 | `pr-review-toolkit` | 2 | `plugins/pr-review-toolkit/` | _(unset)_ | `plugins/pr-review-toolkit/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-public/tree/main/plugins/pr-review-toolkit` |
| 10 | `security-guidance` | 2 | `plugins/security-guidance/` | _(unset)_ | `plugins/security-guidance/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-public/tree/main/plugins/security-guidance` |
| 11 | `session-report` | 2 | `plugins/session-report/` | _(no plugin.json)_ | `plugins/session-report/LICENSE` | ✅ | `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/session-report` |

> **Original-version 기록 규칙**: 각 편입 파일의 vendoring 헤더 `original-version` 필드는 다음 2개 값을 이어 붙여서 기록한다 — `marketplace-sha:cf62a6c02dc03db88da8eb7c61bdb9fd88da6326, plugin-version:<위 표의 plugin.json version 또는 unset>`.

---

## 2. Components (§1.1)

selection A-1~A-4의 CONFIRM 항목을 실제 파일에 1:1 매핑. **전부 존재 확인 완료**.

### 2.1 Skills (15)

| # | Plugin | Selection의 스킬명 | 실제 디렉토리 | 대상 팩 |
|---|---|---|---|---|
| 1 | claude-code-setup | claude-automation-recommender | `skills/claude-automation-recommender/SKILL.md` | productivity |
| 2 | claude-md-management | claude-md-improver | `skills/claude-md-improver/SKILL.md` | productivity |
| 3 | hookify | ⚠️ selection은 `writing-hookify-rules` | **실제: `skills/writing-rules/SKILL.md`** | productivity |
| 4 | mcp-server-dev | build-mcp-server | `skills/build-mcp-server/SKILL.md` | productivity |
| 5 | mcp-server-dev | build-mcp-app | `skills/build-mcp-app/SKILL.md` | productivity |
| 6 | mcp-server-dev | build-mcpb | `skills/build-mcpb/SKILL.md` | productivity |
| 7 | playground | playground | `skills/playground/SKILL.md` | **analysis** |
| 8 | plugin-dev | plugin-structure | `skills/plugin-structure/SKILL.md` | productivity |
| 9 | plugin-dev | skill-development | `skills/skill-development/SKILL.md` | productivity |
| 10 | plugin-dev | command-development | `skills/command-development/SKILL.md` | productivity |
| 11 | plugin-dev | agent-development | `skills/agent-development/SKILL.md` | productivity |
| 12 | plugin-dev | hook-development | `skills/hook-development/SKILL.md` | productivity |
| 13 | plugin-dev | mcp-integration | `skills/mcp-integration/SKILL.md` | productivity |
| 14 | plugin-dev | plugin-settings | `skills/plugin-settings/SKILL.md` | productivity |
| 15 | session-report | session-report | `skills/session-report/SKILL.md` | **analysis** |

> **Selection 오기 수정**: `writing-hookify-rules` → `writing-rules` (실제 디렉토리명). `vendored-from`에는 실제 이름 사용.

### 2.2 Commands (11)

| # | Plugin | Selection의 명령어 | 실제 파일 | 대상 팩 |
|---|---|---|---|---|
| 1 | claude-md-management | `/revise-claude-md` | `commands/revise-claude-md.md` | productivity |
| 2 | commit-commands | `/clean_gone` | `commands/clean_gone.md` | productivity |
| 3 | commit-commands | `/commit` | `commands/commit.md` | productivity |
| 4 | commit-commands | `/commit-push-pr` | `commands/commit-push-pr.md` | productivity |
| 5 | feature-dev | `/feature-dev` | `commands/feature-dev.md` | productivity |
| 6 | hookify | `/hookify` | `commands/hookify.md` | productivity |
| 7 | hookify | `/configure` | `commands/configure.md` | productivity |
| 8 | hookify | `/list` | `commands/list.md` | productivity |
| 9 | hookify | `/help` | `commands/help.md` | productivity |
| 10 | plugin-dev | `/create-plugin` | `commands/create-plugin.md` | productivity |
| 11 | pr-review-toolkit | `/review-pr` | `commands/review-pr.md` | productivity |

### 2.3 Hooks (5)

| # | Plugin | 이벤트 | 실제 파일 | 런타임 | 대상 팩 |
|---|---|---|---|---|---|
| 1 | hookify | PreToolUse | `hooks/pretooluse.py` | python | productivity |
| 2 | hookify | PostToolUse | `hooks/posttooluse.py` | python | productivity |
| 3 | hookify | Stop | `hooks/stop.py` | python | productivity |
| 4 | hookify | UserPromptSubmit | `hooks/userpromptsubmit.py` | python | productivity |
| 5 | security-guidance | PreToolUse | `hooks/security_reminder_hook.py` | python | productivity |

> hookify는 `hooks/hooks.json` 매니페스트도 함께 존재 — 편입 시 파일 세트 일체로 복사.

### 2.4 Agents (13)

| # | Plugin | Agent | 실제 파일 | 대상 팩 |
|---|---|---|---|---|
| 1 | feature-dev | code-architect | `agents/code-architect.md` | productivity |
| 2 | feature-dev | code-explorer | `agents/code-explorer.md` | productivity |
| 3 | feature-dev | code-reviewer | `agents/code-reviewer.md` | productivity |
| 4 | hookify | conversation-analyzer | `agents/conversation-analyzer.md` | productivity |
| 5 | plugin-dev | agent-creator | `agents/agent-creator.md` | productivity |
| 6 | plugin-dev | plugin-validator | `agents/plugin-validator.md` | productivity |
| 7 | plugin-dev | skill-reviewer | `agents/skill-reviewer.md` | productivity |
| 8 | pr-review-toolkit | code-reviewer | `agents/code-reviewer.md` | productivity |
| 9 | pr-review-toolkit | code-simplifier | `agents/code-simplifier.md` | productivity |
| 10 | pr-review-toolkit | comment-analyzer | `agents/comment-analyzer.md` | productivity |
| 11 | pr-review-toolkit | pr-test-analyzer | `agents/pr-test-analyzer.md` | productivity |
| 12 | pr-review-toolkit | silent-failure-hunter | `agents/silent-failure-hunter.md` | productivity |
| 13 | pr-review-toolkit | type-design-analyzer | `agents/type-design-analyzer.md` | productivity |

> ⚠️ **Agent 이름 충돌**: `code-reviewer`가 feature-dev와 pr-review-toolkit 양쪽에 존재. 편입 시 **같은 팩 내에서 파일명 충돌** 발생. 대응: 팩 내 배치 경로를 원본 플러그인 디렉토리로 분리 (`agents/feature-dev/code-reviewer.md` vs `agents/pr-review-toolkit/code-reviewer.md`)하거나, frontmatter name을 `code-reviewer-feature` / `code-reviewer-pr`로 분화. §3.6.5에서 단일화하지 않은 이유(두 agent의 역할·모델이 다름: feature-dev는 sonnet, pr-review-toolkit는 opus)와 맞물려, **별도 파일 유지** 권장. 편입 시 경로 분리 방식으로 처리.

---

## 3. Internal Dependencies (§1.2)

§1.2 detection 규칙대로 11개 플러그인 내부 Grep 전수 조사 완료. 단일 세트(commit-commands, claude-code-setup, claude-md-management, playground, session-report, security-guidance)는 self-ref 외 cross-ref 없음. 다음은 cross-ref 있는 세트.

### 3.1 hookify

| From | Type | To | Reference Form | 파일 | 편입 시 resolve 필요 |
|---|---|---|---|---|---|
| `/configure` (command) | load | `writing-rules` (skill) | `hookify:writing-rules` (namespaced) | `commands/configure.md:8` | 스킬 경로 동일 팩 내 배치 |
| `/hookify` (command) | load | `writing-rules` (skill) | `hookify:writing-rules` | `commands/hookify.md:9` | 동일 |
| `/list` (command) | load | `writing-rules` (skill) | `hookify:writing-rules` | `commands/list.md:8` | 동일 |
| `/hookify` (command) | launch (Task tool) | `conversation-analyzer` (agent) | `conversation-analyzer agent` | `commands/hookify.md:25,30` | agent 이름으로 resolve |
| `/configure` (command) | mention | `/hookify:list` | `/hookify:list` | `commands/configure.md:116` | cross-command URL, self-namespace |
| `conversation-analyzer` (agent) | mention | `/hookify` (command) | `/hookify command` | `agents/conversation-analyzer.md:3,172` | doc reference only |

### 3.2 plugin-dev

| From | Type | To | Reference Form | 파일 | 편입 시 resolve 필요 |
|---|---|---|---|---|---|
| `/create-plugin` (command) | load (Skill tool) | `plugin-structure` (skill) | "Load plugin-structure skill" | `commands/create-plugin.md:60,64` | 팩 내 형제 skill 위치 |
| `/create-plugin` (command) | load | `skill-development` (skill) | 동일 | `:176,187,200` | 동일 |
| `/create-plugin` (command) | load | `command-development` (skill) | 동일 | `:177,206` | 동일 |
| `/create-plugin` (command) | load | `agent-development` (skill) | 동일 | `:178,217` | 동일 |
| `/create-plugin` (command) | load | `hook-development` (skill) | 동일 | `:179,227` | 동일 |
| `/create-plugin` (command) | load | `mcp-integration` (skill) | 동일 | `:180,237` | 동일 |
| `/create-plugin` (command) | load | `plugin-settings` (skill) | 동일 | `:181,248` | 동일 |
| `/create-plugin` (command) | use (Task tool) | `agent-creator` (agent) | "Use agent-creator agent" | `:26,218` | agent 이름 |
| `/create-plugin` (command) | use | `plugin-validator` (agent) | 동일 | `:26,266` | 동일 |
| `/create-plugin` (command) | use | `skill-reviewer` (agent) | 동일 | `:26,200` | 동일 |
| `agent-creator` (agent) | suggest | `plugin-validator` (agent) | `Use the plugin-validator agent` | `agents/agent-creator.md:130` | agent 이름 |
| `plugin-validator` (agent) | reference | `agent-development/scripts/validate-agent.sh` | "utility from agent-development skill" | `agents/plugin-validator.md:89` | **상대 경로 의존** — 스킬 내부 스크립트 참조 |
| `plugin-validator` (agent) | reference | `hook-development/scripts/validate-hook-schema.sh` | 동일 | `agents/plugin-validator.md:108` | 동일 |

### 3.3 feature-dev

| From | Type | To | Reference Form | 파일 |
|---|---|---|---|---|
| `/feature-dev` (command) | Launch (Task tool) | `code-explorer` (agent) | "Launch code-explorer agents" | `commands/feature-dev.md:41` |
| `/feature-dev` (command) | Launch | `code-architect` (agent) | "Launch code-architect agents" | `commands/feature-dev.md:78` |
| `/feature-dev` (command) | Launch | `code-reviewer` (agent, **feature-dev 소속**) | "Launch code-reviewer agents" | `commands/feature-dev.md:106` |

### 3.4 pr-review-toolkit

| From | Type | To | Reference Form | 파일 |
|---|---|---|---|---|
| `/review-pr` (command) | mention | `code-reviewer` (agent, **pr-review-toolkit 소속**) | name-only | `commands/review-pr.md:38,137` |
| `/review-pr` (command) | mention | `pr-test-analyzer` (agent) | name-only | `:39,122` |
| `/review-pr` (command) | mention | `comment-analyzer` (agent) | name-only | `:40,117` |
| `/review-pr` (command) | mention | `silent-failure-hunter` (agent) | name-only | `:41,127` |
| `/review-pr` (command) | mention | `type-design-analyzer` (agent) | name-only | `:42,132` |
| `/review-pr` (command) | mention | `code-simplifier` (agent) | name-only | `:43,142` |

### 3.5 mcp-server-dev ⚠️ 상대경로 의존 주의

| From | Type | To | Reference Form | 파일 |
|---|---|---|---|---|
| `build-mcp-app/SKILL.md` | relative-path | `build-mcp-server/references/elicitation.md` | `../build-mcp-server/references/elicitation.md` | `SKILL.md:54` |
| `build-mcp-app/references/widget-templates.md` | relative-path | `../build-mcp-server/references/elicitation.md` | 동일 | `:131` |
| `build-mcp-server/references/elicitation.md` | name-only | `build-mcp-app` (skill) | "`build-mcp-app` widgets" | `:5,124` |
| `build-mcp-server/references/server-capabilities.md` | relative-path | `build-mcpb/references/local-security.md` | `build-mcpb/references/local-security.md` | `:66` |
| `build-mcp-server/references/tool-design.md` | relative-path | `build-mcpb/references/local-security.md` | 동일 | `:151` |
| `build-mcp-app/SKILL.md` | name-only | `build-mcp-server` (skill) | "`build-mcp-server` skill" | `:11` |
| `build-mcp-app/SKILL.md` | name-only | `build-mcpb` (skill) | "`build-mcpb` skill" | `:83,252` |

**🔴 편입 시 배치 제약**: 3개 skill(`build-mcp-server`, `build-mcp-app`, `build-mcpb`)은 반드시 **같은 팩의 `skills/` 디렉토리 내 형제**로 배치해야 함. 원본 상대경로(`../build-mcp-server/...`, `build-mcpb/references/...`)가 유지되어야 파일 참조 resolve 성공. productivity-pack의 `skills/build-mcp-server/`, `skills/build-mcp-app/`, `skills/build-mcpb/` 구조 확정.

### 3.6 cross-plugin 참조 — **없음**

11개 세트 간 cross-plugin 참조는 Grep에서 0건. 각 세트는 self-contained. 이는 배치 순서와 무관하게 세트별 편입이 가능하다는 뜻.

---

## 4. Aliases (§1.2)

각 컴포넌트의 정식 이름과 별칭.

| 컴포넌트 정식명 | 디렉토리명/파일명 | frontmatter `name:` | 추가 표기법 |
|---|---|---|---|
| hookify: writing-rules (skill) | `skills/writing-rules/` | `writing-rules` | `hookify:writing-rules` (namespaced) |
| hookify: `/hookify` | `commands/hookify.md` | — | `/hookify`, `/hookify:hookify` |
| hookify: `/configure` | `commands/configure.md` | — | `/hookify:configure` |
| hookify: `/list` | `commands/list.md` | — | `/hookify:list` |
| hookify: `/help` | `commands/help.md` | — | `/hookify:help` |
| hookify: conversation-analyzer (agent) | `agents/conversation-analyzer.md` | `conversation-analyzer` | — |
| plugin-dev: plugin-structure (skill) | `skills/plugin-structure/` | `plugin-structure` | — |
| plugin-dev: skill-development (skill) | `skills/skill-development/` | `skill-development` | — |
| plugin-dev: command-development (skill) | `skills/command-development/` | `command-development` | — |
| plugin-dev: agent-development (skill) | `skills/agent-development/` | `agent-development` | — |
| plugin-dev: hook-development (skill) | `skills/hook-development/` | `hook-development` | — |
| plugin-dev: mcp-integration (skill) | `skills/mcp-integration/` | `mcp-integration` | — |
| plugin-dev: plugin-settings (skill) | `skills/plugin-settings/` | `plugin-settings` | — |
| plugin-dev: `/create-plugin` | `commands/create-plugin.md` | — | — |
| plugin-dev: agent-creator (agent) | `agents/agent-creator.md` | `agent-creator` | — |
| plugin-dev: plugin-validator (agent) | `agents/plugin-validator.md` | `plugin-validator` | — |
| plugin-dev: skill-reviewer (agent) | `agents/skill-reviewer.md` | `skill-reviewer` | — |
| feature-dev: code-architect (agent) | `agents/code-architect.md` | `code-architect` | — |
| feature-dev: code-explorer (agent) | `agents/code-explorer.md` | `code-explorer` | — |
| feature-dev: **code-reviewer** (agent) | `agents/code-reviewer.md` | `code-reviewer` | **충돌 해결 권장 alias**: `code-reviewer-feature` |
| feature-dev: `/feature-dev` | `commands/feature-dev.md` | — | — |
| pr-review-toolkit: **code-reviewer** (agent) | `agents/code-reviewer.md` | `code-reviewer` | **충돌 해결 권장 alias**: `code-reviewer-pr` (opus, differs from feature-dev sonnet) |
| pr-review-toolkit: code-simplifier (agent) | `agents/code-simplifier.md` | `code-simplifier` | — |
| pr-review-toolkit: comment-analyzer (agent) | `agents/comment-analyzer.md` | `comment-analyzer` | — |
| pr-review-toolkit: pr-test-analyzer (agent) | `agents/pr-test-analyzer.md` | `pr-test-analyzer` | — |
| pr-review-toolkit: silent-failure-hunter (agent) | `agents/silent-failure-hunter.md` | `silent-failure-hunter` | — |
| pr-review-toolkit: type-design-analyzer (agent) | `agents/type-design-analyzer.md` | `type-design-analyzer` | — |
| pr-review-toolkit: `/review-pr` | `commands/review-pr.md` | — | — |
| mcp-server-dev: build-mcp-server (skill) | `skills/build-mcp-server/` | `build-mcp-server` | — |
| mcp-server-dev: build-mcp-app (skill) | `skills/build-mcp-app/` | `build-mcp-app` | — |
| mcp-server-dev: build-mcpb (skill) | `skills/build-mcpb/` | `build-mcpb` | — |
| commit-commands: `/commit`, `/commit-push-pr`, `/clean_gone` | `commands/*.md` | — | — |
| claude-code-setup: claude-automation-recommender (skill) | `skills/claude-automation-recommender/` | `claude-automation-recommender` | — |
| claude-md-management: claude-md-improver (skill) | `skills/claude-md-improver/` | `claude-md-improver` | — |
| claude-md-management: `/revise-claude-md` | `commands/revise-claude-md.md` | — | — |
| playground: playground (skill) | `skills/playground/` | `playground` | — |
| session-report: session-report (skill) | `skills/session-report/` | `session-report` | — |
| security-guidance: PreToolUse hook | `hooks/security_reminder_hook.py` | — | `hooks.json`에서 참조 |
| hookify: 4 hooks | `hooks/{pre,post,...}tooluse.py` | — | `hooks/hooks.json`에서 참조 |

### 4.1 Agent 이름 충돌 대응 방침 ⭐

**`code-reviewer` 이름 충돌** (feature-dev sonnet vs pr-review-toolkit opus) 처리:

- **옵션 A** — frontmatter `name:` 보존 + 파일 경로 분리: `agents/feature-dev/code-reviewer.md`, `agents/pr-review-toolkit/code-reviewer.md`. Claude Code의 agent 해석이 디렉토리 구조로 분기되는지 확인 필요.
- **옵션 B** — frontmatter `name:` 분화: `code-reviewer-feature`, `code-reviewer-pr`. 각 플러그인 내부 명령어(`/feature-dev`, `/review-pr`)의 호출 코드도 alias로 수정 → `modified: minor`.

**Batch 3 진입 전 옵션 최종 선택**. 초기값은 **옵션 B**를 잠정 선택 (더 단순, agent name 명시적, Claude Code의 agent 해석이 경로보다 frontmatter name에 의존할 확률 높음).

옵션 B 선택 시 modified 대상:
- `plugins/productivity-pack/agents/code-reviewer-feature.md` (rename, frontmatter name 변경, `modified: minor`)
- `plugins/productivity-pack/agents/code-reviewer-pr.md` (동일)
- `plugins/productivity-pack/commands/feature-dev.md` (ref 수정, `modified: minor`)
- `plugins/productivity-pack/commands/review-pr.md` (ref 수정, `modified: minor`)

---

## 5. Authoritative Count (§1.1 5단계 exit)

### 5.1 실제 파일 기준 집계

| 유형 | productivity-pack | analysis-pack | 합계 |
|---|---|---|---|
| Skills | 13 | 2 | 15 |
| Commands | 11 | 0 | 11 |
| Hooks | 5 | 0 | 5 |
| Agents | 13 | 0 | 13 |
| **총계** | **42** | **2** | **44** |

### 5.2 불일치 원인 규명

| 출처 | 수치 | 원인 |
|---|---|---|
| selection 요약표 "CONFIRM 총계" | 45 | **hookify `/help` 이중 집계** — A-2 표에 이미 포함(11행 중 한 행)인데 요약의 "Commands 11 (+ hookify `/help` = 12)" 부기 때문에 총합에 1 초과 가산 |
| selection 요약표 "팩별 분포 productivity 40, analysis 2" | 42 | 분포 합(42)은 실제와 정확히 1 적음. productivity의 Skills/Commands/Hooks/Agents 세부 합은 13+11+5+13=42이므로 **"productivity 40"은 단순 숫자 오기** (42가 맞음) |
| phase4-plan.md §2 Batch 표 합계 | 44 | **실제값과 일치** |
| 실제 파일 기준 (본 문서 §5.1) | **44** | **authoritative** |

### 5.3 선언

**Phase 4의 authoritative component count = 44.**

- productivity-pack: 42 (Skills 13 / Commands 11 / Hooks 5 / Agents 13)
- analysis-pack: 2 (Skills: playground, session-report)

이 값은 phase4-plan.md §0 Scope, §2 배치표, §6.1 Exit Criteria, §6.6 CHANGELOG 메타 전부의 기준.

### 5.4 selection 문서 보정 방침

`docs/workbench-selection-2026-04-23.md`의 요약표 수치(45 / 40 / 42)는 Phase 4 실행 목적으로 **이 source-lock 문서의 44가 우선**. selection 본문은 Phase 2 역사 문서로 보존하되 CHANGELOG 또는 Phase 4 마감 커밋 메시지에 수정 근거 기록.

---

## 6. Batch 진행 기록

### 6.1 Batch 1A — plugin-dev (완료, 커밋 대기)

- **작업일**: 2026-04-23
- **대상**: plugin-dev → productivity-pack (7 skills + 1 command + 3 agents = 11 components)
- **복사 방식**: `cp -r` 원본 그대로 (편집 금지), 이후 vendoring 헤더만 삽입
- **실파일 수**: 57개 (`find skills commands agents -type f` 기준)
  - `.md`: 44개 — HTML comment 헤더, frontmatter 존재 시 closing `---` 뒤에 삽입, 없으면 최상단
  - `.sh`: 10개 — `#` comment 헤더, shebang 뒤에 삽입
  - `.json`: 3개 (mcp-integration/examples/*.json) — JSON 표준에 주석 불가하여 **헤더 생략**. 원본 무수정.

#### 헤더 삽입 검증

`grep -L "vendored-from"` 결과 0건 (헤더 누락 없음, `.json` 3개 제외).

모든 헤더 내용:
```
vendored-from: https://github.com/anthropics/claude-plugins-public/tree/main/plugins/plugin-dev
vendored-at: 2026-04-23
original-version: marketplace-sha:cf62a6c02dc03db88da8eb7c61bdb9fd88da6326, plugin-version:unset
modified: none
```

#### 스캔 결과

| 패턴 | 파일 건수 | 판정 | 사유 |
|---|---|---|---|
| GitHub 계정명 / Windows 사용자명 / Windows 사용자 홈 절대경로 / Windows 작업 루트 | 0 | pass | 개인 식별자 없음 |
| `/Users/`, `/home/` | 7건 | warn+allow | 모두 anti-pattern 예시(❌), `alice`/`name` 가상 사용자, 또는 hook-linter의 탐지 regex 패턴 |
| email | 9건 | warn+allow | 전부 `@example.com` 또는 `@company.com` RFC 예약 placeholder |
| PEM/ghp/sk- token | 0 | pass | — |
| KEY/TOKEN/SECRET/PASSWORD 하드코딩 | 1건 | warn+allow | `authentication.md:227` `DB_PASSWORD=mypassword` — `.env` 파일 예시 블록 내 명백한 placeholder |
| `.env` 참조 | 3건 | warn+allow | 전부 hook 스크립트의 `.env` 파일명 **탐지**용 (쓰기 차단 방어 코드) |

**fail 0건**. 모든 warn은 §5 Placeholder 특례 조건(`example`/`demo`/`sample`/`placeholder` 문맥) 충족.

#### Internal dependency 수동 trace

§3.2 표의 모든 참조가 productivity-pack 내부에서 resolve됨:

| From | To | 검증 |
|---|---|---|
| `/create-plugin` → 7 sibling skills (plugin-structure, skill-development, command-development, agent-development, hook-development, mcp-integration, plugin-settings) | `skills/<name>/SKILL.md` | ✅ 7개 모두 존재 |
| `/create-plugin` → 3 agents (agent-creator, plugin-validator, skill-reviewer) | `agents/<name>.md` | ✅ 3개 모두 존재 |
| `agent-creator.md:138` → plugin-validator agent | `agents/plugin-validator.md` | ✅ |
| `plugin-validator.md:97` → `validate-agent.sh` from agent-development | `skills/agent-development/scripts/validate-agent.sh` | ✅ |
| `plugin-validator.md:116` → `validate-hook-schema.sh` from hook-development | `skills/hook-development/scripts/validate-hook-schema.sh` | ✅ |

**모든 참조 resolve 성공. modified: none 유지 가능 (경로 치환 없음).**

#### 커밋

**Batch 1A 커밋**: `075309d` (2026-04-23) — 58 files, +22070 insertions. phase4-plan.md §2의 승인 지점 (Batch 1A 완료 후 1회) 사용자 승인 완료.

### 6.2 Batch 1B — claude-code-setup + claude-md-management

- **작업일**: 2026-04-23
- **대상**: productivity-pack (3 components)
  - claude-code-setup → `skills/claude-automation-recommender/` (6 files)
  - claude-md-management → `skills/claude-md-improver/` (4 files) + `commands/revise-claude-md.md` (1 file)
- **총 파일**: 11개, 모두 `.md`. `.sh`·`.json` 0건.
- **헤더**: plugin별 `vendored-from` URL·`plugin-version: 1.0.0` 적용. 누락 0건.
- **스캔**: personal identifier 0건, `/Users/`/`/home/` 0건, email 0건, secret/token 0건. **fail 0**.
- **Internal dependency**: 두 플러그인 모두 Source Lock §3 표에서 self-ref only로 분류. `claude-automation-recommender` 내부 reference 표들이 ecosystem catalog로서 다른 플러그인 이름(code-reviewer, writing-rules, skill-development 등)을 **서술적**으로 언급하나, 이는 Skill 툴 load·Task 실행 dep이 아닌 문서 콘텐츠. 참조된 엔티티들도 Phase 4 완료 시 전부 productivity-pack에 존재 예정이므로 eventual consistency OK.
- **modified**: none

### 6.3 Batch 2 — hookify + mcp-server-dev

- **작업일**: 2026-04-23
- **대상**: productivity-pack (13 components)
  - hookify (10 components): 1 skill + 4 commands + 4 hooks + 1 agent
  - mcp-server-dev (3 components): 3 skills (build-mcp-server, build-mcp-app, build-mcpb)

#### hookify 편입 파일 확장 (§2.3 표 대비 추가 복사)

hookify는 순수 5개 component 파일 외에 **런타임 의존 파이썬 모듈 + hooks.json**이 있음. `hooks/pretooluse.py` 등이 `from core.config_loader import load_rules` 등을 통해 지역 모듈에 의존. 이들이 없으면 hooks 모두 ImportError fallback으로 무효화됨.

- `hooks/` 전체: 4 hook .py + `__init__.py` + `hooks.json` (6 파일)
- `core/` 전체: `__init__.py` + `config_loader.py` (297 lines) + `rule_engine.py` (313 lines) (3 파일)
- `matchers/` : `__init__.py` (1 파일, 빈 패키지)
- `utils/` : `__init__.py` (1 파일, 빈 패키지)
- `examples/` : 4개 `.local.md` 룰 템플릿 (user-visible)

총 hookify 편입 파일: **15개** (§2.3 표의 10 component count와는 차원이 다름 — component 수는 manifest 선언 가능한 논리 단위, 편입 파일은 런타임 포함 전체).

배치 위치 결정: `core/`, `matchers/`, `utils/`, `examples/`를 **productivity-pack 루트**에 둠. hook script의 `sys.path.insert(0, PLUGIN_ROOT)` 패턴 유지, `modified: none`. 향후 다른 플러그인이 동명 디렉토리를 가지면 그 시점에 namespace 대응.

#### python3 cross-platform 판단 (§4 리스크 4)

hookify `hooks.json`의 `"command": "python3 ..."` 유지. 이유: Linux/macOS의 `python3` 표준성 vs Windows의 `python`/`py` 관례 중 전자를 우선. Windows 사용자는 `python3.exe` alias 또는 `py -3` wrapper 설정 책임을 짐. **modified: none** 확정 (치환 시 Unix 사용자가 깨짐).

#### mcp-server-dev 배치 제약 (§3.5) 검증

3개 skill(`build-mcp-server`, `build-mcp-app`, `build-mcpb`) 모두 `plugins/productivity-pack/skills/<name>/`의 sibling으로 배치. `../build-mcp-server/references/elicitation.md` 류 상대경로가 resolve됨. `build-mcpb/references/local-security.md` 같은 bare path는 upstream 문서의 textual 참조로 판단(실제 경로는 `skills/build-mcpb/references/...`로 존재).

#### 헤더

- hookify: 전 파일 `vendored-from: .../hookify`, `plugin-version: unset`
- mcp-server-dev: 전 파일 `vendored-from: .../mcp-server-dev`, `plugin-version: unset`
- `.py` 파일: `#` comment 헤더 (shebang 뒤 또는 빈 파일에 단독으로)
- `.json` 파일 (`hooks/hooks.json`): JSON 표준에 주석 불가하여 헤더 생략 (Batch 1A `.json` 3개와 동일 처리)

#### 스캔 결과

| 패턴 | 건수 | 판정 | 사유 |
|---|---|---|---|
| 개인 식별자(rwang2gun/code1412 등) | 0 | pass | |
| `/Users/`, `/home/` | 1건 | warn+allow | `server-capabilities.md:65` `file:///home/user/project` placeholder |
| email | 3건 | warn+allow | `mcp-review@anthropic.com` 2건은 **Anthropic 공식 partner 지원 주소** (upstream Anthropic 문서 원본, 개인정보 아님), `@modelcontextprotocol/ext-apps@1.2.2` 1건은 npm scope 이름이지 이메일이 아닌 regex false positive |
| secret/token | 0 | pass | |
| KEY/TOKEN/SECRET/PASSWORD 하드코딩 | 0 | pass | |

**fail 0건.**

#### Internal dependency trace

| From | To | 결과 |
|---|---|---|
| `/hookify`, `/configure`, `/list` → `hookify:writing-rules` | `skills/writing-rules/SKILL.md` | ✅ |
| `/hookify` (Task tool) → `conversation-analyzer` | `agents/conversation-analyzer.md` | ✅ |
| `hooks/hooks.json` → `python3 ${CLAUDE_PLUGIN_ROOT}/hooks/*.py` | 4개 .py 존재 | ✅ |
| `hooks/pretooluse.py` 등 → `from core.config_loader`, `from core.rule_engine` | `core/` at pack root | ✅ |
| build-mcp-app/SKILL.md → `../build-mcp-server/references/elicitation.md` | sibling skill 경로 | ✅ |
| build-mcp-server → build-mcpb textual refs | sibling skill 존재 | ✅ (문서 내 참조, 절대경로 아님) |

**전체 resolve. modified: none.**

### 6.4 Batch 3 — pr-review-toolkit + feature-dev + commit-commands

- **작업일**: 2026-04-23
- **대상**: productivity-pack (14 components, 14 파일)
  - pr-review-toolkit: 1 command + 6 agents
  - feature-dev: 1 command + 3 agents
  - commit-commands: 3 commands

#### `code-reviewer` 이름 충돌 해결 — §4.1 옵션 B 채택 확정

| 원본 | 신규 파일 / frontmatter | modified |
|---|---|---|
| feature-dev/agents/code-reviewer.md | `agents/code-reviewer-feature.md`, frontmatter `name: code-reviewer-feature` | minor |
| pr-review-toolkit/agents/code-reviewer.md | `agents/code-reviewer-pr.md`, frontmatter `name: code-reviewer-pr` | minor |
| feature-dev/commands/feature-dev.md | `commands/feature-dev.md` line 114 `code-reviewer` → `code-reviewer-feature` | minor |
| pr-review-toolkit/commands/review-pr.md | `commands/review-pr.md` lines 46, 145 `code-reviewer` → `code-reviewer-pr` | minor |

**남는 문서 드리프트**: `code-reviewer-pr.md` frontmatter `description` 필드 내 `<example>` 대화 예시 속 `code-reviewer` 언급은 유지 (단일 문자열, `name:` 필드가 권위 있으므로 트리거링 영향 없음). 4개 파일만 `modified: minor`, 나머지 10개는 `modified: none`.

#### 헤더 적용 결과

14개 모두 헤더 존재 확인. minor 4개·none 10개 분류 정확.

#### 스캔 결과

모든 범주 0 finding. fail 0, warn 0.

#### Internal dependency trace

| From | To | 결과 |
|---|---|---|
| `/feature-dev` (Task tool) → code-explorer, code-architect | `agents/code-explorer.md`, `agents/code-architect.md` | ✅ |
| `/feature-dev` (Task tool) → **code-reviewer-feature** (renamed) | `agents/code-reviewer-feature.md` (frontmatter name 일치) | ✅ |
| `/review-pr` → comment-analyzer, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, code-simplifier | 각 `agents/<name>.md` 존재 | ✅ |
| `/review-pr` → **code-reviewer-pr** (renamed) | `agents/code-reviewer-pr.md` (frontmatter name 일치) | ✅ |
| commit-commands 3개 command | self-contained, cross-ref 0 | ✅ |

**resolve 전체 성공. Option B rename 성공적.**

### 6.5 Batch 4 — security-guidance + session-report + playground + 마감

- **작업일**: 2026-04-23
- **대상**: 3개 components + Phase 4 마감
  - security-guidance: `hooks/security_reminder_hook.py` → `plugins/productivity-pack/hooks/` + hooks.json 병합
  - session-report: `skills/session-report/` (3 파일: SKILL.md + analyze-sessions.mjs + template.html) → `plugins/analysis-pack/skills/`
  - playground: `skills/playground/` (SKILL.md + 6 templates) → `plugins/analysis-pack/skills/`

#### hooks.json 병합 (modified: minor)

기존 `productivity-pack/hooks/hooks.json`(hookify에서 편입)의 `PreToolUse` 배열에 security-guidance 엔트리 추가:

```json
{
  "hooks": [{"type":"command","command":"python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_reminder_hook.py"}],
  "matcher": "Edit|Write|MultiEdit"
}
```

다른 이벤트(PostToolUse / Stop / UserPromptSubmit)는 hookify 단독, 변경 없음. `description` 문자열은 두 플러그인 범위를 기술하도록 갱신. **JSON 표준에 주석 불가로 vendoring 헤더 없음** — 대신 `THIRD_PARTY_NOTICES.md` Modifications 표에 별도 기록.

#### 헤더 (modified: none — 병합된 hooks.json 제외)

- `security_reminder_hook.py`: `#` 헤더, `modified: none`
- `session-report/SKILL.md`: HTML comment 헤더, frontmatter 뒤
- `session-report/analyze-sessions.mjs`: `//` 헤더 (.mjs ≈ JS)
- `session-report/template.html`: HTML comment 헤더 최상단 (원본은 `<!doctype html>` 뒤에 붙여도 브라우저 무시 OK)
- `playground/SKILL.md` + 6 templates: HTML comment 헤더

#### 스캔 결과

Batch 4 파일 범위, 전 범주 **0 finding**.

#### 전체 리포 최종 스캔

- `plugins/**` 하위: 0 finding
- 루트 `LICENSE` line 3 `rwang2gun` (저작권자), `README.md` line 19 `rwang2gun/rwang-workbench` (install URL) — 둘 다 프로젝트의 canonical 속성, §4.3 "vendored 내부 사적 언급" 대상 아님. 유지.

#### modified 합계 (§6.6 CHANGELOG 메타용)

| 분류 | 건수 | 해당 파일 |
|---|---|---|
| minor | 5 | code-reviewer-feature.md, code-reviewer-pr.md, feature-dev.md, review-pr.md, hooks/hooks.json |
| major | 0 | — |
| none | 나머지 | 100+ 파일 (SKILL.md·references·agents·scripts·templates 등) |

#### Internal dependency trace

security-guidance, session-report, playground 전부 self-contained, cross-plugin 참조 0. hookify ↔ security-guidance는 merged hooks.json을 통해 공존, 서로 호출 관계 없음.

#### 커밋

**Batch 4 commit**: 편입 3종 + hooks.json 병합 + THIRD_PARTY_NOTICES.md 채움 + CHANGELOG Phase 4 한 줄 + MASTER_PLAN §8 상태 전이 + `phase4-plan.md`/`phase4-source-lock.md` → `docs/archive/` 이동을 단일 커밋으로 처리.

### 6.6 Phase 4 exit gates (§6.1–6.6 대조)

| Gate | 상태 | 증거 |
|---|---|---|
| §6.1 11개 플러그인 편입 완료, 44 components | ✅ | 본 문서 §5.1 / §6.1–6.5 각 배치 기록 |
| §6.1 모든 편입 파일 vendoring 헤더 존재 (JSON 파일 제외) | ✅ | 배치별 `grep -L "vendored-from"` 0건 |
| §6.1 Internal dependency resolve 수동 trace 통과 | ✅ | §6.1–6.5 각 배치 trace 표 |
| §6.2 LICENSE 요건 (11개 원본 경로 기록, notices 실값, Apache-2.0 확인) | ✅ | §1 Source Lock Table + `THIRD_PARTY_NOTICES.md` |
| §6.3 비밀값 관리 (scan 0 finding) | ✅ | 배치별 + 전체 리포 스캔 |
| §6.3 `.mcp.json` 편입 없음, `.env.example` 필요 없음 | ✅ | 편입 대상에 `.mcp.json` 0개, 신규 hook은 비밀값 요구 없음 |
| §6.4 개인정보 제거 (경로·계정명·이메일 fail 0) | ✅ | 전체 스캔 통과 (루트 LICENSE/README는 canonical 예외) |
| §6.5 동작 검증 | ⏳ | `/reload-plugins` + 각 팩 skill 트리거는 Claude Code 재기동 후 수동 확인 필요 — CHANGELOG에 pending 표기 |
| §6.6 MASTER_PLAN §8 "✅ Phase 4 완료" | ✅ | `docs/MASTER_PLAN_v1.5.md` §8 업데이트 완료 |
| §6.6 CHANGELOG `[Unreleased]` Phase 4 블록 | ✅ | `docs/CHANGELOG.md` 업데이트 완료 |
| §6.6 phase4-plan.md / phase4-source-lock.md → `docs/archive/` 이동 | ✅ | 본 Batch 4 커밋에 포함 |
