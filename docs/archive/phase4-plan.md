# Phase 4 실행 계획 (Codex 1차 리뷰 반영)

> **역할**: Phase 4(vendoring + Source Lock + notices + scan)의 단일 실행 계획서.
> **수명**: Phase 4 진행 중 참조. Phase 4 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: MASTER_PLAN v1.5 §3.5(Source Lock), §4.1–4.3(public-release), §5 Phase 4 / Phase 6, `workbench-selection-2026-04-23.md` A 섹션.

---

## 0. Scope

- **원본**: 11개 Apache-2.0 Claude Code 플러그인
- **편입 대상 (authoritative, Step 0 확정)**: **44개 구성요소** (Skills 15 / Commands 11 / Hooks 5 / Agents 13) — 출처는 [workbench-selection-2026-04-23.md](workbench-selection-2026-04-23.md) A-1~A-4 + 실파일 검증 [phase4-source-lock.md §2 / §5](phase4-source-lock.md)
- **팩 분포**: productivity-pack **42**, analysis-pack **2**
  - ⚠️ selection 요약표 불일치 규명 완료: 총계 45는 hookify `/help` 이중 집계, "productivity 40"은 42의 단순 오기. [phase4-source-lock.md §5.2](phase4-source-lock.md) 참조.
- **game-design-pack**: 유예 (§2.3.1 게이트 미달), 이 Phase에서 건드리지 않음

---

## 1. Step 0 — 선행 고정 작업 (3종)

**Source Lock이 걸리기 전 편집 금지** 원칙(§3.5)을 지키려면, 실편집 전에 아래 3종을 먼저 고정한다.

### 1.1 컴포넌트 실제 파일 목록 확정

각 11개 원본을 열어 CONFIRM 45개가 어느 파일에 대응하는지 1:1 매핑.

산출: `docs/phase4-source-lock.md`의 `## Components` 섹션 — 플러그인 × (컴포넌트명, 원본 상대경로, 유형, 대상 팩) 표.

**exit 절차 (5단계, 모두 통과해야 Step 0.1 종료):**

1. **기준 목록 고정** — `workbench-selection-2026-04-23.md` A-1~A-4를 **authoritative inventory**로 선언. 이 45개가 Phase 4 편입 대상의 진실 원천.
2. **원본 파일 존재 확인** — 각 45개 항목이 §1.3에서 resolve된 원본 디렉토리에 실제 파일로 존재하는지 1:1 확인. 없는 항목은 blocked(§1.3 G 규칙)로 처리.
3. **배치표 재산정** — §2 배치표 Batch별 합계를 원본 파일 존재 확인 결과로 재계산.
4. **팩 분포 재계산** — 각 항목의 `팩` 열을 A-1~A-4의 팩 할당과 일치시켜 productivity / analysis 분포 재산출.
5. **최종 authoritative count 선언** — 45 / 42(selection 요약표) / 44(초기 배치표 합계) 세 수치 불일치의 원인을 한 줄로 기재하고, 최종 확정 값을 **§0 Scope의 "팩 분포"를 덮어쓰며 기록**.

### 1.2 Internal dependency 전수 조사

Codex 리뷰가 1순위 리스크로 지적한 항목. plugin-dev뿐 아니라 모든 세트가 대상.

**조사 대상 참조 유형:**
- skill → agent (SKILL.md 본문에서 agent 이름 호출)
- skill → command (`/xxx` 표기)
- command → agent (command.md 본문)
- hook → skill/command (hook 스크립트 안 path·name 참조)
- agent → skill (agent.md 본문)

**Detection 규칙 (모두 수집):**

각 원본 디렉토리에 대해 `Grep`으로 아래 **모든** 표기법을 검색. 한 형제 구성요소라도 누락 없이 매치되어야 함.

| 표기법 | 예시 | 대상 |
|---|---|---|
| 정확 파일명 | `SKILL.md`, `some-agent.md` | 모든 유형 |
| slug / 디렉토리명 | `skill-development`, `code-reviewer` | 모든 유형 |
| frontmatter `name:` 값 | `name: code-reviewer` | agent/skill |
| `/command-name` | `/review-pr`, `/commit` | command |
| `@agent-name` | `@code-reviewer` | agent |
| 자연어 호출 | `use code-reviewer`, `call the ... agent`, `delegate to ...` | agent |
| 상대경로 | `../agents/foo.md`, `./skills/bar/SKILL.md` | 모든 유형 |
| hooks JSON / hook 스크립트 내 문자열 | `"command": "skill-name"`, hook 파이썬 안의 경로·skill 이름 | skill/command |

**Alias 수집**: 각 구성요소의 정식 이름과 별칭(slug, frontmatter name, 디렉토리명)을 `phase4-source-lock.md`의 `## Aliases` 섹션에 보존. 편입 후 참조 trace 시 이 alias 목록으로 검증.

산출: `docs/phase4-source-lock.md`의 `## Internal Dependencies` 및 `## Aliases` 섹션.

exit: 참조가 하나라도 있는 쌍은 표에 기록. **편입 후 참조가 여전히 resolve되는지**는 배치별 커밋 직전 수동 trace로 재확인.

### 1.3 Source Lock 경로 resolve 4단계 명문화

11개 원본의 로컬 경로 확보 절차. 첫 단계에서 실패해도 다음으로 넘어가며, 4단계에서도 실패 시 해당 플러그인은 Phase 4 진행 중단 리스트에 등재.

| # | 방법 | 전제 | 성공 기준 |
|---|---|---|---|
| 1 | `~/.claude/plugins/installed_plugins.json` 파싱해 source/name 매칭 | 파일 존재 + 유효 JSON | `source` 필드의 marketplace 조합으로 로컬 경로 산출 가능 |
| 2 | `~/.claude/plugins/marketplaces/**/<plugin-name>/` 직접 탐색 | — | 디렉토리 실존 + `.claude-plugin/plugin.json` 존재 |
| 3 | 원본 마켓플레이스 URL로 fresh clone → 임시 디렉토리 | **Source URL이 `THIRD_PARTY_NOTICES.md` / selection 문서 / Phase 1 카탈로그 중 하나에서 확보됨** | 성공하면 version은 `git log -1 --format=%H`로 확정 |
| 4 | 위 모두 실패 (또는 3단계 전제인 URL 미확보) | — | 해당 플러그인을 **"Phase 4 blocked"** 표에 등재 |

> **URL 미확보 시 3단계 skip**: Source URL이 어느 문서에서도 확인되지 않는 플러그인은 3단계(fresh clone)를 건너뛰고 **즉시 4단계로 이동**. URL 없이 임시 clone 시도는 false resolve의 위험.

**Blocked 결정 기준 (G 규칙):**

| blocked 플러그인 성격 | Phase 4 행동 |
|---|---|
| **필수 세트 or dependency provider** (plugin-dev, 또는 internal dependency 표에서 provider로 등장한 플러그인) | **전체 중단** — Phase 4 보류, 사용자 확인 필요 |
| **독립 플러그인** (다른 컴포넌트가 참조하지 않음) | 해당 플러그인 제외 후 나머지 진행 **가능하되**, §6.1 "45개 exit"는 **실패로 표시** → 부분 진행 모드 진입. Phase 4 마감 커밋에 blocked 사유·대응 계획 기재 |

**필수 필드** (source-lock 테이블):
- resolved local path (또는 `BLOCKED`)
- marketplace source URL
- version 또는 commit hash (blocked 시 `N/A`)
- LICENSE evidence path (원본 `LICENSE` 또는 `NOTICE` 파일 실경로)
- LICENSE 내용 확인 완료 여부 (Apache-2.0)
- resolve 단계 번호 (1~4 중 어느 단계에서 성공했는지)

---

## 2. 편입 배치 (Codex 리뷰 반영 — plugin-dev 선행)

Codex 지적: plugin-dev가 self-hosting 세트라 배치 규칙 자체를 정의. **Batch 1에 배치해야 이후 배치가 그 규칙을 따를 수 있음.**

| 배치 | 플러그인 | 컴포넌트 수 | 팩 |
|---|---|---|---|
| **Batch 1A** ⭐ | plugin-dev (7 skills + 1 command + 3 agents) | 11 | productivity |
| **Batch 1A 계** | 1개 플러그인 | **11** | |
| **Batch 1B** | claude-code-setup (1 skill) | 1 | productivity |
|              | claude-md-management (1 skill + 1 command) | 2 | productivity |
| **Batch 1B 계** | 2개 플러그인 | **3** | |
| **Batch 2** | hookify (1 skill + 4 commands + 4 hooks + 1 agent) | 10 | productivity |
|            | mcp-server-dev (3 skills) | 3 | productivity |
| **Batch 2 계** | 2개 플러그인 | **13** | |
| **Batch 3** | pr-review-toolkit (1 command + 6 agents) | 7 | productivity |
|            | feature-dev (1 command + 3 agents) | 4 | productivity |
|            | commit-commands (3 commands) | 3 | productivity |
| **Batch 3 계** | 3개 플러그인 | **14** | |
| **Batch 4** | security-guidance (1 hook) | 1 | productivity |
|            | session-report (1 skill) | 1 | analysis |
|            | playground (1 skill) | 1 | analysis |
|            | + 마감 작업 (Notices 채움, 스캔, CHANGELOG 메타) | — | — |
| **Batch 4 계** | 3개 플러그인 + 마감 | **3** | |
| **총계** | 11개 플러그인 | **44** | |

> Batch 계 합 = 11+3+13+14+3 = 44. 위 Scope의 45와 1 차이. **Step 0 §1.1의 5단계 exit 절차에서 최종 authoritative count 확정 시 해소**.

**승인 지점**: **Batch 1A 완료 후 한 번만** ⭐. plugin-dev(self-hosting 세트)가 파이프라인·배치 규칙을 정의하므로 여기서만 사용자 확인. Batch 1B~4는 자동 진행.

**커밋 단위**: 배치당 1커밋 (총 **5커밋**).

---

## 3. 플러그인별 Sub-task 7단계

각 플러그인마다 다음 순서를 그대로 반복.

| # | 작업 | 산출 |
|---|---|---|
| 1 | Source Lock 기록 (경로/version/LICENSE) | `phase4-source-lock.md`에 엔트리 |
| 2 | 대상 디렉토리 생성 | `plugins/<pack>/{skills,commands,hooks,agents}/<name>/` |
| 3 | 파일 복사 (**편집 금지**) | 원본 그대로 |
| 4 | vendoring 헤더 삽입 (§3.5 양식) | 아래 양식 준수 |
| 5 | 스캔 & 범용화 | 개인경로·계정명·키 발견 시 치환, `modified: minor`/`major` 기록 |
| 6 | Internal dependency resolve 수동 trace | Step 0의 표 대조 |
| 7 | 배치 단위 커밋 대기 | 배치 전체 완료 후 일괄 |

### vendoring 헤더 양식 (§3.5)

```markdown
<!--
vendored-from: [원본 마켓플레이스 URL 또는 리포 경로]
vendored-at: 2026-04-23
original-version: [버전 또는 commit hash]
modified: none | minor | major
-->
```

- `modified: none` — 원문 그대로 복사만
- `modified: minor` — 경로·계정명·하드코딩 값 제거 수준
- `modified: major` — 로직·구조 변경 (selection A 섹션 전부 🟢이라 예상 발생 없음, 발생 시 이유 커밋 메시지에 명시)

---

## 4. 리스크 & 대응 (Codex 리뷰 반영 순위 조정)

| 순위 | 리스크 | 대응 |
|---|---|---|
| **1** | **Internal set dependency 참조 깨짐** (세트 전체, not just plugin-dev) | Step 0에서 참조 표 선제 작성. 배치 커밋 직전 수동 trace |
| **2** | Source Lock 경로 가정 실패 — `marketplaces/` 캐시 경로가 11개 모두에 존재 안 할 수 있음 | 4단계 resolve + Phase 4 blocked 표 |
| **3** | SKILL.md·hook·command 내부 절대경로·사용자 ID 하드코딩 | `scripts/phase4-scan.ps1` + modified:minor 치환 |
| **4** | hookify hooks `python3` vs Windows `python` | Batch 2 진입 전 각 hook 소스 확인, 필요 시 modified:minor |
| **5** | 🟡 major 수정 없을 가능성 | 정상 시나리오. 발생 시 커밋 메시지에 근거 명시 |
| **6** | 원본 plugin.json name 필드 충돌 | 실제로는 구성요소만 편입, 팩 루트 plugin.json만 유지 → 문제 없음 |

---

## 5. 스캔 스크립트 — `scripts/phase4-scan.ps1` (임시)

Phase 6에서 정규화될 `validate-plugins.ps1`와 별개. Phase 4에서만 쓰는 한시적 도구.

**검사 패턴 (fail 처리):**

| 범주 | Regex | 비고 |
|---|---|---|
| 환경변수 하드코딩 키값 | `(?i)^[A-Z0-9_]*(KEY\|TOKEN\|SECRET\|PASSWORD)[A-Z0-9_]*\s*=\s*[^$%<\s].+` | `FOO_KEY = literal-value` 류. `$env:` / `%VAR%` / `<placeholder>` 로 시작하면 placeholder로 간주, fail 제외 |
| `.env` 파일 내부 값 지정 | `(?i)(dotenv\|\.env\|env_file).*(=\|:).*['"][^'"]+['"]` | `.env.example`은 warn만 (빈 값/placeholder 허용) |
| PEM 블록 | `BEGIN .*PRIVATE KEY` | — |
| GitHub Personal Access Token | `ghp_[A-Za-z0-9]{36}` | — |
| OpenAI-style 시크릿 | `sk-[A-Za-z0-9]{20,}` | — |
| 이메일 | `[\w.+-]+@[\w-]+\.[\w.-]+` | — |
| Windows 사용자 경로 | `C:\\\\Users\\\\`, `D:\\\\claude` | 이중 이스케이프 주의 |
| POSIX 사용자 경로 | `/Users/`, `/home/` | — |
| 개인 식별자 | `rwang2gun`, `code1412` | — |

**Placeholder 특례 (warn + allow, fail 제외):**

`.env.example` 뿐 아니라 **vendored 내부 README·튜토리얼·SKILL.md 본문에서 교육 목적으로 등장하는 placeholder**도 동일 처리. 실값과 구분하는 휴리스틱:

| 조건 | 처리 |
|---|---|
| 값이 `<...>`, `{{...}}`, `$...`, `%...%`, `...YOUR...`, `...EXAMPLE...`, `...PLACEHOLDER...`, `your_key_here` 류 | warn + allow |
| 값이 빈 문자열 또는 공백만 | warn + allow |
| 값이 실제 token 형식(`ghp_...`, `sk-...`, 40자 이상 랜덤)이거나 UUID/hash 패턴 | **fail** |
| 주변 3줄 내에 `example`, `placeholder`, `demo`, `sample`, `<your` 중 하나가 있음 | warn + allow |
| 위 중 어느 것도 해당 안 되는 구체 값 | **fail** |

휴리스틱이 판단 불가인 경우 `review-needed`로 표시 후 사람이 확정.

**제외 규칙:**
- `docs/**` 전체 (공개 설치 예시에 `rwang2gun/rwang-workbench` 등장 허용)
- `.git/`, `dist/`, `node_modules/` (혹시 생길 경우)
- 루트 `LICENSE`, `README.md`, `THIRD_PARTY_NOTICES.md`, `CHANGELOG.md`도 스캔 대상 포함 (vendored 내부 사적 언급 제거가 §4.3 요점)
- **편입된 플러그인 내부**의 README/CHANGELOG는 **스캔 대상** — 사적 언급 제거 필수

**출력**: `<file>:<line>:<pattern>` fail 목록. 0건이어야 Phase 4 exit.

**fallback**: gitleaks가 설치된 경우 병행 실행. 없으면 이 스크립트 단독.

---

## 6. Exit Criteria

### 6.1 Phase 4 자체
- [ ] 11개 플러그인 전부 편입 완료 (Step 0 매핑 기준 45개 구성요소 배치)
  - **blocked 발생 시 처리** (§1.3 G 규칙):
    - 필수 세트/provider blocked → Phase 4 **전체 중단**, 사용자 확인까지 exit 판정 보류
    - 독립 플러그인만 blocked → 이 체크박스는 **실패로 표시**하되 나머지 진행. Phase 4 마감 커밋 메시지에 blocked 사유 + 재도전 계획 명시 (**부분 진행 모드**)
- [ ] 모든 편입 파일에 vendoring 헤더 존재 (§3.5 양식)
- [ ] Internal dependency 표의 모든 참조가 편입 후에도 resolve됨 (수동 trace 통과)

### 6.2 §4.1 LICENSE 요건
- [ ] 11개 원본 LICENSE 파일 경로가 `phase4-source-lock.md`에 기록
- [ ] `THIRD_PARTY_NOTICES.md` version/commit/URL 실값으로 채워짐
- [ ] 각 라이선스가 Apache-2.0임을 확인한 evidence 기록

### 6.3 §4.2 비밀값 관리
- [ ] `scripts/phase4-scan.ps1` 0 finding (docs/ 제외)
- [ ] `.mcp.json`이 편입됐다면 토큰·계정 식별자 0건
- [ ] 새 hook/MCP가 비밀값을 요구하는 경우에만 `.env.example` 작성 (그렇지 않으면 skip, 그 판단 결과를 `phase4-source-lock.md`에 한 줄로 기록)

### 6.4 §4.3 개인정보 제거
- [ ] 경로·계정명 스캔 0 finding (Windows 사용자 홈 절대경로, GitHub 계정명, 이메일 등)
- [ ] README/CHANGELOG 포함 모든 **vendored 파일**에 사적 언급 없음
- [ ] 절대경로 → 상대경로 치환 완료

### 6.5 동작 검증
- [ ] `/reload-plugins` 후 두 팩에서 skill 1개씩 최소 트리거 성공
  - **Partial mode 분기** (blocked 플러그인이 있을 때):
    - blocked 플러그인이 트리거 대상 skill의 유일 후보면 → **같은 팩 내 다른 vendored skill** 선택
    - 같은 팩에 대체 skill도 없으면 → 다른 팩의 skill 1개를 대체로 선택하고, 해당 팩은 `/plugin list` 노출 확인만으로 통과
    - 두 팩 다 skill 0개로 귀결되면 Phase 4 전체 중단으로 승격
- [ ] `/plugin list` 출력에 두 팩이 정상 노출

### 6.6 문서 마감
- [ ] `MASTER_PLAN_v1.5.md` §10 상태 `✅ Phase 4 완료 (YYYY-MM-DD)`로 업데이트
- [ ] `CHANGELOG.md` `[Unreleased]` 블록에 Phase 4 한 줄 + 최소 메타 4항 (릴리스 블록 승격은 Phase 8):
  - 헤드라인: `Phase 4 vendoring: 11 plugins, <final-count> components`
  - `Source: docs/archive/phase4-source-lock.md`
  - `Plugins: 11 (blocked: <n>)`
  - `Components final: <authoritative-count>`
  - `Modified: minor=<n>, major=<n>, none=<n>`
  - `Scan: 0 finding (scripts/phase4-scan.ps1)`
- [ ] `phase4-plan.md`와 `phase4-source-lock.md`를 `docs/archive/`로 이동

---

## 7. 확정된 결정사항 (변경 불가)

- 커밋 단위: **배치당 1커밋, 총 5커밋** (Batch 1A / 1B / 2 / 3 / 4)
- 승인 지점: **Batch 1A 완료 후 1회만**, Batch 1B~4 자동
- 시크릿 스캔: `scripts/phase4-scan.ps1` 기본. gitleaks 있으면 병행
- Source Lock intake 문서: `docs/phase4-source-lock.md` → 마감 시 `docs/archive/`
- `validate-plugins.ps1`는 **Phase 6 몫** — Phase 4에서 작성하지 않음

---

## 8. Codex 리뷰 반영 로그

### 8.1 1차 리뷰 (2026-04-23)

| # | Codex 지적 | 반영 위치 |
|---|---|---|
| 1 | 수치 모순 (45 vs 42 vs ~43) | §0 Scope 경고 + §1.1 Step 0.1 |
| 2 | Exit Criteria에 §4.1 LICENSE, `.mcp.json`, `.env.example` 누락 | §6.2 / §6.3 새 항목 |
| 3 | Internal dependency 1순위 리스크 | §1.2 Step 0.2 + §4 순위 1 |
| 4 | plugin-dev를 Batch 1로 | §2 배치표 변경 |
| 5 | Source Lock 경로 4단계 resolve | §1.3 Step 0.3 |
| 6 | 스캔 스크립트화 + allowlist | §5 전체 |
| 7 | 1인 사용자 과잉 설계 축소 | §6.6 CHANGELOG 한 줄, §7 validate는 Phase 6, §2 승인 지점 1회 |

### 8.2 2차 리뷰 (2026-04-23)

| # | Codex 지적 | 반영 위치 |
|---|---|---|
| A | §1.1 exit 절차 부재 — 불일치 해소 구체 단계 필요 | §1.1 5단계 exit 절차 |
| B | Batch 1 크기 14개로 "작게 검증" 목적 희석 | §2 Batch 1A/1B 분할, 승인 지점을 1A 후로 이동 |
| C | Internal dependency detection 규칙 모호 | §1.2 detection 규칙 표 + Aliases 섹션 |
| D | §1.3 3단계 전제(URL 확보) 불명 | §1.3 3단계에 전제 명시, URL 미확보 시 4단계 직행 |
| E | §5 regex 미정 — `.env` 하드코딩 패턴 | §5 regex 구체식 표 + `.env.example` placeholder 특례 |
| F | CHANGELOG 한 줄만 남기면 Phase 8 복원 어려움 | §6.6 최소 메타 4항 추가 |
| G | Blocked 시나리오 결정 기준 부재 | §1.3 G 규칙 표 + §6.1 체크박스에 부분 진행 모드 |

### 8.3 3차 리뷰 (2026-04-23)

Codex 판정: **조건부 실행 가능**. A/C/D/F는 CLOSED 확정, B/E/G는 PARTIAL로 소규모 수정 필요 → 반영 완료.

| # | Codex 지적 | 반영 위치 |
|---|---|---|
| 3-1 | §7이 "4커밋 / Batch 1 완료 후"로 남아 §2와 불일치 (B PARTIAL의 실질 원인) | §7 커밋 수 5 + 승인 지점 Batch 1A 후로 정렬 |
| 3-2 | §5 regex가 vendored 일반 문서의 `API_KEY = your_key_here` 류 튜토리얼 placeholder를 fail로 잡을 위험 (E PARTIAL) | §5 Placeholder 특례 확장 — `.env.example`만이 아니라 vendored 내부 일반 문서에도 적용, 휴리스틱 표 추가 |
| 3-3 | §6.5 동작 검증이 partial mode에서 blocked 플러그인 skill이 유일 후보인 경우 대체 로직 부재 (G PARTIAL) | §6.5 Partial mode 분기 추가 — 같은 팩 대체 → 다른 팩 대체 → 두 팩 0개면 전체 중단 승격 |

---

## 9. 실행 대기 중

**다음 액션**: Step 0 (§1.1–1.3) 시작. 원본 경로 4단계 resolve부터.
