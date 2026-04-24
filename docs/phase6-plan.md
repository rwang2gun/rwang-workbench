# Phase 6 실행 계획

> **역할**: Phase 6(빌드 & 로컬 검증)의 단일 실행 계획서.
> **수명**: Phase 6 진행 중 참조. Phase 6 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: MASTER_PLAN v1.5 §5 Phase 6, §4.5 Public 전환 게이트 체크리스트 일부, Phase 2 Exit Gate 검증 재활용.
> **개정 이력**:
> - 초안 (2026-04-24)
> - **v2 (2026-04-24): Codex 1차 리뷰 7건 반영 — High 3건(V-3 `license` 추가, V-5 unique plugin set 비교로 교체, Phase 7 진입 gate 대체성 검증 추가) + Low 4건(V-3 확장 후보 명시, PS 5.1 추가 주의, 6B 누락 step 보강, B-5 결과 분리 기록)**

---

## 0. Scope

Phase 6은 "빌드 & 로컬 검증" 단계. Phase 5까지 축적된 플러그인 구성요소를 **스크립트로 자동 검증**하고 **Claude Code 세션에서 실설치 검증**하는 것이 핵심.

| 스트림 | 범위 | 출처 |
|---|---|---|
| **A** | `scripts/validate-plugins.ps1` 작성 (Phase 2 exit gate 임시 스크립트 → 정규화) | MASTER_PLAN §5 Phase 6 |
| **B** | 로컬 설치 재검증 (인터랙티브): `/plugin marketplace add` + 두 팩 install + Skill 트리거 + hook 로드 확인 + `check-recommended` production 경로 | MASTER_PLAN §5 Phase 6, Phase 3 acceptance 패턴 재현 |
| **C** | Phase 6 마감: CHANGELOG, MASTER_PLAN §8, 본 문서 archive | Phase 4/5 마감 패턴 |

**범위 외:**
- Phase 7 원본 플러그인 비활성화 (별도 Phase)
- `scripts/build-skills-zip.ps1` (배포 후 파생 빌드, Phase 8 이후)
- MCP 연결 검증 — `.mcp.json`이 두 팩에 없으므로 대상 없음
- game-design-pack (유예 중)

---

## 1. Ordering Rationale

**A → B → C 순서 고정.** B는 인터랙티브(Claude Code 세션 필요)이므로 스크립트(A)로 구조 검증 먼저.

---

## 2. 배치

| 배치 | 내용 | 커밋 단위 |
|---|---|---|
| **Batch 6A** | `scripts/validate-plugins.ps1` 작성 + 로컬 실행 PASS 확인 | 1 커밋 |
| **Batch 6B** | 인터랙티브 로컬 설치 재검증 결과 → CHANGELOG에 기록 (파일 변경 = CHANGELOG 1줄) | 1 커밋 |
| **Batch 6C** | CHANGELOG Phase 6 블록 + MASTER_PLAN §8 갱신 + 본 문서 archive | 1 커밋 |

**승인 지점:**
- **G1** — 본 Plan 최종 완성 (Codex 리뷰 후)
- **G2** — Batch 6A `validate-plugins.ps1` 실행 PASS 확인 후 6B 진입

---

## 3. 배치별 세부

### 3.1 Batch 6A — `scripts/validate-plugins.ps1`

#### 3.1.1 목적

Phase 2 exit gate에서 임시(`Work/phase2-validate-plugins.ps1`)로 수행했던 검증을 `rwang-workbench` 리포 내 `scripts/validate-plugins.ps1`로 **정규화**. 이후 Phase 8 배포 전 / 신규 컴포넌트 추가 시마다 재실행 가능.

#### 3.1.2 검증 항목 (MASTER_PLAN §5 Phase 6 + §4.5 사전 충족)

| 번호 | 검증 항목 | 기준 | 심각도 |
|---|---|---|---|
| V-1 | `marketplace.json` 파싱 성공 + 필수 필드 존재(`name`, `owner`, `plugins[]`) | JSON 유효 + 필드 존재 | FAIL |
| V-2 | 각 팩 `plugin.json` 파싱 + 필수 필드(`name`, `description`) | 필드 존재 | FAIL |
| V-3 | 각 팩 `plugin.json` unknown 필드 검출 | 허용 필드 외 키 = 경고 | WARN |
| V-4 | 각 팩 `recommends.json` 존재 시 구조 검증: `recommends[]`, 각 항목 `name`·`reason` | 필드 존재 | FAIL |
| V-5 | `THIRD_PARTY_NOTICES.md` 일관성: `vendored-from:` URL에서 unique plugin set 추출 ↔ NOTICES `Plugin` 컬럼 11개 set 비교 | 미등재 plugin = WARN | WARN |
| V-6 | `scripts/git-hooks/pre-commit` 파일 존재 확인 | 파일 존재 = INFO | INFO |

**V-3 허용 필드 목록 (plugin.json 공식 스키마 기준, 8개):**
`name`, `description`, `version`, `author`, `keywords`, `homepage`, `icon`, `license`

> **v2 변경**: `license` 추가 — 두 실제 manifest가 이미 사용 중(`plugin.json:5`). 미포함 시 즉시 false positive WARN 발생.

> **V-3 확장 후보 (현재 Phase 6 범위 외)**: `mcpServers`, `commands`, `agents`, `hooks` — vendored 문서에 manifest 예시로 등장하나, 현재 두 팩은 자동 discovery를 사용하므로 실제로 쓰이지 않음. Phase 6은 `license`만 반영; 나머지는 Phase 9 이후 재검토.

> **참고**: Phase 2 결과에서 plugin.json은 unknown 필드에 "lenient"(경고 미발생)임이 확인됐으나, V-3은 본 스크립트의 독립 검증으로 경고만 출력 (FAIL 아님).

#### 3.1.3 출력 형식

```
rwang-workbench validate-plugins v1.0
========================================
[V-1] marketplace.json structure          ... PASS
[V-2] analysis-pack/plugin.json           ... PASS
[V-2] productivity-pack/plugin.json       ... PASS
[V-3] plugin.json unknown fields          ... PASS (none found)
[V-4] productivity-pack recommends.json   ... PASS
[V-5] THIRD_PARTY_NOTICES consistency     ... PASS (11/11 plugins matched)
[V-6] pre-commit hook file                ... INFO (exists)
========================================
Result: 6 PASS, 0 WARN, 0 FAIL
```

FAIL 있으면 exit code 1, 없으면 0.

#### 3.1.4 구현 제약

- **PowerShell 5.1 호환** (Windows PowerShell, not PS 7+)
- 실행: `powershell -NoProfile -File scripts/validate-plugins.ps1` (리포 루트에서)
- 경로 기준: `$PSScriptRoot` + `Join-Path` → 절대경로 하드코딩 금지
- 검증 실패 시 즉시 종료 말고 **모든 항목 실행 후 일괄 리포트** (fail-fast 아님)

**PowerShell 5.1 주의사항 (Codex Low 반영):**

| 항목 | 금지 | 대안 |
|---|---|---|
| `-AsHashtable` | ❌ PS7 전용 | `PSObject.Properties.Name` 열거 |
| `??` / ternary `?:` | ❌ PS7 전용 | `if/else` 사용 |
| `ForEach-Object -Parallel` | ❌ PS7 전용 | 순차 `foreach` |
| `ConvertFrom-Json` 에러 | 무시 시 오류 숨김 | `-ErrorAction Stop` + `try/catch` |
| JSON 배열 단일 원소 | 자동 unwrap됨 | `@(...)` 강제 배열 래핑 |
| 출력 인코딩 | 한글 깨짐 가능 | 메시지는 ASCII 위주 또는 `[Console]::OutputEncoding` 명시 |

#### 3.1.5 V-5 구현 전략 (v2 교체)

`vendored-from:` 파일 수(126개) ≠ NOTICES 팩 수(11개) — 단순 카운트 비교는 항상 불일치. 대신:

1. `plugins/` 하위 전체 파일에서 `vendored-from:` 줄을 grep
2. URL에서 `/plugins/<plugin-name>` 부분을 추출 → **unique plugin name set** 생성
3. `THIRD_PARTY_NOTICES.md`의 표 `| Plugin |` 컬럼 값 11개를 파싱 → set 생성
4. 두 set 비교: 양쪽 모두 있으면 PASS, 한쪽에만 있으면 WARN + 차이 목록 출력
5. 각 vendored URL이 NOTICES Source URL 중 하나로 prefix-match 되는지 추가 확인 (선택)

불일치 시 WARN (FAIL 아님) → 사람이 수동 확인.

#### 3.1.6 실행 검증 기준

```
Result: N PASS, 0 FAIL
```
로컬에서 위 결과 확인 후 6A 커밋.

---

### 3.2 Batch 6B — 인터랙티브 로컬 설치 재검증

Phase 3 acceptance에서 수행한 설치 검증을 Phase 5 변경사항 반영 후 재수행. Phase 3 이후 변경된 파일: hooks.json (python), check-recommended.md (신규), pre-commit hook (신규).

**검증 시나리오 (Claude Code 세션에서 수행):**

| # | 단계 | 기대 결과 | blocker? |
|---|---|---|---|
| B-0 | 기존 rwang-workbench 마켓플레이스/팩 등록 상태 확인 + 이미 설치된 경우 uninstall/remove 처리 | 클린 상태 확보 | Yes |
| B-1 | `/plugin marketplace add D:/claude/rwang-workbench` | 마켓플레이스 등록 성공 | Yes |
| B-2 | `/plugin install productivity-pack@rwang-workbench` | 설치 성공 | Yes |
| B-2a | `/hooks` 또는 hook 유발 동작으로 hook 로드 확인 | PreToolUse/PostToolUse hook 로드됨 | Yes |
| B-3 | `/plugin install analysis-pack@rwang-workbench` | 설치 성공 | Yes |
| B-4 | productivity-pack Skill 1개 트리거 (`/productivity-pack:plugin-structure` 등) | 응답 생성 | Yes |
| B-4a | analysis-pack Skill 1개 트리거 (`/analysis-pack:playground` 등) | 응답 생성 (두 팩 discovery 검증) | Yes |
| B-5 | `/productivity-pack:check-recommended` 실행 | **command 로드·실행 성공 + 표 포맷 출력** | Yes (command load) |
| B-5 결과 | 설치 상태 값 (`✅`/`❌`/`—`/warning) 기록 | 모두 정상. 값 자체는 non-blocking | No |
| B-6 | `/plugin uninstall productivity-pack@rwang-workbench` | 제거 성공 | Yes |
| B-7 | `/plugin uninstall analysis-pack@rwang-workbench` | 제거 성공 | Yes |
| B-8 | B-6/B-7 후 command/skill 노출 사라졌는지 확인 (`/help` 또는 명령 시도) | 제거 완전 | No (기록만) |

> **B-5 판단 기준**: command 자체가 로드되어 실행되고 표 포맷이 출력되면 PASS. 설치 상태 값(`✅`/`❌`/`—`)은 `installed_plugins.json` 상태에 따른 non-blocking 결과이므로 어떤 값이든 정상.

**6B 커밋 내용:** CHANGELOG에 검증 결과 한 줄 추가.

---

### 3.3 Batch 6C — 마감

Phase 4/5 마감 패턴 동일.

- `docs/CHANGELOG.md` [Unreleased]: Phase 6A/6B/6C 블록 추가
- `docs/MASTER_PLAN_v1.5.md` §8: `⬜ Phase 6~8` → `✅ Phase 6 완료 (2026-04-2X)` + `⬜ Phase 7~8`
- `docs/phase6-plan.md` → `docs/archive/phase6-plan.md`

---

## 4. 리스크 & 판단

| 리스크 | 대응 |
|---|---|
| V-3 false positive (license 등 허용 필드 오탐) | v2에서 `license` 추가로 해결. `mcpServers/commands/agents/hooks`는 현재 미사용이므로 WARN 발생 시 Phase 6 스코프 아닌 것으로 판단. |
| V-5 THIRD_PARTY_NOTICES 파싱 — 표 포맷 변경 시 깨짐 | plugin name 파싱은 `^\| (\w[\w-]+)` 패턴으로 단순 추출. 실패 시 WARN 출력 + 수동 확인. |
| 인터랙티브 B-5 `check-recommended`가 `—` 출력 | 정상 동작. command load 성공이면 PASS. |
| PS 5.1 `ConvertFrom-Json` 배열 unwrap | `@(...)` 강제 래핑 + `-ErrorAction Stop` 패턴 적용. |
| Phase 2 임시 스크립트 코드 미보유 | 처음부터 작성. MASTER_PLAN §5 Phase 2 Exit Gate 항목을 사양으로 사용. |
| B-0 기존 설치 상태 충돌 | `/plugin list`로 확인 후 충돌 시 먼저 제거. |

---

## 5. Exit Gate

| 게이트 | 기준 |
|---|---|
| 6A | `validate-plugins.ps1` 실행 → `0 FAIL` |
| 6B | B-0~B-7 시나리오 전수 통과 + B-5 command load 성공 확인 (CHANGELOG에 기록) |
| 6B → Phase 7 추가 조건 | productivity-pack + analysis-pack **만** 설치된 상태(원본 플러그인 없음)에서 대표 command 1개 + skill 1개 + hook 로드가 동작함을 B-2a~B-4a에서 확인 |
| 6C | CHANGELOG·MASTER_PLAN 갱신 + archive 이관 |

> **Phase 7 진입 근거**: Phase 7은 원본 플러그인 비활성화 단계. 6B exit gate의 "원본 없이 새 pack만으로 대표 경로 동작" 확인이 비활성화 전 대체성 검증 역할을 한다.

---

## 6. Codex 리뷰 결과

**1차 리뷰 (2026-04-24) — CLOSED. 7건 전수 반영.**

| # | 심각도 | 지적 내용 | 반영 |
|---|---|---|---|
| H-1 | High | V-3 허용 목록 `license` 누락 → false positive | ✅ 8개로 수정 |
| H-2 | High | V-5 파일 수 카운트는 구조적 부적합 (126 vs 11) | ✅ unique plugin set 비교로 교체 |
| H-3 | High | Phase 6 exit gate만으로 Phase 7 진입 불충분 | ✅ 대체성 검증 조건 + B-2a hook 확인 추가 |
| L-1 | Low | V-3 확장 후보(`mcpServers` 등) 언급 | ✅ "확장 후보, 현재 미사용" 노트 추가 |
| L-2 | Low | PS 5.1 추가 주의사항 | ✅ 주의사항 표 추가 |
| L-3 | Low | 6B 누락 step (B-0, B-2a, B-4a, B-8) | ✅ 시나리오 표에 추가 |
| L-4 | Low | B-5 command load(blocker) vs 설치 상태값(non-blocking) 분리 | ✅ 판단 기준 명시 |
