# Phase 5 실행 계획

> **역할**: Phase 5(본인 자산 흡수·신규 작성 + §4.6 v0.1 + Phase 4 이월 이슈 처리)의 단일 실행 계획서.
> **수명**: Phase 5 진행 중 참조. Phase 5 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: MASTER_PLAN v1.5 §5 Phase 5, §4.6 (v0.1 구현), §3.5 (Source Lock), [docs/CHANGELOG.md Unreleased](./CHANGELOG.md) (Python hook known-issue 이월), [phase4-plan.md §4 Risk #4](archive/phase4-plan.md).
> **개정 이력**:
> - 초안 (2026-04-23)
> - v1 (2026-04-23): Codex 1차 리뷰 9건 반영 (MAJOR 6 / MINOR 3)
> - v2 (2026-04-23): Codex 2차 리뷰 7건 반영 — Python fix를 A2 inline wrapper로 승급 등
> - v3 (2026-04-23): Codex 3차 리뷰 반영 — round 2 PARTIAL 4건 해소 + 신규 5건(V2-1~V2-5). 주요 변경: **A2에서 A1으로 회귀** (shell 가정 제거), README PREREQUISITES 신설, CHANGELOG 경로 정정, command doc env override 문서화 필수화, 5C G2 pre-step 질문 프로토콜 명시, fixture 구성 구체화.
> - v3.1 (2026-04-23): Codex 4차 리뷰 APPROVE with minor edits 반영 — §3.2에 MASTER §4.6.2 확장 문구, §3.3에 5C Sub-task 0 (질문지 실행 의무), README Prerequisites 배치 앵커("before `## Install`"), CHANGELOG line 18 기준 → "기존 Known issue 라인"으로 완화.

---

## 0. Scope

네 개의 독립 작업 스트림으로 구성.

| 스트림 | 범위 | 출처 |
|---|---|---|
| **A** | Phase 4 이월: Python hook 크로스 플랫폼 수정(A1) + README PREREQUISITES 신설 | Phase 4 Risk #4, §6.5 error 3건 |
| **B** | §4.6 v0.1: `/productivity-pack:check-recommended` 명령어 + `docs/RECOMMENDED_PLUGINS.md` 보강 + command doc env override 문서화 | MASTER_PLAN §4.6 |
| **C** | 본인 자산 신규 작성 (4개 후보 + G2 pre-step 질문 프로토콜) | MASTER_PLAN §5 Phase 5 |
| **D** | 마감: docs/CHANGELOG.md [Unreleased] Phase 5 블록, MASTER_PLAN §8 상태, 본 문서 `docs/archive/`로 이관 | Phase 4 마감 패턴 |

**범위 외:** `validate-plugins.ps1` (Phase 6), game-design-pack skill (유예), Skills ZIP (배포 후).

---

## 1. Ordering Rationale

**A → B → C → D 순서 고정**. (A: 노이즈 해소 우선 / B: 스펙 명확 / C: 가장 유동적 / D: 자동)

---

## 2. 배치

| 배치 | 내용 | 커밋 단위 |
|---|---|---|
| **Batch 5A** | `hooks.json` 5개 command + 7개 shebang `python3`→`python` (A1), §3.1.1 inline source-lock 표, `README.md` PREREQUISITES 섹션 신설, 로컬 재검증 | 1 커밋 |
| **Batch 5B** | `plugins/productivity-pack/scripts/check-recommended.mjs`, `commands/check-recommended.md`(env override 문서 포함), `docs/RECOMMENDED_PLUGINS.md` 보강, 10 cells 검증 | 1 커밋 |
| **Batch 5C** | G2 pre-step 질문 → 결정표 확정 → implement 자산 구현 | 결정표 + 자산당 1 커밋 |
| **Batch 5D** | `docs/CHANGELOG.md` [Unreleased] Phase 5 블록 + Known Issue 갱신, MASTER_PLAN §8, 본 문서 archive 이관 | 1 커밋 |

**승인 지점:**
- **G1** — Plan 최종 완성 (Codex 리뷰 모두 소화된 시점)
- **G2** — 5C 결정표 작성 완료 (**mandatory**)
- Batch 5A·5B·5D는 G1 후 자동

**Codex 리뷰 게이트:**
- 1차(초안) → v1 / 2차(v1) → v2 / 3차(v2) → v3 — 모두 CLOSED 시 G1
- 4차(5C 결정표 완성 시) — **mandatory**
- 배치 구현 리뷰는 per-asset optional

---

## 3. 배치별 세부

### 3.1 Batch 5A — Python hook 크로스 플랫폼 수정

**영향 범위:**

| 파일 | `python3` 언급 유형 |
|---|---|
| `plugins/productivity-pack/hooks/hooks.json` | 5개 `command` 필드 — **런타임 실제 호출** |
| `plugins/productivity-pack/hooks/*.py` × 5 | shebang — consistency-only (hooks.json이 인터프리터 지정) |
| `plugins/productivity-pack/core/*.py` × 2 | shebang — consistency-only |
| `commands/help.md`, `commands/hookify.md`, `skills/writing-rules/SKILL.md` | 사용자 문서 예시 — **수정 불필요** |

**채택: A1 (`python3` → `python` 단순 치환)** (Codex 3차 V2-2 반영 — A2 inline wrapper의 shell 가정 리스크 회피)

근거:
- hooks.json `command` 필드는 Claude Code hook runner가 어떤 셸로 해석하는지 문서화되어 있지 않음 → A2 inline `sh -c` 구문은 **검증되지 않은 가정**에 의존
- A1은 셸과 무관하게 단일 토큰 교체 → 알려진 제약(POSIX `python` 미존재 시 실패)만 보유
- 알려진 제약은 **README PREREQUISITES로 이전**해 투명화 (Codex 3차 V2-5 반영)
- POSIX `python` 미존재 환경에서 실패 시 대응은 Phase 9 pain report 기반 wrapper-file 방식 승급

**베이스라인 (새 README PREREQUISITES 섹션 — Sub-task 5에서 작성):**

- **Python**: `python` 명령이 Python 3.x를 가리켜야 함
  - Windows: 공식 Python installer로 설치하면 기본 충족 (`python`이 python3)
  - macOS (Homebrew `python@3.x`): 기본 충족 (`python` symlink)
  - Ubuntu 22.04+: `sudo apt install python-is-python3` 또는 수동 symlink
  - Ubuntu 20.04 이하 / 기타 `python` = python2 환경: Phase 5 범위 외 (Phase 9 wrapper 승급 후보)
- **Shell**: hook 실행을 위한 특수 shell 요구 없음 (A1은 단일 바이너리 호출)

**Sub-task:**
1. `hooks.json` 5개 `command` 필드 `python3 ${...}` → `python ${...}` 단순 치환
2. 5개 `hooks/*.py` shebang `python3` → `python` (consistency, 런타임 영향 없음)
3. 2개 `core/*.py` shebang 동일 처리
4. §3.1.1 inline source-lock 표 12행 채움 (아래)
5. **`README.md`에 `## Prerequisites` 섹션 신설** (Codex 3차 V2-5 반영, 4차 #3 배치 명시):
   - **배치 위치**: `## Install` 섹션 **직전**
   - Python 3.x on PATH as `python`
   - OS별 확인 명령
   - POSIX `python-is-python3` 설치 안내
6. 각 영향 파일 vendoring 헤더 `modified: none` → `modified: minor`
7. **검증 분리:**
   - **경로 A (런타임)**: Claude Code 재기동 + `/reload-plugins` → skill 트리거 → transcript grep `hook error: Python` 0건
   - **경로 B (직접 호출)**: hooks의 `.py`를 직접 호출하는 use case 없음 확인 → shebang 변경은 consistency-only로 §3.1.1 명기
8. 배치 커밋

**Exit:** 경로 A에서 Python hook error 3종 0건.

---

#### 3.1.1 Phase 5 Source-Lock Appendix (작성 대기)

Batch 5A 진행 시 채움. phase4-source-lock.md는 read-only 유지 (Codex 2차 N2).

| # | 파일 (:라인) | Before | After | 사유 | 런타임 영향 |
|---|---|---|---|---|---|
| 1 | `hooks/hooks.json:9` command | `python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py` | `python ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py` | Phase 4 Risk #4 fix | ✅ |
| 2 | `hooks/hooks.json:18` command | `python3 ${...}/hooks/security_reminder_hook.py` | `python ${...}/hooks/security_reminder_hook.py` | 동일 | ✅ |
| 3 | `hooks/hooks.json:29` command | `python3 ${...}/hooks/posttooluse.py` | `python ${...}/hooks/posttooluse.py` | 동일 | ✅ |
| 4 | `hooks/hooks.json:40` command | `python3 ${...}/hooks/stop.py` | `python ${...}/hooks/stop.py` | 동일 | ✅ |
| 5 | `hooks/hooks.json:51` command | `python3 ${...}/hooks/userpromptsubmit.py` | `python ${...}/hooks/userpromptsubmit.py` | 동일 | ✅ |
| 6 | `hooks/pretooluse.py:1` shebang | `#!/usr/bin/env python3` | `#!/usr/bin/env python` | consistency | ❌ |
| 7 | `hooks/security_reminder_hook.py:1` shebang | ↑ | ↑ | consistency | ❌ |
| 8 | `hooks/posttooluse.py:1` shebang | ↑ | ↑ | consistency | ❌ |
| 9 | `hooks/stop.py:1` shebang | ↑ | ↑ | consistency | ❌ |
| 10 | `hooks/userpromptsubmit.py:1` shebang | ↑ | ↑ | consistency | ❌ |
| 11 | `core/config_loader.py:1` shebang | ↑ | ↑ | consistency | ❌ |
| 12 | `core/rule_engine.py:1` shebang | ↑ | ↑ | consistency | ❌ |

**정책:** 본 appendix는 Batch 5A 커밋과 함께 확정. Phase 9 upstream 업데이트 시 Phase 5 변경의 단일 출처.

---

### 3.2 Batch 5B — §4.6 v0.1 구현

**산출물:**
- `plugins/productivity-pack/scripts/check-recommended.mjs` (신규 — pack-scoped `scripts/` 하위)
- `plugins/productivity-pack/commands/check-recommended.md` (신규 — Claude 지시 + **env override 문서 포함**, Codex 3차 V2-4 반영)
- `docs/RECOMMENDED_PLUGINS.md` 보강

**스크립트 설계 (env 오버라이드):**

```javascript
const INSTALL_LIST = process.env.RWANG_INSTALLED_PLUGINS_PATH
  || join(homedir(), '.claude', 'plugins', 'installed_plugins.json');
```

- Production: env 미설정 → 기본 경로 (§4.6.2 default)
- 검증: env 설정 → fixture 경로. **실 installed_plugins.json mutation 금지**

> **MASTER §4.6.2와 관계 (Codex 4차 #1 반영):** `RWANG_INSTALLED_PLUGINS_PATH` 오버라이드는 MASTER_PLAN v1.5 §4.6.2 reference implementation의 **Phase 5 testability 확장**. MASTER 본문은 reference-only로 유지 (기본 경로 하드코딩된 형태 보존). Phase 5 구현은 여기 env 분기를 얹음. Phase 9 pain report 있을 때 MASTER에 역반영 여부 재평가.

**command doc 필수 섹션 (Codex 3차 V2-4):**

`commands/check-recommended.md`에 다음 하위 섹션 **반드시 포함**:

```
## 환경변수 오버라이드 (INSTALLED_PLUGINS_PATH)

기본 동작: `~/.claude/plugins/installed_plugins.json`을 읽음.

검증·테스트 용도로 경로 오버라이드:
- Git Bash: `RWANG_INSTALLED_PLUGINS_PATH=/tmp/fixture.json /productivity-pack:check-recommended`
- PowerShell 5.1: `$env:RWANG_INSTALLED_PLUGINS_PATH = "C:\tmp\fixture.json"; /productivity-pack:check-recommended`

env 설정 시 실제 설치 목록은 읽지 않음.
```

**동작 흐름 (§4.6.2 기반):**
1. `${CLAUDE_PLUGIN_ROOT}` 기준 상위 탐색, `marketplace.json` 읽기
2. 팩별 `recommends.json` 읽기 (누락 허용)
3. `INSTALL_LIST` 파싱 → 설치 plugin 키 추출
4. 팩 × 권장 × 설치 여부 표 출력
5. 실패(`file-missing/parse-failed/unexpected-schema`) non-blocking 경고

**검증 매트릭스 (fixture 기반, Codex 3차 V2-3 반영):**

**사전 준비:** `plugins/productivity-pack/scripts/__tests__/` 아래 **4개 실 JSON 파일**:
- `installed-codex.json` — codex 엔트리 존재
- `installed-no-codex.json` — codex 없는 정상
- `bad-json.json` — `{bad json` (parse 실패 유발)
- `unexpected-schema.json` — `{"plugins": []}` (array로 스키마 위반)

**file-missing 케이스:** fixture 파일 **생성하지 않음**. env를 의도적으로 존재하지 않는 경로 문자열(`scripts/__tests__/does-not-exist.json`)로 설정해서 트리거.

| # | Fixture / env 값 | 기대 출력 | Git Bash | PowerShell 5.1 |
|---|---|---|---|---|
| 1 | `installed-codex.json` | 표 · `codex` / `✅` | 필수 | 필수 |
| 2 | `installed-no-codex.json` | 표 · `codex` / `❌` | 필수 | 필수 |
| 3 | `does-not-exist.json` (실재 X) | `💡 ... (사유: file-missing)` | 필수 | 필수 |
| 4 | `bad-json.json` | `💡 ... (사유: parse-failed)` | 필수 | 필수 |
| 5 | `unexpected-schema.json` | `💡 ... (사유: unexpected-schema)` | 필수 | 필수 |

총 **10 cells** 전부 통과. 실 `~/.claude/plugins/installed_plugins.json`은 **read도 안 함**.

**docs/RECOMMENDED_PLUGINS.md 보강:**
- [ ] 초기 설치 one-liner
- [ ] `/productivity-pack:check-recommended` 명령어 언급

**Sub-task:**
1. `scripts/check-recommended.mjs` 작성 (ESM, env override 포함)
2. `commands/check-recommended.md` 작성 (Claude 지시 + **env override 서브섹션 의무**)
3. `scripts/__tests__/` 4개 fixture JSON 작성
4. `docs/RECOMMENDED_PLUGINS.md` 보강 2항 반영
5. 10 cells 매트릭스 검증
6. 배치 커밋

**Exit:** 10 cells 전수 pass + command doc env override 서브섹션 존재 확인.

---

### 3.3 Batch 5C — 본인 자산 신규 작성

**5C 결정 용어 정의:**

| 결정 | 의미 | Phase |
|---|---|---|
| **implement** | 이번 Phase 5에서 구현·검증·커밋 | Phase 5 |
| **defer** | 범위 명확·필요성 인정, 일정·스코프 사유로 보류 | Phase 9 이후 재평가 |
| **drop** | 범위 검토 결과 불필요 또는 아키텍처적 부적합 | 영구 제외 |

**G2 pre-step 질문 프로토콜 (Codex 3차 V2-5 · N5 반영):**

Batch 5C 킥오프 시점에 Claude가 **4개 후보 각각에 대해 아래 질문지를 사용자에게 제시**. 사용자 응답 기반으로 rationale 초안 작성 → 사용자 검토·수정 → G2 승인.

**질문지 템플릿 (각 후보마다 개별 적용):**

```
[후보 C-X: <이름>]
Q1. 이 자산의 주 사용 빈도는? (매일 / 주 1–2회 / 월 수 회 / 특정 이벤트 시)
Q2. 지금 Phase 5에서 구현하면 어떤 작업이 즉시 개선되는가?
Q3. 연기 시 영향받는 다른 작업·Phase는?
Q4. 범위 재검토 결과 "불필요"로 판정될 수 있는 이유는?
```

- Q1·Q2 → implement 성향 평가
- Q3 → defer 정당화
- Q4 → drop 가능성 확인
- Claude가 4답을 종합해 rationale 초안(2–3줄) 작성, 사용자가 수정

---

**5C 결정표 (G2 승인 대상)**

Phase 5 exit은 **4행 전원이 결정 + rationale 기록**됐을 때만 가능.

| # | 후보 | 결정 | 대상 Phase | Rationale | 대상 팩 | 예상 파일 | 검증 방법 |
|---|---|---|---|---|---|---|---|
| C-1 | `/sync-to-git` (본인 래퍼·동기화) | TBD | Phase 5 or 9+ | TBD (G2 pre-step 후 채움) | productivity | TBD | TBD |
| C-2 | Git pre-commit hook | TBD | Phase 5 or 9+ | TBD | productivity | TBD | TBD |
| C-3 | draw.io MCP 번들 | TBD | Phase 5 or 9+ | TBD | §MCP 버킷 | TBD | TBD |
| C-4 | GCP MCP 번들 | TBD | Phase 5 or 9+ | TBD | §MCP 버킷 | TBD | TBD |

**MCP 버킷 규칙:**

| 유형 | 위치 | 예시 |
|---|---|---|
| 팩 소유 MCP 서버 | 해당 팩의 `.mcp.json` + docs/env 예시 | draw.io, GCP |
| 외부 Claude 플러그인 (권장만) | `recommends.json` + `docs/RECOMMENDED_PLUGINS.md` | codex |
| 설치 가이드만 | docs only | 일회성 도구 |

draw.io·GCP는 `.mcp.json` 후보. auth 노출 위험 → 5C 검증에 **`.mcp.json` 시크릿 수동 grep 필수**.

**`/sync-to-git` mini-spec (C-1 implement 시 의무, 9항):**

```
source:           (예: ~/.claude/)
destination:      (예: git@github.com:rwang2gun/ClaudeMD.git main)
allowed paths:    whitelist
excluded paths:   blacklist (secrets, local caches)
direction:        push-only / pull-only / bidirectional
conflict policy:  local wins / remote wins / prompt
dry-run default:  true
auth assumption:  gh CLI / ssh key / PAT env var
secrets exclusion:  .env, *.pat, tokens, credentials 글로브
```

**Sub-task 0 — G2 질문지 실행 (mandatory, Codex 4차 #2 반영):**

5C 착수 직후 다른 Sub-task 진입 전에:
1. Claude가 4개 후보(C-1~C-4) 각각에 대해 위 질문지 4문항 사용자에게 제시
2. 사용자 답변 기반 rationale 초안 작성 (2–3줄)
3. 사용자 검토·수정 → 결정표 4행 전수 TBD 해소
4. **G2 승인 요청** → 통과 시 implement 결정 항목의 Sub-task 1 진입 가능

결정표가 완성되지 않은 상태에서 Sub-task 1 진입 금지.

**Sub-task 1+ (implement 결정 항목당 반복):**
1. 스펙 확정 (mini-spec 또는 해당 자산 스펙)
2. 파일 작성 (신규 작성은 vendoring 헤더 불필요)
3. 로컬 검증 + `.mcp.json` 시크릿 수동 grep 0건
4. 개별 커밋

**Exit (각 항목):** 스펙대로 동작 + 시크릿 0건.

---

### 3.4 Batch 5D — 마감

**Sub-task:**
1. `docs/CHANGELOG.md` `[Unreleased]` 아래 Phase 5 블록 추가 (Codex 3차 V2-1 경로 정정):
   - `Phase 5 — YYYY-MM-DD`
   - `Python hook cross-platform fix: A1 (python3 → python) across 12 files`
   - `README Prerequisites section added`
   - `§4.6 v0.1: /productivity-pack:check-recommended (scripts/check-recommended.mjs + commands/check-recommended.md incl. env override) + RECOMMENDED_PLUGINS.md polish`
   - `Self-authored (5C implement): <목록>` / `Deferred: <목록>` / `Dropped: <목록>`
   - `docs/CHANGELOG.md` 기존 Python hook Known Issue 라인을 "Resolved in Phase 5"로 갱신 (line 번호 참조 대신 **기존 Known issue 라인**을 탐색해 교체 — Codex 4차 #4 반영)
2. `MASTER_PLAN_v1.5.md` §8 상태 라인 추가
3. `phase5-plan.md` → `docs/archive/` (§3.1.1 source-lock appendix 포함)
4. 마감 커밋

---

## 4. 리스크 & 대응

| # | 리스크 | 대응 |
|---|---|---|
| 1 | A1이 Ubuntu 20.04 이하·python3 미존재 환경에서 실패 | README PREREQUISITES가 baseline 명시. pain report 시 Phase 9 wrapper 방식 승급 |
| 2 | source-lock appendix(§3.1.1) 누락 | 5A-4에서 전수, 커밋 전 diff 확인 |
| 3 | `check-recommended.mjs`의 `${CLAUDE_PLUGIN_ROOT}` 미존재 환경 | §4.6.2 fallback (`import.meta.url`) 구현 |
| 4 | fixture 스키마 드리프트 | §4.6.2 reference implementation과 fixture 구조 동기. Phase 9 이후 재확인 |
| 5 | 5C `.mcp.json` 시크릿 스캔 도구 부재 | 수동 grep + gitleaks(있으면) |
| 6 | 5C rationale TBD로 G2 직전까지 남음 | G2 pre-step 질문 프로토콜이 선행 해소 |
| 7 | A1 적용 후 다른 숨겨진 hook 문제 노출 (예: .py 자체 버그) | 5A-7 경로 A에서 error grep. Python hook error 외 패턴 발견 시 별도 티켓 분리 |

---

## 5. 검증 접근

- **5A**: 경로 A(런타임 transcript 0 error) + 경로 B(직접 호출 없음 확인) + §3.1.1 표 12행 + README PREREQUISITES 렌더링 확인
- **5B**: 10 cells 매트릭스, 실 `installed_plugins.json` 무변경, command doc env override 서브섹션 존재 확인
- **5C**: 각 implement 자산 스펙별 수동 테스트 + `.mcp.json` 시크릿 grep
- **5D**: 문서 diff + `docs/CHANGELOG.md` Known Issue 라인 갱신 확인

**공통:** `validate-plugins.ps1` 부재 → 신규·수정 파일 수동 grep으로 개인정보·경로·시크릿 0건 (Phase 6에서 자동화).

---

## 6. Exit Criteria

### 6.1 Phase 5 자체
- [ ] Batch 5A — 경로 A transcript Python hook error 0건, §3.1.1 표 12행 완성, `README.md`에 Prerequisites 섹션 존재
- [ ] Batch 5B — 10 cells pass, fixture 외 파일 mutation 0건, command doc env override 서브섹션 존재
- [ ] Batch 5C — 결정표 4행 전부 implement/defer/drop + rationale 채움. implement 항목 구현·검증 완료
- [ ] 모든 신규 작성 파일에 개인정보·절대경로·하드코딩·시크릿 0건

### 6.2 §4.6 v0.1 충족
- [ ] `docs/RECOMMENDED_PLUGINS.md` §4.6.1 요건 + 2개 보강 항목
- [ ] `plugins/productivity-pack/.claude-plugin/recommends.json` 구조 확인
- [ ] `/productivity-pack:check-recommended` 10 cells 동작 + env override 문서화

### 6.3 Phase 4 이월 이슈 종결
- [ ] `docs/CHANGELOG.md` [Unreleased] Python hook Known Issue 라인 "Resolved in Phase 5"로 갱신
- [ ] §3.1.1 source-lock appendix 12행 완성 (본 문서 내, 5D에서 archive 함께 이관, `docs/archive/phase4-source-lock.md`는 read-only 유지)

### 6.4 문서 마감
- [ ] `MASTER_PLAN_v1.5.md` §8 상태 라인 업데이트
- [ ] `docs/CHANGELOG.md` [Unreleased] Phase 5 블록 추가
- [ ] `phase5-plan.md` → `docs/archive/`

---

## 7. 확정된 결정사항 (변경 불가)

- 스트림 순서: **A → B → C → D** 고정
- 커밋 단위: **배치당 1 커밋** (5C는 자산당 1 커밋)
- 승인 지점: **G1 + G2 mandatory**
- Codex 리뷰 게이트: **1차·2차·3차(+v3)·4차(5C)** — 4차 mandatory
- Python hook 수정: **A1 (`python3` → `python`)**. POSIX baseline은 README PREREQUISITES로 문서화. wrapper-file 승급은 Phase 9 pain report 이후
- `/check-recommended` 구조: **`commands/check-recommended.md`** (지시 + env override 서브섹션) + **`scripts/check-recommended.mjs`** (실행 스크립트)
- `check-recommended.mjs`는 `RWANG_INSTALLED_PLUGINS_PATH` env 오버라이드 지원. command doc에도 기재 의무
- MCP 버킷 규칙: **팩 소유 → `.mcp.json` / 외부 플러그인 → `recommends.json`**
- Phase 5 source-lock: **본 문서 §3.1.1 inline 표** (phase4-source-lock.md read-only)
- 5C 결정어: implement / defer / drop. G2 pre-step 질문 프로토콜로 rationale 초안 작성 → 사용자 확정
- `validate-plugins.ps1` 작성: **Phase 6 몫**

---

## 8. Codex 리뷰 반영 로그

### 8.1 1차 리뷰 (2026-04-23) — CLOSED (9건 반영 → v1)

Verdict: **GO with modifications**.

| # | Codex 지적 | 심각도 | 반영 위치 |
|---|---|---|---|
| 1 | A1 "변경 불가" 고정 | MAJOR | §3.1 (v1 A1 완화 → v2 A2 → v3 A1+baseline) |
| 2 | shebang 변경과 hooks.json 경로 무관 | MINOR | §3.1 Sub-task 7 경로 A/B 분리 |
| 3 | `modified: minor`만으론 감사 추적 약함 | MINOR | §3.1.1 per-file 12행 표 |
| 4 | 5B 검증이 file-missing만 커버 | MAJOR | §3.2 5케이스 × 2셸 매트릭스 |
| 5 | `node -e` + ESM 셸 프래질 | MAJOR | §3.2 번들 `.mjs` + `.md` 지시 |
| 6 | 5C 결정표 없음, exit 축소 가능 | MAJOR | §3.3 결정표 의무 + exit 4행 처리 요건 |
| 7 | MCP 버킷 모호 | MAJOR | §3.3 MCP 버킷 규칙 표 |
| 8 | `/sync-to-git` 미명세 | MAJOR | §3.3 mini-spec 9항 |
| 9 | 5C scope review optional | MINOR | §2 Codex 4차 mandatory |

### 8.2 2차 리뷰 (2026-04-23) — CLOSED (7건 반영 → v2 / 일부는 v3까지 이어짐)

Verdict: **NEEDS v2 round**.

| # | 지적 | 심각도 | 반영 |
|---|---|---|---|
| round-1 #1 잔존 | A2' validator 미지정 | MAJOR | v2 A2 inline → v3 A1+baseline로 최종 해소 |
| round-1 #3 잔존 | archive 수정 | MAJOR | v2 §3.1.1 inline으로 해소 |
| N1 | cross-platform validator | MAJOR | v3 A1+baseline 해소 |
| N2 | archived 문서 mutation | MAJOR | v2 inline 해소 |
| N3 | `.mjs` under `commands/` | MAJOR | v2 `scripts/` 이동 해소 |
| N4 | 실 `installed_plugins.json` mutation | MAJOR | v2 env override → v3 command doc 문서화 의무 추가 |
| N5 | 5C rationale 주체·semantics | MINOR | v2 정의 → v3 G2 pre-step 질문 프로토콜 추가 |

### 8.3 3차 리뷰 (2026-04-23) — CLOSED (5건 반영 → v3)

Verdict: **NEEDS v3 round**.

**Round 2 PARTIAL:**

| # | 잔존 지적 | 반영 |
|---|---|---|
| round-1 #1 / N1 잔존 | A2 shell 가정 미검증 | §3.1 A1 회귀 + README PREREQUISITES 신설 |
| N4 잔존 | command doc에 env override 미기록 | §3.2 command doc 필수 서브섹션 |
| N5 잔존 | G2 pre-step 질문 구체성 | §3.3 질문 프로토콜 4문항 |

**Round 3 신규:**

| # | Codex 지적 | 심각도 | 반영 위치 |
|---|---|---|---|
| V2-1 | CHANGELOG 경로 오기 (`CHANGELOG.md` vs `docs/CHANGELOG.md`) | MAJOR | 헤더 링크 + 본문 전수 정정 |
| V2-2 | A2 shell assumption 미검증 | MAJOR | §3.1 A1 회귀 |
| V2-3 | fixture-missing 구성 모호 | MINOR | §3.2 4개 real fixture + 1개 nonexistent path 명시 |
| V2-4 | command doc env override 문서화 누락 | MAJOR | §3.2 command doc 필수 서브섹션 |
| V2-5 | Public baseline 미문서화 | ADVISORY | §3.1 Sub-task 5 `README.md` Prerequisites 신설 |

### 8.4 4차 리뷰 (2026-04-23) — CLOSED (4건 반영 → v3.1)

Verdict: **APPROVE with minor edits**.

| # | Codex 지적 | 심각도 | 반영 위치 |
|---|---|---|---|
| 1 | env override MASTER 관계 불명 | MINOR | §3.2 "MASTER §4.6.2와 관계" 블록 추가 (testability 확장 명시) |
| 2 | G2 질문지 실행 시점 암묵적 | MINOR | §3.3 Sub-task 0 mandatory 추가 (Sub-task 1 진입 전 필수) |
| 3 | README Prerequisites 배치 불명 | ADVISORY | §3.1 Sub-task 5에 "before `## Install`" 앵커 |
| 4 | CHANGELOG line 18 참조 brittle | ADVISORY | §3.4에서 라인 번호 대신 "기존 Known issue 라인 탐색" |

Codex 리뷰 사이클 **모두 CLOSED**. G1 승인만 남음.

---

## 9. 실행 대기 중

**현재 상태**: v3.1 완성. Codex 4차 리뷰 APPROVE, 4건 반영 완료.

**다음 액션**:
1. 사용자 **G1 승인 요청**
2. G1 통과 → Batch 5A 시작
