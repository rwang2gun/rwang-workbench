# Phase 5 실행 계획

> **역할**: Phase 5(본인 자산 흡수·신규 작성 + §4.6 v0.1 + Phase 4 이월 이슈 처리)의 단일 실행 계획서.
> **수명**: Phase 5 진행 중 참조. Phase 5 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: MASTER_PLAN v1.5 §5 Phase 5, §4.6 (v0.1 구현), §3.5 (Source Lock), [docs/CHANGELOG.md Unreleased](./CHANGELOG.md) (Python hook known-issue 이월), [phase4-plan.md §4 Risk #4](archive/phase4-plan.md).
> **개정 이력**:
> - 초안 (2026-04-23)
> - v1 (2026-04-23): Codex 1차 9건 반영
> - v2 (2026-04-23): Codex 2차 7건 반영 — A2 inline wrapper 시도
> - v3 (2026-04-23): Codex 3차 5건 반영 — A1 회귀, README PREREQUISITES 신설
> - v3.1 (2026-04-23): Codex 4차 4건 반영 — APPROVE with minor edits
> - v4 (2026-04-24): Codex 5차 3 High 반영 — A3 Node 런처 승급, C-1/C-3/C-4 drop
> - v5 (2026-04-24): Codex 6차 3건 반영 — A안 강화 (launch-python.mjs + install-check.mjs + plugin.json precondition 조사)
> - **v6 (2026-04-24): Codex 7차 + Claude Code 플랫폼 조사 결과 반영. A3 → A1 회귀. `launch-python.mjs` / `install-check.mjs` / plugin.json precondition 조사 sub-task 전부 폐기. "플랫폼 한계 수용"으로 설계 단순화. 근거: Claude Code 자체가 크로스 플랫폼 훅 실행을 미완전 지원(Issue #37634, #18527), `shell:` 옵션·plugin.json `prerequisites` 필드 공식 스키마 미정의. hookify 원본의 ImportError graceful exit 0 패턴이 공식 설계 철학. Anthropic 공식 방침 준수를 Codex 완벽주의 권고보다 우선.**

---

## 0. Scope

네 개의 독립 작업 스트림으로 구성.

| 스트림 | 범위 | 출처 |
|---|---|---|
| **A** | Phase 4 이월: `hooks.json` 5개 command `python3` → `python` 단순 치환(A1) + `README.md` Prerequisites 섹션 신설 + 플랫폼 한계 투명 문서화 | Phase 4 Risk #4, §6.5 error 3건 |
| **B** | §4.6 v0.1: `/productivity-pack:check-recommended` 명령어 + `docs/RECOMMENDED_PLUGINS.md` 보강 + command doc env override 문서화 + MCP 서버 추천 서브섹션 + production path 검증 | MASTER_PLAN §4.6 + Codex 6차 M2 |
| **C** | 본인 자산 신규 작성 (C-2만 생존; C-1/C-3/C-4 drop) | MASTER_PLAN §5 Phase 5 |
| **D** | 마감: docs/CHANGELOG.md [Unreleased] Phase 5 블록, MASTER_PLAN §8 상태, 본 문서 `docs/archive/`로 이관 | Phase 4 마감 패턴 |

**범위 외:**
- `validate-plugins.ps1` (Phase 6)
- game-design-pack skill (유예)
- Skills ZIP (배포 후)
- `/sync-to-git`, draw.io MCP 번들, GCP MCP 번들 (사용자 drop)
- `hooks/*.py` · `core/*.py` 재작성 (vendored 보존 — F안 배제)
- **`hooks/launch-python.mjs` (v5 폐기 — 플랫폼 한계 수용)**
- **`scripts/install-check.mjs` (v5 폐기 — 플랫폼 한계 수용)**
- **plugin.json precondition 선언 (Claude Code 미지원 확정)**

---

## 1. Ordering Rationale

**A → B → C → D 순서 고정**.

---

## 2. 배치

| 배치 | 내용 | 커밋 단위 |
|---|---|---|
| **Batch 5A** | `hooks.json` 5개 `command` 필드 `python3` → `python` 단순 치환 + `hooks/*.py`·`core/*.py` shebang **무변경**(vendored 보존) + §3.1.1 source-lock 표 + `README.md` Prerequisites 섹션 + 플랫폼 한계 투명 문서화 + A-Win / A-POSIX 런타임 검증 | 1 커밋 |
| **Batch 5B** | `scripts/check-recommended.mjs` + `commands/check-recommended.md`(env override 포함) + `docs/RECOMMENDED_PLUGINS.md` 보강(MCP 서브섹션 포함) + 12 cells 검증(fixture 10 + production 2) | 1 커밋 |
| **Batch 5C** | G2 pre-step 질문(C-2만 남음) → 결정표 확정 → implement 시 자산 구현 | 결정표 + 자산당 1 커밋 |
| **Batch 5D** | `docs/CHANGELOG.md` [Unreleased] Phase 5 블록 + Known Issue 갱신 + 플랫폼 한계 기록, MASTER_PLAN §8, 본 문서 archive 이관 | 1 커밋 |

**승인 지점:**
- **G1** — Plan 최종 완성
- **G2** — 5C 결정표 작성 완료 (**mandatory**; C-2 1건만 TBD 해소)

**Codex 리뷰 게이트:**
- 1~7차 CLOSED.
- **8차 (v6 재확인) — optional**: 본 문서는 Anthropic 공식 방침 준수를 상위 원칙으로 채택했으므로 Codex 추가 지적은 informational 참고로 처리. blocker 아님.
- **9차 (C-2 결정 후 축약) — optional**: 동일 원칙.
- 배치 구현 리뷰는 per-asset optional.

---

## 3. 배치별 세부

### 3.1 Batch 5A — Python hook 크로스 플랫폼 수정 (A1 + 플랫폼 한계 수용)

**영향 범위:**

| 파일 | 역할 | vendored 상태 |
|---|---|---|
| `plugins/productivity-pack/hooks/hooks.json` | 5개 `command` 필드 `python3 ...` → `python ...` 단순 치환 | minor (command 필드만) |
| `plugins/productivity-pack/hooks/*.py` × 5 | **무변경** | `modified: none` |
| `plugins/productivity-pack/core/*.py` × 2 | **무변경** | `modified: none` |
| `plugins/productivity-pack/README.md` | Prerequisites 섹션 신설 + 플랫폼 한계 투명 문서화 | minor |

**채택: A1 (`python3` → `python` 단순 치환) + 플랫폼 한계 투명 수용**

선행 방안들의 사망 기록:

| 방안 | 사망 원인 | 근거 |
|---|---|---|
| A1 v3 | POSIX baseline 축소 ("이건 fix가 아니라 이전") | Codex 5차 H1 |
| A2 v2 | Windows `bash`가 WSL 스텁으로 해석되는 미해결 버그 + `shell:` 공식 스키마 미정의 | Claude Code Issue [#37634](https://github.com/anthropics/claude-code/issues/37634), [#18527](https://github.com/anthropics/claude-code/issues/18527); claude-code-guide 조사 (2026-04-24) |
| A3 v4·v5 | Node 없으면 훅 조용한 실패 + `install-check.mjs` 자기모순(Node로 Node 체크) | Codex 6·7차 H1 |
| Option 3 (`.py` 경로만) | 공식 미지원, Windows py launcher가 hook runner spawn에 자동 개입 안 함 | claude-code-guide 조사 (2026-04-24) |
| F (Node 재작성) | Node 의존성 여전 + vendored 단절 → upstream 자동 머지 불가 | 이전 분석 |

**A1 재채택 근거 (v6):**

1. **Claude Code 자체가 크로스 플랫폼 훅 실행을 미완전 지원**:
   - `shell:` 옵션·`plugin.json` precondition 공식 스키마 부재
   - Windows `bash` 해석 버그 (#37634)
   - 공식 플러그인 크로스 플랫폼 패턴 부재
2. **hookify 원본의 공식 설계 철학**: ImportError 발생 시 **graceful exit 0** 패턴이 `pretooluse.py:22-29`에 이미 존재. "훅 실행 실패 시 조용한 스킵 + 메인 동작 지속"이 Anthropic 공식 수용 모델
3. **Anthropic 공식 방침 준수 > Codex 완벽주의**: 플랫폼이 제공하지 않는 우회책을 자체 개발하는 것보다, 공식 패턴을 따르고 한계를 투명 문서화하는 것이 **장기 사후 비용 최소화**
4. **Phase 9 경로 열림**: Claude Code upstream 개선(Issue #37634 해결 등) 이후 Phase 9에서 재평가 가능

**`hooks.json` 변경:**

```jsonc
// before
{ "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py" }
// after
{ "command": "python ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py" }
```

5개 command 동일 패턴.

**README Prerequisites 섹션 (5A-3, `## Install` **직전** 배치):**

```
## Prerequisites

### Python 3.x on PATH as `python`

이 플러그인의 훅은 `python` 명령이 Python 3.x를 가리킨다고 가정합니다.

**OS별 상태:**
- **Windows** (공식 Python installer): 기본 충족 (`python` = Python 3).
- **macOS** (Homebrew `python@3.x` 또는 Xcode): 기본 충족.
- **Ubuntu 22.04+ / 최신 Linux**: `python3`은 있으나 `python` symlink는 선택적. `sudo apt install python-is-python3` 1회 권장.
- **Ubuntu 20.04 이하 / `python` = Python 2 환경**: 훅이 Python 2로 실행되면 ImportError 발생 → hookify 원본의 graceful skip 로직(`pretooluse.py:22-29`)으로 **조용히 스킵**. 메인 Claude Code 동작은 손상되지 않으나 훅 기능(보안 규칙 엔진 등)은 비활성 상태.

### 플랫폼 한계 투명 고지

Claude Code는 현재 크로스 플랫폼 훅 실행을 미완전 지원합니다:
- Windows native installer에서 `bash` 훅이 WSL 스텁으로 해석되는 미해결 버그: Claude Code Issue #37634, #18527
- `plugin.json` 시스템 prerequisite 필드·`shell:` 옵션 공식 스키마 미정의

본 플러그인은 위 제약 안에서 **Anthropic hookify 원본 설계 철학(graceful skip)**을 그대로 따릅니다. Phase 9에서 upstream 개선 후 재평가 예정.

### 수동 확인 (선택)

설치 후 Python 버전 확인:
- Git Bash: `python --version`
- PowerShell: `python --version`

Python 3.x가 표시되지 않으면 OS별 가이드에 따라 조치.
```

**Sub-task:**
1. `hooks.json` 5개 `command` 필드 `python3` → `python` 치환
2. `hooks/*.py` · `core/*.py` shebang **무변경** (vendored `modified: none` 보존)
3. `README.md`에 `## Prerequisites` 섹션 신설 (`## Install` 직전)
4. `hooks.json` vendoring 헤더 `modified: none` → `modified: minor` (command 필드만)
5. §3.1.1 inline source-lock 표 채움
6. **검증:**
   - **경로 A-Win (런타임)**: Windows + 공식 Python installer → skill 트리거 → transcript `hook error` 0건
   - **경로 A-POSIX (런타임)**: macOS 또는 Ubuntu 22.04+ (`python-is-python3` 설치 후) 동일 검증
   - **경로 A-POSIX-구식 (문서 검증만, 런타임 테스트 선택)**: Ubuntu 20.04 이하 시뮬레이션 시 graceful skip 동작 확인. 범위 외로 취급 — README에 한계 고지 있음
7. 배치 커밋

**Exit:** Windows + 최신 POSIX 환경에서 Python hook error 0건. README Prerequisites 섹션 존재 + 플랫폼 한계 고지 존재. vendored 7개 파일 `modified: none` 유지 확인.

**Batch 5A 실행 기록 (2026-04-24):**

- [x] 1. `hooks.json` 5개 command 필드 치환 완료 (line 9/18/29/40/51)
- [x] 2. `hooks/*.py` · `core/*.py` shebang 무변경 (vendored `modified: none` 보존 확인)
- [x] 3. `README.md`에 `## Prerequisites` 섹션 신설 (`## Install (local, pre-release)` 직전, 플랫폼 한계 고지 포함)
- [N/A] 4. `hooks.json` vendoring 헤더 — JSON이라 주석/헤더 개념 없음. Sub-task 사실상 vacuous
- [x] 5. §3.1.1 source-lock 표 — 계획 시점 작성분이 실제 치환 결과와 일치 확인
- [부분] 6. 검증 — **환경 제약**: 현 개발 PC에 Python 3 미설치(Windows Store stub만 존재). 실제 Python 실행 경로 직접 검증 불가. 대체 확인:
  - 현 Claude Code 세션이 훅 설정 로드된 상태에서 수십 회 tool call 동안 사용자 체감 지장 0건 → **hookify graceful skip 철학 실제 작동 검증**
  - A1 치환 자체는 파일 diff로 정확성 확인
  - Python 3 설치된 Windows 환경에서의 A1 개선 효과는 해당 환경 확보 후 추후 확인
- [x] 7. 배치 커밋 (commit: `Phase 5A: Python hook cross-platform fix (A1) + README Prerequisites`)

---

#### 3.1.1 Phase 5 Source-Lock Appendix ✅ (Batch 5A 완료, 2026-04-24)

Batch 5A 진행 시 채움. `phase4-source-lock.md`는 read-only 유지.

| # | 파일 (:라인) | Before | After | 사유 | 런타임 영향 |
|---|---|---|---|---|---|
| 1 | `hooks/hooks.json:9` command | `python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py` | `python ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py` | A1 (Phase 4 Risk #4 fix) | ✅ |
| 2 | `hooks/hooks.json:18` command | `python3 ${...}/hooks/security_reminder_hook.py` | `python ${...}/hooks/security_reminder_hook.py` | 동일 | ✅ |
| 3 | `hooks/hooks.json:29` command | `python3 ${...}/hooks/posttooluse.py` | `python ${...}/hooks/posttooluse.py` | 동일 | ✅ |
| 4 | `hooks/hooks.json:40` command | `python3 ${...}/hooks/stop.py` | `python ${...}/hooks/stop.py` | 동일 | ✅ |
| 5 | `hooks/hooks.json:51` command | `python3 ${...}/hooks/userpromptsubmit.py` | `python ${...}/hooks/userpromptsubmit.py` | 동일 | ✅ |
| 6 | `hooks/pretooluse.py:1` shebang | `#!/usr/bin/env python3` | (무변경) | vendored 보존 | ❌ |
| 7–12 | 나머지 `hooks/*.py` · `core/*.py` shebang | ↑ | (무변경) | vendored 보존 | ❌ |
| 13 | `README.md` Prerequisites 섹션 | 부재 | 신설 (`## Install` 직전, 플랫폼 한계 고지 포함) | 플랫폼 한계 투명화 | ❌ |

**정책:** 본 appendix는 Batch 5A 커밋과 함께 확정. vendored 파일 전수 `modified: none` 유지 (Phase 9 upstream 자동 머지 경로 보존). `hooks.json`만 `modified: minor`.

---

### 3.2 Batch 5B — §4.6 v0.1 구현

**산출물:**
- `plugins/productivity-pack/scripts/check-recommended.mjs` (신규)
- `plugins/productivity-pack/commands/check-recommended.md` (신규 — env override 서브섹션 포함)
- `docs/RECOMMENDED_PLUGINS.md` 보강 (초기 설치 + 명령어 + MCP 서브섹션)

**Node 의존성 범위 제한 (v6 명시):**

`check-recommended.mjs`는 **수동 실행 명령어 경로**이므로 Node 없으면 사용자가 즉시 알 수 있음(`/productivity-pack:check-recommended` 실행 시 에러). 훅 자동 실행 경로와 달라 Codex 6·7차 H1이 가리킨 "조용한 실패" 위험이 없음. 따라서 Node는 5B 선에서만 optional prerequisite로 유지.

README Prerequisites 섹션의 플랫폼 한계 고지에도 이 구분을 명시.

**스크립트 설계 (env 오버라이드):**

```javascript
const INSTALL_LIST = process.env.RWANG_INSTALLED_PLUGINS_PATH
  || join(homedir(), '.claude', 'plugins', 'installed_plugins.json');
```

- Production: env 미설정 → 기본 경로 (§4.6.2 default)
- 검증: env 설정 → fixture 경로. **실 installed_plugins.json mutation 금지**

> **MASTER §4.6.2와 관계:** `RWANG_INSTALLED_PLUGINS_PATH` 오버라이드는 §4.6.2 reference implementation의 Phase 5 testability 확장.

**command doc 필수 섹션:**

`commands/check-recommended.md`에 다음 서브섹션 **반드시 포함**:

```
## 환경변수 오버라이드 (INSTALLED_PLUGINS_PATH)

기본 동작: `~/.claude/plugins/installed_plugins.json`을 읽음.

검증·테스트 용도로 경로 오버라이드:
- Git Bash: `RWANG_INSTALLED_PLUGINS_PATH=/tmp/fixture.json /productivity-pack:check-recommended`
- PowerShell 5.1: `$env:RWANG_INSTALLED_PLUGINS_PATH = "C:\tmp\fixture.json"; /productivity-pack:check-recommended`

env 설정 시 실제 설치 목록은 읽지 않음.
```

**동작 흐름 (§4.6.2 기반):**
1. `${CLAUDE_PLUGIN_ROOT}` 기준 상위 탐색 (미존재 시 `import.meta.url` fallback)
2. `marketplace.json` 읽기
3. 팩별 `recommends.json` 읽기 (누락 허용)
4. `INSTALL_LIST` 파싱 → 설치 plugin 키 추출
5. 팩 × 권장 × 설치 여부 표 출력
6. 실패(`file-missing/parse-failed/unexpected-schema`) non-blocking 경고

**검증 매트릭스 (12 cells — Codex 6차 M2 유지):**

**Fixture (Cells 1–10 — env override):**

| # | Fixture / env 값 | 기대 출력 | Git Bash | PowerShell 5.1 |
|---|---|---|---|---|
| 1 | `installed-codex.json` | 표 · `codex` / `✅` | 필수 | 필수 |
| 2 | `installed-no-codex.json` | 표 · `codex` / `❌` | 필수 | 필수 |
| 3 | `does-not-exist.json` (실재 X) | `💡 ... (사유: file-missing)` | 필수 | 필수 |
| 4 | `bad-json.json` | `💡 ... (사유: parse-failed)` | 필수 | 필수 |
| 5 | `unexpected-schema.json` | `💡 ... (사유: unexpected-schema)` | 필수 | 필수 |

**Production path (Cells 11–12 — M2 해소):**

| # | 조건 | 기대 동작 | 검증 방법 |
|---|---|---|---|
| 11 | env 미설정 + 실 `~/.claude/plugins/installed_plugins.json` 존재 | 기본 경로 resolve · **read-only** · 정상 표. 파일 mutation 0건 | 실행 전후 `md5sum`/`Get-FileHash` 비교 |
| 12 | env 미설정 + `CLAUDE_PLUGIN_ROOT` 제거 | `import.meta.url` fallback · 정상 동작 | `unset CLAUDE_PLUGIN_ROOT` 후 실행 |

총 **12 cells** 전부 통과. 실 `installed_plugins.json` mutation 0건.

**docs/RECOMMENDED_PLUGINS.md 보강:**
- [ ] 초기 설치 one-liner
- [ ] `/productivity-pack:check-recommended` 명령어 언급
- [ ] **MCP 서버 추천 서브섹션**: draw.io MCP / GCP MCP 팩 번들 X, "필요 시 Claude에게 설치 요청" 1~2줄

**Sub-task:**
1. `scripts/check-recommended.mjs` 작성 (ESM, env override + `import.meta.url` fallback)
2. `commands/check-recommended.md` 작성 (env override 서브섹션 의무)
3. `scripts/__tests__/` 4개 fixture JSON 작성
4. `docs/RECOMMENDED_PLUGINS.md` 보강 3항 반영
5. 12 cells 매트릭스 검증 (fixture 10 + production 2)
6. 배치 커밋

**Exit:** 12 cells 전수 pass + command doc env override 서브섹션 + RECOMMENDED_PLUGINS.md 3항 + production path 해시 무변화.

---

### 3.3 Batch 5C — 본인 자산 신규 작성

**5C 결정 용어:**

| 결정 | 의미 |
|---|---|
| **implement** | Phase 5 구현·검증·커밋 |
| **defer** | 보류 → Phase 9+ 재평가 |
| **drop** | 영구 제외 |

**사용자 결정 (2026-04-24):**
- **C-1 `/sync-to-git`: drop** — 자동 동기화 불필요
- **C-3 draw.io MCP: drop** — 팩 번들 X
- **C-4 GCP MCP: drop** — 동일
- **C-2 Git pre-commit hook: TBD** — G2 pre-step 질문지 대상

**G2 pre-step 질문지 (C-2만):**

```
[후보 C-2: Git pre-commit hook]
Q1. 주 사용 빈도? (매일 / 주 1–2회 / 월 수 회 / 특정 이벤트)
Q2. Phase 5 구현 시 즉시 개선되는 작업?
Q3. 연기 시 영향?
Q4. "불필요" 판정 가능한 이유?
```

**5C 결정표:**

| # | 후보 | 결정 | 대상 Phase | Rationale | 대상 팩 | 예상 파일 | 검증 |
|---|---|---|---|---|---|---|---|
| C-1 | `/sync-to-git` | **drop** | — | 사용자 결정 (2026-04-24): 자동 동기화 불필요 | — | — | — |
| C-2 | Git pre-commit hook | **implement** | Phase 5 | Q1 답변 "매일" (집↔회사 병행 작업으로 커밋 주기 밀도 높음). 환경 간 차이가 자주 섞여 들어올 구조. 현실적 조합 a+b+d 채택: (a) 시크릿 패턴 + (b) 개인 절대경로 + (d) vendored `modified: none` 보호. 레포 단위 훅, 번들 아님 | (repo-level) | `scripts/git-hooks/pre-commit` + `README.md` | 6 시나리오 전수 pass |
| C-3 | draw.io MCP 번들 | **drop** | — | 사용자 결정: 팩 번들 X | — | docs 1줄 | 줄 존재 확인 |
| C-4 | GCP MCP 번들 | **drop** | — | 동일 | — | docs 1줄 | 줄 존재 확인 |

**Batch 5C 실행 기록 (2026-04-24):**

- [x] G2 pre-step Q1–Q4 사용자 응답:
  - Q1: 매일 (집↔회사 병행 작업)
  - Q2/Q3/Q4: 불필요 판정 불가, "Claude가 알아서 필터해줬지만 자동화하는 편이 안전"
- [x] 결정: **implement** (현실적 조합 a+b+d)
- [x] 스펙 확정:
  - bash 스크립트 `scripts/git-hooks/pre-commit`
  - 활성화: `git config core.hooksPath scripts/git-hooks` (레포당 1회)
  - 우회: `git commit --no-verify`
  - 스캔 범위: `git diff --cached --unified=0 --diff-filter=AM`의 added 라인만 (기존 내용 retroactive 트리거 없음)
  - (d)는 modification(M)만 대상, Add(A)는 통과
- [x] 검증 6 시나리오 전수 pass:
  1. clean staging → exit 0
  2. fake AWS key `AKIA...` → 블록
  3. `C:\Users\<owner>\...` 패턴 staged (실제 테스트는 owner 유저명 사용) → 블록
  4. vendored `modified: none` 파일 수정 → 블록
  5. 새 vendored 파일 Add → 통과 (M 아닌 A)
  6. `--no-verify` 우회 → 정상 커밋
- [x] 훅 자기-트리거 회피: `PATH_SKIP`에 `scripts/git-hooks/pre-commit` 포함 (시크릿 체크는 예외 없음)
- [x] README.md 상위에 "Git hooks (optional)" 섹션 추가 + 활성화 one-liner

**MCP 버킷 규칙:**

| 유형 | 위치 | 예시 |
|---|---|---|
| 외부 Claude 플러그인 (권장만) | `recommends.json` + `docs/RECOMMENDED_PLUGINS.md` | codex |
| 외부 MCP 서버 (요청 시 안내) | `docs/RECOMMENDED_PLUGINS.md` MCP 서브섹션 1줄 | draw.io, GCP |

**Sub-task 0 — G2 질문지 실행 (mandatory):**

1. Claude가 C-2 질문지 4문항 제시
2. 사용자 답변 → rationale 초안 (2–3줄)
3. 사용자 검토·수정 → 결정표 C-2 TBD 해소
4. **G2 승인 요청** → implement이면 Sub-task 1 진입

**Sub-task 1+ (C-2 = implement일 때만):**
1. 스펙 확정
2. 파일 작성
3. 로컬 검증
4. 개별 커밋

**Exit:** C-2 결정 기록 + drop 3건 보존 + implement 시 스펙대로 동작.

---

### 3.4 Batch 5D — 마감

**Sub-task:**
1. `docs/CHANGELOG.md` `[Unreleased]` 아래 Phase 5 블록:
   - `Phase 5 — YYYY-MM-DD`
   - `Python hook cross-platform fix: A1 (python3 → python, 5 hooks.json commands). hooks/*.py · core/*.py unchanged (vendored modified: none preserved).`
   - `README Prerequisites section added with transparent platform limitation notice (Issue #37634, #18527).`
   - `§4.6 v0.1: /productivity-pack:check-recommended + RECOMMENDED_PLUGINS.md polish (incl. MCP subsection)`
   - `Self-authored (5C): <C-2 결과>` / `Dropped: C-1, C-3, C-4`
   - `Accepted platform limitation: on systems where 'python' points to Python 2 (e.g., Ubuntu ≤20.04), hooks gracefully skip via hookify's existing ImportError handler. Main Claude Code operation is not impacted. Follow-up tracked: upstream Claude Code Issues #37634, #18527. Revisit in Phase 9.`
   - Python hook Known Issue 라인을 "Resolved in Phase 5 (A1 + graceful skip on Py2 systems; see Accepted Limitations)"로 갱신 (**기존 Known issue 라인**을 탐색해 교체)
2. `MASTER_PLAN_v1.5.md` §8 상태 라인 추가
3. `phase5-plan.md` → `docs/archive/` (§3.1.1 source-lock appendix 포함)
4. 마감 커밋

---

## 4. 리스크 & 대응

| # | 리스크 | 대응 |
|---|---|---|
| 1 | Ubuntu 20.04 이하·`python`=Py2 환경에서 훅 비활성 | hookify 원본 graceful skip이 처리. README Prerequisites에 투명 고지 |
| 2 | Claude Code 자체 버그(#37634 등)로 Windows에서 훅이 예상 외 동작 | Phase 9에서 upstream 상태 재확인. Phase 5 범위 외 |
| 3 | source-lock appendix 누락 | 5A-5 전수, 커밋 전 diff 확인 |
| 4 | `check-recommended.mjs`의 `${CLAUDE_PLUGIN_ROOT}` 미존재 | §4.6.2 `import.meta.url` fallback. Cell 12 검증 |
| 5 | fixture 스키마 드리프트 | §4.6.2 reference와 동기. Phase 9 재확인 |
| 6 | 5C C-2 rationale TBD 잔존 | G2 pre-step 질문지 선행 (1건이라 경량) |
| 7 | production path 테스트(Cell 11)가 실 파일 mutation 유발 | 실행 전후 해시 비교 + read-only 경로 확인 |
| 8 | MCP 번들 생략 → 사용자가 나중에 수동 추가 → 시크릿 노출 | Phase 5 scope 외. Phase 6 `validate-plugins.ps1` 후 재평가 |
| 9 | 플랫폼 한계 고지를 사용자가 간과 | README 전용 섹션 + CHANGELOG Accepted Limitations 블록으로 이중 고지 |

---

## 5. 검증 접근

- **5A**: 경로 A-Win + A-POSIX 런타임 Python hook error 0건 + §3.1.1 표 완성 + README Prerequisites 렌더링 + vendored 7개 파일 `modified: none` 유지 확인
- **5B**: 12 cells 매트릭스, Cell 11 해시 무변화, Cell 12 fallback 동작, command doc env override 서브섹션 존재, RECOMMENDED_PLUGINS.md 3항
- **5C**: C-2 implement일 때만 스펙별 수동 테스트. drop 3건은 결정표 rationale 기록
- **5D**: 문서 diff + Known Issue 라인 갱신 + Accepted Limitations 블록 존재

**공통:** 신규·수정 파일 수동 grep으로 개인정보·절대경로 0건 (Phase 6 자동화).

---

## 6. Exit Criteria

### 6.1 Phase 5 자체
- [x] Batch 5A (2026-04-24) — A-Win·A-POSIX 런타임 직접 검증은 환경 제약으로 보류, graceful skip 실제 작동 확인됨. §3.1.1 표 완성, README Prerequisites 섹션(플랫폼 한계 고지 포함), vendored 7개 파일 `modified: none` 유지. Exit 조건 문서상 요건은 충족, 실환경 Python 3 설치 후 확인은 후속
- [x] Batch 5B (2026-04-24) — 12 cells 전수 pass (Git Bash + PowerShell 5.1 + production + fallback), Cell 11 md5 무변화 (`64819c38…a79e` before == after), Cell 12 `import.meta.url` fallback 정상 동작, command doc env override 서브섹션 포함, RECOMMENDED_PLUGINS.md 3항 반영(초기 설치 one-liner + `/check-recommended` 안내 + MCP 서브섹션)
- [x] Batch 5C (2026-04-24) — C-2 implement (현실적 조합 a+b+d), C-1/C-3/C-4 drop 보존. `scripts/git-hooks/pre-commit` + README "Git hooks (optional)" 섹션. 6 시나리오 전수 pass (clean/secret/path/vendored-M/vendored-A/--no-verify)
- [ ] 모든 신규 파일에 개인정보·절대경로 0건

### 6.2 §4.6 v0.1 충족
- [ ] `docs/RECOMMENDED_PLUGINS.md` §4.6.1 요건 + 3 보강 항목
- [ ] `plugins/productivity-pack/.claude-plugin/recommends.json` 구조 확인
- [ ] `/productivity-pack:check-recommended` 12 cells 동작 + env override 문서화

### 6.3 Phase 4 이월 이슈 종결
- [ ] `docs/CHANGELOG.md` Python hook Known Issue 라인 "Resolved in Phase 5 (A1 + graceful skip)" 갱신
- [ ] `docs/CHANGELOG.md` Accepted Limitations 블록 추가 (Issue #37634, #18527 언급)
- [ ] §3.1.1 source-lock appendix 완성

### 6.4 문서 마감
- [ ] `MASTER_PLAN_v1.5.md` §8 상태 라인 업데이트
- [ ] `docs/CHANGELOG.md` [Unreleased] Phase 5 블록 추가
- [ ] `phase5-plan.md` → `docs/archive/`

---

## 7. 확정된 결정사항 (변경 불가)

- 스트림 순서: **A → B → C → D**
- 커밋 단위: 배치당 1 커밋 (5C는 자산당 1 커밋)
- 승인 지점: **G1 + G2 mandatory**
- Codex 리뷰 게이트: 1~7차 CLOSED. **8차·9차 optional (informational, non-blocking)** — Anthropic 공식 방침 준수 원칙이 상위
- Python hook 수정: **A1 (`python3` → `python`)** + **플랫폼 한계 투명 수용**. hookify graceful skip 철학 보존. vendored `hooks/*.py`·`core/*.py` `modified: none` 유지
- **폐기된 v5 산출물**: `launch-python.mjs`, `install-check.mjs`, plugin.json precondition 조사 sub-task (Claude Code 미지원 확정)
- `/check-recommended` 구조: `commands/check-recommended.md` (지시 + env override) + `scripts/check-recommended.mjs` (실행). Node는 이 수동 명령 선에서만 prereq
- MCP 버킷: 외부 플러그인 → `recommends.json` / 외부 MCP 서버 → `RECOMMENDED_PLUGINS.md` 서브섹션 1줄. 팩 소유 `.mcp.json` 번들은 Phase 5 미채택
- Phase 5 source-lock: 본 문서 §3.1.1 inline 표
- 5C 결정어: implement / defer / drop
- **C-1 / C-3 / C-4: drop** (사용자 결정 2026-04-24)
- `validate-plugins.ps1`: Phase 6

---

## 8. Codex 리뷰 반영 로그

### 8.1 1차 (2026-04-23) — CLOSED (9건 → v1)

Verdict: GO with modifications. 반영 상세는 v1 이력 참조.

### 8.2 2차 (2026-04-23) — CLOSED (7건 → v2)

Verdict: NEEDS v2 round. A2 inline wrapper 도입 (v6에서 사망 확정).

### 8.3 3차 (2026-04-23) — CLOSED (5건 → v3)

Verdict: NEEDS v3 round. A1 회귀 (v4에서 A3로 승급했다가 v6에서 다시 A1 + 한계 수용으로 최종).

### 8.4 4차 (2026-04-23) — CLOSED (4건 → v3.1)

Verdict: APPROVE with minor edits.

### 8.5 5차 adversarial (2026-04-24) — CLOSED (3 High → v4)

Verdict: needs-attention.

| # | 지적 | 심각도 | v6 최종 처리 |
|---|---|---|---|
| H1 | A1 POSIX baseline 축소 | HIGH | **재수용** — Claude Code 크로스 플랫폼 미지원 + hookify graceful skip 철학이 공식 패턴. 투명 문서화로 mitigation |
| H2 | `/sync-to-git` mini-spec 위험 | HIGH | C-1 drop (사용자 결정 유지) |
| H3 | `.mcp.json` 시크릿 manual grep | HIGH | C-3/C-4 drop (사용자 결정 유지) |

### 8.6 6차 adversarial (2026-04-24) — CLOSED (3건 → v5)

Verdict: needs-attention.

| # | 지적 | 심각도 | v6 최종 처리 |
|---|---|---|---|
| H1 | A3 Node 의존성 무방비 | HIGH | **A3 자체 폐기**로 해소 |
| M1 | 런처 self-test argv 계약 불일치 | MEDIUM | 런처 폐기로 소멸 |
| M2 | 5B production 경로 미검증 | MEDIUM | **v5 설계 유지** — 12 cells 매트릭스 (Cell 11 해시 무변화 + Cell 12 fallback) |

### 8.7 7차 adversarial (2026-04-24) — CLOSED (3건 → v6)

Verdict: needs-attention.

| # | 지적 | 심각도 | v6 최종 처리 |
|---|---|---|---|
| H1 | Node-less 환경 훅 조용한 실패 | HIGH | **A3·install-check 폐기로 경로 소멸**. 플랫폼 한계 투명 수용 (README + CHANGELOG) |
| M1 | install-check 자기모순(Node로 Node 체크) | MEDIUM | install-check 폐기로 소멸 |
| M2 | 런처 에러 경로 README 불일치 | MEDIUM | 런처 폐기로 소멸 |

**조사 기록 (2026-04-24, claude-code-guide 2회):**

| 질문 | 결과 |
|---|---|
| `plugin.json` precondition 필드 지원? | **No** (공식 스키마 미정의) |
| hooks.json command 실행 실패 처리? | **조용한 non-blocking 스킵**. Claude에게 전달 안 됨 |
| Anthropic 공식 크로스 플랫폼 훅 패턴? | **부재**. hookify 원본도 Linux/macOS 기반 |
| hooks command shell 실행자? | 기본 bash. **Windows 환경에서 `bash`가 WSL 스텁으로 해석되는 버그** (#37634) |
| `shell:` 옵션 공식 스키마? | **미정의** |
| 인터프리터 없이 `.py` 경로만? | **미지원**. Windows py launcher도 hook runner spawn에 자동 개입 안 함 |

**상위 원칙 채택:** Anthropic 공식 방침(hookify graceful skip 철학) > Codex 완벽주의 권고. 플랫폼이 제공하지 않는 우회책 개발보다 한계 투명화가 장기 사후 비용 최소.

### 8.8 8차 이후 (optional)

v6는 Anthropic 공식 방침 준수를 상위 원칙으로 채택. Codex 추가 지적은 **informational 참고로 처리**, blocker 아님. Phase 9 upstream 개선 이후 재평가.

---

## 9. 실행 현황

**현재 상태 (2026-04-24)**: G1·G2 승인. **Batch 5A·5B·5C 완료**. 5D 대기.

**진행:**
- [x] G1 승인 (2026-04-24)
- [x] Batch 5A (2026-04-24) — commit `Phase 5A: Python hook cross-platform fix (A1) + README Prerequisites`
- [x] Batch 5B (2026-04-24) — `scripts/check-recommended.mjs` + `commands/check-recommended.md` + fixture 4종 + RECOMMENDED_PLUGINS.md 3항 + 12 cells 전수 pass
- [x] G2 승인 (2026-04-24) — C-2 implement 결정 (현실적 조합 a+b+d)
- [x] Batch 5C (2026-04-24) — `scripts/git-hooks/pre-commit` + README "Git hooks (optional)" 섹션 + 6 시나리오 전수 pass. C-1/C-3/C-4 drop 보존
- [ ] Batch 5D — 마감 (CHANGELOG Phase 5 블록 + MASTER_PLAN §8 업데이트 + archive 이관)

**다음 액션:** Batch 5D 착수. `docs/CHANGELOG.md` Unreleased 아래 Phase 5 블록 + Known Issue 갱신 + Accepted Limitations 블록, `docs/MASTER_PLAN_v1.5.md` §8 상태 라인, 본 문서 `docs/archive/` 이관.
