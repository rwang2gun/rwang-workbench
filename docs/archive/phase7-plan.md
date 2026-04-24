# Phase 7 실행 계획

> **역할**: Phase 7(원본 플러그인 비활성화 / 환경 정리)의 단일 실행 계획서.
> **수명**: Phase 7 진행 중 참조. Phase 7 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: MASTER_PLAN v1.5 §5 Phase 7, §4.5 Public 전환 게이트 체크리스트(일부 선제), Phase 6B B-0 "원본 hookify 부재 확인" 재활용.
> **개정 이력**:
> - v1 초안 (2026-04-24)
> - **v2 (2026-04-24): Codex 1차 리뷰 4건 반영 — High 2건(O-1 installed_plugins 키 generic parsing으로 확장 + scope=='user' 필터 / O-2 skill 이름을 디렉토리명 ∪ SKILL.md frontmatter name 합집합으로) + Low 2건(PS 5.1 inherit 항목 명시 / §6 '실행 기록' 참조 제거 — CHANGELOG 단일 기록 패턴)**
> - **v3 (2026-04-24): Codex 2차 리뷰 3건 반영 — High 2건(O-1 실패 분류 정의: file-missing=PASS / parse-failed·unexpected-schema=FAIL / 7B cleanup 명령을 plain key → entry installPath에서 marketplace 유도하는 절차로 구체화) + Low 1건(O-2 scope 명시: `~/.claude/commands/`·`~/.claude/agents/`는 MASTER §5 Phase 7 literal text상 out-of-scope, 필요 시 수동 점검)**
> - **v4 (2026-04-24): Codex 3차 리뷰 3건 반영 — High 1건(7A exit code 의미 각 언급 지점에 명시: 0=clean=7B skip / 2=WARN=7B 진행 / 1=FAIL=7A 블록) + Low 2건(installPath fallback을 OS-agnostic `[/\\]` 파싱으로 확장 / fallback 실패 시 수동 개입 필요 + 7B FAIL로 exit 명시)**
> - **v5 (2026-04-25): Codex 4차 리뷰 3건 반영 — High 1건(per-key entry schema drift 처리: 11개 원본과 매칭되는 key의 `entries`가 Array 아니면 FAIL로 격상) + Low 2건(§4.1.5 clean 기준을 `N PASS, 0 WARN, 0 FAIL`로 명확화 / fallback marketplace 추출을 "접미부 매칭" — `.claude/plugins/cache/<marketplace>/<name>/<version>`의 `<name>/<version>` 바로 앞 세그먼트 채택)**
> - **v6 (2026-04-25): Codex 5차 리뷰 2건 반영 — High 1건(Array 내부 요소가 malformed·non-object·scope 파싱 불가일 때도 FAIL로 격상) + Low 1건(fallback token 가드를 "4개 미만 FAIL"로 정정 + 빈 토큰 필터 명시)**

---

## 0. Scope

Phase 7은 "편입된 플러그인의 **원본**이 user-scope로 독립 설치되어 있으면 비활성화하여 중복 로드를 방지"하는 단계. MASTER_PLAN §5 Phase 7:
> - 편입 완료·검증 후 원본 `/plugin disable`
> - **외부 의존 플러그인(codex 등)은 비활성화하지 않음**
> - `~/.claude/skills/` 중 편입된 것 정리, 중복 로드 방지

| 스트림 | 범위 | 근거 |
|---|---|---|
| **A** | **상태 점검 자동화**: 11개 편입 원본 + `~/.claude/skills/` 복제본 부재를 스크립트로 전수 확인 | §5 Phase 7 |
| **B** | 부재 아닌 항목이 있을 경우에만 `claude plugin disable` + `~/.claude/skills/<이름>` 제거 | §5 Phase 7 |
| **C** | 두 팩 **최종 설치 복원** (Phase 6B B-7 uninstall로 현재 미설치 상태) + `claude plugin list` 최종 스냅샷 기록 | 사용 상태 복원 |
| **D** | Phase 7 마감: CHANGELOG, MASTER_PLAN §8, 본 문서 archive | Phase 4~6 마감 패턴 |

**범위 외:**
- Phase 8 public 전환 게이트 체크리스트 (§4.5) 전체 수행 — 시크릿 스캔 자동화, `.env.example`, `release-checklist-v{버전}.md` 작성은 Phase 8 몫
- `scripts/build-skills-zip.ps1` (Phase 8 이후)
- `codex@openai-codex` 비활성화 — 외부 의존으로 유지
- game-design-pack (유예 중)

---

## 1. 현재 환경 선제 진단 (plan 작성 시점 스냅샷)

Phase 6B 종료 시점(2026-04-24)에 확인된 사실:

- `claude plugin list` → `codex@openai-codex`만 enabled. productivity-pack / analysis-pack은 Phase 6B B-7에서 uninstall됨.
- `installed_plugins.json` → codex 1개.
- `~/.claude/skills/` 디렉토리 자체 **부재** (`ls` 실패).
- 원본 편입 대상 11개(`hookify`, `claude-code-setup`, `claude-md-management`, `mcp-server-dev`, `playground`, `plugin-dev`, `session-report`, `commit-commands`, `feature-dev`, `pr-review-toolkit`, `security-guidance`) — Phase 6B B-0에서 `hookify` 1개 부재 확인, 나머지 10개는 미검증.

따라서 Phase 7의 실제 작업량은 **검증 위주, 실제 disable 대상 0건 가능성이 높음**. 그래도 스크립트로 전수 확인해 근거를 남겨야 Phase 8 진입 조건(§4.5) 일부가 선제 충족됨.

---

## 2. Ordering Rationale

**A → B(조건부) → C → D 순서 고정.**

- A가 "부재 전수"를 증명하면 B는 skip (파일 변경 없음).
- C는 A/B와 독립이지만 **Phase 7 마감 시점의 사용 상태**를 확정하기 위해 D 직전에 수행.

---

## 3. 배치

| 배치 | 내용 | 커밋 단위 |
|---|---|---|
| **Batch 7A** | `scripts/check-orphan-originals.ps1` 작성 + 로컬 실행 결과 기록 | 1 커밋 |
| **Batch 7B** | (조건부) disable + `~/.claude/skills/` 제거. 대상 0건이면 **skip** (커밋 없음) | 0 or 1 커밋 |
| **Batch 7C** | 두 팩 재설치 + `claude plugin list` 스냅샷을 CHANGELOG에 한 줄 기록 | 1 커밋 |
| **Batch 7D** | CHANGELOG Phase 7 블록 + MASTER_PLAN §8 갱신 + 본 문서 archive + CLAUDE.md 상태 동기화 | 1 커밋 |

**승인 지점:**
- **G1** — 본 Plan 최종 완성 (Codex 리뷰 후)
- **G2** — Batch 7A 실행 결과 확인 후 7B/7C 진행 결정
- **G3** (조건부) — 7B에서 실제 disable/제거가 일어나는 경우 한 번 더 확인

---

## 4. 배치별 세부

### 4.1 Batch 7A — `scripts/check-orphan-originals.ps1`

#### 4.1.1 목적

편입 11개 원본 플러그인의 **독립 설치 여부** + `~/.claude/skills/` 내 **편입된 skill의 개별 복제본 여부**를 단일 스크립트로 전수 확인. 결과는 표로 출력하고 exit code로 요약.

#### 4.1.2 검증 항목

| 번호 | 검증 항목 | 기준 | 심각도 |
|---|---|---|---|
| O-1 | `~/.claude/plugins/installed_plugins.json`의 `plugins` 필드를 **generic enumerate** 후 scope=='user'인 엔트리만 추려, 키가 (a) 11개 원본 이름 중 하나와 **정확 일치** `<name>` 또는 (b) `<name>@*` **prefix 일치** 둘 중 하나에 해당하는지 검사 | 존재 = WARN (정리 대상) / 부재 = PASS | WARN |
| O-2 | `~/.claude/skills/` 디렉토리 존재 여부 + 존재 시 **편입 skill 이름 합집합**(디렉토리명 ∪ SKILL.md frontmatter `name:`)과 겹치는 하위 디렉토리 검출 | 겹침 = WARN / 겹침 없음 or 디렉토리 부재 = PASS | WARN |
| O-3 | `~/.claude/plugins/known_marketplaces.json`에서 `anthropics/claude-plugins-official`, `anthropics/claude-plugins-public` 등록 여부 — 등록 자체는 INFO (vendoring source 리포로 남아 있어도 무방) | 참고 | INFO |

**11개 원본 이름 하드코딩 리스트(THIRD_PARTY_NOTICES.md 첫 번째 표 Plugin 컬럼 기준, 수동 복사):**
`hookify`, `claude-code-setup`, `claude-md-management`, `mcp-server-dev`, `playground`, `plugin-dev`, `session-report`, `commit-commands`, `feature-dev`, `pr-review-toolkit`, `security-guidance`.

**O-1 키 매칭 근거**: MASTER_PLAN §4.6.2 reference implementation(`Object.keys(data.plugins).filter(key => ...scope === 'user')`) 패턴 차용. 실제 Claude Code가 설치 상태를 `<name>@<marketplace>` 키로 기록하지만(현 이 PC: `codex@openai-codex`) scope-by-scope / 버전별로 plain `<name>` 키도 등장할 수 있으므로 두 형태 모두 검사. PS 5.1에서는 `$json.plugins.PSObject.Properties.Name`으로 키 enumerate.

**O-1 실패 분류(MASTER §4.6.2 카테고리 준수):**

| 상황 | 분류 | 이유 |
|---|---|---|
| `installed_plugins.json` 파일 자체 부재 | PASS | 어떤 플러그인도 user-scope로 설치된 적 없음 = 원본도 없음. 목표 달성. |
| JSON 파싱 실패 (`parse-failed`) | **FAIL** | 설치 상태를 검증할 수 없음. 계속 진행하면 원본 잔존 가능성 은폐 |
| 예상 스키마 불일치 (`unexpected-schema` — 예: `plugins` 키 없음·object 아님·Array 타입 등) | **FAIL** | 동일 사유 |
| 읽기 권한 등 I/O 실패 | **FAIL** | 동일 사유 |
| **11개 원본과 매칭된 key의 `entries` 값이 Array 아님** (예: `plugins["hookify"]`가 object로 진화) | **FAIL** | per-key schema drift 감지 — silent skip 방지 (MASTER §4.6.2 line 331의 `Array.isArray(entries)` 체크를 strict하게 격상) |
| **11개 원본과 매칭된 key의 `entries` Array 내부 요소가 malformed** (non-object / `scope` 필드 부재·파싱 불가) | **FAIL** | Array shell만 보호하면 요소 레벨 drift가 silent skip됨. 매칭 key의 각 element가 object + `scope` 문자열 필드를 갖는지 명시 검증 |
| 위 모두 정상 + 11개 원본 중 1개라도 매칭 | WARN (기존) | 7B 정리 대상 |
| 위 모두 정상 + 11개 원본 0건 매칭 | PASS (기존) | 목표 달성 |

**exit code 규칙 (7A 전체 gate 의미론):**

| exit | 의미 | 후속 |
|---|---|---|
| **0** | clean — WARN 0건·FAIL 0건 | 7B skip, 바로 7C 진입 |
| **2** | WARN 1건 이상, FAIL 0건 | **정상 진행** → 7B 실행 대상 있음. 이 경우 shell-level failure로 취급하지 말 것 |
| **1** | FAIL 1건 이상 (파싱/스키마/IO 실패) | 7A 게이트 **블록**. 원인 해소 전 7B/7C 진행 금지 |

PowerShell / shell에서 호출할 때는 반드시 exit code를 명시 분기 (`if ($LASTEXITCODE -eq 1) { ... } elseif ($LASTEXITCODE -eq 2) { ... }`). 단순 `-ne 0` 체크는 WARN도 실패로 오인하므로 금지.

**O-2 편입 skill 합집합 구성:**

1. `plugins/*/skills/<dir>/` glob → 디렉토리명 집합
2. 각 `plugins/*/skills/*/SKILL.md`에서 YAML frontmatter `name:` 필드 파싱 → name 집합
3. 두 집합의 **합집합**을 편입 skill 이름으로 채택

**실사례**: `plugins/productivity-pack/skills/writing-rules/SKILL.md`의 frontmatter는 `name: writing-hookify-rules`. 디렉토리명(`writing-rules`)과 다르므로 디렉토리명만 기준으로 검사하면 `~/.claude/skills/writing-hookify-rules/` 같은 복제본이 누락됨. 합집합 방식은 양쪽 모두 포착.

**O-2 scope 범위**: `~/.claude/skills/`만 대상. MASTER_PLAN §5 Phase 7 literal text는 `~/.claude/skills/ 중 편입된 것 정리, 중복 로드 방지`만 명시하며 commands/agents는 언급 없음. 따라서 `~/.claude/commands/`·`~/.claude/agents/` user-level 복제본 검사는 **Phase 7 out-of-scope**. 필요 시 수동 점검(`ls ~/.claude/commands ~/.claude/agents 2>/dev/null`)으로 별도 처리. Phase 8 이후 `§4.5` 절대경로·계정명 노출 검사와 함께 재평가 후보.

#### 4.1.3 출력 형식

```
rwang-workbench check-orphan-originals v1.0
========================================
[O-1] original plugins independently installed
       hookify                    ... PASS (not installed)
       claude-code-setup          ... PASS (not installed)
       ...
[O-2] ~/.claude/skills/ orphans
       directory not found        ... PASS
[O-3] marketplaces references
       claude-plugins-official    ... INFO (known)
       claude-plugins-public      ... INFO (not registered)
========================================
Result: 13 PASS, 0 WARN, 0 FAIL, N INFO
```

WARN 있으면 exit 2, FAIL 있으면 exit 1, clean이면 exit 0 (§4.1.3 exit code 규칙 표 참조).

#### 4.1.4 구현 제약

- PowerShell 5.1 호환 (Phase 6A `validate-plugins.ps1`와 동일 기준)
- 실행: `powershell -NoProfile -File scripts/check-orphan-originals.ps1` (리포 루트에서)
- `$RepoRoot = Split-Path -Parent $PSScriptRoot` 패턴 재사용
- **Phase 6A inherit 주의사항** (archive/phase6-plan.md §3.1.4 표 준수):
  - `-AsHashtable` / `??` / `ForEach-Object -Parallel` / `Join-Path -AdditionalChildPath` 전부 PS 7 전용 → 금지
  - `ConvertFrom-Json`: `-ErrorAction Stop` + `try/catch`, 반환값 `@(...)` 강제 배열 래핑
  - JSON 루트가 array인지 `-is [Array]` 타입 체크 (Phase 6A Codex 1차 Low 반영 경험)
  - `Write-Output` 파이프라인 오염 → 중간 디버그는 `Write-Host`, helper 반환은 `return` 명시
  - `Test-Path` 반드시 `-PathType Leaf` / `-PathType Container`
  - 경로 결합: 중첩 `Join-Path` (`Join-Path (Join-Path $a $b) $c`)
  - UTF-8 입출력 보장, 메시지는 ASCII 위주 또는 `[Console]::OutputEncoding` 명시

#### 4.1.5 실행 검증 기준

```
Result: N PASS, 0 WARN, 0 FAIL   ← clean 최종 판정(exit 0)
```

**분기 (`Result:` 라인 자체가 최종 판정을 좌우하지 않음 — exit code를 기준으로 분기):**
- `exit 0` (clean: `0 WARN, 0 FAIL`) → Batch 7A 커밋 → 7B skip → 바로 7C 진입
- `exit 2` (WARN ≥ 1, `0 FAIL`) → Batch 7A 커밋 → 7B 진행 (실제 정리 작업 있음). **shell failure로 오인 금지**. 이때 `Result:` 라인은 `N PASS, M WARN, 0 FAIL` 형식
- `exit 1` (FAIL ≥ 1) → 7A 게이트 블록. 원인 해소 후 재실행, 이전에는 커밋 금지

---

### 4.2 Batch 7B — (조건부) disable + skill 정리

**실행 조건**: 7A 결과에서 O-1 WARN(독립 설치된 원본) 또는 O-2 WARN(skill 복제본)이 1건 이상.

**절차:**

1. O-1 WARN 각 항목에 대해 `claude plugin disable <key>` 실행 (**uninstall 아님** — MASTER_PLAN §5 문구 `/plugin disable` 정확 준수). `<key>`는 `installed_plugins.json.plugins`의 실제 키 그대로 사용.
2. 만약 `claude plugin disable` CLI가 plain `<name>` 키를 거부하면 **fallback — 접미부 매칭 방식**: 해당 entry의 첫 `scope=='user'` 레코드에서 `installPath`를 읽어 OS-agnostic 분할 후 **빈 토큰 필터**(`$installPath -split '[\\/]+' | Where-Object { $_ -ne '' }`) 적용 → 정규화된 토큰 배열에서 **뒤에서 세 번째 토큰**(= `<name>/<version>` 바로 앞 세그먼트)을 `<marketplace>`로 채택 → `<name>@<marketplace>` 조립 후 재시도. 접미부가 `.../plugins/cache/<marketplace>/<name>/<version>` 형태여야 하며, 추출한 세그먼트 앞 세그먼트가 정확히 `cache`임을 검증(`tokens[-4] == 'cache'`) — 검증 실패 시 fallback도 실패 처리. 이 방식은 installPath에 앞서 무관한 `cache` 디렉토리가 있거나 trailing slash가 있어도 오추출 안 됨. (예: `...\cache\claude-plugins-official\hookify\1.0.0\` → 빈 토큰 필터 후 뒤에서 세 번째 = `claude-plugins-official` + 그 앞 = `cache` → `hookify@claude-plugins-official`)
   - **fallback 실패 시**(`installPath` 부재·빈 값·**정규화된 토큰 수 4개 미만**·`tokens[-4] != 'cache'`): 해당 항목은 **7B FAIL**로 분류하고 사용자 수동 개입 필요. 7B는 이 경우 커밋하지 말고 중단, CHANGELOG에 미해결 항목으로 기록 후 대기.
3. O-2 WARN 각 항목에 대해 `~/.claude/skills/<name>` 디렉토리 제거 (Windows: `Remove-Item -LiteralPath <path> -Recurse -Force`). 삭제 전 `ls` / `dir`로 내용 확인하여 사용자 private 자산이 없는지 체크.
4. 7A 스크립트 재실행하여 모든 WARN 해소 확인
5. 변경 결과는 **CHANGELOG에만** 기록 (repo 외 변경이므로 본 plan에 실행 기록 append 없음 — Phase 6 패턴 일치). `disable`/`delete`된 원본 이름·key·marketplace 모두 개별 기록.

**커밋 내용**: CHANGELOG 한 줄 (파일 변경은 없을 수 있음 — `~/.claude/`는 repo 밖이므로 기록만)

**주의**: `codex@openai-codex`는 외부 의존 → **절대 disable 금지** (MASTER_PLAN §5 Phase 7 명시).

---

### 4.3 Batch 7C — 두 팩 최종 설치 복원

**절차:**

1. `claude plugin install productivity-pack@rwang-workbench`
2. `claude plugin install analysis-pack@rwang-workbench`
3. `claude plugin list` 실행, 출력을 CHANGELOG Phase 7C 항목에 포함 (`codex` + 두 팩 = 3개 enabled 확인)

**검증**:
- `installed_plugins.json`에서 3개 키 모두 presence
- 스모크 체크: 7A 스크립트 재실행하여 WARN 0건 유지 (재설치 후 skill orphan 발생 없음 재확인)

**커밋**: CHANGELOG 한 줄.

---

### 4.4 Batch 7D — 마감

Phase 4/5/6 마감 패턴 동일.

- `docs/CHANGELOG.md` [Unreleased]: Phase 7 블록 (7A/7B/7C/7D) 추가
- `docs/MASTER_PLAN_v1.5.md` §8: `⬜ Phase 7~8` → `✅ Phase 7 완료 (2026-04-2X)` + `⬜ Phase 8`
- `docs/phase7-plan.md` → `docs/archive/phase7-plan.md`
- `CLAUDE.md` 상태 표 Phase 7 반영 + 다음 액션을 Phase 8 착수로 전환

---

## 5. 리스크 & 판단

| 리스크 | 대응 |
|---|---|
| 원본이 user-scope 아닌 project-scope에 설치됐을 가능성 | O-1 검증은 user-scope(`~/.claude/plugins/installed_plugins.json`)만 대상. project-scope는 현재 이 리포에 없음 — `claude plugin list`에서도 codex/두 팩만 보임. project-scope 확장은 Phase 7 범위 외 |
| `~/.claude/skills/` 복제본이 user가 의도적으로 둔 것일 가능성 | O-2에서 검출되면 **자동 제거하지 않고 WARN 출력** → 7B에서 사용자 승인 후 제거. 본 plan은 "편입된 이름과 겹치는 경우"만 WARN 대상으로 제한 |
| disable 후 재활성화가 필요할 때 | `claude plugin enable <name>@<marketplace>` 1줄로 복구 가능. Phase 7B 기록에 원본 상태(enabled/disabled) 남김 |
| 11개 원본 이름 오타 | 하드코딩 리스트는 `THIRD_PARTY_NOTICES.md` 첫 번째 표 Plugin 컬럼에서 수동 복사. 스크립트에 상수로 기록 + 본 plan §4.1.2에도 명시 |
| Phase 8 게이트(§4.5)와의 경계 | Phase 7 scope는 "중복 로드 방지"로 국한. `gitleaks` / `.env.example` / `release-checklist` 는 Phase 8 |
| PC마다 상태가 다를 수 있음 | 본 plan은 이 PC(`code1412`) 환경 기준. Phase 8 이후 다른 PC 셋업 시 같은 스크립트 재실행하여 동일 검증 수행 |

---

## 6. Exit Gate

| 게이트 | 기준 |
|---|---|
| 7A | `check-orphan-originals.ps1` 실행 → **exit 0 (clean)** 또는 **exit 2 (WARN 1건↑, FAIL 0)** 중 하나. exit 1(FAIL)은 게이트 블록 |
| 7B (조건부) | 모든 WARN 해소 후 7A 재실행하여 **exit 0**. 7B 내부에서 installPath fallback이 실패하면 그 항목을 7B FAIL로 분류하고 수동 개입 대기 — 게이트 미통과 |
| 7C | `claude plugin list` → `codex@openai-codex` + `productivity-pack@rwang-workbench` + `analysis-pack@rwang-workbench` 3개 enabled + 7A 재실행 clean |
| 7D | CHANGELOG·MASTER_PLAN §8·CLAUDE.md 갱신 + archive 이관 |

**Phase 8 진입 조건**: Phase 7 exit gate 통과 + §4.5 체크리스트 중 "절대경로·계정명 노출 0건"이 선제 충족(현재 `core.hooksPath=scripts/git-hooks` 훅이 이미 (b) 검사 중). 나머지 §4.5 항목은 Phase 8 자체 스코프.

---

## 7. Codex 리뷰 결과

**1차 리뷰 (2026-04-24) — CLOSED. 4건 전수 반영.**

| # | 심각도 | 지적 내용 | 반영 |
|---|---|---|---|
| H-1 | High | O-1 `<name>@<marketplace>` 단일 형식 매칭으로는 plain `<name>` 키 등장 시 누락 위험 (MASTER_PLAN §4.6.2 reference implementation 불일치) | ✅ O-1을 generic enumerate + scope=='user' 필터 + `<name>` 정확 일치 or `<name>@*` prefix 매칭으로 확장 |
| H-2 | High | O-2 디렉토리명만 기준으로 하면 SKILL.md frontmatter `name:`이 다른 skill 복제본(예: `writing-rules` 디렉토리의 `name: writing-hookify-rules`)이 누락됨 | ✅ 편입 skill 이름 집합을 디렉토리명 ∪ SKILL.md frontmatter `name:` 합집합으로 정의 |
| L-1 | Low | PS 5.1 inherit 주의사항이 너무 짧아 Phase 6A에서 확립된 세목(Write-Output 오염, Test-Path -PathType, Join-Path 중첩) 누락 | ✅ §4.1.4에 inherit 주의사항 전체 bullet으로 명시 |
| L-2 | Low | `## 6. 실행 기록` append는 섹션 번호 불일치(§6은 Exit Gate). Phase 6 plan에 없던 구조이고 plan이 archive될 때 재혼란 | ✅ 해당 문구 제거, CHANGELOG 단일 기록 패턴으로 통일 |

**2차 리뷰 (2026-04-24) — CLOSED. 3건 전수 반영.**

| # | 심각도 | 지적 내용 | 반영 |
|---|---|---|---|
| H-1 | High | O-1이 plain `<name>` 키를 허용하게 됐지만 7B `claude plugin disable <name>@<marketplace>`는 여전히 marketplace를 요구 — plain key에서 marketplace 유도 절차 누락 | ✅ 7B 절차 구체화: 1차로 실제 key 그대로 `disable`, 실패 시 entry의 `installPath` 패턴(`cache\<marketplace>\<name>\<version>`)에서 `<marketplace>` 추출 fallback |
| H-2 | High | O-1이 `installed_plugins.json` 실패 분류 미정의 — 파싱/스키마 실패 시 false PASS 위험, exit gate에 `0 FAIL`만 있으므로 "검증 불가 = 통과"로 오인될 여지 (MASTER §4.6.2의 file-missing / parse-failed / unexpected-schema 구분과 불일치) | ✅ O-1 실패 분류 표 추가: file-missing=PASS(설치 전무 해석), parse-failed / unexpected-schema / I/O 실패 = FAIL. exit code 규칙(FAIL=1, WARN만=2, clean=0) 명시 |
| L-1 | Low | O-2가 `~/.claude/skills/`만 커버. `~/.claude/commands/`·`~/.claude/agents/` user-level 복제본 가능성은 MASTER §5 literal에선 언급 없지만 plan의 "중복 로드 방지" 목적 상 scope 명시 필요 | ✅ O-2 scope 범위 bullet 추가: MASTER §5 literal 준수로 commands/agents는 Phase 7 out-of-scope, 수동 점검 안내 |

**3차 리뷰 (2026-04-24) — CLOSED. 3건 전수 반영.**

| # | 심각도 | 지적 내용 | 반영 |
|---|---|---|---|
| H-1 | High | WARN이 exit 2로 정의됐지만 7A gate/검증 문구가 여전히 "0 FAIL"만 pass로 말함 — shell에서 exit 2를 실패로 오인할 위험 | ✅ §4.1.3에 exit code 규칙 표 추가(0=clean/2=WARN/1=FAIL) + §4.1.5·§6 Exit Gate에 각 code별 후속 분기 명시. PowerShell에서 `$LASTEXITCODE -eq 1` / `-eq 2`로 분기하도록 명시 |
| L-1 | Low | `installPath` fallback이 Windows 슬래시 `\` 전용 — macOS/Linux에서는 `/` 슬래시라 매칭 실패 | ✅ `$installPath -split '[\\/]+'` 후 `cache` 세그먼트 뒤 토큰 추출하는 OS-agnostic 파싱으로 확장. 양쪽 예시 명시 |
| L-2 | Low | fallback이 installPath 부재/빈 값/패턴 불일치 시 outcome 미정의 | ✅ 해당 경우 7B FAIL로 분류, 수동 개입 대기, CHANGELOG에 미해결 항목 기록 후 커밋 중단 |

**4차 리뷰 (2026-04-25) — CLOSED. 3건 전수 반영.**

| # | 심각도 | 지적 내용 | 반영 |
|---|---|---|---|
| H-1 | High | O-1 실패 분류가 root `plugins` 레벨만 다룸. per-key entry schema drift(`plugins["hookify"]`가 Array 아닌 형태로 진화) 시 silent skip → false PASS. MASTER §4.6.2 line 331 `Array.isArray(entries)` 체크를 strict FAIL로 격상 필요 | ✅ 실패 분류 표에 "11개 원본 매칭 key의 `entries` 값이 Array 아님 = FAIL" 행 추가 |
| L-1 | Low | §4.1.5 `Result: N PASS, 0 FAIL` 문구는 WARN 경우에도 참 → 인간이 skim할 때 clean 오인 | ✅ clean 판정 기준을 `N PASS, 0 WARN, 0 FAIL`로 명확화. `Result:` 라인보다 exit code가 최종 판정임을 명시 |
| L-2 | Low | fallback marketplace 추출이 "첫 `cache` 세그먼트 뒤 토큰" → installPath에 앞서 무관한 `cache` 디렉토리 있으면 오추출 | ✅ "접미부 매칭" 방식으로 전환: 뒤에서 세 번째 토큰을 `<marketplace>`로 채택 + `tokens[-4] == 'cache'` 명시적 검증. 검증 실패 시 fallback도 실패 처리 |

**5차 리뷰 (2026-04-25) — CLOSED. 2건 전수 반영.**

| # | 심각도 | 지적 내용 | 반영 |
|---|---|---|---|
| H-1 | High | Array shell만 FAIL로 격상되었을 뿐 Array 내부 요소 malformed(non-object / scope 필드 부재·파싱 불가)일 때 여전히 silent skip → false PASS | ✅ 실패 분류 표에 "매칭 key의 entries Array 내부 요소가 malformed = FAIL" 행 추가. 각 element가 object + string scope 필드 갖는지 명시 검증 |
| L-1 | Low | fallback 가드가 "tokens 3개 미만"만 체크 → `tokens[-4]` 접근 시 exactly 3 토큰도 out-of-range. trailing slash로 인한 빈 토큰 미필터 | ✅ 빈 토큰 필터 명시(`Where-Object { $_ -ne '' }`) + 정규화 후 "**4개 미만** FAIL"로 정정 |

**6차 리뷰 (2026-04-25) — CLOSED. No new findings.**

수렴 확인. 건수 추이: 1차 4건 → 2차 3건 → 3차 3건 → 4차 3건 → 5차 2건 → 6차 0건.

**G1 게이트 통과** — v6으로 Batch 7A 착수 가능.
