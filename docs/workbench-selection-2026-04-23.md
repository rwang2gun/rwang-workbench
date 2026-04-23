# Workbench Selection 2026-04-23

> MASTER_PLAN v1.4 Phase 2 산출물. Phase 1 카탈로그(🟢 45개)를 기반으로 CONFIRM / Deferred / Dropped 라벨링 + 팩 배치를 확정.
> Exit Gate 자동 부분은 PowerShell 스크립트로 검증 완료. 인터랙티브 부분(/plugin marketplace add/install)은 사용자 실행 대기.

---

## 요약

| 항목 | 수 |
|---|---|
| CONFIRM (Skills) | 15 |
| CONFIRM (Commands) | 11 (+ hookify `/help` = 12) |
| CONFIRM (Hooks) | 5 |
| CONFIRM (Agents, 세트 의존) | 13 |
| **CONFIRM 총계** | **45** |
| Deferred | 5 + draw.io 헬퍼 1(게이트 미달로 큐 이동) = 6 |
| Dropped | 18 |
| 팩별 분포 | productivity-pack 40, analysis-pack 2, **game-design-pack 유예** |
| game-design-pack 게이트 | **유예** — vendored 0 + 신규 확정 1 = 1 < 2. `marketplace.json` 미포함. |
| analysis-pack 배치 결정 | **분리 유지** (playground·session-report 그대로) |
| recommends.json 도입 결정 | **Phase 3에서 도입** — `/productivity-pack:check-recommended` 명령어 Phase 5 구현 전제 |
| 라이선스 이슈 | 없음 (전수 Apache-2.0) |
| Phase 3 진입 전 체크리스트 | 7개 항목 v1.5 minor 패치 예약 |
| Exit Gate 판정 | **Conditional Go (연기)** — 자동 검증 PASS, 인터랙티브 부분은 Phase 3 스캐폴드 acceptance에서 흡수 |

---

## A. CONFIRM 목록 (Phase 4 편입 대상)

### A-1. Skills (15)

| 플러그인 | 스킬명 | 라벨 | 팩 | 1줄 근거 |
|---|---|---|---|---|
| claude-code-setup | claude-automation-recommender | ✅ CONFIRM | productivity-pack | 신규 프로젝트 도입 시 자동화 추천 유용 |
| claude-md-management | claude-md-improver | ✅ CONFIRM | productivity-pack | 본인 `~/.claude` 동기화 리포 유지 필수 |
| hookify | writing-hookify-rules | ✅ CONFIRM | productivity-pack | hookify 세트 일체로 편입 |
| mcp-server-dev | build-mcp-server | ✅ CONFIRM | productivity-pack | 본 워크벤치가 MCP 자체 제작 가능성 있음 (self-hosting 연장) |
| mcp-server-dev | build-mcp-app | ✅ CONFIRM | productivity-pack | 세트 일관성 |
| mcp-server-dev | build-mcpb | ✅ CONFIRM | productivity-pack | 세트 일관성 |
| playground | playground | ✅ CONFIRM | analysis-pack | 자립형 HTML 생성은 본인 트렌드 리포트 계열과 직결 |
| plugin-dev | plugin-structure | ✅ CONFIRM | productivity-pack | self-hosting 세트 (§3.6.3) |
| plugin-dev | skill-development | ✅ CONFIRM | productivity-pack | self-hosting 세트, skill-creator 대체 |
| plugin-dev | command-development | ✅ CONFIRM | productivity-pack | self-hosting 세트 |
| plugin-dev | agent-development | ✅ CONFIRM | productivity-pack | self-hosting 세트 |
| plugin-dev | hook-development | ✅ CONFIRM | productivity-pack | self-hosting 세트 |
| plugin-dev | mcp-integration | ✅ CONFIRM | productivity-pack | self-hosting 세트 |
| plugin-dev | plugin-settings | ✅ CONFIRM | productivity-pack | self-hosting 세트 |
| session-report | session-report | ✅ CONFIRM | analysis-pack | 세션 트랜스크립트 → HTML, 분석 파이프라인과 결 맞음 |

**Dropped (4):**
- `skill-creator/skill-creator` — §3.6.5 단일화 결정 (plugin-dev/skill-development로 흡수)
- `codex/codex-cli-runtime`, `codex/codex-result-handling`, `codex/gpt-5-4-prompting` — §3.6.3 codex 세트 외부 의존 확정

### A-2. Commands (11 + hookify `/help` = 12)

| 플러그인 | 명령어 | 라벨 | 팩 | 1줄 근거 |
|---|---|---|---|---|
| claude-md-management | `/revise-claude-md` | ✅ CONFIRM | productivity-pack | 세션 학습을 CLAUDE.md에 반영, 동기화 루틴의 핵심 |
| commit-commands | `/clean_gone` | ✅ CONFIRM | productivity-pack | 멀티 PC 브랜치 정리 (§3.6.5 gh CLI 편입) |
| commit-commands | `/commit` | ✅ CONFIRM | productivity-pack | git commit 자동 작성, 본인 상시 사용 |
| commit-commands | `/commit-push-pr` | ✅ CONFIRM | productivity-pack | PR 생성까지 일괄 |
| feature-dev | `/feature-dev` | ✅ CONFIRM | productivity-pack | 피처 개발 워크플로우 세트 |
| hookify | `/hookify` | ✅ CONFIRM | productivity-pack | 대화 → hook 생성 |
| hookify | `/configure` | ✅ CONFIRM | productivity-pack | 세트 일체 |
| hookify | `/list` | ✅ CONFIRM | productivity-pack | 세트 일체 |
| hookify | `/help` | ✅ CONFIRM | productivity-pack | 🟡 재평가 결과 — 세트 편입되므로 포함 (B 참조) |
| plugin-dev | `/create-plugin` | ✅ CONFIRM | productivity-pack | self-hosting 중핵 |
| pr-review-toolkit | `/review-pr` | ✅ CONFIRM | productivity-pack | §3.6.5 단일화 (code-review 제외) |

**Dropped (8):**
- `code-review/code-review` — §3.6.5 (pr-review-toolkit로 단일화)
- `codex/*` 7개(`adversarial-review, cancel, rescue, result, review, setup, status`) — §3.6.3 외부 의존. `docs/RECOMMENDED_PLUGINS.md`로 안내.

### A-3. Hooks (5)

| 플러그인 | 이벤트 | 런타임 | 라벨 | 팩 | 1줄 근거 |
|---|---|---|---|---|---|
| hookify | PreToolUse | Python3 | ✅ CONFIRM | productivity-pack | 세트 일체 |
| hookify | PostToolUse | Python3 | ✅ CONFIRM | productivity-pack | 세트 일체 |
| hookify | Stop | Python3 | ✅ CONFIRM | productivity-pack | 세트 일체 |
| hookify | UserPromptSubmit | Python3 | ✅ CONFIRM | productivity-pack | 세트 일체 |
| security-guidance | PreToolUse | Python3 | ✅ CONFIRM | productivity-pack | Edit/Write 시 보안 패턴 경고, 공개 리포 전환과 정합 |

**Dropped (3):** codex SessionStart/SessionEnd/Stop — §3.6.3 외부 의존.

### A-4. Agents (세트 의존, 13)

| 플러그인 | agent | 모델 | 라벨 | 팩 |
|---|---|---|---|---|
| feature-dev | code-architect | sonnet | ✅ CONFIRM | productivity-pack |
| feature-dev | code-explorer | sonnet | ✅ CONFIRM | productivity-pack |
| feature-dev | code-reviewer | sonnet | ✅ CONFIRM | productivity-pack |
| hookify | conversation-analyzer | inherit | ✅ CONFIRM | productivity-pack |
| plugin-dev | agent-creator | — | ✅ CONFIRM | productivity-pack |
| plugin-dev | plugin-validator | — | ✅ CONFIRM | productivity-pack |
| plugin-dev | skill-reviewer | — | ✅ CONFIRM | productivity-pack |
| pr-review-toolkit | code-reviewer | opus | ✅ CONFIRM | productivity-pack |
| pr-review-toolkit | code-simplifier | inherit | ✅ CONFIRM | productivity-pack |
| pr-review-toolkit | comment-analyzer | inherit | ✅ CONFIRM | productivity-pack |
| pr-review-toolkit | pr-test-analyzer | inherit | ✅ CONFIRM | productivity-pack |
| pr-review-toolkit | silent-failure-hunter | inherit | ✅ CONFIRM | productivity-pack |
| pr-review-toolkit | type-design-analyzer | inherit | ✅ CONFIRM | productivity-pack |

**Dropped (1):** `codex/codex-rescue` — codex 세트 외부 의존.

### A-5. MCP 서버

본 Phase에서 편입 확정된 MCP 서버 **없음**. 모든 🟡 후보는 B 섹션에서 Deferred.

---

## B. 🟡 재평가 결과

| 항목 | 판정 | 근거 |
|---|---|---|
| `frontend-design/frontend-design` (skill) | 📋 Deferred | 현재 프론트 작업 없음. 필요 시 재도입 (재평가 큐). |
| `/new-sdk-app` (agent-sdk-dev) | 📋 Deferred | Claude Agent SDK 앱 직접 개발 예정 없음. |
| `/hookify /help` (hookify) | ✅ CONFIRM | hookify 세트 편입 확정 → 세트 무결성 유지 위해 포함. A-2에 포함됨. |
| `/ralph-loop`, `/cancel-ralph`, ralph `/help` (ralph-loop) | ❌ Dropped | bash 의존 + 실험적. Windows 환경 포팅 가치 대비 낮음. |
| `explanatory-output-style SessionStart` | ❌ Dropped | bash, Windows 호환성 이슈 + 취향 훅. |
| `learning-output-style SessionStart` | ❌ Dropped | 동일. |
| `ralph-loop Stop` hook | ❌ Dropped | bash 의존, ralph-loop 세트 전체 Dropped와 일관. |
| `context7` MCP | 📋 Deferred | docs lookup 유용하나 당장 필수 아님. Upstash 호스팅 의존 있음. |
| `playwright` MCP | 📋 Deferred | 브라우저 자동화 필요 상황 생기면 도입. 토큰 불필요라 진입 비용은 낮음. |
| `serena` MCP | 📋 Deferred | uvx(python) 의존. semantic analysis 수요 발생 시. |

---

## C. 외부 의존 정보 수집 (Phase 3에서 파일화)

### C-1. codex

- **귀속 팩:** productivity-pack (`plugins/productivity-pack/.claude-plugin/recommends.json`)
- **RECOMMENDED_PLUGINS.md 초안 항목:**

```yaml
- name: codex
  marketplace: openai/codex-plugin-cc
  install_command: "/plugin marketplace add openai/codex-plugin-cc && /plugin install codex@openai-codex"
  reason: "/codex:review 일상 사용 + codex-rescue agent + 장문 작업 위임"
  required: false
  last_verified: 2026-04-23
  self_hosting_note: null
```

- **사유:** 14개 구성요소 세트(§3.6.1 기준 15개 근접), OpenAI 공식 유지보수, 본인 상시 사용. 편입 시 용량 비대화 + 자주 업데이트되는 외부 리포 추적 부담.

### C-2. github MCP

- **결정:** `recommends.json` 미포함 (Dropped as external dependency 후보).
- **사유:** §3.6.5에 따라 `commit-commands` + `gh` CLI가 편입됨. 본인 워크플로우에서 gh CLI로 PR 생성·조회 모두 충족. github MCP 추가는 중복.
- **재검토 조건:** 나중에 `gh`로 불가능한 GitHub 자동화 필요 시(예: 대량 이슈 bulk 처리) Phase 9 이후 재고.

### C-3. 파일화 시점 (결정)

**Phase 3 스캐폴드 시 `recommends.json` 도입 확정.**

- `plugins/productivity-pack/.claude-plugin/recommends.json` — codex 1개 엔트리로 출발
- `docs/RECOMMENDED_PLUGINS.md` — 사람이 읽기 좋은 동일 정보 병기
- `/productivity-pack:check-recommended` 명령어 — Phase 5에서 §4.6.2 로직으로 구현(§4.6.2 `${CLAUDE_PLUGIN_ROOT}` 경로 + `import.meta.url` fallback + `installed_plugins.json` 파싱)

**v1.4 §4.6.1의 "외부 의존 3개 누적 전엔 JSON 유예" 권고와의 관계:** 본 선택은 권고와 차이가 있으나, `/check-recommended` 명령어를 v0.1에 넣기로 결정했으므로 **기계 파싱 소스 필수**. v1.5 minor 패치 F 체크리스트에 "recommends 단일 소스 결정" 항목이 있어 거기서 정합성 문서화.

---

## D. game-design-pack 게이트

### D-1. 편입 가능 vendored 자산

없음. Phase 1 카탈로그에 game-design 도메인 플러그인 0개.

### D-2. 신규 작성 후보 재평가

후보 4종을 본인 작업 접점·범용도로 재심:

| 후보 | 판정 | 근거 |
|---|---|---|
| **draw.io 다이어그램 헬퍼** | ✅ 확정 (1개) | 다이어그램은 **범용** — 게임 기획 외에도 시스템 설계·워크플로우 전반에 쓰임. 본인 드로잉 작업 상시. |
| 범용 전투 밸런싱 체크리스트 | 📋 Deferred | 전투 밸런싱은 특정 장르 업무 특화. |
| 기획문서 템플릿 | 📋 Deferred | GDD·스펙 포맷은 팀/프로젝트별 색깔이 강해 범용성 낮음. |
| 레벨 디자인 리뷰 | 📋 Deferred | 현재 작업 접점 없음. |

### D-3. 게이트 판정 — **유예**

- **vendored 자산 0** + **신규 확정 1** = 합계 **1 < 2** → **`§2.3.1` 게이트 미달, 팩 유예**
- **처리:**
  - `plugins/game-design-pack/` 디렉토리 **생성하지 않음**
  - `marketplace.json` `plugins` 배열에 **미포함**
  - 초기 배포(v0.1.0)는 **analysis-pack + productivity-pack 2개 팩만**
- **draw.io 다이어그램 헬퍼 skill:** 재평가 큐에 등록. Phase 5 도중 **추가로 game-design 계열 skill 1개 이상 작성 의사 생길 때** 게이트 재판정. 단독으론 팩으로 승격 불가.
- **draw.io 단독 활용 경로:** 범용성이 높으므로 Phase 9 이후 **productivity-pack에 흡수**하는 선택지도 열려 있음 (설계 다이어그램 용도). Phase 5 착수 시점에 최종 결정.

---

## E. 라이선스 / THIRD_PARTY_NOTICES 초안

Phase 1 카탈로그에서 전수 **Apache-2.0** 확인. CONFIRM 대상 중 라이선스 이슈 없음.

### THIRD_PARTY_NOTICES.md 초안 항목 (Phase 4 Source Lock에서 값 확정)

| 플러그인 | 팩 | 원본 라이선스 | 버전/commit | 출처 URL |
|---|---|---|---|---|
| claude-code-setup | productivity-pack | Apache-2.0 | (Source Lock) | (Source Lock) |
| claude-md-management | productivity-pack | Apache-2.0 | — | — |
| hookify | productivity-pack | Apache-2.0 | — | — |
| mcp-server-dev | productivity-pack | Apache-2.0 | — | — |
| playground | analysis-pack | Apache-2.0 | — | — |
| plugin-dev | productivity-pack | Apache-2.0 | — | — |
| session-report | analysis-pack | Apache-2.0 | — | — |
| commit-commands | productivity-pack | Apache-2.0 | — | — |
| feature-dev | productivity-pack | Apache-2.0 | — | — |
| pr-review-toolkit | productivity-pack | Apache-2.0 | — | — |
| security-guidance | productivity-pack | Apache-2.0 | — | — |

---

## F. Phase 3 진입 전 해결 체크리스트 — **v1.5 minor 패치 완료 (2026-04-23)**

MASTER_PLAN v1.4 3차 Codex 리뷰 지적 7건 전부 `MASTER_PLAN_v1.5.md`에 반영 완료.

- [x] **§4.6.2 스키마 guard 강화** — `!data || typeof data !== 'object' || !data.plugins || typeof data.plugins !== 'object' || Array.isArray(data.plugins)` 적용
- [x] **§5 Phase 2 Exit Gate fixture 구체화** — fixture A/B/C 파일 트리·명령어·기대 출력 명시, 자동/인터랙티브 분리, 연기 허용 조건 명문화
- [x] **validate-plugins.ps1 시점 정리** — Phase 2 `Work/phase2-validate-plugins.ps1` 임시 → Phase 6 `scripts/validate-plugins.ps1` 승격 경로 §5에 반영
- [x] **recommends 단일 소스 결정** — Phase 2 결정 반영: `recommends.json`을 v0.1에 포함. "3개 이상 누적 시" 조건 삭제
- [x] **훅 재도입 조건 제거** — "3개 이상 누적 시" → "실제 pain report 있을 때"로 완화
- [x] **§7.2 포터빌리티 보강** — Phase 3 acceptance에 "fresh clone 또는 두 번째 PC에서 통과" 조건 추가
- [x] **§4.6.2 용어 정리** — "pseudo-implementation" → "reference implementation", "manual command logic" 명시

**v1.5 적용 후 다음 단계:** Phase 3 스캐폴드 착수.

---

## G. Phase 2 Exit Gate 실행 결과

### G-1. 환경변수 검증 (`${CLAUDE_PLUGIN_ROOT}`)

| 테스트 | 결과 | 상세 |
|---|---|---|
| 호스트 PowerShell에서 `$env:CLAUDE_PLUGIN_ROOT` | ❌ unset | 정상 — 이 env var은 Claude Code가 플러그인 내부 프로세스에만 주입하는 값. 호스트 셸에선 unset이 기대 동작. |
| 플러그인 컨텍스트(인터랙티브) 검증 | ⏳ 대기 | Claude Code 세션에서 `/plugin marketplace add ${CLAUDE_WORK_ROOT}\Work\phase2-fixtures\fixture-a-minimal` → `/plugin install hello@fixture-a` → hello skill 트리거하여 `echo $CLAUDE_PLUGIN_ROOT` 결과 관찰 필요. |

**판정:** 호스트 유효성만 봄 → Inconclusive. 인터랙티브 실행 결과가 unset이면 `import.meta.url` fallback이 §4.6.2대로 필수.

### G-2. 스키마 검증 (plugin.json)

자동 검증 스크립트 결과 (`Work/phase2-validate-plugins.ps1` 실행):

| 테스트 | 결과 | 상세 |
|---|---|---|
| Fixture A (minimal) | ✅ PASS | name + description 존재, unknown 필드 없음, JSON 파싱 정상. |
| Fixture B (recommends.json sibling) | ✅ PASS | plugin.json 스키마 자체는 영향 없음. `/plugin marketplace add` 로드 시 sibling 파일이 경고를 유발하는지는 인터랙티브 확인 필요. |
| Fixture C (unknown field `xyz_unknown`) | ✅ PASS (parse) | JSON 파싱은 관대하게 통과. 본 결과는 **"plugin.json이 unknown 필드를 거부하는지"**에 대한 답이 아님 — Claude Code `/plugin marketplace add`가 경고·오류를 내는지 인터랙티브 확인 필요. |

**인터랙티브 실행 절차 (사용자 수행):**

```
# Claude Code 세션에서:
/plugin marketplace add ${CLAUDE_WORK_ROOT}\Work\phase2-fixtures\fixture-a-minimal
/plugin install hello@fixture-a
# → hello skill 트리거해서 CLAUDE_PLUGIN_ROOT 출력 확인
/plugin uninstall hello@fixture-a
/plugin marketplace remove fixture-a

# Fixture B, C도 동일 반복

# 관찰 항목:
#  - A, B: 경고 없이 로드되어야 함
#  - C: "unknown field xyz_unknown" 경고/오류 기대
#  - 각 skill 실행에서 $CLAUDE_PLUGIN_ROOT 값 출력
```

### G-3. 최종 판정

**Conditional Go (인터랙티브 부분 연기)** 🟡

- **Go 조건 충족:**
  - 자동 스키마 검증 3/3 통과
  - fixture 3종 정상 생성·보존 (Phase 3 acceptance에서 재사용)
  - CONFIRM/Deferred/Dropped 라벨링 완료
  - game-design-pack 게이트 판정 완료 (유예)
  - 라이선스 이슈 0
- **연기 결정 근거:**
  - `/plugin marketplace add` 계열 슬래시 명령은 Claude Code CLI 인터랙티브 세션 내에서만 실행 가능 — 자동화 경로 없음
  - Phase 3 스캐폴드가 실제 `rwang-workbench` 리포를 `/plugin marketplace add [로컬경로]`로 등록하면서 **fixture A/B에 해당하는 검증을 자연스럽게 수행**
  - `${CLAUDE_PLUGIN_ROOT}` 여부는 Phase 5 `/check-recommended` 구현 착수 시 최초 확인 가능 — 그 결과를 보고 fallback 구현 범위 확정
- **Phase 3 acceptance에 흡수할 관찰 항목:**
  1. `${CLAUDE_PLUGIN_ROOT}` 플러그인 컨텍스트 set 여부 → unset이면 `import.meta.url` fallback 필수화 (v1.5 또는 Phase 5에서 반영)
  2. `recommends.json`이 sibling일 때 plugin.json 스키마 경고 유발 여부 (F 체크리스트에 이미 포함)
  3. unknown field 경고 여부는 **Phase 3에서 확인되지 않으면 별도 fixture C 테스트 Phase 5 이전 수동 실행**
- **v1.5 minor 패치 선행 필수:** F 체크리스트 7개 항목 반영 후 Phase 3 진입.

**다음 단계:** Phase 2 완료 선언 → v1.5 minor 패치 → Phase 3 스캐폴드 착수.

---

## 재평가 큐 (Appendix: Deferred 상세)

재평가 트리거를 명시. Phase 9 이후 해당 조건이 오면 재검토.

| 항목 | 재평가 트리거 |
|---|---|
| frontend-design skill | 본인 프로젝트 중 React/Vue 등 프론트 작업 착수 |
| /new-sdk-app | Claude Agent SDK 앱 직접 구축 계획 생김 |
| context7 MCP | 외부 lib docs lookup이 Claude Code 본체 지식보다 명백히 우세한 상황 누적 |
| playwright MCP | E2E 테스트·스크래핑·브라우저 자동화 실제 수요 |
| serena MCP | 큰 코드베이스 semantic search 필요 상황 |
| github MCP | gh CLI로 불가능한 자동화(bulk 이슈, Project 관리 등) 필요 |
| **draw.io 다이어그램 헬퍼 skill** (신규) | Phase 5에서 game-design 계열 skill 추가 의사 생김 → game-design-pack 재게이트 / 또는 productivity-pack 흡수 고려 |
| 범용 전투 밸런싱 체크리스트 | 해당 도메인 업무 재개 시 |
| 기획문서 템플릿 | 팀 작업·특정 프로젝트 합류 시 |
| 레벨 디자인 리뷰 | 레벨/스테이지 디자인 실작업 발생 시 |

---

## 확인 필요 항목

모든 Phase 2 판단 결정 완료 — 별도 대기 항목 없음.

### 결정 이력 (2026-04-23 세션)

1. **game-design-pack:** 유예 — 신규 확정 1개(draw.io 헬퍼)로 게이트 미달, 재평가 큐 이동.
2. **Exit Gate 인터랙티브:** 연기 — Phase 3 스캐폴드 acceptance에 흡수.
3. **recommends.json 도입:** Phase 3 스캐폴드 시 도입 확정, Phase 5에서 `/check-recommended` 구현.
4. **analysis-pack 배치:** 분리 유지 — 도메인 경계 우선, 본인 분석 자산 생태계 활발.

---

## 산출물 파일 경로

- 본 문서: `${CLAUDE_WORK_ROOT}\Work\workbench-selection-2026-04-23.md`
- Fixture 디렉토리: `${CLAUDE_WORK_ROOT}\Work\phase2-fixtures\fixture-{a-minimal,b-with-recommends,c-unknown-field}\`
- 자동 검증 스크립트: `${CLAUDE_WORK_ROOT}\Work\phase2-validate-plugins.ps1`
- Exit Gate 상세 보고(실패 시에만 생성 예정): `${CLAUDE_WORK_ROOT}\Work\phase2-exit-gate-report.md` — 현재 미작성 (자동 부분 PASS, 인터랙티브 대기)
