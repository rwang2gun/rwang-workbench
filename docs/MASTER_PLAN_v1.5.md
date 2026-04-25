# rwang-workbench — Master Plan (v1.5)

> **이 문서의 역할**
> `rwang-workbench` 플러그인 제작 프로젝트의 전체 설계·원칙·로드맵을 담는 단일 진실 문서.
> Claude Code가 각 Phase 실행 전 이 문서를 먼저 읽고 맥락을 파악한다.
> Phase 진행 중 판단이 애매할 때 이 문서의 원칙을 따른다.

> **변경 이력**
> - v1.0~v1.3 (2026-04-23): 초판 → 외부 의존 원칙·권장 안내·스키마 검증·Skills ZIP 규칙 등 누적 패치
> - v1.4 (2026-04-23): Codex 2차 리뷰 결과 **전면 간소화**. 1인 사용자 맥락에 맞게 과잉 설계 제거. 주요 변경:
>   - **recommends 시스템 v0.1 범위 축소** — SessionStart 훅·마커·suppress-all 전부 제거, `RECOMMENDED_PLUGINS.md` + 수동 명령어만. 훅은 권장 항목 3개 이상일 때 Phase 9 이후 도입.
>   - **Node.js fallback 의사코드 명시** — `installed_plugins.json` 파싱을 `fs.readFileSync`·`JSON.parse`·`Array.isArray` 기반으로 구체화
>   - **`${CLAUDE_PLUGIN_ROOT}` 검증 게이트** — Phase 2 exit gate에 환경변수 존재 확인 + `import.meta.url` fallback 명시
>   - **Phase 3 acceptance ↔ game-design-pack 게이트 충돌 해소** — 유예 팩은 marketplace.json에 미포함, 생성 결정된 팩만 검증
>   - **Phase 2 exit gate를 `validate-plugins.ps1` 단일 명령으로 통합**
>   - **Phase 9 분기별 점검 → 릴리스 전/실패 제보 시 수동 점검**으로 낮춤
>   - **Skills ZIP 배포를 Phase 8 필수에서 "배포 후 파생 빌드"로 격하**
>   - **7.2 staging 멀티 PC 이동성** — 진행 중 최신 MASTER_PLAN private 동기화 권고 추가
>   - **4.6.1 UX 퇴행 수정** — 자동 훅 제거로 원인 소멸
>   - 문서 길이 600줄 → 약 450줄
> - v1.5 (2026-04-23): Phase 2 종료 산출물(`Work/workbench-selection-2026-04-23.md`) 결정사항 + Codex 3차 리뷰 지적 7건 반영:
>   - **§4.6.2 스키마 guard 강화** — `data.plugins` 타입 체크에 `!data`·`Array.isArray` 방어 추가
>   - **§4.6.2 용어 정리** — "pseudo-implementation" → "reference implementation", 본체 명령어 로직은 "manual command logic"
>   - **§4.6.1 recommends.json v0.1 도입 확정** — Phase 2 결정 반영. `/productivity-pack:check-recommended`를 v0.1에 포함, JSON도 v0.1에 함께 생성 (기계 파싱 소스 필수). "외부 의존 3개 이상 누적 시" 조건 삭제.
>   - **§4.6.1·§5 Phase 9 훅 재도입 조건 완화** — "3개 이상 누적 시" → "실제 pain report 있을 때"
>   - **§5 Phase 2 Exit Gate fixture 구체화** — fixture A/B/C 파일 구조·설치 명령어·기대 출력 명시 (Phase 2에서 `Work/phase2-fixtures/`에 생성 완료)
>   - **§5 validate-plugins.ps1 시점 정리** — Phase 2: `Work/phase2-validate-plugins.ps1` 임시 → Phase 6: `scripts/validate-plugins.ps1` 승격
>   - **§7.2 포터빌리티 보강** — Phase 3 acceptance에 "fresh clone 또는 두 번째 PC에서 통과" 조건 추가

---

## 1. 프로젝트 목표

설치된 Claude Code 플러그인들 + 본인 기존 자산에서 **범용적인 구성요소만 선별 편입**해 본인 전용 플러그인 마켓플레이스 `rwang-workbench`를 제작한다.

- **메인 배포 타겟:** Claude Code (풀스펙)
- **부가 배포 타겟 (배포 후 파생):** claude.ai 채팅 (Skills ZIP 파생 빌드)
- **공개 범위:** Public (GitHub public 리포)
- **사용자:** 제작자 본인 1명 (현재), 향후 팀원 공유 가능성 열어둠

---

## 2. 플러그인 아키텍처

### 2.1 리포 구조

```
rwang2gun/rwang-workbench/              ← GitHub public 리포 (최종 산출물)
│
├── .claude-plugin/
│   └── marketplace.json                ← 마켓플레이스 루트 (생성된 팩만 등록)
│
├── plugins/
│   ├── analysis-pack/                  ← 데이터·트렌드 분석 영역
│   │   ├── .claude-plugin/
│   │   │   ├── plugin.json             ← 표준 스키마만
│   │   │   └── recommends.json         ← (있으면) 외부 의존 메타
│   │   ├── skills/
│   │   ├── commands/
│   │   └── .mcp.json
│   │
│   ├── productivity-pack/              ← 업무 자동화·문서 영역
│   │   ├── (analysis-pack과 동일 구조)
│   │   └── commands/
│   │       └── check-recommended.md    ← /productivity-pack:check-recommended
│   │
│   └── game-design-pack/               ← (2.3.1 게이트 통과 시에만 존재)
│       └── (동일 구조)
│
├── dist/                               ← 빌드 산출물 (gitignore)
│
├── scripts/
│   ├── validate-plugins.ps1            ← 팩 구조 + plugin.json 스키마 검증 통합 도구
│   └── build-skills-zip.ps1            ← claude.ai 파생 빌드 (배포 후 선택 사항)
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── INSTALL.md
│   ├── RECOMMENDED_PLUGINS.md          ← 외부 권장 플러그인 상세 안내 (수동 참조)
│   └── CHANGELOG.md
│
├── LICENSE                             ← MIT 권장
├── THIRD_PARTY_NOTICES.md              ← vendored 라이선스 고지
├── README.md
└── .gitignore

---

rwang-workbench-staging/                ← 별도 local-only 폴더 (7.2 참조)
├── MASTER_PLAN_v{N}.md
├── backup/
└── phase{N}-*.md
```

### 2.2 팩 분리 원칙

- **영역별 분리** (단일 플러그인 X, 강도별 X)
- **크로스 팩 의존 금지** — 각 팩은 독립 설치·독립 동작
- **MCP 서버는 팩 단위로 귀속** — 팩 설치 안 했으면 그 MCP도 연결 안 됨
- 공통 유틸 필요해지면 그때 `core-pack` 만듦 (지금은 YAGNI)

### 2.3 각 팩의 역할 정의

| 팩 | 도메인 | 예상 포함 내용 |
|---|---|---|
| `analysis-pack` | 데이터 분석·SNA·트렌드 보고서·HTML 빌드 | CSV 파이프라인, 자립형 HTML 리포트 생성, 범용 분석 템플릿 |
| `productivity-pack` | 메일·미팅·GCP·Git 동기화·PR 리뷰 | Git 동기화 명령어, GCP 예산 모니터, PR 리뷰, 범용 문서 자동화, `/productivity-pack:check-recommended` |
| `game-design-pack` | 게임 기획·전투 설계·Godot 개발·다이어그램 | (조건부 생성) |

#### 2.3.1 game-design-pack 생성 게이트

Phase 1 카탈로그 결과 `game-design-pack`에 들어갈 vendored 소스가 거의 없음. Phase 2 종료 시점에 게이트 판정:

| 조건 | 판정 |
|---|---|
| 구체적 편입 자산 + 신규 작성 스킬 합계 **≥ 2개** | **팩 생성 진행** |
| 2개 미만 | **팩 유예** — Phase 9 이후 재논의, `marketplace.json`에 포함하지 않음 |

**유예 시 처리:**
- `plugins/game-design-pack/` 디렉토리 자체를 만들지 않음
- `marketplace.json` `plugins` 배열에 엔트리 미포함
- 초기 배포는 analysis-pack + productivity-pack 2개 팩만

게이트 판정은 Phase 2 산출물에 "game-design-pack 구성 후보" 섹션으로 기록.

---

## 3. 편입 원칙 (가장 중요)

### 3.1 범용도 등급

- **L0 범용** — 어떤 프로젝트·도메인이든 쓸 수 있음 → 편입 대상
- **L1 도메인 종속** — 큰 범주 종속 → 편입 대상 (해당 팩에 배치)
- **L2 프로젝트 종속** — 특정 게임·특정 포맷 종속 → **편입 제외**

### 3.2 편입 제외 예시 (본인 제작 스킬 중)

- `zzz-skill-tagger` — ZZZ 특정 데이터 구조 종속
- `subculture-trend-report` — 특정 월간 보고서 포맷 종속

→ **프로젝트 리포**에 `.claude/skills/` 로 귀속 (Claude Code `--add-dir` 기반 자동 인식).

### 3.3 편입 후 원본 처리

- 원본 플러그인은 **삭제하지 않고 `/plugin disable`** 로 비활성화만.
- 편입본 업데이트 시 원본 참조 필요.
- `disable` = 파일 유지 + 세션 로드 제외 → 컨텍스트 절약.

### 3.4 의존성 세트 편입

스킬이 같은 플러그인의 Command·Hook을 참조하면 **함께 편입**. Phase 1 카탈로그의 "의존성 그래프"에서 확인.

### 3.5 vendoring 메타 주석

편입된 모든 구성요소의 SKILL.md·Command .md 맨 위에 추가:

```markdown
<!--
vendored-from: [원본 마켓플레이스 URL 또는 리포 경로]
vendored-at: YYYY-MM-DD
original-version: [버전 또는 commit hash]
modified: [수정 여부: none / minor / major]
-->
```

**Phase 4 Source Lock:** 원본 파일 편집 전 **반드시** `vendored-from` + `original-version` 기록 먼저. commit hash는 원본 리포 `git log -1` 또는 plugin.json의 version 필드에서 취득.

### 3.6 외부 플러그인 의존성 처리

일부 플러그인은 **편입하지 않고 외부 의존으로 선언**.

#### 3.6.1 외부 의존 선택 기준

다음 중 하나라도 해당 시 검토:
1. **규모가 큼** — 세트 구성요소 **15개 이상**
2. **활발히 유지보수됨**
3. **라이선스 리스크** (GPL 전염성 등)
4. **이미 생태계에 안착**

#### 3.6.2 Self-hosting 예외

**본 워크벤치 자체 개발·유지보수에 쓰이는 플러그인**은 위 기준에 걸려도 편입 우선. 예: `plugin-dev` 세트 (11개). self-hosting 명분 메모는 `recommends.json` 또는 `docs/RECOMMENDED_PLUGINS.md`에 기록 (plugin.json 아님).

#### 3.6.3 판단 결과

| 세트 | 결정 |
|---|---|
| `codex` (14개) | **외부 의존** |
| `plugin-dev` (11개) | **편입** (self-hosting 예외) |
| `pr-review-toolkit` (7개) | **편입** |
| `hookify` (10개) | **편입** |
| `feature-dev` (4개) | **편입** |
| `mcp-server-dev` (3개) | **편입** |

#### 3.6.4 외부 의존 구현 방식

해당 팩 디렉토리에 `.claude-plugin/recommends.json` 생성:

```json
{
  "self_hosting_note": "(optional) 적용 사유",
  "recommends": [
    {
      "name": "codex",
      "marketplace": "openai/codex-plugin-cc",
      "install_command": "/plugin marketplace add openai/codex-plugin-cc && /plugin install codex@openai-codex",
      "reason": "/codex:review 등 일상 사용 명령어 제공",
      "required": false,
      "last_verified": "2026-04-23"
    }
  ]
}
```

- Claude Code 본체는 이 파일을 읽지 않음. 본 플러그인 내 명령어만 읽어서 활용.
- `docs/RECOMMENDED_PLUGINS.md`에 동일 내용의 사람이 읽기 좋은 버전 유지.
- 팩 내부 Skill·Command가 외부 플러그인을 호출할 때는 **방어적 작성** (없을 때 명시적 에러).

#### 3.6.5 단일화 결정

| 중복 쌍 | 결정 |
|---|---|
| `skill-creator` vs `plugin-dev/skill-development` | plugin-dev 세트 편입, skill-creator 제외 |
| `code-review` vs `pr-review-toolkit/review-pr` | pr-review-toolkit 편입, code-review 제외 |
| `github` MCP vs `commit-commands` + `gh` CLI | commit-commands + gh 편입, github MCP 외부 의존 |

### 3.7 Phase 2 2차 거르기

Phase 1의 🟢 45개를 간단히 재검토:
- **✅ CONFIRM 목록** — Phase 4 편입 대상 확정 (1줄 근거)
- **📋 Deferred/Dropped appendix** — 제외한 것들 간단 메모

판정 기준:
| 상태 | 기준 |
|---|---|
| CONFIRM | 본인 최근 3개월 내 사용 경험 또는 본 워크벤치 작업에 즉시 필요 |
| Deferred | 가치는 있으나 즉시 필요성 불확실. Phase 9 이후 재평가 |
| Dropped | 중복·불일치·L2 재분류 |

---

## 4. Public 전환에 따른 기준

### 4.1 LICENSE

- MIT 권장. 리포 루트에 `LICENSE` 파일 필수.
- vendored는 원본 라이선스 준수. MIT/Apache-2.0/BSD는 재배포 가능(저작권 고지 유지), GPL은 신중, 미표기는 편입 제외.

### 4.2 비밀값 관리

- API 키·토큰·계정 정보 코드 포함 금지. `.env` 사용, `.gitignore`에 포함, `.env.example`로 키 목록 공유.
- Phase 4 편입 중 원본 하드코딩 키 발견 시 환경변수로 치환.

### 4.3 개인 정보 제거

- vendored 시 내부 경로·ID·이메일·계정명 제거. 절대 경로는 상대 경로로.
- README·CHANGELOG에서도 사적 언급 배제.

### 4.4 Discoverability

- README에 용도·설치법·구성요소 명시.
- plugin.json `keywords`로 `/plugin search` 노출.
- CHANGELOG 유지.

### 4.5 Public 전환 게이트 체크리스트 (Phase 8 직전)

- [ ] 라이선스 검토 완료
- [ ] `THIRD_PARTY_NOTICES.md` 생성
- [ ] 시크릿 스캔 통과 (`gitleaks` 또는 `trufflehog`, 0 finding)
- [ ] `.mcp.json` 토큰/계정 식별자 0건
- [ ] 절대경로·계정명 노출 0건
- [ ] `.env.example` 작성
- [ ] `.gitignore` 검증 (`.env`, `dist/`, 임시 파일, 개인 메모)
- [ ] 공개 불가 자산 최종 확인

통과 결과는 `docs/release-checklist-v{버전}.md`로 보존.

### 4.6 권장 플러그인 안내 — v0.1 구현 (v1.5 명확화) ⭐

외부 의존이 현재 **codex 1개**. 자동 훅·마커 시스템은 과잉이므로 제외하되, **기계 파싱 소스(`recommends.json`) + 조회 명령어(`/check-recommended`)는 v0.1에 포함**. Phase 2 결정 반영.

#### 4.6.1 v0.1 구성 요소

1. **`docs/RECOMMENDED_PLUGINS.md`** — 모든 외부 권장 플러그인의 용도·설치 명령어·last_verified 날짜를 사람이 읽기 좋게 정리. 수동 참조용.
2. **`.claude-plugin/recommends.json`** (각 팩에, 필요한 팩만) — 기계 파싱 가능한 동일 정보. `/productivity-pack:check-recommended`가 읽어 표로 출력. **v0.1에 포함 확정 (Phase 2 결정).**
3. **`/productivity-pack:check-recommended`** 수동 명령어 — 전체 팩의 권장 플러그인 현재 설치 상태 조회. Phase 5에서 구현.

**v0.1에 포함하지 않는 것:**
- SessionStart 훅 (자동 안내 시스템)
- 마커 파일 (`recommend-check.*.marker`, `suppress-all`)
- 첫 설치 시 1회 자동 안내 로직

**자동 훅 도입 시점 재검토 (v1.5 완화):** 사용자가 "자주 확인하기 번거로움"을 **실제 pain report**로 제기할 때. 외부 의존 누적 개수 조건(기존 "3개 이상")은 **지표일 뿐 트리거 아님** — 개수가 많아도 수동으로 충분하면 훅은 불필요.

#### 4.6.2 `/productivity-pack:check-recommended` 동작

**형제 팩 발견 로직:**

1. `${CLAUDE_PLUGIN_ROOT}`가 set되어 있으면 그 경로에서 상위로 올라가며 `.claude-plugin/marketplace.json` 검색
2. `${CLAUDE_PLUGIN_ROOT}`가 없으면 `import.meta.url` 또는 `process.cwd()` 기반 현재 명령어 파일 경로에서 상위 탐색
3. `marketplace.json`의 `plugins` 배열에서 팩 이름 목록 취득
4. 각 팩 경로에서 `.claude-plugin/recommends.json` 읽기 시도
5. **누락 허용:** 파일 없으면 "권장 없음"으로 표시

**설치 여부 판별 — reference implementation (Node.js, Phase 5 `manual command logic` 구현 시 본체로 확장):**

```javascript
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const INSTALL_LIST = join(homedir(), '.claude', 'plugins', 'installed_plugins.json');

function getInstalledUserPlugins() {
  if (!existsSync(INSTALL_LIST)) {
    return { ok: false, reason: 'file-missing' };
  }
  let raw, data;
  try {
    raw = readFileSync(INSTALL_LIST, 'utf8');
    data = JSON.parse(raw);
  } catch (e) {
    return { ok: false, reason: 'parse-failed', error: e.message };
  }
  // v1.5 강화: data 자체의 truthiness + plugins 필드 존재 + object 타입 + Array 거부
  if (!data || typeof data !== 'object' || !data.plugins || typeof data.plugins !== 'object' || Array.isArray(data.plugins)) {
    return { ok: false, reason: 'unexpected-schema' };
  }
  const names = Object.keys(data.plugins).filter(key => {
    const entries = data.plugins[key];
    return Array.isArray(entries) && entries.some(e => e?.scope === 'user');
  });
  return { ok: true, names };
}
```

> **용어 (v1.5):** 위 코드는 **reference implementation** — 설계 시 고려할 최소 형태를 보여주는 참조. Phase 5에서 실제 `/productivity-pack:check-recommended`의 **manual command logic**을 작성할 때 이 형태를 골격으로 사용하되, 에러 메시지·출력 포맷·경로 fallback은 실환경 검증 결과에 맞춰 확정.

**실패 시 출력 (non-blocking):**

```
💡 권장 플러그인 상태를 자동 확인하지 못했습니다.
   (사유: file-missing | parse-failed | unexpected-schema)
   /plugin list 로 직접 확인하거나 docs/RECOMMENDED_PLUGINS.md 를 참조하세요.
```

**정상 출력:** 팩 | 권장 플러그인 | 설치 상태 (✅/❌) | 용도 표.

#### 4.6.3 commands/ vs skills/ 선택 정책

- **vendored 항목:** 원본 방식 그대로 유지
- **신규 작성:** `skills/<name>/SKILL.md` with `user-invocable: true` 선호 (plugin-dev 권고)
- **예외:** `/productivity-pack:check-recommended`는 상태 조회 명령이라 `commands/*.md`로 작성 (본 시점 결정, Phase 3 스캐폴드 시 최종 확정)

### 4.7 claude.ai Skills ZIP 파생 빌드 (배포 후 선택)

v1.3는 Phase 8 필수로 두었으나 v1.4는 **배포 후 파생 빌드**로 격하. Phase 8에서는 Claude Code 배포까지만. ZIP 빌드는 필요 시 별도 작업.

**포함 대상 (Skills ZIP):** `skills/**/SKILL.md` + 리소스 (references/, scripts/, assets/)

**제외 대상:** `commands/**`, `hooks/**`, `hooks.json`, `.mcp.json`, `agents/**`, `.claude-plugin/recommends.json`

**손실 기능 명시:** ZIP과 함께 `dist/{팩이름}-claude-ai-NOTICE.md` 생성 — claude.ai에 업로드 후 사용자가 누락 기능 확인 가능.

**구현:** `scripts/build-skills-zip.ps1`. 실행은 배포 후 별도.

---

## 5. 작업 로드맵 (전체 Phase)

### Phase 1: 구성요소 카탈로그 ✅ 완료
### Phase 2: 편입 대상 선별 + Exit Gate (현재)

**Phase 2 본작업:**
- 카탈로그 검토 → 편입 여부 결정 (🟢/🟡/🔴)
- **3.7** 적용: CONFIRM 확정 목록 + Deferred/Dropped appendix
- **3.6.5** 단일화 결정 적용
- **3.6** 외부 의존 판별: codex → 외부, plugin-dev → 편입(self-hosting)
- **2.3.1** game-design-pack 게이트 판정 (자산 2개 이상?)
- 라이선스 호환성, 팩 배치 결정

**Phase 2 Exit Gate — 환경 및 스키마 검증 (통합, v1.5 구체화):**

Phase 2에서 임시 스크립트 `$env:CLAUDE_WORK_ROOT\Work\phase2-validate-plugins.ps1`로 수행. Phase 6에서 `scripts/validate-plugins.ps1`로 **승격**하며 rwang-workbench 리포 내부로 이관(경로·팩 검증 로직 추가).

**fixture 구조 (Phase 2에서 `$env:CLAUDE_WORK_ROOT\Work\phase2-fixtures\` 생성):**

```
phase2-fixtures/
├── fixture-a-minimal/
│   ├── .claude-plugin/
│   │   ├── marketplace.json       ← name·owner·plugins[name,source,description]
│   │   └── plugin.json            ← {name, description} 2필드만
│   └── skills/hello/SKILL.md      ← "echo $CLAUDE_PLUGIN_ROOT" 한 줄
├── fixture-b-with-recommends/
│   ├── .claude-plugin/
│   │   ├── marketplace.json
│   │   ├── plugin.json            ← A와 동일
│   │   └── recommends.json        ← codex 1개 엔트리
│   └── skills/hello/SKILL.md
└── fixture-c-unknown-field/
    ├── .claude-plugin/
    │   ├── marketplace.json
    │   └── plugin.json            ← "xyz_unknown": "test" 추가
    └── skills/hello/SKILL.md
```

**실행 절차 (자동 부분 + 인터랙티브 부분 분리):**

1. **자동 (PowerShell)**: `powershell -NoProfile -File Work\phase2-validate-plugins.ps1 -FixturesRoot Work\phase2-fixtures`
   - 각 fixture의 plugin.json 파싱·스키마 체크·unknown 필드 검출
   - 통과 기준: A/B `name + description` 존재 + unknown 필드 없음 / C는 unknown 필드 감지

2. **인터랙티브 (Claude Code 세션)** — 자동 부분 통과 후:
   ```
   /plugin marketplace add <FixturesRoot>\fixture-a-minimal
   /plugin install hello@fixture-a
   # hello skill 트리거 → $CLAUDE_PLUGIN_ROOT 출력 관찰
   /plugin uninstall hello@fixture-a
   /plugin marketplace remove fixture-a
   ```
   B, C도 동일 반복. C는 **"unknown field xyz_unknown" 경고 발생 여부** 관찰.

3. **기대 출력:**
   - A/B 경고 없이 로드
   - C는 경고 발생 (발생 안 하면 "plugin.json은 lenient" → `recommends.json` 분리가 **설계 선택**으로 격하됨을 메모)
   - `$CLAUDE_PLUGIN_ROOT` set이면 §4.6.2 primary path 유효 / unset이면 `import.meta.url` fallback 필수

4. **결과 기록:**
   - 모두 통과: `Work\phase2-exit-gate-OK.md` 간단 메모
   - 실패 또는 연기: `Work\phase2-exit-gate-report.md` 상세 기록
   - Phase 2 최종 판정은 `Work\workbench-selection-{날짜}.md`의 G 섹션에 기재

**연기 허용 조건:** 자동 부분 PASS + 인터랙티브 슬래시 명령 수행이 어려울 경우, 판정을 **"Conditional Go (연기)"**로 두고 Phase 3 스캐폴드 acceptance에 흡수 가능 (실제 rwang-workbench 리포 `/plugin marketplace add` 단계에서 동일 검증).

**출력:** `workbench-selection-{날짜}.md` (+ OK 또는 exit-gate-report)

### Phase 3: rwang-workbench 스캐폴드

**작업:**
- 로컬 디렉토리 초기화 (2.1 구조)
- Git 리포 초기화 + GitHub public 리포 생성
- `marketplace.json` (**2.3.1 게이트 통과한 팩만** 등록), N개 `plugin.json` (표준 스키마), 필요한 팩에 `recommends.json`, LICENSE, README, THIRD_PARTY_NOTICES.md, `.gitignore`
- `docs/RECOMMENDED_PLUGINS.md` 초안
- MASTER_PLAN + Phase 1·2 산출물 `docs/`로 이관

**Phase 3 Acceptance Criteria (v1.5 포터빌리티 보강):**

- [ ] 로컬 `/plugin marketplace add` 등록 성공
- [ ] `marketplace.json`에 등록된 **모든 팩**이 경고 없이 표시 (유예 팩은 등록되지 않아 검증 대상 아님)
- [ ] **등록된 각 팩** `/plugin install` → 빈 팩이어도 설치 성공 → `/plugin uninstall` 제거 성공
- [ ] `.gitignore`에 `.env`, `dist/`, 개인 아카이브 포함
- [ ] `recommends.json`이 plugin.json 스키마 경고 유발하지 않음 (Phase 2 exit gate 결과와 일치)
- [ ] **포터빌리티 검증 (v1.5 신규)** — 다음 중 하나로 통과 확인:
  - (a) **fresh clone 검증**: 별도 임시 디렉토리에서 `git clone` 후 `/plugin marketplace add [clone-path]` → install → skill 1개 트리거. 절대경로·개인 식별자 의존 0건.
  - (b) **두 번째 PC 검증**: `$env:CLAUDE_WORK_ROOT`만 $PROFILE에 선언된 다른 Windows PC에서 동일 시퀀스 통과. 기존 staging 폴더·개인 메모·아카이브 없이 공개 리포만으로 동작.
  - 둘 다 여의치 않으면 Phase 8 Public 게이트 전까지 연기하되 그 사실을 명시 기록.
- [ ] Phase 2 Exit Gate 인터랙티브 부분이 연기되었다면 본 Phase 3 acceptance에서 함께 관찰 (fixture 경로는 Phase 2 결과 재활용)

### Phase 4: 편입 작업

- 🟢 대상: 원본 복사 → 팩 배치 + vendored-from 주석 (**Source Lock 선행**, 3.5)
- 🟡 대상: 범용화 수정 + modified: major
- 내부 의존 세트 함께 이동
- 비밀값·개인정보 제거
- 외부 의존(codex 등)은 편입하지 않고 `recommends.json`에만 등록

### Phase 5: 본인 자산 흡수 및 신규 작성

- 본인 래퍼·동기화 명령어 흡수/신규 (`/sync-to-git` 등)
- draw.io MCP, GCP 관련 MCP 번들 정의
- Git pre-commit 등 Hook 작성
- **4.6 권장 플러그인 안내 v0.1 구현 (v1.5 확정):**
  - `docs/RECOMMENDED_PLUGINS.md` 작성
  - **`plugins/productivity-pack/.claude-plugin/recommends.json` 작성** (codex 1개 엔트리) — Phase 3 스캐폴드에서 빈 파일 생성, Phase 5에서 엔트리 채움
  - `/productivity-pack:check-recommended` 명령어 (§4.6.2 manual command logic) — reference implementation 기반
  - SessionStart 훅은 **도입하지 않음** (실제 pain report 접수 시 Phase 9에서 재검토)
- game-design-pack 생성된 경우 범용 게임 기획 스킬 신규 작성

### Phase 6: 빌드 & 로컬 검증

- `validate-plugins.ps1` 작성 (Phase 2 exit gate에서 만든 스크립트를 정규화)
- 로컬 `/plugin marketplace add [로컬경로]` 자가 설치 테스트
- 각 팩 독립 설치·동작 확인, Skill 트리거, MCP 연결 확인
- `/productivity-pack:check-recommended` 동작 검증:
  - 정상 경로(installed_plugins.json 존재)
  - fallback 경로(임시로 파일 rename 후 테스트) → non-blocking 경고 확인
  - `${CLAUDE_PLUGIN_ROOT}` 없는 케이스 시뮬레이션

### Phase 7: 원본 플러그인 비활성화

- 편입 완료·검증 후 원본 `/plugin disable`
- **외부 의존 플러그인(codex 등)은 비활성화하지 않음**
- `~/.claude/skills/` 중 편입된 것 정리, 중복 로드 방지

### Phase 8: 배포 & 운영 개시

- 4.5 Public 게이트 통과
- GitHub public 리포 푸시
- `/plugin marketplace add rwang2gun/rwang-workbench`로 재설치 확인
- v0.1.0 태그 + CHANGELOG 시작
- **claude.ai Skills ZIP 빌드는 배포 후 필요 시 수행** (4.7, Phase 8 필수 아님)

### Phase 9 이후: 지속 운영

- 새 스킬 추가 시 범용도 판단 → 팩 배치
- 원본 플러그인 업데이트 확인은 수동, 분기별 아님 (강박 금지)
- **recommends 재검증**: 분기 점검 대신 **"릴리스 전 또는 `/check-recommended` install 실패 제보 시"** 수동 실행. 유효하면 `last_verified` 갱신, 무효하면 `RECOMMENDED_PLUGINS.md`·`recommends.json` 동시 업데이트.
- Deferred 항목 재평가 (필요 시)
- **권장 안내 SessionStart 훅 도입 재검토 (v1.5 완화)**: **실제 pain report가 접수될 때만**. 외부 의존 누적 개수는 더 이상 자동 트리거가 아님.

---

## 6. 중요 판단 원칙

1. **편입 vs 제외 애매** → 3.1 등급 → 그래도 애매하면 제외 (나중 추가 쉬움)
2. **편입 vs 외부 의존** → 3.6 기준. self-hosting 예외(3.6.2) 우선.
3. **CONFIRM vs Deferred** → 3.7 기준. 최근 3개월 사용 이력 없고 즉시 필요성 불확실이면 Deferred.
4. **팩 A vs B 애매** → description 주 키워드 영역 → 그래도 애매하면 사용자 확인
5. **파괴적 작업 전 Git 커밋**
6. **본인 제작 자산은 Phase 4 편입 대상 아님**
7. **Public 리포 원칙** — 민감 정보 유출 의심 시 즉시 중단
8. **작업 단위는 작게** — Phase 내에서도 쪼개서 단계별 확인
9. **비표준 필드는 plugin.json 밖으로** — `recommends.json` 또는 `docs/`
10. **과잉 설계 경계 (v1.4)** — 외부 의존이 1~2개일 땐 수동 안내·수동 점검만. 자동화는 규모 커질 때 도입.

---

## 7. 환경 전제

> 본 프로젝트의 일차 목표는 **여러 PC 간 작업 환경 포터빌리티**다. 절대경로·하드코딩은 버그로 간주하고 환경변수로 추출.

- 작업 PC: Windows (멀티 디바이스)
- Git 리포 관리: `rwang2gun/ClaudeMD` 에 `~/.claude` 동기화
- 새 PC 부트스트랩: `git clone` + draw.io MCP 재등록 루틴
- 기존 커스텀 자산: `zzz-skill-tagger`, `subculture-trend-report`, `claude-design-prompt` (Phase 1 실재 확인)

### 7.1 경로 표기 규칙

| 의미 | 표기 |
|---|---|
| Claude 설정 루트 | `~/.claude/` 또는 `$env:USERPROFILE\.claude\` |
| 플러그인 디렉토리 | `~/.claude/plugins/` |
| 사용자 스킬 디렉토리 | `~/.claude/skills/` |
| 설치된 플러그인 목록 | `~/.claude/plugins/installed_plugins.json` (fallback은 4.6.2) |
| 작업 루트 | `$env:CLAUDE_WORK_ROOT` |
| Phase 1 카탈로그 | `$env:CLAUDE_WORK_ROOT\Work\workbench-catalog-{YYYY-MM-DD}.md` |
| Staging 폴더 | `$env:CLAUDE_WORK_ROOT\rwang-workbench-staging\` |
| 플러그인 리포 | `$env:CLAUDE_WORK_ROOT\rwang-workbench\` |

### 7.2 Git 추적 정책 및 멀티 PC 포터빌리티

| 디렉토리 | Git 추적 | 공개 | 비고 |
|---|---|---|---|
| `rwang-workbench/` | ✅ tracked | 🟢 public | 최종 산출물, GitHub public |
| `rwang-workbench-staging/` | ❌ local-only | 🔴 non-public | 작업 문서 |
| `rwang-workbench-staging/backup/` | ❌ local-only | 🔴 non-public | 구버전 아카이브 |
| `$env:CLAUDE_WORK_ROOT\Work\` | ❌ local-only | 🔴 non-public | Phase 산출물 임시 |

**멀티 PC 포터빌리티 (Phase 1~3 진행 중):**

staging이 local-only라 여러 PC에서 설계 작업을 이어가려면 추가 동기화가 필요함. 권고:

- **간단 방식:** 최신 `MASTER_PLAN_v{N}.md`만 Private Gist 또는 OneDrive/Dropbox 같은 private 동기화 경로에 복사. 다른 PC에선 해당 파일 download해서 `$CLAUDE_WORK_ROOT\rwang-workbench-staging\`에 배치.
- **철저한 방식:** staging 전체를 별도 private GitHub 리포로 관리. 단, backup/ 폴더 크기와 개인 Phase 노트 포함 여부를 의식.
- **본 프로젝트 기본:** Phase 3까지는 한 PC에서 완주 권장. Phase 3 완료 후 MASTER_PLAN 최신본이 `rwang-workbench/docs/`(public)로 이관되므로, 그때부턴 자연스레 멀티 PC 공유 가능.

**Phase 3 완료 후:** MASTER_PLAN 최신 버전을 `rwang-workbench/docs/`로 복사 이관. staging 원본은 삭제하지 않고 보존 (롤백용).

**새 PC 셋업:**
- `$PROFILE`에 `$env:CLAUDE_WORK_ROOT = "..."` 한 줄 추가
- `git clone rwang2gun/rwang-workbench` (공개 리포만)
- staging이 필요하면 위 포터빌리티 방법 중 선택

**금지:** 문서·프롬프트에 계정명·절대 드라이브명 직접 노출.

---

## 8. 현재 상태

- ✅ 설계 고정 v1.0 (2026-04-23)
- ✅ Phase 1 완료 (2026-04-23)
- ✅ 설계 보강 v1.1 (2026-04-23)
- ✅ 설계 패치 v1.2 (2026-04-23)
- ✅ 설계 패치 v1.3 (2026-04-23)
- ✅ 설계 간소화 v1.4 (2026-04-23) — Codex 2차 리뷰 전면 반영, recommends 시스템 v0.1 축소, 문서 600→450줄
- ✅ Phase 2 완료 (2026-04-23) — `Work/workbench-selection-2026-04-23.md`. CONFIRM 45, Deferred 6, Dropped 18. Exit Gate 자동 부분 PASS, 인터랙티브 부분은 Phase 3 acceptance에 흡수.
- ✅ 설계 패치 v1.5 (2026-04-23) — Phase 2 결정 + Codex 3차 리뷰 7건 반영 (스키마 guard, recommends.json v0.1 도입, 훅 재도입 완화, fixture 구체화, validate-plugins 승격 경로, 포터빌리티, 용어 정리)
- 🔶 game-design-pack **유예** — Phase 2 결정. `marketplace.json` 미포함, draw.io 헬퍼 skill 재평가 큐로. 초기 배포는 analysis-pack + productivity-pack 2개.
- ✅ Phase 3 완료 (2026-04-23) — 스캐폴드 + GitHub public 리포 생성, 마켓플레이스 등록 + 두 팩 install/uninstall 검증, fresh clone 포터빌리티 통과(로컬 Windows 절대경로), MASTER_PLAN `docs/`로 이관 완료.
- ✅ Phase 4 완료 (2026-04-23) — 11개 Apache-2.0 플러그인 vendoring, 44개 구성요소 편입 (productivity-pack 42 / analysis-pack 2), Source Lock + 헤더 + dependency trace + 스캔(0 finding). 5배치 커밋(Batch 1A/1B/2/3/4). `code-reviewer` 이름 충돌은 Option B rename(code-reviewer-feature / code-reviewer-pr)으로 해결. `hooks/hooks.json`은 hookify+security-guidance 병합. 상세: `docs/archive/phase4-source-lock.md` + `docs/archive/phase4-plan.md`. §6.5 런타임 검증 통과 (desktop app `/reload-plugins` → 18 skills 로드 → `plugin-structure`/`session-report` skill 배너 확인, CHANGELOG에 기록). Phase 5 이월 이슈: hookify Python hook이 Windows에서 `python3` 미존재로 non-blocking 실패(Phase 4 plan §4 Risk #4 발현).
- ✅ Phase 5 완료 (2026-04-24) — 4배치 커밋(5A/5B/5C/5D). **5A**: `hooks.json` 5개 command `python3` → `python` 치환 + README Prerequisites 섹션 + 플랫폼 한계 투명 고지. vendored `hooks/*.py`·`core/*.py` 7개 `modified: none` 유지. **5B**: `/productivity-pack:check-recommended` (Node 16+ ESM) + `docs/RECOMMENDED_PLUGINS.md` 3항 보강(초기 one-liner + `/check-recommended` 가이드 + MCP 서브섹션) + 12 cells 전수 pass(Cell 11 md5 무변화, Cell 12 `import.meta.url` fallback 정상). **5C**: `scripts/git-hooks/pre-commit` C-2 implement(현실적 조합 a+b+d: secret / 개인 절대경로 / vendored `modified: none` 보호) + README "Git hooks (optional)" + 6 시나리오 pass. C-1 `/sync-to-git` / C-3 draw.io MCP / C-4 GCP MCP **drop**(사용자 결정). **5D**: CHANGELOG Phase 5 블록 + Known Issue "Resolved in Phase 5" 갱신 + Accepted Limitations(Issue #37634, #18527) + `phase5-plan.md` archive 이관. **상위 원칙 확립(v6)**: Anthropic 공식 패턴(hookify graceful skip) > Codex 완벽주의. 자체 플랫폼 우회책(`launch-python.mjs`, `plugin.json` `prerequisites`) 공식 스키마 미지원 확정으로 드롭.
- ✅ Phase 6 완료 (2026-04-24) — 3배치 커밋(6A/6B/6C). **6A**: `scripts/validate-plugins.ps1` (PS 5.1 호환, V-1~V-6) 정식 승격 → 7 PASS / 0 FAIL / 1 INFO (`V-5 11/11 plugins matched`). Codex 2-round review (1차 Low 2건 `-is [Array]` 타입 체크 반영, 2차 No findings). **6B**: `claude plugin` CLI로 B-0~B-8 인터랙티브 설치 재검증 전 단계 자동화. B-2a smoke hook 실 실행 세션 jsonl attachment(PreToolUse+PostToolUse `hook_system_message` = `SMOKE-OK`)로 확증. 진행 중 Python 3.12.10 로컬 설치(`winget`)로 CLAUDE.md "Python 3 미설치" 환경 특이사항 해소. Phase 7 진입 대체성 조건(원본 hookify 부재 + command/skill/hook 실 실행 성공) 충족. Known Issue: Claude Code Desktop v2.1.111에서 `hook_system_message` UI 렌더링 미관찰(기능은 정상, v6 원칙대로 투명 기록). **6C**: CHANGELOG Phase 6 블록 + 본 §8 갱신 + `phase6-plan.md` archive 이관.
- ✅ Phase 7 완료 (2026-04-25) — 3배치 커밋(7A/7C/7D, 7B skip). **7A**: `scripts/check-orphan-originals.ps1` (PS 5.1 호환, O-1~O-3) 작성 → 12 PASS / 0 WARN / 0 FAIL / 2 INFO (exit 0 clean). 11개 편입 원본 모두 user-scope 미설치, `~/.claude/skills/` 부재, vendoring source marketplace만 known. Codex 3-round review (1차 High 2+Low 1, 2차 Low 2, 3차 No findings): case-sensitive `-ceq`/`-clike` 매칭 + 실패 taxonomy + O-3 `.source.repo` 매칭 + frontmatter 인라인 YAML 코멘트 스트립. **7B skip**: 7A clean으로 WARN 해소 대상 없음 (Phase 6B B-0 hookify 부재 확인이 10개 원본까지 확장 확인됨). **7C**: `claude plugin install` 두 번 + `claude plugin list` 3개 enabled + 재실행 orphan-check 유지 clean. **7D**: CHANGELOG Phase 7 블록 + 본 §8 갱신 + `phase7-plan.md` archive 이관(v6까지 Codex 6회 리뷰 이력 보존: 4→3→3→3→2→0 수렴).
- ✅ Phase 8 완료 (2026-04-25) — 8P/8A/8B/8C/8C-post/8D 흡수. v0.1.0 첫 public release. §4.5 게이트 8/8 PASS, GitHub source 재설치 검증 PASS, atomic push success, release 후 GitHub source smoke PASS (V-1/V-2/V-3/V-5), GitHub Release page <https://github.com/rwang2gun/rwang-workbench/releases/tag/v0.1.0>. 자세히는 docs/CHANGELOG.md [0.1.0] 블록.
- ⬜ Phase 9 (지속 운영) — 트리거 기반(신규 자산·릴리스 전 점검·실패 제보)

각 Phase 시작 시 이 섹션 업데이트.
