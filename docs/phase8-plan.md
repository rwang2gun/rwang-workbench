# Phase 8 실행 계획

> **역할**: Phase 8(Public 전환 게이트 통과 + GitHub 재설치 검증 + v0.1.0 release + 배포 개시)의 단일 실행 계획서.
> **수명**: Phase 8 진행 중 참조. Phase 8 마감 커밋에서 `docs/archive/`로 이동.
> **근거**: MASTER_PLAN v1.5 §4.5(Public 게이트), §5 Phase 8, §4.7(Skills ZIP 후순위), Phase 4 §5(시크릿 스캔 이연), [PLAN_DESIGN_GUIDELINES.md](PLAN_DESIGN_GUIDELINES.md) **v1.2 — 5축 + 메타 패턴(주장 강도/구현 정밀도, 본문 예시/실 실행 진실)**.
> **개정 이력**:
> - v1 초안 (2026-04-25) — Codex 1차 BLOCK (High 7, Low 5).
> - v2 전면 재작성 (2026-04-25) — GUIDELINES v1.0 5축 prose 흡수. Codex 2차 BLOCK (High 7, Low 4) — prose만 적고 구현 짝이 부족했던 것이 새 종류 finding으로 노출. GUIDELINES v1.0 → v1.1 시드.
> - v3 전면 재작성 (2026-04-25) — GUIDELINES v1.1 적용. wrapper·try/finally·flag·regex 짝짓기 완성. Codex 3차 BLOCK (High 5, Low 3) — 자기참조 BLOCK loop(plan 본문이 plan 자신의 게이트 위반) 신규 노출. v1.2 시드 일부.
> - v4 minimal patch (2026-04-25) — Codex 3차 8건 흡수. self-sanitize 적용. Codex 4차 BLOCK (High 5, Low 4) — patch 누적이 5축 strict 기준을 흔들리게 한 결과 9건 살짝 역행. v1.2 시드 완성.
> - v5 전면 재작성 (2026-04-25) — GUIDELINES **v1.2** 전면 적용. Codex 4차 9건 + Claude self-review 4건 = 총 13건 흡수. Codex 5차 BLOCK (High 2, Low 2) — patch 누적이 아닌 v5 작성 시 누락 4건.
> - v5.1 minimal patch (2026-04-25) — Codex 5차 4건 흡수. Codex 6차 BLOCK (High 1, Low 1) — §7 5차 row 자체에 literal 절대경로 예시 잔존(self-trigger) + §4.1.5 file read 코드 vs prose mismatch.
> - v5.2 minimal patch (2026-04-25) — Codex 6차 2건 흡수. Codex 7차 non-BLOCK (Low 1, Note 1) — §4.1.5 작성 흐름 prose가 "임의의 `<`" 차단으로 오해 가능.
> - v5.3 minor patch (2026-04-25) — Codex 7차 L-1 흡수. Codex 8차 BLOCK (High 1, Low 1) — §4.1.5 `$gitleaksVersion` 검증 부재(빈 치환 false-pass) + §3.1/§4.2.3/§4.3.11/§5의 일부 §4.3.10 smoke 오참조.
> - **v5.4 minor patch (2026-04-25)** — Codex 8차 2건 흡수: (a) **§4.1.5 `$gitleaksVersion` 재검증** (`-not` + 형식 정규식) + **`$rendered` 빈 치환 false-pass 검사** (`gitleaks v?\d+\.\d+\.\d+` + `실행일: \d{4}-...` 포함 검증, Codex 8차 H-1), (b) **§3.1 / §4.2.3 / §4.3.11 prose / §5 R-15의 §4.3.10 smoke 오참조 → §4.3.11**로 정정 (§4.3.10은 atomic push 전용, Codex 8차 L-1).
> - **v5.5 minor patch (2026-04-25)** — Codex 9차 non-BLOCK 2건 흡수: (a) **§4.3.11 line 1130 equivalence 표 제목 §4.3.10 → §4.3.11 정정** — 표 컬럼·본문은 v5.4에서 §4.3.11로 정정됐으나 표 제목 1줄 누락(Codex 9차 L-1, v5.4 self-check "§4.3.10 smoke 오참조 0건" 주장과의 잔여 갭), (b) **§7 8차 H-1 row 흡수표 정규식 `^v?8\.\d+\.\d+$` → `^v?8\.\d+\.\d+`** — §4.1.5 line 521 실 코드의 trailing `$` 부재와 정합(Codex 9차 N-1, prose vs 구현 정밀도 일치 메타 v1.1).

---

## 0. Scope

Phase 8은 **위상 변화 phase** — 본 프로젝트가 처음으로 release/public milestone으로 전환되는 단계. 이전 phase(검증·정리)와 비대칭:

- 작업 결과 = 영구 marker(v0.1.0 tag, GitHub Release object)
- 실패 비용 = partial state가 사고 (mid-failure에서의 dev 환경 비복원, false-claim commit이 release tag로 박힘)
- 보안 finding = sanitize 단독으로 회수 불가 (fork/mirror/cache 잔존)

| 스트림 | 범위 | 근거 |
|---|---|---|
| **P** | **Plan-fix seed** — plan v5 + GUIDELINES v1.2 + CLAUDE.md 변경분을 본 phase 본 작업 전 별도 commit으로 고정. 8A 착수 조건 = `git status --short` 결과가 `?? .claude/` 한 줄(8P 시점 .claude/는 아직 untracked, 8A에서 .gitignore 일반화로 ignored 전환)만 남음 | GUIDELINES v1.2 축 3 / Codex 4차 L-1 |
| **A** | §4.5 잔여 게이트 통과: gitleaks(primary, `dir`/`git` 모드) full repo + history scan / retroactive 절대경로·계정명 grep / `.env.example` 판정 / `.gitignore` 보강(`.claude/` 추가) / `docs/release-checklist-v0.1.0.md` 작성 (8A commit 상태로 release까지 그대로 유지, 본문은 변수 치환 후 specific 값 박힘 — placeholder 잔존 0건) | §4.5, Phase 4 §5 이연 |
| **B** | GitHub source 재설치 검증 — preflight snapshot → 두 팩 uninstall + Directory marketplace remove → GitHub marketplace add → install → 검증(source.source `github` + installPath ∉ repo + 두 팩 모두 enabled + orphan-check) → finally restore (Directory source 복원). **PowerShell §3.1 표준 wrapper inline + try/finally** | §5 Phase 8 |
| **C** | v0.1.0 **Release commit + tag (prepared)** — 두 팩 `plugin.json` version `0.1.0-alpha`→`0.1.0` / README L5 status badge 갱신 / CHANGELOG `[Unreleased]`→`[0.1.0]` (8C 시점에는 prepared 진술만, 8C-post 결과는 8D commit에서 변수 치환으로 채움) / MASTER_PLAN §8 8C까지만 표기 / annotated tag `v0.1.0` 생성. **commit 자체는 "prepared", push·smoke·Release object 결과는 commit 이후 단계라 8C commit에서 완료 진술 X** | §5 Phase 8 |
| **C-post** | 8C commit·tag 생성 후 G5 승인 → **`git push --atomic`** (실패 시 BLOCK 기본, fallback은 "atomic unsupported" 정규식 한정 + 사용자 명시 재승인) → **release 후 GitHub source smoke** (release commit 기준, §3.1 wrapper inline + try/finally + cache 사전 삭제 + §4.2.2와 line-by-line 검증 항목 equivalence) → **`gh release view`/`create` 분기 + 사후 view exit code 검사** | §5 Phase 8 |
| **D** | Phase 8 closure — phase8-plan archive (`git mv` — 8P에서 commit됐으므로 작동 보장) / CLAUDE.md Phase 9 전환 / MASTER_PLAN §8 8D 완료 표기 / **C-post 결과 흡수** (atomic push 결과·smoke 결과·Release URL을 변수에 캡처해 CHANGELOG·commit 메시지 here-string에 치환 후 commit 전 placeholder 잔존 grep BLOCK) / push | Phase 4~7 마감 패턴 + Codex 4차 H-5 |

**Scope 외 (drop 명시):**
- `scripts/build-skills-zip.ps1` (§4.7 — 배포 후 파생, Phase 8 필수 X)
- 11개 vendored 라이선스 "심화 검토" — 모두 Apache-2.0 확정. 추가 검토 불필요
- game-design-pack — Phase 2 유예 결정 유지
- Phase 9+ 운영 활동 — Phase 8 종료 후 ad-hoc

**Release-time 결정 후보 — 모두 drop 명시 (1인 repo 사유):**

| 후보 | 결정 | 사유 |
|---|---|---|
| GitHub branch protection (main force-push 금지 등) | drop | 1인 repo. Phase 9에서 협업 발생 시 재평가 |
| commit/tag GPG signing | drop | CLAUDE.md `--no-gpg-sign` 금지 정책은 일반 commit 한정. release tag도 unsigned annotated로 통일 |
| DCO / signed-off-by | drop | 1인 repo. external contributor 발생 시 재평가 |
| GitHub security settings (Dependabot / secret scanning / code scanning) | drop | scope. 1인 repo. 향후 enable 시 별도 ad-hoc |
| 외부 announcement 채널 | drop | GitHub Release page만으로 충분 |

---

## 1. 현재 환경 선제 진단 (plan 작성 시점 사실 캡처)

GUIDELINES v1.2 축 3(Repo 사실 확인) 적용. v5 작성 시점에 grep/`--help`로 모두 확정. **plan 자체 git state도 자기참조로 포함**.

### 1.1 Plan 자체의 git state

본 v5 작성 직후 `git status --short` 기대값:
```
 M CLAUDE.md
?? .claude/
?? docs/PLAN_DESIGN_GUIDELINES.md
?? docs/phase8-plan.md
```

→ 8D `git mv docs/phase8-plan.md docs/archive/phase8-plan.md`가 작동하려면 phase8-plan.md가 **commit 상태**여야 함. 현재는 untracked → `git mv` 실패. **Batch 8P 필요**.

추가:
- `docs/release-checklist-v0.1.0.md`는 8A에서 신규 작성 — plan-fix scope 외 (8A commit에 포함, release까지 8A 상태 그대로 유지)
- `.claude/` 처리 시점 (Codex 4차 L-1):
  - 8P 시점: untracked 상태 그대로 (`git status --short`에 `?? .claude/` 한 줄 잔존 허용)
  - 8A에서 `.gitignore` 일반화 후: ignored. `git status --short`에서 사라짐
- **plan 본문 자체에 절대경로·사용자명·email 박힘 여부**: v5에서 sanitize 완료(개정 이력 v5 참조). plan은 8P 후 retroactive grep scope에 포함되며, 그 검사를 통과하도록 본문은 placeholder/`$repo` 변수만 사용. commit footer의 Anthropic `noreply` 도메인은 §4.1.2 P-2가 명시 면죄

### 1.2 Git / GitHub 상태

- `git --version` → `2.53.x` (Windows). `git push --atomic` 지원 (2.4+).
- `git remote -v` → `origin = https://github.com/rwang2gun/rwang-workbench.git` (public).
- `git tag -l` → 빈 결과. `git ls-remote --tags origin` → 원격에도 0건. **v0.1.0이 첫 태그**.
- `gh --version` → `2.89.x`. **GitHub Release object 생성 가능**.

### 1.3 두 팩 manifest 상태

- `plugins/productivity-pack/.claude-plugin/plugin.json` → `version: "0.1.0-alpha"`
- `plugins/analysis-pack/.claude-plugin/plugin.json` → `version: "0.1.0-alpha"`
- `.claude-plugin/marketplace.json` → version 필드 없음 (스키마상 부재 OK)
- `README.md:5` → `> **Status:** v0.1.0-alpha (scaffolded). ...`
- → **8C에서 두 팩 plugin.json + README L5 모두 갱신** (single commit)

### 1.4 현재 설치 상태 (preflight 기준)

`claude plugin list` 기대 형태:
```
analysis-pack@rwang-workbench       0.1.0-alpha   user   ✔ enabled
codex@openai-codex                  1.0.3         user   ✔ enabled
productivity-pack@rwang-workbench   0.1.0-alpha   user   ✔ enabled
```

`~/.claude/plugins/installed_plugins.json` 두 팩 entry 형태 (사용자 PC 절대경로는 plan 본문에 박지 않음 — 자기참조 sanitize):
- installPath 패턴: `<사용자 홈>/.claude/plugins/cache/rwang-workbench/<pack>/<version>`
- gitCommitSha = Phase 7A 시점 sha (실 실행 시 `git log` 등으로 조회)

`~/.claude/plugins/known_marketplaces.json` `rwang-workbench` entry 형태:
- 현재: `source.source = "directory"`, `source.path = <리포 루트 절대경로>`
- 8B에서 `github`/`rwang2gun/rwang-workbench`로 전환 후 finally restore 시 다시 directory

### 1.5 환경변수 사용처 (`.env.example` 판정 근거)

- `plugins/productivity-pack/scripts/check-recommended.mjs:8,17` — `RWANG_INSTALLED_PLUGINS_PATH` (fixture/debug override)
- `plugins/productivity-pack/commands/check-recommended.md:23-29` — 동일 doc
- vendored SKILL.md의 `process.env.PORT`/`process.env.ROOT_DIR` — vendored example(자체 동작 X)
- `CLAUDE_PLUGIN_ROOT` — host-provided

→ **사용자가 직접 설정해야 하는 runtime config env = 0건**. `.env.example` **미작성** 결정. `.gitignore`의 `.env*` 패턴은 미래 사용 대비 보존.

### 1.6 외부 도구 가용성

- `gitleaks` → **미설치**. winget으로 8A 시작 시 1회 설치(8.19+ 새 syntax 사용). plan 본문에 specific 버전(`8.30.x` 등)은 박지 않음 — 8A 실 실행 후 `gitleaks version` 캡처값을 release-checklist의 변수 자리에 치환
  - **gitleaks 8.19+에서 `detect`/`protect` deprecated**. v5는 새 syntax: `gitleaks dir <path>` (working tree), `gitleaks git <path>` (history)
- `trufflehog` → 미설치. **drop**
- `git push --atomic` → 지원. **primary**. fallback은 atomic unsupported 정규식 한정. 실 git stderr 메시지: `fatal: the receiving end does not support --atomic push` 형태(Codex 4차 L-2 — 옆에 주석 고정)
- `gh release` → CLI 2.89 가능. v5는 `gh release view` preflight + 결과별 `create`/`edit`/`delete` 분기 + 사후 `view --json url`도 `$LASTEXITCODE` 명시 검사(Codex 4차 L-3)
- pre-commit hook PATH_PATTERNS: `scripts/git-hooks/pre-commit:27-30` 직접 참조. **plan 본문에 정규식 string 박지 않음** (자기참조 sanitize)

### 1.7 사전 진단 요약

| 항목 | 상태 | 처리 |
|---|---|---|
| plan 자체 git state | untracked | **Batch 8P** |
| plan 본문 자기참조 sanitize | v5 적용 완료 | 본문 패턴 박힘 0건 (placeholder + `$repo`, P-2 noreply 명시 면죄) |
| `.claude/` 시점 | 8P 시점 untracked 잔존 / 8A 후 ignored | 두 시점 분리 명시 (§4.0.3 / §4.1.4) |
| gitleaks 설치 | 미설치 | 8A (winget, `dir`/`git` syntax) |
| trufflehog | drop | — |
| `.env.example` | 미작성 | 8A (사유 release-checklist) |
| 두 팩 plugin.json version | `0.1.0-alpha` | 8C (`0.1.0` 갱신) |
| README L5 status | `v0.1.0-alpha (scaffolded)` | 8C 갱신 |
| GitHub remote / tag | push 완료 / tag 0건 | 8C tag prepared, C-post에서 push |
| `git --atomic` push | 지원 | C-post primary |
| `gh release` | 가능, view preflight + 사후 view exit code | C-post |
| Skills ZIP | scope 외 | drop |
| Release-time 결정 5종 | 모두 drop | §0 표 |
| PowerShell wrapper drift | 두 §에 inline | §3.1 표준 박스 + grep diff 검증 step |

---

## 2. Ordering Rationale

**P → A → B → C → C-post → D 순서 고정.**

- 8P 미통과 시 plan/guidelines가 untracked → 8D `git mv` 실패 + retroactive grep scope에서 release-bound 문서 누락
- 8A 미통과 시 8B GitHub source 검증 의미 X
- 8B에서 GitHub source 동작 미확인 시 8C tag = 깨진 install path 가리킴
- **8C release commit ≠ 8C-post 후속 작업** (commit boundary 분리 — Codex 3차 H-3). 8C commit 시점에는 "release commit/tag prepared"까지만 진술. atomic push·smoke·Release object 결과는 commit 이후 단계라 8C commit에서 완료 선언 X
- **C-post 결과는 8D commit + CHANGELOG에 변수 치환으로 흡수** — 모든 단계 종료 후 한 번에 기록. release tag(v0.1.0)는 8C release commit을 가리키지만 그 commit 자체는 false-claim 없음. 8D commit 메시지 here-string은 변수(`$atomicResult`/`$smokeResult`/`$releaseUrl`)로 생성 후 commit 전 placeholder 잔존 grep BLOCK(Codex 4차 H-5)

---

## 3. 배치 + 승인 게이트

| 배치 | 내용 | commit |
|---|---|---|
| **Batch 8P** | plan v5 + GUIDELINES v1.2 + CLAUDE.md 변경분을 commit으로 고정 | 1 |
| **Batch 8A** | gitleaks 설치 + 양 모드 0 finding + retroactive grep 0 finding (allowlist는 hook 파일의 PATH_PATTERNS 정의 line만 line 단위 식별, file 단위 면죄 없음 — release-checklist도 0 finding 대상) + `.gitignore` `.claude/` 추가 + `.env.example` 미작성 사유 + `release-checklist-v0.1.0.md` (실 실행 결과 변수 치환 후 specific 값 박힘 — placeholder 잔존 0건, 8A commit 상태 그대로 release까지 유지) | 1 |
| **Batch 8B** | preflight snapshot → uninstall+remove → GitHub source add → install 검증 → finally restore. §3.1 wrapper inline + grep diff 검증 step | 0 (8C CHANGELOG 흡수) |
| **Batch 8C** | 두 팩 plugin.json + README L5 + CHANGELOG 8C block(prepared만, 8D 결과 자리는 변수 placeholder 명시) + MASTER §8 8C까지 prepared + tag `v0.1.0` annotated. **commit 시점에는 prepared까지만, 후속 결과 진술 X** | 1 + tag (push 안 함) |
| **Batch 8C-post** (G5 후) | `git push --atomic` (BLOCK 기본) → cache 사전 삭제 → release 후 GitHub source smoke (§3.1 wrapper inline + try/finally + §4.2.2와 검증 항목 line-by-line equivalence) → `gh release view`/`create` 분기 + 사후 view exit code 검사 | 0 (8D commit/CHANGELOG에 변수 치환으로 결과 흡수) |
| **Batch 8D** | phase8-plan archive (`git mv` 작동) + CLAUDE.md Phase 9 + MASTER §8 8D 완료 + **C-post 결과 변수 치환 + commit 전 placeholder 잔존 grep BLOCK** + push | 1 + push |

**승인 게이트 (5개):**
- **G1** — 본 plan v5 + Codex N차 리뷰 수렴 → 8P 착수
- **G2** — 8P commit 통과(`git status --short` `?? .claude/` 1줄만 잔존, 다른 변경 0건) → 8A 착수
- **G3** — 8A 결과(gitleaks 0 finding, retroactive 0 finding, allowlist line 단위 식별) → 8B 진행
- **G4** — 8B GitHub source 재설치 PASS + dev restore 완료 → 8C 착수
- **G5** — 8C release commit·tag 생성 후 **C-post 진입(atomic push) 직전 사용자 명시 승인**. v0.1.0 tag는 user-visible irreversible

### 3.1 PowerShell 표준 wrapper 박스 (단일 정의 source — F-4 흡수)

§4.2.2 (8B 검증)·§4.3.11 (8C-post smoke) 두 곳에서 사용. 두 inline은 본 박스와 byte-for-byte 동일해야 함. **8B/8C-post 실행 직전 grep diff 검증 step**으로 drift 감지.

```powershell
# === RWANG-WB STANDARD WRAPPER BLOCK START — DO NOT MODIFY INLINE COPIES INDEPENDENTLY ===
function Invoke-CliStrict {
    param([scriptblock]$Cmd, [string]$Step)
    & $Cmd
    if ($LASTEXITCODE -ne 0) {
        throw "$Step 실패 (exit $LASTEXITCODE)"
    }
}

function Invoke-CliAllowFail {
    param([scriptblock]$Cmd, [string]$Step)
    & $Cmd 2>&1 | Out-Host
    Write-Host "$Step (exit $LASTEXITCODE — noop 허용)"
    $global:LASTEXITCODE = 0
}
# === RWANG-WB STANDARD WRAPPER BLOCK END ===
```

**Drift 검증 step (8B/8C-post 실행 직전):**

regex pattern은 **line 시작 anchor (`^`)**를 사용해 marker가 line 첫 글자일 때만 매치 — 본 검증 코드 자체의 regex string에 박힌 marker literal은 line 첫 글자가 아니므로 self-trigger 회피.

```powershell
$ErrorActionPreference = 'Stop'
$planFile = 'docs/phase8-plan.md'
$content = Get-Content $planFile -Raw
# (?sm) — singleline + multiline. ^ anchor로 line 시작 marker만 매치 (regex string self-trigger 회피)
$pattern = '(?sm)^# === RWANG-WB STANDARD WRAPPER BLOCK START[^\r\n]*[\r\n]+(.*?)^# === RWANG-WB STANDARD WRAPPER BLOCK END ==='
$blocks = [regex]::Matches($content, $pattern)
if ($blocks.Count -lt 3) { throw "wrapper 박스 inline 사본 < 3 (§3.1 표준 + §4.2.2 + §4.3.11 = 3 기대), 실제: $($blocks.Count)" }
$first = $blocks[0].Groups[1].Value
foreach ($b in $blocks) {
    if ($b.Groups[1].Value -ne $first) { throw "wrapper 박스 byte-for-byte drift 감지 — §3.1과 §4.2.2/§4.3.11 inline이 불일치" }
}
Write-Host "wrapper 박스 drift 검증 PASS ($($blocks.Count)개 사본 일치)"
```

archive 후(8D 이후)에는 plan이 `docs/archive/phase8-plan.md`로 이동하므로 본 검증 step은 8D commit 이전(즉 archive 전)에만 의미를 가짐 — Phase 8 진행 중 8B/8C-post 두 시점에서만 실행.

---

## 4. 배치별 세부

### 4.0 Batch 8P — Plan-fix seed commit

#### 4.0.1 목적

본 plan v5 실행 동안 untracked였던 plan·guidelines·CLAUDE.md 변경분을 별도 commit으로 고정. 효과:

- 8A retroactive grep scope에 plan/guidelines가 tracked로 포함됨
- 8D `git mv docs/phase8-plan.md`가 작동(현재 untracked면 실패)
- release-checklist v0.1.0 commit과 plan/guidelines commit을 분리 — release tag가 plan archive 상태가 아닌 "release commit" 자체를 가리킴

#### 4.0.2 절차 (실제 명령)

```powershell
$ErrorActionPreference = 'Stop'

# Stage 명시 add — git add -A 금지
git add docs/phase8-plan.md
git add docs/PLAN_DESIGN_GUIDELINES.md
git add CLAUDE.md
if ($LASTEXITCODE -ne 0) { throw "8P stage 실패" }

# pre-commit hook 통과 확인 (added lines에 secret/personal-path 0건이어야 함)
# plan 본문 sanitize(v5)로 이 단계 통과 보장
git status --short

# Commit
$msg = @'
Phase 8P: Plan-fix seed — phase8-plan v5 + PLAN_DESIGN_GUIDELINES v1.2 + CLAUDE.md sync

- docs/phase8-plan.md (신규): Phase 8 v5 plan. v1·v2·v3·v4 BLOCK 회고 흡수, plan 본문 자기참조 sanitize 적용, GUIDELINES v1.2 5축 + 메타 패턴 v1.2-A/B 전면 적용.
- docs/PLAN_DESIGN_GUIDELINES.md (신규): 5축 + 메타 패턴 v1.0/v1.1/v1.2 (위상 변화 / prose vs 구현 / 주장 강도 vs 구현 정밀도 + 본문 예시 vs 실 실행 진실).
- CLAUDE.md: 핵심 설계 문서 GUIDELINES 추가 + plan 작성 흐름 박음.

본 commit은 plan/guidelines/CLAUDE.md 변경분을 본 phase 본 작업(8A~) 전 고정하는 seed commit.
8A retroactive grep scope에 plan/guidelines가 tracked로 포함되며, 8D git mv 작동 보장.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
'@

git commit -m $msg
if ($LASTEXITCODE -ne 0) { throw "8P commit 실패 — pre-commit hook 차단 가능성. plan 본문 자기참조 sanitize 재확인" }

# 8A 착수 조건 검증 — .claude/만 untracked 잔존 허용
$status = git status --short
$nonClaudeChanges = $status | Where-Object { $_ -and $_ -notmatch '^\?\?\s+\.claude/' }
if ($nonClaudeChanges) {
    throw "8A 착수 조건 미충족: 예상치 못한 변경 잔존: $nonClaudeChanges"
}
Write-Host "8P PASS — 8A 착수 가능 (`.claude/` 한 줄 untracked 잔존 — 8A에서 .gitignore 일반화 후 ignored)"
```

#### 4.0.3 8P Exit Gate (G2)

- `git log -1 --oneline` → "Phase 8P: Plan-fix seed ..."
- `git status --short` → `?? .claude/` 한 줄만 잔존, 다른 변경 0건. **8A에서 `.gitignore` 일반화 후에는 ignored로 전환되어 status에서 사라짐**. 시점별 분리: 8P 시점=untracked / 8A 후=ignored
- pre-commit hook 통과 (sanitize 덕분)
- `git ls-files docs/phase8-plan.md docs/PLAN_DESIGN_GUIDELINES.md` → 둘 다 출력 (tracked)

---

### 4.1 Batch 8A — §4.5 잔여 게이트 통과

#### 4.1.1 gitleaks scan (primary, 8.19+ syntax)

**설치 및 버전 캡처 (release-checklist 변수 치환용):**
```powershell
$ErrorActionPreference = 'Stop'
winget install Gitleaks.Gitleaks --silent --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) { throw "gitleaks 설치 실패 (exit $LASTEXITCODE)" }

$gitleaksVersion = (gitleaks version 2>&1).Trim()
if ($gitleaksVersion -notmatch '^v?8\.\d+\.\d+') { throw "gitleaks 버전 확인 실패: $gitleaksVersion" }
Write-Host "gitleaks: $gitleaksVersion"
# → 본 변수는 release-checklist 작성 시 변수 치환에 사용 (specific 버전을 plan 본문에 hardcode 금지 — 메타 v1.2-B)
```

**스캔 (양 모드 — 새 syntax: `dir`/`git`, `detect` 미사용):**

```powershell
$repo = (Resolve-Path .).Path  # 리포 루트 — plan 본문에 절대경로 박지 않음
$wtReport = "$env:TEMP\gitleaks-wt.json"
$gitReport = "$env:TEMP\gitleaks-git.json"

try {
    # Mode 1: working tree (no-git)
    gitleaks dir $repo --redact --report-format json --report-path $wtReport
    $wtExit = $LASTEXITCODE
    if ($wtExit -ne 0) {
        if ($wtExit -eq 1) { throw "gitleaks dir mode: findings detected — release BLOCK" }
        else { throw "gitleaks dir mode: tool error (exit $wtExit)" }
    }

    # Mode 2: git history
    gitleaks git $repo --redact --report-format json --report-path $gitReport
    $gitExit = $LASTEXITCODE
    if ($gitExit -ne 0) {
        if ($gitExit -eq 1) { throw "gitleaks git mode: findings detected — release BLOCK" }
        else { throw "gitleaks git mode: tool error (exit $gitExit)" }
    }

    Write-Host "gitleaks 양 모드 0 finding"
}
finally {
    Remove-Item $wtReport, $gitReport -ErrorAction SilentlyContinue
}
```

**release-checklist에 변수 치환으로 박힐 메타** (보고서 파일 자체는 commit 안 함):
- `$gitleaksVersion` (8A 실 캡처값 — plan 본문에 hardcode X)
- 두 모드 명령 (`gitleaks dir <repo>` / `gitleaks git <repo>`)
- finding count: 0/0 (PASS 시 진술. FAIL 시는 BLOCK 진입이라 release 진행 X)
- 실행 시각 (`Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'` 캡처)

**비-zero finding 시 처리 절차** (총 7항목):

1. 즉시 release **BLOCK** — Phase 8 게이트 통과 무효
2. credential revoke/rotate를 history rewrite보다 **먼저** 수행
3. fork·mirror·archive·search-index 잔존 사실을 release-checklist에 기록 (rewrite로 회수 불가)
4. 사용자 명시 승인 없이 force-push 금지
5. `git filter-repo` 또는 BFG로 history sanitize
6. fresh clone에서 두 모드 재스캔 → 0 finding 확인
7. 사용자 명시 force-push 승인 → 위 6항목 통과 후에만 v0.1.0 tag/release 진행. 위양성은 `.gitleaksignore`에 사유 명시 + release-checklist 기록

#### 4.1.2 Retroactive 절대경로·계정명 grep

**Scope (명시 정의):**

- **포함**:
  - `git ls-files`로 추출한 tracked working tree 전체 (8P commit 후 plan/guidelines 포함됨)
  - `docs/archive/` (tracked)
  - **`docs/release-checklist-v0.1.0.md` 도 포함** — release-bound 문서지만 0 finding 대상 (Codex 4차 H-2 — file 단위 면죄 금지)
- **제외**:
  - `.git/`
  - `.claude/worktrees/`·`.claude/` (8A 후 `.gitignore` 일반화로 차후 추적 자동 제외)
  - 외부 cache 디렉토리

**검색 패턴 (P-1~P-4 — strict 정의):**

| # | 자연어 의미 | 검사 코드 출처 |
|---|---|---|
| P-1 | 본인 PC 사용자 홈 절대경로 (Windows·Git Bash 양 형태) | `scripts/git-hooks/pre-commit:27-30`의 PATH_PATTERNS 두 정규식 import |
| P-2 | 본인 commit author email (literal). **Anthropic noreply (`noreply@anthropic.com`)는 명시 면죄** — Co-Authored-By footer 표준 패턴 | `(git config user.email).Trim()` literal escape, noreply 면죄는 hit 후 line-content 필터로 |
| P-3 | Windows OS 일반 절대 드라이브 경로 — Windows 사용자 홈 절대경로 또는 작업 루트 절대경로 형태(드라이브 문자 + 슬래시 + Users/claude 시작). hook PATH_PATTERNS는 본인 PC 사용자명 한정이라 일반 케이스 별도 정규식 추가 (Codex 4차 H-3, plan 본문에는 literal 예시 박지 않음 — Codex 5차 H-1) | 정규식: 코드 블록의 `$p3Pattern` 변수 참조 |
| P-4 | staging 폴더 절대경로 누설 (§7.2 staging 보호) | `$env:CLAUDE_WORK_ROOT` 기반 도출 literal escape |

**PASS 기준 — strict, line/pattern 단위 (Codex 4차 H-2):**

file content 내 P-1~P-4 모두 0건. **allowlist는 line 단위로만 식별**:

| 위치 | line 식별 사유 |
|---|---|
| `scripts/git-hooks/pre-commit` PATH_PATTERNS 정의 line (`27-30` 부근) | hook이 탐지 대상 패턴을 알아야 동작. **그 line만** allowlist, 다른 line의 hit는 finding |

`docs/release-checklist-v0.1.0.md`는 **allowlist에서 제거**(v4 H-2). 본문은 §4.1.5에서 변수 치환·자연어 서술로 작성되어 P-1~P-4 패턴 0 hit이 자연 보장 — 추가 면죄 불필요. plan 본문(`docs/phase8-plan.md`·`docs/PLAN_DESIGN_GUIDELINES.md`)도 allowlist X — v5 본문 sanitize로 P-1~P-4 패턴 0 hit이어야 함.

**실행 (PowerShell):**

```powershell
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path .).Path

# 패턴 source:
#   1) scripts/git-hooks/pre-commit의 PATH_PATTERNS 추출 → P-1
#   2) 본인 commit author email (P-2) — noreply@anthropic.com 면죄
#   3) 일반 절대 드라이브 경로 (P-3) — 추가 정규식
#   4) staging 절대경로 (P-4) — $env:CLAUDE_WORK_ROOT 도출

$hookFile = Join-Path $repo 'scripts/git-hooks/pre-commit'
$hookContent = Get-Content $hookFile -Raw

# P-1: hook의 PATH_PATTERNS 배열 본문 추출
$pathBlock = if ($hookContent -match 'PATH_PATTERNS=\(([\s\S]*?)\)') { $matches[1] } else { throw "hook PATH_PATTERNS 추출 실패" }
$p1Patterns = ($pathBlock -split "`n" | ForEach-Object {
    if ($_ -match "^\s*'([^']+)'") { $matches[1] }
}) | Where-Object { $_ }

# P-2: 본인 commit author email
$userEmail = (git config user.email).Trim()
if (-not $userEmail) { throw "git config user.email 비어있음" }
$p2Pattern = [regex]::Escape($userEmail)

# P-3: 일반 절대 드라이브 경로 (Windows OS)
$p3Pattern = '[A-Za-z]:[\\\/](?:Users|claude)[\\\/]'

# P-4: staging 절대경로 (있을 때만)
$p4Patterns = if ($env:CLAUDE_WORK_ROOT) {
    @(
        [regex]::Escape("$env:CLAUDE_WORK_ROOT\rwang-workbench-staging"),
        [regex]::Escape("$($env:CLAUDE_WORK_ROOT -replace '\\','/')/rwang-workbench-staging")
    )
} else { @() }

$allPatterns = @{
    'P-1' = $p1Patterns
    'P-2' = @($p2Pattern)
    'P-3' = @($p3Pattern)
    'P-4' = $p4Patterns
}

# Allowlist line 단위 — hook 파일의 PATH_PATTERNS 정의 line만
function Test-AllowedHit {
    param([string]$FilePath, [int]$LineNumber, [string]$LineText, [string]$PatternId)
    # P-1만 hook line 면죄 (hook이 패턴을 알아야 동작)
    if ($PatternId -ne 'P-1') { return $false }
    if ($FilePath -notmatch 'scripts[\\/]git-hooks[\\/]pre-commit$') { return $false }
    # PATH_PATTERNS=( ... ) 블록 안의 line만 면죄. 단순히 line 번호 27-30 hardcode 대신 hook 파일을 다시 파싱
    return $LineText -match "^\s*'.*'\s*$"
}

# P-2 noreply 면죄 — Anthropic Co-Authored-By footer 정확한 line shape만 (Codex 5차 H-2)
# 단순 noreply 포함 line이 아니라 exact footer shape으로 좁힘 — 동일 line에 본인 email이 섞이는 false-pass 회피
function Test-NoreplyExempt {
    param([string]$LineText, [string]$PatternId)
    if ($PatternId -ne 'P-2') { return $false }
    # exact shape: "Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
    # 앞뒤 trim, 다른 토큰이 같은 line에 섞이면 면죄 X
    return $LineText.Trim() -match '^Co-Authored-By:\s+Claude\s+Opus\s+4\.7\s+\(1M\s+context\)\s+<noreply@anthropic\.com>\s*$'
}

$tracked = git ls-files | Where-Object { $_ -notmatch '^\.claude/' }
$findings = @()

foreach ($pid in $allPatterns.Keys) {
    foreach ($pat in $allPatterns[$pid]) {
        foreach ($f in $tracked) {
            $full = Join-Path $repo $f
            if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
            $hits = Select-String -LiteralPath $full -Pattern $pat -CaseSensitive:$false -ErrorAction SilentlyContinue
            foreach ($h in $hits) {
                if (Test-AllowedHit -FilePath $h.Path -LineNumber $h.LineNumber -LineText $h.Line -PatternId $pid) { continue }
                if (Test-NoreplyExempt -LineText $h.Line -PatternId $pid) { continue }
                $findings += [PSCustomObject]@{
                    Pattern = $pid
                    File    = $f
                    Line    = $h.LineNumber
                    Text    = $h.Line.Trim()
                }
            }
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Error "retroactive grep finding ($($findings.Count)건):"
    $findings | Format-Table -AutoSize | Out-String | Write-Error
    throw "8A retroactive grep failed — sanitize commit 후 8A 재실행"
}
Write-Host "retroactive grep 0 finding (P-1 hook PATH_PATTERNS 정의 line + P-2 Anthropic noreply 면죄 외 hit 0건)"
```

**자연어 정의 vs 검사 코드 1:1 대응 (메타 v1.2-A):**

| 자연어 | 검사 코드 |
|---|---|
| P-1 본인 PC 사용자 홈 절대경로 | hook PATH_PATTERNS import (PS 추출) |
| P-2 본인 commit author email (Anthropic noreply 면죄) | `(git config user.email).Trim()` literal escape + Test-NoreplyExempt |
| P-3 일반 절대 드라이브 경로 | `[A-Za-z]:[\\\/](?:Users\|claude)[\\\/]` 정규식 |
| P-4 staging 절대경로 | `$env:CLAUDE_WORK_ROOT` 기반 양 형태 escape |

#### 4.1.3 `.env.example` 판정

§1.5 사전 진단 결과 → **미작성** 결정. release-checklist에 사유 기록.

#### 4.1.4 `.gitignore` 보강

```diff
- # Claude Code local settings overlay (if any ever appears at repo root)
- .claude/settings.local.json
+ # Claude Code local state (settings overlay, worktrees, tool results, etc.) — never commit
+ .claude/
```

→ 8A commit 직후 `.claude/`는 ignored. `git status --short`에서 `?? .claude/` 사라짐 (Codex 4차 L-1 — 시점 명확화).

#### 4.1.5 `docs/release-checklist-v0.1.0.md` 작성 (변수 치환 후 specific 값 박힘, placeholder 잔존 0건, 8A commit 상태 그대로 release까지 유지)

**작성 흐름** (메타 v1.2-B — plan 본문 예시 vs 실 실행 진실 분리):
1. 8A 실 실행에서 `$gitleaksVersion` (위 §4.1.1) + `$execTimestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'` 캡처
2. 아래 본문 template의 `{{...}}` placeholder를 변수로 치환
3. 치환 후 파일에 쓰고, **commit 전 `{{...}}` 또는 `<...채움...>` placeholder 잔존 grep BLOCK** (placeholder 잔존 0건 검증 — 임의의 `<`가 아니라 angle placeholder 한정)
4. PASS 시 8A commit에 stage

**작성 + 치환 + 잔존 grep BLOCK (PowerShell 블록 self-contained — Codex 6차 L-1):**

template은 별도 파일 두지 않고 here-string으로 inline. 8A 실행자는 본 PS 블록을 그대로 실행하면 release-checklist 본문 작성 + 변수 치환 + placeholder 잔존 BLOCK + file write가 한 번에 진행됨.

```powershell
$ErrorActionPreference = 'Stop'

$execDate = Get-Date -Format 'yyyy-MM-dd'
$execTimestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

# $gitleaksVersion 검증 — 새 PS 세션에서 §4.1.5만 실행 시 빈 값 false-pass 회피 (Codex 8차 H-1)
# §4.1.1에서 캡처한 값이 같은 세션에 살아있다면 통과. 다른 세션이면 throw → 사용자가 §4.1.1 재실행 또는 변수 직접 할당
if (-not $gitleaksVersion) { throw "release-checklist 작성 실패: `$gitleaksVersion 미정의 (§4.1.1 캡처값을 변수에 할당하라)" }
if ($gitleaksVersion -notmatch '^v?8\.\d+\.\d+') { throw "release-checklist 작성 실패: `$gitleaksVersion 형식 오류 ($gitleaksVersion)" }

# release-checklist 본문 — here-string으로 inline (별도 template 파일 부재, prose vs 코드 일치)
$tmpl = @'
# Release Checklist — v0.1.0

> 목적: MASTER_PLAN v1.5 §4.5 Public 전환 게이트 8개 항목 통과 증빙 + Phase 8 결정 기록.
> 실행일: {{EXEC_DATE}}
> 본 문서가 가리키는 release: tag `v0.1.0` (Phase 8C-post에서 push). git history에서 `git log v0.1.0 -1`로 commit sha 조회 가능.
> 본 문서는 8A commit 상태 그대로 release tag까지 유지 — 후속 수정 placeholder 없음.

## §4.5 게이트 8개 항목

- [x] 라이선스 검토 — LICENSE: MIT. vendored 11개 모두 Apache-2.0(Phase 1·4 재확인). 호환 OK.
- [x] `THIRD_PARTY_NOTICES.md` — Phase 3 작성, Phase 4 데이터 채움.
- [x] 시크릿 스캔 — gitleaks {{GITLEAKS_VERSION}}, `dir` 모드 0 finding / `git` 모드 0 finding ({{EXEC_TIMESTAMP}}).
- [x] `.mcp.json` 토큰/계정 식별자 0건 — 본 리포에 `.mcp.json` 파일 0건(부재로 자동 충족).
- [x] 절대경로·계정명 노출 0건 — P-1~P-4 retroactive grep 0 finding (hook PATH_PATTERNS 정의 line + Anthropic Co-Authored-By footer noreply 면죄 외 hit 0).
- [x] `.env.example` — 미작성 결정. 사유: 사용자 설정 env 0건.
- [x] `.gitignore` — 보강 적용(`.claude/` 일반화).
- [x] 공개 불가 자산 최종 확인 — staging·개인 메모는 `$CLAUDE_WORK_ROOT` 외부 분리 확인.

## Phase 8 자체 결정

- gitleaks를 primary 시크릿 스캐너로 단일 결정 (trufflehog drop, `dir`/`git` 새 syntax)
- GitHub Release object include — 8C-post에서 `gh release view` preflight 후 `gh release create v0.1.0`
- v0.1.0이 첫 tag, semver pre-release(`0.1.0-alpha`) → stable(`0.1.0`)
- atomic push BLOCK 기본 — fallback은 atomic unsupported 정규식 한정 + 사용자 재승인
- Skills ZIP은 §4.7대로 Phase 8 외
- Release-time 5종(branch protection / commit signing / DCO / GitHub security / external announcement) 모두 drop. 1인 repo 사유.

## Allowlist (line 단위)

| 위치 (file:line) | 패턴 | 사유 |
|---|---|---|
| `scripts/git-hooks/pre-commit` 의 PATH_PATTERNS 정의 line | P-1 | hook이 탐지 대상 패턴을 알아야 동작 (line 단위, 다른 line은 면죄 X) |
| Co-Authored-By footer 정확한 line shape (`^Co-Authored-By:\s+Claude\s+Opus\s+4\.7\s+\(1M\s+context\)\s+<noreply@anthropic\.com>\s*$` trim 매치) | P-2 | Anthropic Co-Authored-By footer 표준 line. footer 외 다른 토큰이 같은 line에 섞이면 면죄 X (Codex 5차 H-2) |

본 release-checklist 자체는 file 단위 면죄 X — P-1~P-4 패턴 0 hit이 자연 보장(본 문서 본문은 자연어 서술 + 변수 치환 결과만 박힘).

## 비-zero finding 발생 시 BLOCK 절차 참조

phase8-plan §4.1.1 (gitleaks 7항목) / §4.1.2 (retroactive). revoke first → release BLOCK → sanitize → 재스캔 → 사용자 승인 후 push.

## 통과 판정

모든 항목 PASS → v0.1.0 release 진행.
'@

$rendered = $tmpl `
    -replace '\{\{EXEC_DATE\}\}', $execDate `
    -replace '\{\{EXEC_TIMESTAMP\}\}', $execTimestamp `
    -replace '\{\{GITLEAKS_VERSION\}\}', $gitleaksVersion

# placeholder 잔존 grep BLOCK (메타 v1.2-A) — `{{...}}` + `<...채움...>` 두 형태 모두 (Codex 5차 L-1)
if ($rendered -match '\{\{[A-Z_]+\}\}') {
    throw "release-checklist에 `{{...}}` placeholder 잔존: $($matches[0])"
}
if ($rendered -match '<[^>]*채움[^>]*>') {
    throw "release-checklist에 한국어 angle placeholder 잔존: $($matches[0])"
}

# 빈 치환 false-pass 검사 — 변수가 빈 문자열로 치환됐을 때 placeholder grep은 통과하지만 본문에 specific 값 부재 (Codex 8차 H-1)
if ($rendered -notmatch 'gitleaks v?\d+\.\d+\.\d+') {
    throw "release-checklist에 gitleaks 버전 specific 값 부재 — 빈 치환 false-pass 가능성"
}
if ($rendered -notmatch '실행일: \d{4}-\d{2}-\d{2}') {
    throw "release-checklist에 실행일 specific 값 부재"
}

$rendered | Out-File 'docs/release-checklist-v0.1.0.md' -Encoding utf8 -NoNewline
Write-Host "release-checklist 작성 완료 — placeholder 잔존 0건 + 빈 치환 false-pass 검증 통과"
```

#### 4.1.6 8A commit

stage:
- `.gitignore`
- `docs/release-checklist-v0.1.0.md`

```
Phase 8A: §4.5 Public 전환 게이트 통과 — release-checklist-v0.1.0.md

- gitleaks 설치 (winget). dir/git 양 모드 0 finding. 실 버전·실행 시각은 release-checklist 본문에 변수 치환으로 박힘.
- retroactive 절대경로·계정명 grep (P-1~P-4 strict 자연어 정의 ↔ 검사 코드 1:1) 0 finding. allowlist line 단위(hook PATH_PATTERNS 정의 line + Anthropic noreply footer line만).
- .gitignore 보강: .claude/settings.local.json → .claude/ 일반화. 8A commit 직후 .claude/는 ignored 전환.
- .env.example: 사용자 설정 env 0건 → 미작성 결정 + 사유 기록.
- docs/release-checklist-v0.1.0.md 작성 — §4.5 8/8 PASS + Release-time 5종 drop. 본문은 변수 치환 후 specific 값 박힘 (placeholder 잔존 0건). 8A commit 상태 그대로 release까지 유지.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

---

### 4.2 Batch 8B — GitHub source 재설치 검증 (PS try/finally + §3.1 wrapper inline)

#### 4.2.1 Preflight snapshot

```powershell
$ErrorActionPreference = 'Stop'
$snapshot = "$env:TEMP\phase8b-snapshot-$(Get-Date -Format yyyyMMdd-HHmmss)"
New-Item -ItemType Directory -Path $snapshot | Out-Null

claude plugin list > "$snapshot\plugin-list.txt"
if ($LASTEXITCODE -ne 0) { throw "preflight: claude plugin list 실패" }

Copy-Item "$env:USERPROFILE\.claude\plugins\installed_plugins.json" "$snapshot\installed.json"
Copy-Item "$env:USERPROFILE\.claude\plugins\known_marketplaces.json" "$snapshot\marketplaces.json"
git rev-parse HEAD > "$snapshot\commit.txt"

Write-Host "preflight snapshot: $snapshot"
```

#### 4.2.2 검증 + finally restore (실 PS try/finally + §3.1 wrapper inline)

**§3.1 wrapper drift 검증 step (실행 직전):**

```powershell
$ErrorActionPreference = 'Stop'
$planFile = 'docs/phase8-plan.md'
$content = Get-Content $planFile -Raw
$pattern = '(?sm)^# === RWANG-WB STANDARD WRAPPER BLOCK START[^\r\n]*[\r\n]+(.*?)^# === RWANG-WB STANDARD WRAPPER BLOCK END ==='
$blocks = [regex]::Matches($content, $pattern)
if ($blocks.Count -lt 3) { throw "wrapper 박스 inline 사본 < 3, 실제: $($blocks.Count)" }
$first = $blocks[0].Groups[1].Value
foreach ($b in $blocks) { if ($b.Groups[1].Value -ne $first) { throw "wrapper 박스 byte-for-byte drift 감지" } }
Write-Host "§3.1 wrapper drift 검증 PASS"
```

**본 batch 실행 블록:**

```powershell
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path .).Path

# === RWANG-WB STANDARD WRAPPER BLOCK START — DO NOT MODIFY INLINE COPIES INDEPENDENTLY ===
function Invoke-CliStrict {
    param([scriptblock]$Cmd, [string]$Step)
    & $Cmd
    if ($LASTEXITCODE -ne 0) {
        throw "$Step 실패 (exit $LASTEXITCODE)"
    }
}

function Invoke-CliAllowFail {
    param([scriptblock]$Cmd, [string]$Step)
    & $Cmd 2>&1 | Out-Host
    Write-Host "$Step (exit $LASTEXITCODE — noop 허용)"
    $global:LASTEXITCODE = 0
}
# === RWANG-WB STANDARD WRAPPER BLOCK END ===

$verified = $false
try {
    # Step 1: 두 팩 uninstall (이미 미설치일 수 있어 noop 허용)
    Invoke-CliAllowFail { claude plugin uninstall productivity-pack@rwang-workbench } 'Step 1a'
    Invoke-CliAllowFail { claude plugin uninstall analysis-pack@rwang-workbench } 'Step 1b'

    # Step 2: Directory marketplace remove (없을 수 있어 noop 허용)
    Invoke-CliAllowFail { claude plugin marketplace remove rwang-workbench } 'Step 2'

    # Step 3: GitHub source 재등록 (반드시 성공)
    Invoke-CliStrict { claude plugin marketplace add rwang2gun/rwang-workbench } 'Step 3'

    # Step 4: 두 팩 install (반드시 성공)
    Invoke-CliStrict { claude plugin install productivity-pack@rwang-workbench } 'Step 4a'
    Invoke-CliStrict { claude plugin install analysis-pack@rwang-workbench } 'Step 4b'

    # Step 5: 검증 — 4가지 항목 (V-1~V-4)
    # V-1: claude plugin list 출력에 두 팩 + codex 모두 포함
    $list = (claude plugin list) -join "`n"
    if ($LASTEXITCODE -ne 0) { throw 'V-1 plugin list 실패' }
    if ($list -notmatch 'productivity-pack@rwang-workbench') { throw 'V-1: productivity-pack missing' }
    if ($list -notmatch 'analysis-pack@rwang-workbench') { throw 'V-1: analysis-pack missing' }
    if ($list -notmatch 'codex@openai-codex') { throw 'V-1: codex missing' }

    # V-2: known_marketplaces.json source.source == 'github'
    $km = Get-Content "$env:USERPROFILE\.claude\plugins\known_marketplaces.json" -Raw | ConvertFrom-Json
    if ($km.'rwang-workbench'.source.source -ne 'github') {
        throw "V-2: rwang-workbench source 미전환 (현재: $($km.'rwang-workbench'.source.source))"
    }

    # V-3: installed_plugins.json installPath ∉ repo (Directory source가 아님)
    $ip = Get-Content "$env:USERPROFILE\.claude\plugins\installed_plugins.json" -Raw | ConvertFrom-Json
    foreach ($pack in 'productivity-pack@rwang-workbench','analysis-pack@rwang-workbench') {
        $entries = $ip.plugins.$pack
        if (-not $entries -or $entries.Count -eq 0) { throw "V-3: $pack entry 없음" }
        $userScope = $entries | Where-Object { $_.scope -eq 'user' } | Select-Object -First 1
        if (-not $userScope) { throw "V-3: $pack user-scope entry 없음" }
        if ($userScope.installPath -like "$repo*") {
            throw "V-3: $pack 가 여전히 Directory source ($($userScope.installPath))"
        }
    }

    # V-4: orphan-check 재실행
    powershell -NoProfile -File scripts/check-orphan-originals.ps1
    if ($LASTEXITCODE -ne 0) { throw "V-4: orphan-check exit $LASTEXITCODE (clean이면 0)" }

    $verified = $true
    Write-Host "8B 검증 PASS (V-1~V-4) — restore 진행"
}
finally {
    Write-Host "[finally] dev 환경 복원 시작"
    Invoke-CliAllowFail { claude plugin uninstall productivity-pack@rwang-workbench } 'restore-1a'
    Invoke-CliAllowFail { claude plugin uninstall analysis-pack@rwang-workbench } 'restore-1b'
    Invoke-CliAllowFail { claude plugin marketplace remove rwang-workbench } 'restore-2'
    Invoke-CliStrict { claude plugin marketplace add $repo } 'restore-3'
    Invoke-CliStrict { claude plugin install productivity-pack@rwang-workbench } 'restore-4a'
    Invoke-CliStrict { claude plugin install analysis-pack@rwang-workbench } 'restore-4b'

    $kmAfter = Get-Content "$env:USERPROFILE\.claude\plugins\known_marketplaces.json" -Raw | ConvertFrom-Json
    if ($kmAfter.'rwang-workbench'.source.source -ne 'directory') {
        Write-Error "[finally] restore 후 source가 directory 아님: $($kmAfter.'rwang-workbench'.source.source)"
        Write-Error "[finally] snapshot: $snapshot — 수동 복구 필요"
        throw "8B FAIL — restore 깨짐, 8C 진입 금지"
    }
    Write-Host "[finally] dev 환경 복원 PASS"

    if (-not $verified) {
        throw "8B 검증 FAIL — restore 정상 완료. 8B 재실행 또는 사용자 결정"
    }
}
```

#### 4.2.3 검증 PASS 기준 (8B Exit Gate) — V-N 식별자 §4.3.11과 1:1 매칭

| # | 항목 | 기준 |
|---|---|---|
| V-0 (preflight) | snapshot 생성 | `$snapshot` 디렉토리에 `installed.json`/`marketplaces.json`/`plugin-list.txt`/`commit.txt` |
| V-1 | `claude plugin list` 3 enabled (codex + 두 팩) | 모두 출력 + `LASTEXITCODE == 0` |
| V-2 | `known_marketplaces.json` source.source `github` | strict 비교 |
| V-3 | `installed_plugins.json` installPath ∉ `$repo*` | 두 팩 user-scope 모두 |
| V-4 | orphan-check (`scripts/check-orphan-originals.ps1`) | exit 0 |
| V-restore | finally restore 후 source.source `directory` | strict 비교 |

§4.3.11 8C-post smoke는 V-1·V-2·V-3 + version 0.1.0(`V-5`) 검증 — line-by-line equivalence 보장.

#### 4.2.4 실패 처리

- 어느 step 실패해도 **finally 블록이 자동 실행**
- finally 블록 자체가 깨지면 snapshot에서 수동 복구:
  ```powershell
  Copy-Item "$snapshot\installed.json" "$env:USERPROFILE\.claude\plugins\installed_plugins.json"
  Copy-Item "$snapshot\marketplaces.json" "$env:USERPROFILE\.claude\plugins\known_marketplaces.json"
  ```
- `$verified = $false`로 finally까지 통과 → 8B FAIL, 8C 진입 금지

#### 4.2.5 8B 기록

repo 변경 없음. snapshot은 8B 종료 시 삭제. 결과는 8C CHANGELOG 한 단락으로 흡수.

---

### 4.3 Batch 8C — Release commit + tag (prepared만, push/smoke/Release object는 C-post)

#### 4.3.1 두 팩 `plugin.json` version 갱신

`plugins/productivity-pack/.claude-plugin/plugin.json`:
```diff
-  "version": "0.1.0-alpha",
+  "version": "0.1.0",
```

`plugins/analysis-pack/.claude-plugin/plugin.json`: 동일.

#### 4.3.2 README L5 status 갱신

```diff
- > **Status:** v0.1.0-alpha (scaffolded). Vendored content arrives in Phase 4; native workflows in Phase 5. See [docs/CHANGELOG.md](docs/CHANGELOG.md).
+ > **Status:** v0.1.0 (Phase 8 release, {{REL_DATE}}). 11 vendored plugins · 44 components · 2 packs. See [docs/CHANGELOG.md](docs/CHANGELOG.md).
```

→ `{{REL_DATE}}`는 8C 실 commit 시점 `Get-Date -Format 'yyyy-MM-dd'`로 치환. 치환 후 commit 전 `{{` 잔존 grep BLOCK.

추가로 "Install (local, pre-release)" 섹션 제목을 "Install"로 단순화.

#### 4.3.3 CHANGELOG `[Unreleased]` → `[0.1.0]` 전환 — **8C 시점에는 prepared 진술만, 8D 결과 자리는 변수 placeholder 명시**

```diff
- ## [Unreleased]
+ ## [0.1.0] — {{REL_DATE}} — First public release
+
+ Phase 3 alpha(0.1.0-alpha) 이후 Phase 4~8 누적 산출물의 첫 stable release.
+ Vendoring 11 plugins · 44 components · 2 packs · 1 external recommend(codex).
+
+ ### Phase 8 — {{REL_DATE}}
+
+ **Phase 8P — Plan-fix seed**
+ - phase8-plan v5 + PLAN_DESIGN_GUIDELINES v1.2 + CLAUDE.md sync 변경분을 본 phase 본 작업 전 별도 commit으로 고정. plan 본문 자기참조 sanitize 적용 (절대경로/사용자명/email은 placeholder + `$repo` 변수, P-2 Anthropic noreply 명시 면죄). 8A retroactive grep scope에 plan/guidelines 포함, 8D git mv 작동 보장.
+
+ **Phase 8A — §4.5 Public 게이트 통과**
+ - gitleaks {{GITLEAKS_VERSION}} (`dir`/`git` syntax): 양 모드 0 finding ({{GITLEAKS_TS}}).
+ - Retroactive 절대경로·계정명 grep (P-1~P-4 strict 자연어 ↔ 검사 코드 1:1): 0 finding. allowlist line 단위 (hook PATH_PATTERNS 정의 line + Anthropic noreply footer line).
+ - `.gitignore` 보강: `.claude/` 일반화 → 8A 후 ignored.
+ - `.env.example`: 사용자 설정 env 0건으로 미작성 결정.
+ - `docs/release-checklist-v0.1.0.md` 작성 — §4.5 8/8 PASS + Release-time 5종 drop. 본문은 변수 치환 후 specific 값 박힘 (placeholder 잔존 0건). **8A commit 상태 그대로 release까지 유지**.
+
+ **Phase 8B — GitHub source 재설치 검증 (§3.1 wrapper inline + try/finally)**
+ - preflight snapshot → Directory source 제거 → `claude plugin marketplace add rwang2gun/rwang-workbench` (GitHub source) → 두 팩 install → V-1~V-4 검증 → finally restore (Directory source 복원).
+ - V-1 list / V-2 source.source `github` / V-3 installPath ∉ repo / V-4 orphan-check exit 0 / V-restore source.source `directory` 모두 PASS. dev 환경 정상 복원.
+
+ **Phase 8C — Release commit + tag (prepared)**
+ - 두 팩 `plugin.json` version `0.1.0-alpha` → `0.1.0`.
+ - README L5 status: `v0.1.0-alpha (scaffolded)` → `v0.1.0 (Phase 8 release)`.
+ - 본 CHANGELOG 전환 (`[Unreleased]` → `[0.1.0]`).
+ - `docs/MASTER_PLAN_v1.5.md` §8: 8C release commit/tag prepared. push/smoke/Release object 결과는 8D 블록.
+ - annotated tag `v0.1.0` 생성 (push는 G5 승인 후 8C-post에서).
+
+ (8C-post 단계 — atomic push, release 후 GitHub source smoke, GitHub Release object 생성 — 결과는 아래 **Phase 8D** 블록에 8D commit 시 변수 치환으로 채워짐. 8C commit 시점에는 변수 placeholder만 잔존 — 8D commit 전 grep BLOCK으로 잔존 0건 보장)
+
+ **Phase 8D — Closure + post-release 결과**
+ - phase8-plan archive (`git mv` 작동, 8P seed 덕분).
+ - CLAUDE.md Phase 9 (지속 운영) 전환.
+ - MASTER_PLAN §8: 🔶 → ✅ Phase 8 완료 (8P/8A/8B/8C/8C-post/8D 흡수).
+ - **8C-post 결과 (8D commit 시 변수 치환)**:
+   - atomic push: {{ATOMIC_RESULT}}
+   - release 후 GitHub source smoke: {{SMOKE_RESULT}} — 두 팩 version 0.1.0 + source.source `github` + installPath ∉ repo 확인. Directory source 복원 try/finally 보장.
+   - GitHub Release page: {{RELEASE_URL}}
+
+ ### Phase 7 — 2026-04-25
+ ...(기존 그대로)
```

치환 변수 (8C commit 시 `{{REL_DATE}}` / `{{GITLEAKS_VERSION}}` / `{{GITLEAKS_TS}}` 채움 — 8A 캡처값과 8C 시점 날짜 사용. `{{ATOMIC_RESULT}}` / `{{SMOKE_RESULT}}` / `{{RELEASE_URL}}`은 8C 시점에는 그대로 placeholder 잔존, **8D commit 시 치환 + 잔존 grep BLOCK**).

#### 4.3.4 MASTER_PLAN §8 — 8C는 prepared까지만 (commit boundary)

```diff
- ✅ Phase 7 완료 (2026-04-25) — ...
- ⬜ Phase 8
+ ✅ Phase 7 완료 (2026-04-25) — ...
+ 🔶 Phase 8 진행 중 ({{REL_DATE}}) — 8P/8A/8B/8C release commit·tag prepared. 8C-post(atomic push / 검증 smoke / Release object) + 8D housekeeping 대기.
```

8D 완료 표기·5배치 마감·C-post 결과는 §4.4.3에서.

#### 4.3.5 release-checklist는 8A commit 상태 유지

§4.1.5 릴리스 체크리스트는 8A 시점에 변수 치환 + placeholder 잔존 grep BLOCK으로 0건 commit됨 → 8C에서 **stage 안 함**. 본 plan 모든 §에서 "release-checklist SHA 채움"·"release-checklist 후속 갱신" 표현 미등장.

#### 4.3.6 8C release commit 직전 변수 치환 + 부분 잔존 grep

8C commit 전 README·CHANGELOG·MASTER_PLAN의 `{{REL_DATE}}`/`{{GITLEAKS_VERSION}}`/`{{GITLEAKS_TS}}`만 치환 (이 셋은 8C 시점에 확정값). `{{ATOMIC_RESULT}}`/`{{SMOKE_RESULT}}`/`{{RELEASE_URL}}` 셋은 **의도된 잔존** (8D에서 치환).

```powershell
$ErrorActionPreference = 'Stop'

$relDate = Get-Date -Format 'yyyy-MM-dd'
# $gitleaksVersion / $gitleaksTimestamp 는 §4.1.1·§4.1.5에서 캡처 후 보존 — 동일 PS 세션 또는 release-checklist 본문에서 grep으로 재추출
$gitleaksTs = (Select-String -Path 'docs/release-checklist-v0.1.0.md' -Pattern '`dir` 모드 0 finding / `git` 모드 0 finding \(([^)]+)\)' -AllMatches).Matches[0].Groups[1].Value
$gitleaksVersionFromChecklist = (Select-String -Path 'docs/release-checklist-v0.1.0.md' -Pattern '시크릿 스캔 — gitleaks (v?\d+\.\d+\.\d+)' -AllMatches).Matches[0].Groups[1].Value

$targets = @('README.md','docs/CHANGELOG.md','docs/MASTER_PLAN_v1.5.md')
foreach ($f in $targets) {
    $c = Get-Content $f -Raw
    $c = $c -replace '\{\{REL_DATE\}\}', $relDate
    $c = $c -replace '\{\{GITLEAKS_VERSION\}\}', $gitleaksVersionFromChecklist
    $c = $c -replace '\{\{GITLEAKS_TS\}\}', $gitleaksTs
    $c | Out-File $f -Encoding utf8 -NoNewline
}

# 8C 의도된 잔존 placeholder만 남았는지 검증 (8D에서 치환할 셋만)
$expected = @('ATOMIC_RESULT','SMOKE_RESULT','RELEASE_URL')
foreach ($f in $targets) {
    $c = Get-Content $f -Raw
    $remaining = [regex]::Matches($c, '\{\{([A-Z_]+)\}\}') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    foreach ($r in $remaining) {
        if ($r -notin $expected) { throw "8C 단계에서 미예상 placeholder 잔존: $r in $f" }
    }
}
Write-Host "8C 변수 치환 완료. 의도된 잔존: $($expected -join ', ') (8D에서 치환)"
```

#### 4.3.7 8C release commit (G5 직전)

stage 대상 (명시 add):
- `plugins/productivity-pack/.claude-plugin/plugin.json`
- `plugins/analysis-pack/.claude-plugin/plugin.json`
- `README.md`
- `docs/CHANGELOG.md` (8P/8A/8B/8C는 prepared까지만 진술. 8D 결과 자리는 변수 placeholder 잔존 — 8D에서 치환)
- `docs/MASTER_PLAN_v1.5.md`

**8C에 stage 안 함**: `docs/phase8-plan.md` (8D), `CLAUDE.md` (8D), `docs/release-checklist-v0.1.0.md` (8A).

```powershell
$ErrorActionPreference = 'Stop'

git add plugins/productivity-pack/.claude-plugin/plugin.json
git add plugins/analysis-pack/.claude-plugin/plugin.json
git add README.md
git add docs/CHANGELOG.md
git add docs/MASTER_PLAN_v1.5.md

$msg = @'
Phase 8C: v0.1.0 release commit + tag prepared

- plugins/{productivity-pack,analysis-pack}/.claude-plugin/plugin.json: 0.1.0-alpha → 0.1.0
- README.md L5: v0.1.0-alpha (scaffolded) → v0.1.0 (Phase 8 release, REL_DATE 치환)
- docs/CHANGELOG.md: [Unreleased] → [0.1.0]. 8P/8A/8B/8C는 prepared 진술. 8C-post 결과 자리(ATOMIC_RESULT/SMOKE_RESULT/RELEASE_URL)는 의도된 placeholder 잔존 — 8D commit 시 치환 + 잔존 grep BLOCK.
- docs/MASTER_PLAN_v1.5.md §8: 8C release commit/tag prepared. push/smoke/Release object는 8C-post.

본 commit은 release commit 자체만. atomic push, release 후 smoke, GitHub Release object 생성은 commit 이후 단계라 본 commit에서 완료 진술 X (false-claim release tag 회피).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
'@

git commit -m $msg
if ($LASTEXITCODE -ne 0) { throw "8C commit 실패" }
```

#### 4.3.8 Annotated tag `v0.1.0` (commit 직후, push는 8C-post)

```powershell
$tagMsg = @'
rwang-workbench v0.1.0 — first public release

Packs:
- analysis-pack
- productivity-pack

Vendored: 11 plugins, 44 components (all Apache-2.0).
External recommend: codex (openai/codex-plugin-cc).

Phase 3 alpha (0.1.0-alpha) 이후 Phase 4~8 누적 산출물.

See docs/CHANGELOG.md for full release notes.
See docs/MASTER_PLAN_v1.5.md for design rationale.
'@

git tag -a v0.1.0 -m $tagMsg
if ($LASTEXITCODE -ne 0) { throw "v0.1.0 tag 생성 실패" }

git tag -l v0.1.0  # 존재 확인
```

#### 4.3.9 8C Exit Gate (G4 후 G5 직전 통과 기준)

- 8C release commit 통과 (sha 확인 가능)
- v0.1.0 annotated tag 존재 (local)
- working tree clean
- README/CHANGELOG/MASTER_PLAN의 `{{REL_DATE}}`·`{{GITLEAKS_VERSION}}`·`{{GITLEAKS_TS}}` 치환 완료, `{{ATOMIC_RESULT}}`·`{{SMOKE_RESULT}}`·`{{RELEASE_URL}}` 셋만 의도된 잔존
- **8C-post는 G5 승인 후 §4.3.10~§4.3.12에서 진행**

---

### 4.3.10 8C-post Step 1: Atomic push (G5 사용자 승인 후)

GitHub remote는 atomic 지원이 standard. atomic 실패 시 fallback이 partial state를 직접 만드는 것이라 **BLOCK이 기본**. fallback은 atomic unsupported 정규식 한정 + 사용자 재승인.

```powershell
$ErrorActionPreference = 'Stop'

# Preflight
git fetch origin --tags
if ($LASTEXITCODE -ne 0) { throw "preflight fetch 실패" }
git status --short
git rev-parse HEAD
git tag -l v0.1.0

# Atomic push (primary)
$pushOutput = git push --atomic origin main v0.1.0 2>&1
$pushExit = $LASTEXITCODE

# 실 git stderr 메시지 예시 (atomic 미지원 시):
#   fatal: the receiving end does not support --atomic push
#   fatal: atomic push failed for ref refs/heads/main
# 정규식은 위 형태 + 일반화된 "atomic ... not supported"·"atomic ... unsupported" 형태 모두 cover (Codex 4차 L-2)

if ($pushExit -eq 0) {
    $atomicResult = '성공'
    Write-Host "atomic push 성공"
}
else {
    # fallback 조건 — atomic 미지원 메시지일 때만
    $atomicUnsupported = $pushOutput -match '(?is)(atomic.*(unsupported|not[ -]?supported|does not support|protocol)|does not support.*atomic|unsupported.*atomic)'
    if ($atomicUnsupported) {
        Write-Warning "atomic push unsupported by remote: $pushOutput"
        Write-Warning "fallback 사용 시 main이 먼저 push되고 tag가 별도 push (partial state 위험)"
        Write-Warning "사용자 명시 재승인 필요 — 진행 시 아래를 수동 실행:"
        Write-Host "  git push origin main; if (`$LASTEXITCODE -eq 0) { git push origin v0.1.0 }"
        $atomicResult = "fallback 필요 — 사용자 결정 대기 (atomic unsupported)"
        throw "atomic push fallback 미진행 — 사용자 결정 대기"
    }
    else {
        # 다른 에러 (non-fast-forward, 권한, hook, 인증 등): 곧장 BLOCK
        throw "atomic push 실패 (non-atomic 에러): $pushOutput"
    }
}
# $atomicResult 는 8D commit·CHANGELOG 변수 치환에 사용
```

### 4.3.11 8C-post Step 2: Release 후 GitHub source smoke (§3.1 wrapper inline + try/finally + cache 사전 삭제 + §4.2.2와 검증 항목 line-by-line equivalence)

push 직후 release commit 기준으로 GitHub source 재설치 한 번 더. **본 블록은 §4.2.2와 다른 PowerShell 세션일 수 있어 wrapper inline 재정의** + **§3.1 drift 검증 step 재실행** + **§4.2.2와 검증 항목 line-by-line equivalence**(V-1·V-2·V-3 동일 + V-5 version 0.1.0 추가) + **cache 사전 삭제**(claude plugin marketplace add가 stale GitHub cache를 fetch하지 않도록 — F-3).

**§3.1 wrapper drift 검증 step (실행 직전):**

```powershell
$ErrorActionPreference = 'Stop'
$planFile = 'docs/phase8-plan.md'
$content = Get-Content $planFile -Raw
$pattern = '(?sm)^# === RWANG-WB STANDARD WRAPPER BLOCK START[^\r\n]*[\r\n]+(.*?)^# === RWANG-WB STANDARD WRAPPER BLOCK END ==='
$blocks = [regex]::Matches($content, $pattern)
if ($blocks.Count -lt 3) { throw "wrapper 박스 inline 사본 < 3, 실제: $($blocks.Count)" }
$first = $blocks[0].Groups[1].Value
foreach ($b in $blocks) { if ($b.Groups[1].Value -ne $first) { throw "wrapper 박스 byte-for-byte drift 감지" } }
Write-Host "§3.1 wrapper drift 검증 PASS"
```

**Smoke 실행 블록:**

```powershell
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path .).Path

# === RWANG-WB STANDARD WRAPPER BLOCK START — DO NOT MODIFY INLINE COPIES INDEPENDENTLY ===
function Invoke-CliStrict {
    param([scriptblock]$Cmd, [string]$Step)
    & $Cmd
    if ($LASTEXITCODE -ne 0) {
        throw "$Step 실패 (exit $LASTEXITCODE)"
    }
}

function Invoke-CliAllowFail {
    param([scriptblock]$Cmd, [string]$Step)
    & $Cmd 2>&1 | Out-Host
    Write-Host "$Step (exit $LASTEXITCODE — noop 허용)"
    $global:LASTEXITCODE = 0
}
# === RWANG-WB STANDARD WRAPPER BLOCK END ===

$smokeVerified = $false
try {
    # uninstall + marketplace remove (Directory source — 8B finally restore된 상태)
    Invoke-CliAllowFail { claude plugin uninstall productivity-pack@rwang-workbench } 'smoke-1a'
    Invoke-CliAllowFail { claude plugin uninstall analysis-pack@rwang-workbench } 'smoke-1b'
    Invoke-CliAllowFail { claude plugin marketplace remove rwang-workbench } 'smoke-2'

    # cache 사전 삭제 (F-3 — 8B에서 한 번 GitHub source로 install/restore 거쳤으면 stale cache 가능)
    $cacheDir = "$env:USERPROFILE\.claude\plugins\cache\rwang-workbench"
    if (Test-Path -LiteralPath $cacheDir) {
        Remove-Item -LiteralPath $cacheDir -Recurse -Force
        Write-Host "smoke-2.5: stale cache 삭제 ($cacheDir)"
    }

    # GitHub source 재등록 (release commit = main HEAD)
    Invoke-CliStrict { claude plugin marketplace add rwang2gun/rwang-workbench } 'smoke-3'
    Invoke-CliStrict { claude plugin install productivity-pack@rwang-workbench } 'smoke-4a'
    Invoke-CliStrict { claude plugin install analysis-pack@rwang-workbench } 'smoke-4b'

    # 검증 — §4.2.2 V-1·V-2·V-3과 line-by-line 동일 + V-5 version 0.1.0 추가
    # V-1: claude plugin list 3 enabled
    $list = (claude plugin list) -join "`n"
    if ($LASTEXITCODE -ne 0) { throw 'smoke V-1 plugin list 실패' }
    if ($list -notmatch 'productivity-pack@rwang-workbench') { throw 'smoke V-1: productivity-pack missing' }
    if ($list -notmatch 'analysis-pack@rwang-workbench') { throw 'smoke V-1: analysis-pack missing' }
    if ($list -notmatch 'codex@openai-codex') { throw 'smoke V-1: codex missing' }

    # V-2: known_marketplaces.json source.source == 'github'
    $km = Get-Content "$env:USERPROFILE\.claude\plugins\known_marketplaces.json" -Raw | ConvertFrom-Json
    if ($km.'rwang-workbench'.source.source -ne 'github') {
        throw "smoke V-2: rwang-workbench source 미전환 (현재: $($km.'rwang-workbench'.source.source))"
    }

    # V-3: installed_plugins.json installPath ∉ repo
    $ip = Get-Content "$env:USERPROFILE\.claude\plugins\installed_plugins.json" -Raw | ConvertFrom-Json
    foreach ($pack in 'productivity-pack@rwang-workbench','analysis-pack@rwang-workbench') {
        $entries = $ip.plugins.$pack
        if (-not $entries -or $entries.Count -eq 0) { throw "smoke V-3: $pack entry 없음" }
        $userScope = $entries | Where-Object { $_.scope -eq 'user' } | Select-Object -First 1
        if (-not $userScope) { throw "smoke V-3: $pack user-scope entry 없음" }
        if ($userScope.installPath -like "$repo*") {
            throw "smoke V-3: $pack 가 여전히 Directory source ($($userScope.installPath))"
        }
        # V-5: version 0.1.0 (smoke 전용 추가 항목 — release commit이 가리키는 manifest 검증)
        if ($userScope.version -ne '0.1.0') {
            throw "smoke V-5: $pack version $($userScope.version) (기대: 0.1.0)"
        }
    }

    $smokeVerified = $true
    $smokeResult = 'PASS — V-1/V-2/V-3/V-5 (두 팩 version 0.1.0 + source.source github + installPath ∉ repo)'
    Write-Host "release 후 smoke PASS — $smokeResult"
}
finally {
    # 항상 실행 — Directory source 복원
    Write-Host "[finally] dev 환경 복원 시작"
    Invoke-CliAllowFail { claude plugin uninstall productivity-pack@rwang-workbench } 'smoke-restore-1a'
    Invoke-CliAllowFail { claude plugin uninstall analysis-pack@rwang-workbench } 'smoke-restore-1b'
    Invoke-CliAllowFail { claude plugin marketplace remove rwang-workbench } 'smoke-restore-2'
    Invoke-CliStrict { claude plugin marketplace add $repo } 'smoke-restore-3'
    Invoke-CliStrict { claude plugin install productivity-pack@rwang-workbench } 'smoke-restore-4a'
    Invoke-CliStrict { claude plugin install analysis-pack@rwang-workbench } 'smoke-restore-4b'

    $kmAfter = Get-Content "$env:USERPROFILE\.claude\plugins\known_marketplaces.json" -Raw | ConvertFrom-Json
    if ($kmAfter.'rwang-workbench'.source.source -ne 'directory') {
        throw "[finally] smoke restore 후 source가 directory 아님: $($kmAfter.'rwang-workbench'.source.source)"
    }
    Write-Host "[finally] dev 환경 복원 완료"
}

if (-not $smokeVerified) {
    $smokeResult = 'FAIL — restore는 정상 완료. release tag/push 직후라 8D 진입 신중'
    throw "8C smoke FAIL — $smokeResult"
}
# $smokeResult 는 8D commit·CHANGELOG 변수 치환에 사용
```

**§4.2.2 vs §4.3.11 검증 항목 line-by-line equivalence (메타 v1.2-A — functional equivalent 단언 enforce):**

| 검증 ID | §4.2.2 (8B) | §4.3.11 (smoke) | 동일성 |
|---|---|---|---|
| V-1 plugin list 3 enabled | ✓ | ✓ | line-by-line 동일 |
| V-2 source.source `github` | ✓ | ✓ | line-by-line 동일 |
| V-3 installPath ∉ `$repo*` | ✓ | ✓ | line-by-line 동일 |
| V-4 orphan-check | ✓ | ✗ (smoke 시점은 release commit 기준이라 orphan-check 동일 결과 — 생략 OK, 본 표에서 명시 차이) | smoke는 V-4 skip |
| V-5 version 0.1.0 | ✗ | ✓ | smoke 전용 추가 (release 후 검증 본질) |
| V-restore source.source `directory` | ✓ | ✓ | line-by-line 동일 (finally) |

→ smoke는 V-1/V-2/V-3 동일 + V-5 추가 + V-4 생략 (release commit 기준 orphan-check는 8B와 동일 결과 보장이 plan 작성 시점에 추론됨, 사후 검증 필요 시 별도 ad-hoc)

### 4.3.12 8C-post Step 3: GitHub Release object — `gh release view` preflight 분기 + 사후 view exit code (Codex 4차 L-3)

```powershell
$ErrorActionPreference = 'Stop'

$existing = gh release view v0.1.0 --json tagName,name,isDraft,createdAt 2>&1
$ghExit = $LASTEXITCODE

if ($ghExit -eq 0) {
    Write-Warning "v0.1.0 release object 기존재 — preflight 결과:"
    Write-Host $existing
    Write-Warning "옵션:"
    Write-Warning "  (a) gh release edit v0.1.0 --notes-file <new>      # 노트 갱신"
    Write-Warning "  (b) gh release delete v0.1.0 + 재생성              # 사용자 명시 승인 필요"
    throw "release object 기존재 — 사용자 결정 대기"
}
elseif ($existing -match 'release not found' -or $existing -match 'HTTP 404') {
    # 정상 진행 — 신규 생성
    $notes = @"
First public release.

Packs:
- analysis-pack — Data analysis, SNA, trend reports, standalone HTML build
- productivity-pack — Git sync, PR review, plugin development, hookify automation

Vendored: 11 plugins, 44 components (all Apache-2.0). See THIRD_PARTY_NOTICES.md.
External recommend: codex (openai/codex-plugin-cc) — see docs/RECOMMENDED_PLUGINS.md.

## Install

``````
/plugin marketplace add rwang2gun/rwang-workbench
/plugin install productivity-pack@rwang-workbench
/plugin install analysis-pack@rwang-workbench
``````

See [CHANGELOG](docs/CHANGELOG.md) for the full Phase 4~8 history.
"@
    $notes | Out-File "$env:TEMP\release-notes-v0.1.0.md" -Encoding utf8

    gh release create v0.1.0 --title "rwang-workbench v0.1.0" --notes-file "$env:TEMP\release-notes-v0.1.0.md" --verify-tag
    if ($LASTEXITCODE -ne 0) { throw "gh release create 실패" }

    Remove-Item "$env:TEMP\release-notes-v0.1.0.md" -ErrorAction SilentlyContinue

    # 사후 검증 — view exit code 명시 검사 (Codex 4차 L-3)
    $created = gh release view v0.1.0 --json url 2>&1
    if ($LASTEXITCODE -ne 0) { throw "사후 gh release view 실패 (exit $LASTEXITCODE): $created" }
    $releaseUrl = ($created | ConvertFrom-Json).url
    if (-not $releaseUrl) { throw "사후 view에서 url 추출 실패: $created" }
    Write-Host "Release object 생성: $releaseUrl"
}
else {
    throw "gh release view preflight 실패 (exit $ghExit): $existing"
}
# $releaseUrl 는 8D commit·CHANGELOG 변수 치환에 사용
```

#### 4.3.13 8C-post Exit Gate

- atomic push 성공 (또는 사용자 승인 후 fallback 성공) → `$atomicResult` 캡처
- `$smokeVerified == $true` (V-1/V-2/V-3/V-5 PASS + Directory source restore PASS) → `$smokeResult` 캡처
- `gh release view v0.1.0` 사후 view 정상 출력 (exit 0 + URL 추출) → `$releaseUrl` 캡처

세 변수 모두 8D commit 시 치환에 사용. 8D commit 전 placeholder 잔존 grep BLOCK으로 강제.

---

### 4.4 Batch 8D — Phase 8 closure + post-release 결과 흡수

#### 4.4.1 phase8-plan archive

```powershell
$ErrorActionPreference = 'Stop'

git mv docs/phase8-plan.md docs/archive/phase8-plan.md
if ($LASTEXITCODE -ne 0) { throw "8D git mv 실패 — 8P seed commit 누락 의심" }
```

#### 4.4.2 CLAUDE.md sync

- 현재 상태 표: Phase 7 완료 + Phase 8 ✅ + Phase 9 ⬜ 추가
- "다음 액션 — Phase 8 plan v5" → "현재 운영 단계 — Phase 9 (지속 운영)"
- 핵심 설계 문서 / 환경 특이사항 / 커밋 컨벤션 / 확정된 결정사항 / Pre-commit 훅 / 트러블슈팅 — 변경 없음

#### 4.4.3 MASTER_PLAN §8 — 8D 완료 표기 + C-post 결과 흡수

```diff
- 🔶 Phase 8 진행 중 ({{REL_DATE}}) — 8P/8A/8B/8C release commit·tag prepared. 8C-post + 8D housekeeping 대기.
+ ✅ Phase 8 완료 ({{REL_DATE}}) — 8P/8A/8B/8C/8C-post/8D 흡수. v0.1.0 첫 public release. §4.5 게이트 8/8 PASS, GitHub source 재설치 검증 PASS, atomic push {{ATOMIC_RESULT}}, release 후 GitHub source smoke {{SMOKE_RESULT}}, GitHub Release page {{RELEASE_URL}}. 자세히는 docs/CHANGELOG.md [0.1.0] 블록.
+ ⬜ Phase 9 (지속 운영) — 트리거 기반(신규 자산·릴리스 전 점검·실패 제보)
```

→ 위 4 placeholder는 §4.4.4에서 변수 치환 후 잔존 grep BLOCK.

#### 4.4.4 8D commit + push (변수 치환 + commit 전 placeholder 잔존 grep BLOCK — Codex 4차 H-5)

stage 대상: `docs/archive/phase8-plan.md` (rename target — git mv 자동 stage) / `CLAUDE.md` / `docs/CHANGELOG.md` (8D 블록의 C-post 결과 변수 치환) / `docs/MASTER_PLAN_v1.5.md`.

**변수 치환** (8C-post에서 캡처한 `$atomicResult`/`$smokeResult`/`$releaseUrl` 사용. 동일 PS 세션이 아니면 적절한 메커니즘으로 전달 — 본 plan은 동일 세션 가정):

```powershell
$ErrorActionPreference = 'Stop'

# 8C-post 캡처 변수 — 같은 PS 세션 가정. 다른 세션이면 §4.3.10/§4.3.11/§4.3.12의 캡처값을 그대로 변수에
# 할당해 사용. **plan 본문에는 미래 실 실행 결과(URL 등) hardcode 금지** (Codex 5차 L-2, 메타 v1.2-B).
# 변수가 비어 있으면 throw — 실 실행 결과만 채워지도록 강제.

if (-not $atomicResult) { throw "8D 변수 치환: `$atomicResult 미정의 (§4.3.10 캡처값을 변수에 할당하라)" }
if (-not $smokeResult) { throw "8D 변수 치환: `$smokeResult 미정의 (§4.3.11 캡처값을 변수에 할당하라)" }
if (-not $releaseUrl) { throw "8D 변수 치환: `$releaseUrl 미정의 (§4.3.12 사후 view 캡처값을 변수에 할당하라)" }

# $releaseUrl strict shape 검증 — repo URL은 git remote에서 동적 추출 (plan 본문에 future URL hardcode 금지, 메타 v1.2-B)
$remoteRaw = (git config --get remote.origin.url).Trim()
$remoteWeb = $remoteRaw -replace '\.git$',''
if (-not $remoteWeb) { throw "8D 변수 치환: git remote.origin.url 추출 실패" }
$expectedUrlPattern = '^' + [regex]::Escape($remoteWeb) + '/releases/tag/v0\.1\.0$'
if ($releaseUrl -notmatch $expectedUrlPattern) {
    throw "8D 변수 치환: `$releaseUrl 형식이 본 repo v0.1.0 release URL이 아님 ($releaseUrl, expected pattern: $expectedUrlPattern)"
}

$relDate = Get-Date -Format 'yyyy-MM-dd'

# CHANGELOG·MASTER_PLAN의 8D 블록 placeholder 치환
$targets = @('docs/CHANGELOG.md','docs/MASTER_PLAN_v1.5.md','CLAUDE.md')
foreach ($f in $targets) {
    if (-not (Test-Path -LiteralPath $f)) { continue }
    $c = Get-Content $f -Raw
    $c = $c -replace '\{\{REL_DATE\}\}', $relDate
    $c = $c -replace '\{\{ATOMIC_RESULT\}\}', $atomicResult
    $c = $c -replace '\{\{SMOKE_RESULT\}\}', $smokeResult
    $c = $c -replace '\{\{RELEASE_URL\}\}', $releaseUrl
    $c | Out-File $f -Encoding utf8 -NoNewline
}

# stage 후 8D commit 직전 placeholder 잔존 grep BLOCK
git add CLAUDE.md
git add docs/CHANGELOG.md
git add docs/MASTER_PLAN_v1.5.md
# git mv가 phase8-plan을 이미 stage함

# staged content에 placeholder 잔존 0건 검증 (메타 v1.2-A)
$staged = git diff --cached --name-only
foreach ($f in $staged) {
    if (-not (Test-Path -LiteralPath $f)) { continue }
    $c = Get-Content $f -Raw -ErrorAction SilentlyContinue
    if ($c -match '\{\{[A-Z_]+\}\}') { throw "8D commit 전 placeholder 잔존: $f -> $($matches[0])" }
    if ($c -match '<\s*8D\s*시점에\s*채움\s*>') { throw "8D commit 전 한국어 placeholder 잔존: $f" }
}

# commit 메시지도 변수로 생성 + here-string 안에 placeholder 0건
$commitMsg = @"
Phase 8D: close Phase 8 (archive plan + CLAUDE.md sync + MASTER §8 완료 + post-release 결과 흡수)

- docs/phase8-plan.md → docs/archive/phase8-plan.md
- CLAUDE.md: Phase 8 ✅ + Phase 9 (지속 운영)로 전환
- docs/CHANGELOG.md 8D 블록: 8C-post 실 결과 변수 치환
- docs/MASTER_PLAN_v1.5.md §8: 🔶 → ✅ Phase 8 완료 (8P/8A/8B/8C/8C-post/8D 흡수)

8C-post 결과:
- atomic push: $atomicResult
- release 후 GitHub source smoke: $smokeResult
- GitHub Release page: $releaseUrl

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
"@

# commit 메시지 자체에도 placeholder 잔존 grep
if ($commitMsg -match '\{\{[A-Z_]+\}\}') { throw "8D commit 메시지에 placeholder 잔존" }
if ($commitMsg -match '<\s*8D\s*시점에\s*채움\s*>') { throw "8D commit 메시지에 한국어 placeholder 잔존" }

git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) { throw "8D commit 실패" }

git push origin main
if ($LASTEXITCODE -ne 0) { throw "8D push 실패" }
```

---

## 5. 리스크

| # | 리스크 | 대응 |
|---|---|---|
| R-1 | gitleaks 두 모드 finding | release **BLOCK**. credential revoke 우선(§4.1.1 7항목). force push 사용자 명시 승인 후 |
| R-2 | retroactive grep 의도되지 않은 노출 | sanitize commit 후 8A 재실행. archive·release-checklist file 단위 면죄 X (line 단위 allowlist만) |
| R-3 | 8B 중간 실패 → dev 환경 비복원 | §4.2.2 PS try/finally + §3.1 wrapper inline + finally restore + snapshot 수동 복구(§4.2.4) |
| R-4 | 8C release commit이 후속 작업 진술 (false-claim tag) | §4.3.3/4/7 prepared까지만. C-post 결과는 §4.4 8D commit + CHANGELOG에 변수 치환 흡수 |
| R-5 | atomic push fallback이 partial state 직접 생성 | §4.3.10 fallback 조건을 "atomic unsupported" 정규식 + 사용자 재승인 한정. 다른 에러는 BLOCK |
| R-6 | v0.1.0 tag 박힌 후 잘못 발견 | tag delete + force push 사용자 명시 승인. GitHub Release page 노출 사실 고지 |
| R-7 | `gh release create` 부분 성공 / 중복 | §4.3.12 `gh release view` preflight + 결과별 create/edit/delete 분기 + 사후 view exit code |
| R-8 | marketplace remove 실패 → known_marketplaces.json 잔존 | §4.2.4 snapshot 수동 복구. `claude plugin marketplace list`로 정합성 확인 |
| R-9 | public fork/mirror/cache 잔존 | history rewrite/redact 회수 불가. 보안 finding 발생 시 credential revoke를 유일한 회수 수단 |
| R-10 | 8C에 plan/CLAUDE.md를 stage 시 release tag가 plan 폐기 전 commit 가리킴 | §4.3.7 stage 명시 — phase8-plan/CLAUDE.md는 8D 처리 |
| R-11 | release 후 smoke 중간 실패 → dev 환경 비복원 (release tag 박힌 후라 더 critical) | §4.3.11 try/finally + `$smokeVerified` flag + §3.1 wrapper inline |
| R-12 | 8P 누락 → plan/guidelines untracked로 retroactive grep scope 누락 | §4.0 Batch 8P. G2 게이트가 `git status --short`에서 `?? .claude/`만 잔존 검증 |
| R-13 | branch protection / commit signing / DCO / GitHub security / external announcement 미적용 | §0 Release-time 결정 표 — 모두 drop 명시 |
| R-14 | plan 본문 자체가 plan 게이트(8P pre-commit hook + 8A retroactive grep)를 위반 | v5 sanitize: 절대경로/사용자명/email을 placeholder + `$repo` 변수로. P-2 Anthropic noreply 명시 면죄 |
| R-15 | wrapper 함수 inline 사본 drift (§3.1 vs §4.2.2 vs §4.3.11) | §3.1 wrapper drift 검증 step (8B/8C-post 실행 직전 grep diff 3개 사본 byte-for-byte 동일성 강제) |
| R-16 | release-bound 문서(release-checklist·CHANGELOG) 본문에 plan 작성 시점 hardcode 값 박힘 | §4.1.5 변수 치환 + §4.3.6 / §4.4.4 placeholder 잔존 grep BLOCK. plan 본문은 placeholder만 — specific 값은 실 실행 시점 캡처 |
| R-17 | `claude plugin marketplace add`가 stale GitHub cache 사용 → release commit 미반영 smoke | §4.3.11 cache 사전 삭제 step (`Remove-Item ~/.claude/plugins/cache/rwang-workbench`) |
| R-18 | 8C-post와 8D 사이 PS 세션 분리 → 변수 전달 실패 | §4.4.4 변수 미정의 시 명시 throw + 사용자가 직접 변수 할당 후 재실행 가능 |

---

## 6. Exit Gate

| 게이트 | 기준 |
|---|---|
| **8P** | plan v5 + GUIDELINES v1.2 + CLAUDE.md commit 통과. `git status --short` `?? .claude/` 1줄만 잔존. plan/guidelines `git ls-files` 결과 포함. pre-commit hook 통과(plan 본문 sanitize) |
| **8A** | gitleaks 두 모드 0 finding + retroactive P-1~P-4 0 finding(line 단위 allowlist 외) + `.gitignore` `.claude/` 추가 + `release-checklist-v0.1.0.md` 변수 치환 + placeholder 잔존 0건. commit stage = `.gitignore`·release-checklist 둘 |
| **8B** | preflight snapshot + V-1~V-4 PASS + finally restore 후 V-restore PASS. §3.1 wrapper drift 검증 PASS |
| **8C** | 두 팩 plugin.json `0.1.0` + README L5 갱신 + CHANGELOG `[0.1.0]`(prepared 진술 + ATOMIC_RESULT/SMOKE_RESULT/RELEASE_URL placeholder 의도 잔존만) + MASTER §8 8C까지 prepared + tag `v0.1.0` annotated. **commit 시점에 push/smoke/Release object 진술 없음**. C-post는 G5 후 |
| **8C-post** | atomic push 성공(또는 unsupported fallback 사용자 승인) → `$atomicResult` 캡처 + `$smokeVerified == $true` (V-1/V-2/V-3/V-5 PASS) → `$smokeResult` 캡처 + `gh release view v0.1.0` 사후 exit 0 + URL → `$releaseUrl` 캡처 |
| **8D** | phase8-plan archive(`git mv` 작동) + CLAUDE.md sync + MASTER §8 8D 완료 + CHANGELOG 8D 블록 변수 치환 + commit 전 placeholder 잔존 grep BLOCK 통과 + push |

**Phase 9 진입 조건**: 8D push 완료 + GitHub Release page에 v0.1.0 visible + `gh release view v0.1.0` 정상.

---

## 7. Codex 리뷰 결과 + finding 추적

### 1차 (v1) — CLOSED. 12건 흡수.

| # | 심각도 | finding | 흡수 |
|---|---|---|---|
| H-1 | High | history finding 처리 부족 | §4.1.1 7항목 + R-1, R-9 |
| H-2 | High | retroactive grep scope 모호 + archive 면죄 | §4.1.2 strict scope + line 단위 allowlist |
| H-3 | High | 8B 실패 복원 부재 | §4.2.1 preflight + §4.2.2 PS try/finally |
| H-4 | High | commit boundary 깨짐 | §4.3.4 / §4.4.3 / §4.3.7 stage 명시 |
| H-5 | High | push atomic 미보장 | §4.3.10 atomic primary + fallback 한정 |
| H-6 | High | `.env.example` 키 부정확 | §1.5 + §4.1.3 미작성 결정 |
| H-7 | High | README badge 갱신 누락 | §4.3.2 |
| L-1 | Low | gitleaks report §간 모순 | §4.1.1 단일 정책 |
| L-2 | Low | trufflehog 양다리 | §1.6 + §4.1.1 drop |
| L-3 | Low | installPath 기대값 확정 전제 | §4.2.3 일반화 |
| L-4 | Low | GitHub Release object 명시 부재 | §0 + §4.3.12 |
| L-5 | Low | mirror/fork R-1과 분리 | R-9 |

### 2차 (v2) — CLOSED. 11건 흡수.

| # | 심각도 | finding | 흡수 |
|---|---|---|---|
| H-1 | High | working tree 진술 부정확 + plan commit batch 부재 | §4.0 Batch 8P + §1.1 + G2 |
| H-2 | High | release-checklist placeholder vs 8C stage 정합성 | §4.1.5 변수 치환 + §4.3.5 stage 불요 |
| H-3 | High | try/finally prose만 | §4.2.2 wrapper + try/finally + LASTEXITCODE |
| H-4 | High | release 후 0.1.0 미검증 | §4.3.11 release 후 smoke |
| H-5 | High | atomic fallback partial state | §4.3.10 fallback 조건 한정 |
| H-6 | High | `--verify-tag` idempotency 미보장 | §4.3.12 view preflight + 분기 |
| H-7 | High | retroactive grep scope에 untracked plan-bound 누락 | §4.0 8P seed + §4.1.2 scope |
| L-1 | Low | gitleaks `detect` deprecated | §4.1.1 `dir`/`git` |
| L-2 | Low | "5단계" vs 실제 7항목 | §4.1.1 "7항목" 정정 |
| L-3 | Low | release-time 결정 R 누락 | §0 5종 drop + R-13 |
| L-4 | Low | §8 self-check 과대평가 | §8 v1.1 기준 재작성 |

### 3차 (v3) — CLOSED. 8건 흡수.

| # | 심각도 | finding | 흡수 |
|---|---|---|---|
| H-1 | High | 8P seed가 pre-commit hook에 차단 | plan 본문 자기참조 sanitize |
| H-2 | High | 8A retroactive grep이 plan 자기 자신에 trigger | 동일 sanitize + §4.1.2 P-1~P-4 자연어 |
| H-3 | High | 8C release commit이 후속 작업 완료 진술 → false-claim tag | commit boundary 분리 (8C prepared, 8D 결과 흡수) |
| H-4 | High | 8C smoke가 wrapper 함수 사용하지만 정의 없음 | §4.3.11 wrapper inline 재정의 |
| H-5 | High | 8C smoke restore가 try/finally 아님 | §4.3.11 try/finally + `$smokeVerified` flag |
| L-1 | Low | atomic regex가 "does not support --atomic" 매칭 X | §4.3.10 정규식 보강 |
| L-2 | Low | "release-checklist SHA 채움" 잔존 | §4.3.5 / §0 / §3 잔존 표현 제거 |
| L-3 | Low | §8 self-check 과대평가 | §8 갱신 |

### 4차 (v4) — CLOSED. 9건 + Claude self-review 4건 = 13건 흡수.

| # | 심각도 | finding | 흡수 (v5) |
|---|---|---|---|
| H-1 | High | §4.1.2 self-sanitize 자기모순 (P-2 generic email regex가 commit footer Anthropic noreply 잡음 + P-3 예시가 자기 trigger) | §4.1.2 P-2를 strict "본인 commit author email + Anthropic noreply 명시 면죄"로 정의. P-3은 일반 절대 드라이브 경로 정규식 별도 추가. plan 본문 예시는 자연어 |
| H-2 | High | §4.1.5 release-checklist 전체 allowlist 부적정 (file 단위 면죄로 진짜 누설 통과 가능) | §4.1.2 / §4.1.5 file 단위 allowlist 제거. release-checklist도 0 finding 대상 (line 단위 allowlist만 — hook PATH_PATTERNS 정의 line + Anthropic noreply footer line) |
| H-3 | High | §4.1.2 P-3 자연어 정의 vs 검사 코드 mismatch | §4.1.2 P-3에 일반 절대 드라이브 경로 정규식 (`[A-Za-z]:[\\\/](?:Users\|claude)[\\\/]`) 추가. 자연어 정의 ↔ 검사 코드 1:1 표 §4.1.2 말미 |
| H-4 | High | §4.3.10 smoke functional equivalence 부족 (§4.2.2의 source/installPath 검증 누락) | §4.3.11 smoke V-1/V-2/V-3 = §4.2.2 V-1/V-2/V-3 line-by-line 동일 + V-5 version 0.1.0 추가. equivalence 표 §4.3.11 말미 |
| H-5 | High | §4.4.4 8D commit 메시지 placeholder 잔존 | §4.4.4 변수 치환 + here-string 변수 사용 + commit 전 placeholder 잔존 grep BLOCK (한국어 placeholder도 검사) |
| L-1 | Low | §4.0.3 `.claude/` 시점 모호 | §4.0.3 8P 시점 untracked / 8A 후 ignored 두 시점 분리 명시 |
| L-2 | Low | §4.3.9 atomic regex 옆 git 실 stderr 예시 부재 | §4.3.10 정규식 옆에 `fatal: the receiving end does not support --atomic push` 예시 주석 |
| L-3 | Low | §4.3.11 사후 view exit code 검사 부재 | §4.3.12 사후 `gh release view --json url` 후 `if ($LASTEXITCODE -ne 0) { throw ... }` 명시 검사 |
| L-4 | Low | §7/§8 self-check 부분 흡수를 완전 흡수로 표기 | §7 v4 행에 13건 모두 v5에 흡수 표시 + §8 self-check ✅/🔶 구분 |
| F-1 (self) | High | release-checklist `gitleaks 8.30.x` hardcoded | §4.1.5 변수 치환 (`{{GITLEAKS_VERSION}}` ← 8A 캡처) + 잔존 grep BLOCK |
| F-2 (self) | High | smoke에 source.source `github` 검증 누락 | §4.3.11 V-2 source.source `github` 추가 |
| F-3 (self) | Medium | smoke cache invalidation 미보장 | §4.3.11 cache 사전 삭제 step + R-17 |
| F-4 (self) | Low | wrapper 정의 drift 위험 | §3.1 표준 박스 + 8B/§4.3.11 inline + drift 검증 step + R-15 |

### 5차 (v5) — CLOSED. 4건 흡수 (v5.1).

| # | 심각도 | finding | 흡수 (v5.1) |
|---|---|---|---|
| H-1 | High | §4.1.2 P-3 row literal 절대경로 예시(드라이브 문자 + 사용자 홈/작업 루트 형태)가 plan 본문 self-trigger | §4.1.2 P-3 row 자연어로 ("Windows 사용자 홈 절대경로 또는 작업 루트 절대경로 형태") + 정규식은 검사 코드의 `$p3Pattern` 변수 참조. **본 §7 row 자체도 literal 박지 않음 — Codex 6차 H-1 흡수** |
| H-2 | High | P-2 Test-NoreplyExempt가 단순 `noreply@anthropic.com` 포함 line 면죄 — 같은 line에 본인 email 섞이면 false-pass | §4.1.2 Test-NoreplyExempt를 footer 정확 shape predicate로 좁힘 (`^Co-Authored-By:\s+Claude\s+Opus\s+4\.7\s+\(1M\s+context\)\s+<noreply@anthropic\.com>\s*$` trim 매치) + §4.1.5 allowlist 표 동일 shape 명시 |
| L-1 | Low | §4.1.5 prose는 "`<` 또는 `{{` 잔존 BLOCK"인데 검증 코드는 `{{...}}`만 검사 | §4.1.5 release-checklist 검증 코드에 `<[^>]*채움[^>]*>` angle placeholder 검사 추가 (양 형태 모두 BLOCK) |
| L-2 | Low | §4.4.4 `$releaseUrl` 예시 주석에 future URL hardcode | §4.4.4 예시 주석 제거 + 검증 정규식의 repo URL을 `git config --get remote.origin.url`에서 동적 추출 (plan 본문에 future URL hardcode 0건) |

### 6차 (v5.1) — CLOSED. 2건 흡수 (v5.2).

| # | 심각도 | finding | 흡수 (v5.2) |
|---|---|---|---|
| H-1 | High | §7 5차 H-1 row text에 literal 절대경로 예시(드라이브 문자 + 사용자 홈/작업 루트 형태)가 잔존 → P-3 self-trigger | §7 5차 H-1 row text를 literal 없이 자연어로. **본 §7 row 자체도 literal 박지 않음 — Codex 6차 H-1 흡수** 명시 |
| L-1 | Low | §4.1.5 PowerShell 코드(`Get-Content` template file read)와 prose("file 두지 않아도 OK") 미스매치 — 그대로 실행 시 file 부재로 8A 막힘 | §4.1.5 PowerShell 블록을 here-string self-contained로 통합. file read 라인 제거 + prose 정리. release-checklist 본문이 PS 블록 안의 `$tmpl = @'...'@`에 inline. 실행 시 file 부재 무관 |

### 7차 (v5.2) — CLOSED. non-BLOCK. 1건 흡수 (v5.3).

| # | 심각도 | finding | 흡수 (v5.3) |
|---|---|---|---|
| L-1 | Low | §4.1.5 line 503 작성 흐름 prose ("`<` 또는 `{{` 잔존 grep BLOCK")가 임의의 `<` 차단으로 오해 가능 — 실제 검증 코드는 `{{...}}` + `<...채움...>` angle placeholder 한정 (here-string 본문에 `<noreply@anthropic.com>` 등 의도된 `<` 사용처 존재) | line 503 prose를 "commit 전 `{{...}}` 또는 `<...채움...>` placeholder 잔존 grep BLOCK"으로 좁힘 — §4.1.5 검증 코드 + §8 self-check와 일치 |
| N-1 | Note | 6차 2건 흡수 정상 확인. P-3 self-trigger 0 hit, here-string self-contained 정상. 수정 제안 없음 | (no fix) |

### 8차 (v5.3) — CLOSED. 2건 흡수 (v5.4).

| # | 심각도 | finding | 흡수 (v5.4) |
|---|---|---|---|
| H-1 | High | §4.1.5 `$gitleaksVersion`이 검증 없이 사용 — 새 PS 세션에서 변수가 빈 값일 때 `{{GITLEAKS_VERSION}}` → `''` 치환 후 placeholder grep은 통과 → release-checklist에 빈 버전으로 8A commit 가능 (false-pass) | §4.1.5에 `$gitleaksVersion` non-empty + `^v?8\.\d+\.\d+` 형식 검증 + `$rendered` 본문에 `gitleaks v?\d+\.\d+\.\d+` / `실행일: \d{4}-\d{2}-\d{2}` specific 값 포함 검증 추가 |
| L-1 | Low | §3.1 line 179 / §4.2.3 V-N 1:1 매칭 / §4.3.11 본문 / §5 R-15가 smoke를 §4.3.10으로 잘못 참조 — 실 smoke는 §4.3.11, §4.3.10은 atomic push 전용 | 4곳 모두 §4.3.11로 정정. 추적표 §7 4차 H-4 row의 finding 인용("§4.3.10 smoke ...")은 v4 시점 잘못된 참조 자체를 인용한 것이라 그대로 (흡수 컬럼은 §4.3.11) |

### 9차 (v5.4) — CLOSED. non-BLOCK (Low 1, Note 1). 2건 흡수 (v5.5).

| # | 심각도 | finding | 흡수 (v5.5) |
|---|---|---|---|
| L-1 | Low | §4.3.11 line 1130 equivalence 표 제목이 `§4.2.2 vs §4.3.10`로 남음 — 표 컬럼·본문은 §4.3.11로 정정됐지만 제목 1줄 누락. v5.4 self-check "§4.3.10 smoke 오참조 0건" 주장과 충돌 | 제목을 `§4.2.2 vs §4.3.11 검증 항목 line-by-line equivalence (메타 v1.2-A — functional equivalent 단언 enforce):`로 정정. v5.4 8차 L-1 흡수의 잔여 누락 1건 종결 |
| N-1 | Note | §7 8차 H-1 row 흡수표 정규식 `^v?8\.\d+\.\d+$`이 §4.1.5 line 521 실 코드 `^v?8\.\d+\.\d+`(no end anchor)와 정밀도 불일치. 실행 영향 없음 | 흡수표 trailing `$` 제거. prose vs 구현 정밀도 메타 v1.1 일치 |

### 10차 (v5.5) — TBD

---

## 8. PLAN_DESIGN_GUIDELINES v1.2 5축 + 메타 패턴 self-check (v5.5 기준)

| 축 | 적용 위치 | 통과 |
|---|---|---|
| **1. Public irreversibility (v1.2 strict 보강)** | §0 위상 변화 / §4.1.1 revoke first 7항목 / R-1+R-9 / **§4.1.2 line 단위 allowlist (file 단위 면죄 거부, release-checklist도 0 finding 대상)** + **P-2 footer 정확 shape predicate (Codex 5차 H-2)** / **§4.1.5 release-checklist 본문은 변수 치환 후 specific 값 + placeholder 잔존 grep BLOCK (`{{...}}` + `<...채움...>` 양 형태, Codex 5차 L-1)** / 자연어 정의 ↔ 검사 코드 1:1 (§4.1.2 P-1~P-4 표, P-3 row literal 제거 — Codex 5차 H-1) | ✅ |
| **2. Atomic action / rollback (v1.1 prose vs 구현 + v1.2-A 주장 강도/구현 정밀도)** | §4.0 8P 명령 + **§3.1 표준 wrapper 박스 + §4.2.2/§4.3.11 inline + drift 검증 step (메타 v1.2-A wrapper drift)** / §4.3.10 atomic fallback 조건 + 정규식 + git stderr 예시 주석 / **§4.3.11 try/finally + `$smokeVerified` + cache 사전 삭제** / **§4.3.11 §4.2.2와 검증 항목 line-by-line equivalence 표 (V-1/V-2/V-3 동일 + V-5 추가)** / §4.3.12 `gh release view` preflight + 사후 view exit code 검사 / §4.3.3·§4.3.6·§4.4.3 commit boundary (8C prepared, 8D 결과 변수 치환) / **§4.4.4 변수 치환 + commit 전 placeholder 잔존 grep BLOCK** | ✅ |
| **3. Repo 사실 확인 (자기참조 포함)** | §1 사전 진단 / **§1.1 plan 자체 git state + .claude/ 시점 분리** / §1.7 plan 본문 자기참조 sanitize 적용 / §4.0 → §4.4.1 git mv / §4.0 plan-fix seed batch / §4.1.2 scope에 8P 후 plan 포함 + release-checklist 포함 | ✅ |
| **4. 표현 일관성 (v1.2 placeholder grep BLOCK + self-check ✅/🔶 구분)** | §1.6/§4.1.1 trufflehog drop / §4.1.1 단일 정책 / §0 drop·include 명시 / §4.1.1 "7항목" 수치 / **§4.1.5/§4.3.6/§4.4.4 placeholder 잔존 grep BLOCK 모두 박힘** / **§7 v4 행 13건 흡수 표기 + 본 §8 self-check 부분 흡수 🔶 / 완전 흡수 ✅ 구분 (현재 v5 모든 row ✅)** / §4.1.1 gitleaks `dir`/`git` syntax | ✅ |
| **5. Scope 명시** | §0 drop 4건 / include 2건(GitHub Release object, plan-fix seed) / Release-time 5종 drop / §3.1 표준 wrapper 박스 (drift 회피 scope include) | ✅ |

**메타 패턴 v1.0 (위상 변화 인지)**: §0에 명시. ✅
**메타 패턴 v1.1 (prose vs 구현 일치)**: 모든 prose 옆에 PS 코드 블록·명령 블록·preflight 절차를 짝으로 박음. ✅
**메타 패턴 v1.2-A (주장 강도 vs 구현 정밀도 일치)**:
- "0 finding" + line 단위 allowlist + 자연어 ↔ 검사 코드 1:1 (§4.1.2): ✅
- "§4.2.2와 같은 구조" + line-by-line equivalence 표 (§4.3.11): ✅
- "결과 흡수" + 변수 치환 + placeholder 잔존 grep BLOCK (§4.4.4): ✅
- "wrapper 재정의" + drift 검증 step (§3.1 / §4.2.2 / §4.3.11): ✅
- "사후 view exit code 검사" (§4.3.12): ✅
- self-check ✅/🔶 구분 (본 §8): 현재 v5는 모든 row ✅

**메타 패턴 v1.2-B (plan 본문 예시 vs 실 실행 진실 분리)**:
- gitleaks specific 버전 hardcode 금지 → 변수 치환 (§4.1.1 + §4.1.5): ✅
- 실행 일시·날짜 변수 (§4.1.5 EXEC_DATE / §4.3.3 REL_DATE): ✅
- finding count placeholder vs 단언 — `0 finding`은 PASS 시 진술 (FAIL 시 BLOCK 진입이라 release 진행 X), plan 본문은 변수 치환 표현으로 통일: ✅
- 8C-post 결과(atomic/smoke/URL) → 변수 + placeholder + 잔존 grep BLOCK (§4.4.4): ✅

검증: 본 plan **v5.5**는 v4의 13건(Codex 9 + self 4) + Codex 5차 4건 + Codex 6차 2건 + Codex 7차 1건(non-BLOCK) + Codex 8차 2건(H-1 검증 추가 + L-1 §4.3.10→§4.3.11 정정) + Codex 9차 2건(non-BLOCK; L-1 §4.3.11 표 제목 정정 + N-1 흡수표 정규식 trailing `$` 제거) 모두 흡수. 메타 v1.2-A/B의 모든 항목이 검사 step과 짝으로 박혔으며, plan 본문 자체가 8P pre-commit hook + 8A retroactive grep을 통과하도록 sanitize됨:
- P-1/P-3 매칭 0 hit — §4.1.2 row + §7 5차 row 모두 literal 절대경로 예시 자연어로 (Codex 5차 H-1 + 6차 H-1 흡수)
- P-2 매칭은 Co-Authored-By footer 정확 shape line만 면죄 — 다른 line의 `noreply@anthropic.com` hit는 finding (Codex 5차 H-2 흡수)
- placeholder 잔존 grep은 `{{...}}` + `<...채움...>` 양 형태 (Codex 5차 L-1 흡수)
- future URL hardcode 0건 — 검증 정규식의 repo URL은 git remote에서 동적 추출 (Codex 5차 L-2 흡수)
- §4.1.5 release-checklist PS 블록 here-string self-contained — file read 라인 + prose mismatch 해소, 실행 시 file 부재 무관 (Codex 6차 L-1 흡수)
