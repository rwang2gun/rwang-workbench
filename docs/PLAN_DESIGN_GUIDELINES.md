# Plan 작성 설계 축 — 5축 + 메타 패턴

> **목적**: phase plan v1 초안 작성 후 self-review 단계에서 적용할 체크리스트.
> **출처**:
> - v1.0 (2026-04-25): phase8-plan v1 Codex 1차 리뷰 (High 7 + Low 5, BLOCK) + self-review (Critical 10 + Minor 3)
> - v1.1 (2026-04-25): phase8-plan v2 Codex 2차 리뷰 (High 7 + Low 4, BLOCK) 메타 분석. "주장 vs 구현 일치"·"plan 자체 git state" 흡수
> - **v1.2 (2026-04-25)**: phase8-plan **v3·v4** 두 차례 BLOCK 메타 분석. v3는 자기참조 BLOCK loop(plan 본문이 plan 자신의 게이트 위반)을 노출했고 v4는 patch 누적이 5축 strict 기준을 흔들리게 한 결과 살짝 역행(8 → 9건). v1.2는 (a) **주장 강도 vs 구현 정밀도 일치**, (b) **plan 본문 예시 vs 실 실행 진실 분리** 두 차원을 새 메타로 명시 흡수. 축 1·축 4 strict 보강.
> **적용 시점**: 모든 phase plan v1 초안 작성 직후, Codex 리뷰 CLI 호출 **전** 단계.
> **수정 권한**: 새 phase에서 새 finding 패턴이 반복적으로 등장하면 본 문서에 축/체크리스트 추가·보강. 단순 1회성 finding은 추가하지 않음 (재현 가능 패턴만 흡수). **plan 작성 도중 가이드라인 변경 금지** — moving target 방지. 가이드라인 갱신은 새 phase plan 착수 직전 또는 plan 한 라운드(v_n) 마감 시점에만.

---

## 사용법 흐름

1. phase plan v1 초안 작성 (MASTER_PLAN §5 + 이전 phase plan 패턴 기반)
2. **본 문서의 5축 + 메타 패턴 self-review 적용** ← 여기서 사용
3. 발견 항목으로 v1 직접 패치 또는 v1 보존 + finding 별도 정리
4. Codex CLI 리뷰 호출 (`codex exec -C <repo> -s read-only ...`, **Skill 호출 금지**)
5. Codex finding과 self-review finding 통합 → v2 패치
6. 필요 시 2차 Codex 리뷰 → v3 → ... 수렴까지 반복
7. 사용자 승인 (G1 게이트) 후 batch 실행

---

## 5축

### 축 1 — Public state irreversibility 인식

해당 phase가 **public-facing milestone**(release tag, 첫 push, 외부 announcement 등)이면 비대칭성 인식 필요:

- 한 번 push된 시점부터 fork·mirror·archive·search-index 캐시에 복제본 잔존
- history rewrite로 회수 불가 — credential revoke가 우선
- "다시 하면 됨"이 더 이상 통하지 않음
- 이전 phase에서 통하던 "이미 public이니 새 노출 아님" 같은 예외 논리는 release gate에서 부적절

체크리스트:
- [ ] phase가 release/public 단계인지 §0 Scope에 명시했는가
- [ ] 보안 항목에 "revoke first → release BLOCK → sanitize" 시퀀스를 정의했는가 (sanitize 단독 절차로 끝나지 않음)
- [ ] sanitize 한계(fork/mirror 잔존)를 risk로 분리해 기록했는가
- [ ] release-gate 부적절 예외(과거 commit 면죄, archive 면죄)를 plan에 두지 않았는가

**v1.2 보강 — release-bound 문서의 strict 기준 (phase8-plan v4 BLOCK 회고):**

phase8-plan v4가 v3 BLOCK 회고로 self-sanitize를 적용했지만 release-checklist 같은 **release-bound 문서를 file 단위 allowlist에 포함**하면 진짜 누설도 그 파일 안에서는 통과. release-bound 문서는 release tag가 가리키는 commit에 박히므로 release commit에 false PASS·민감 정보가 함께 박힘.

추가 체크리스트:
- [ ] **allowlist는 line/pattern/literal 단위인가** — file 단위 면죄(특정 파일 통째 면죄)는 금지. release-bound 문서도 0 finding 대상에 포함되어야 함. 패턴 출처(hook 파일 등)는 단일 reference로 통일하고 allowlist는 그 출처 file의 특정 line만 식별
- [ ] **release-bound 문서 본문의 예시 값이 미래 실 실행 결과인가** — release commit에 박히는 본문에 "gitleaks 8.30.x" 같은 specific version·SHA·URL·날짜·finding count를 plan 작성 시점에 hardcode 금지. 미래 실 실행 결과면 placeholder("<8A 실 실행 후 채움>" 또는 변수 `$realVersion`) 또는 "실 실행 후 정확값으로 갱신" step과 짝
- [ ] **검사 코드의 P-N 정의가 plan 본문의 P-N 자연어 정의와 1:1 일치하는가** — mismatch 시 false PASS 가능. 자연어가 "Windows OS 일반 절대 드라이브 경로"라면 검사 정규식도 그 일반 패턴을 커버해야 함. 검사 코드가 hook PATH_PATTERNS만 import하고 끝나면 자연어 정의보다 좁은 검사라 false PASS

### 축 2 — Atomic action / rollback 명시

각 multi-step 작업이 happy path 외에 어떻게 동작하는지:

- **preflight snapshot** — 실행 전 state 캡처 (`claude plugin list`, JSON 파일, marketplace entry 등)
- **finally restore** — 성공/실패 무관 복원 절차 (try/finally 패턴)
- **atomic 보장** — 한 단위로 성공 또는 실패. `git push --atomic`, transaction 블록 등. 미보장 시 fallback 명시
- **commit boundary 정합성** — 각 commit이 가리키는 state가 그 commit 시점의 진실이어야 함. 미래 작업을 "완료"로 진술 금지. release tag·marker가 거짓 진술 commit을 가리키지 않아야 함

체크리스트:
- [ ] 각 batch 시작 전 snapshot 항목이 명시됐는가
- [ ] 중간 실패 시 finally restore 절차가 명시됐는가 (어느 step에서 실패해도 복원 trigger)
- [ ] 다단계 외부 명령은 atomic 옵션을 사용했는가, 또는 fallback이 정의됐는가
- [ ] 각 commit이 가리키는 state가 그 commit 시점에 진실인가 (미래 batch 작업을 완료로 선언 X)
- [ ] release tag·milestone marker가 거짓 진술을 포함한 commit을 가리키지 않는가

**v1.1 보강 — prose vs 구현 일치 (phase8-plan v2 BLOCK 회고):**

v2는 위 항목을 모두 prose로 적었지만 구현 코드/명령으로 뒷받침하지 못해 같은 finding이 다시 발생. prose 옆에 그 prose를 강제하는 명령 블록을 한 짝으로 명시.

추가 체크리스트:
- [ ] **try/finally는 prose가 아닌 실제 코드로** — PowerShell이라면 `$ErrorActionPreference='Stop'` + `try { ... } finally { ... }` + 외부 CLI 호출 후 `if ($LASTEXITCODE -ne 0) { ... }` 검사 wrapper. bash라면 `set -euo pipefail` + `trap '... ' EXIT`. 외부 CLI는 non-zero exit가 자동 throw하지 않으므로 명시 검사 필수
- [ ] **실패 허용 단계 분리** — 정상 시 noop인 명령(`uninstall <not-installed>`, `remove <missing>` 등)과 반드시 성공해야 하는 명령은 별도 함수/블록. 동일 try 안에 섞이면 의도된 noop이 finally restore를 trigger
- [ ] **atomic fallback 트리거 조건** — fallback 절차가 있으면 어떤 에러 메시지/exit code일 때 fallback이 정당한지 명시. 모든 실패에 fallback 적용은 plan이 금지하려는 partial state를 직접 만드는 것. 정규식은 실 도구의 stderr 메시지(`fatal: the receiving end does not support --atomic push` 등)를 한 번 확인해 옆에 주석으로 고정
- [ ] **idempotency vs partial state** — 재실행 가능한 명령(`gh release create`, `claude plugin install`, marketplace add 등)이 partial state(이미 존재 / 부분 성공)에서 어떻게 동작하는지 — preflight `view`/`list` → 결과별 `create`/`edit`/`delete` 분기 명시. `--verify-tag` 같은 옵션의 정확한 의미를 plan에 적어야 함. 사후 검증(`view --json url` 등)도 exit code를 명시 검사
- [ ] **release 후 smoke** — 새 commit/tag/release object를 push한 직후 그 새 state로 한 번 더 검증. release 전 검증만으로는 release tag가 가리키는 state는 미검증 상태로 남음

**v1.2 보강 — 주장 강도 vs 구현 정밀도 일치 (phase8-plan v4 BLOCK 회고):**

v4는 v3에서 wrapper·try/finally·flag·regex 보강은 잘 흡수했지만 prose에 **강한 단언**("§4.2.2와 같은 구조", "functional equivalent", "0 finding", "동일")을 새로 박았는데 그 단언을 enforce하는 검사 항목이 누락. 강한 단언은 그 단언을 강제하는 검사 step과 짝으로만 박는다.

추가 체크리스트:
- [ ] **강한 단언과 검사 step 1:1 짝** — "0 finding"·"complete"·"동일"·"전수"·"functional equivalent" 같은 강한 단언이 있는가? 있다면 그 단언을 enforce하는 검사 step이 plan 안에 짝으로 박혔는가. 짝 없으면 단언 약화("일부 검증") 또는 검사 step 추가 둘 중 하나
- [ ] **functional equivalence 검증 항목 diff** — "§X와 같은 구조"라 단언한 두 코드 블록은 검증 항목을 line-by-line 대조. 한쪽이 검증 항목 N개고 다른 쪽이 N-1개면 "동일"이 아니라 "subset"
- [ ] **wrapper·helper 정의 drift** — 같은 wrapper 함수를 여러 §에 inline 박을 때 byte-for-byte 동일성을 보장하는 step(grep diff 또는 단일 helper file dot-source)이 plan 안에 박혔는가. 없으면 두 정의가 점진 drift할 위험

### 축 3 — Repo 사실 확인 (plan 작성 단계)

plan을 추측만으로 짜지 말고 작성 시점에 grep/read로 확정할 사실:

- 환경변수 키 이름 (코드의 정확한 string)
- README·CHANGELOG·status badge 현재 값
- CLI 명령 syntax (이전 phase 기록 또는 `--help`)
- `.git/`, `.claude/worktrees/`, `node_modules/` 등 ignore 외 hidden directory의 실 내용
- vendored 파일과 자체 파일의 분리 (vendored example 코드를 자체 동작 코드로 오인 X)

체크리스트:
- [ ] plan에 등장하는 모든 환경변수·플래그·키 이름을 실제 grep으로 확인했는가
- [ ] 모든 명령어 syntax를 이전 phase 기록 또는 `--help`로 확인했는가
- [ ] `.git/` 외 hidden directory(`.claude/`, `.vscode/` 등)의 실 내용을 직접 확인했는가
- [ ] README·CHANGELOG·status badge 등 user-visible 문서가 phase 결과와 일치하는지 확인했는가
- [ ] grep/검사 scope를 명시적으로 정의했는가 (tracked files only / archive 포함 / worktree 제외 / vendored 분리)

**v1.1 보강 — plan 자체의 git state 자기참조 (phase8-plan v2 BLOCK 회고):**

가장 자주 누락되는 사실은 **plan/guidelines/checklist 파일 자체의 현재 git state**. 외부 사실은 잘 grep하지만 plan 본인의 tracking 상태는 자기참조라 시야에서 빠짐.

추가 체크리스트:
- [ ] **plan 파일 본인의 git state** — `git status --short`로 본 plan 파일·동시 작성 중인 guidelines·checklist가 modified·untracked·staged·committed 중 무엇인지 확인했는가
- [ ] **archive/`git mv` 가능성** — phase 마감에 `git mv` 또는 동등 작업이 있는가? 그렇다면 plan 파일이 commit 상태여야 작동. untracked면 `git mv` 실패 → plan-fix(seed) commit이 별도 batch로 필요
- [ ] **plan-fix seed batch 필요성** — 본 plan을 작성하는 동안 발생한 modified/untracked 파일을 phase 본 작업과 분리해 별도 commit으로 고정할 batch가 필요한가
- [ ] **plan 자체가 release-bound 문서인가** — phase 결과가 release면 plan/guidelines 자체도 그 release commit에 포함됨. retroactive grep·시크릿 스캔 scope에서 본 plan 파일을 untracked라는 이유로 빼면 안 됨. scope 정의를 "tracked files + 이번 phase에서 commit 예정인 untracked docs"로 확장
- [ ] **`.gitignore` 갱신 시점과 grep scope 시점의 정합성** — `.claude/` 같은 디렉토리를 8A에서 ignore에 추가한다면 8P 시점엔 untracked, 8A 후엔 ignored. 각 batch의 `git status --short` 기대값 description은 시점별로 분리 표기

### 축 4 — 표현 일관성, 양다리 제거

plan v1에 흔한 양다리 표현:
- "X 또는 Y 도구"
- "inline 또는 별도 파일"
- "필요 시 작성"
- "TBD"

이런 표현은 **실행 시점 의사결정 비용으로 전이됨**. plan 단계에서 결정해 한 경로로 고정. 또한 같은 항목이 §간 모순된 처리(§4.1.1: 첨부 / §4.1.6: commit X)로 적히지 않게 검토.

체크리스트:
- [ ] 도구 선택을 primary 1개로 고정했는가 (대체 도구는 fallback 한 단락 또는 §리스크로 격하)
- [ ] 산출물 보존 방식이 §간에 모순 없이 일관 명시됐는가
- [ ] "필요 시" 표현이 명확한 판정 절차를 동반하는가
- [ ] 모든 "TBD"가 plan 완성 전에 해소됐는가 (Codex 리뷰 결과 기록 §처럼 본질적으로 후속 항목인 경우는 예외)

**v1.1 보강 — 수치 일관성 + 미세 모순 (phase8-plan v2 BLOCK 회고):**

추가 체크리스트:
- [ ] **수치/단계 수의 일관성** — "5단계 절차"라 적었으면 실제 항목 수가 5인가
- [ ] **stage 대상과 placeholder 정합성** — release-checklist에 "8C sha 채움" 같은 후속 수정 placeholder가 있으면 그 placeholder를 채울 commit의 stage 대상에 그 파일이 포함되어 있는가
- [ ] **CLI 도구 버전·옵션 deprecation** — 사용 도구의 버전과 plan에 적힌 명령어 syntax가 일치하는가

**v1.2 보강 — placeholder 잔존·self-check 정확성 (phase8-plan v4 BLOCK 회고):**

v4는 8D commit 메시지 here-string에 `<8D 시점에 채움>` literal placeholder를 박은 채 commit 시도하는 절차였음. 자동 치환 step이나 placeholder 잔존 grep BLOCK이 짝으로 박히지 않으면 release commit에 placeholder가 그대로 박힘.

추가 체크리스트:
- [ ] **commit 메시지·CHANGELOG에 placeholder가 들어가는 step에 자동 grep BLOCK이 짝으로 박혔는가** — `<...채움>`·`TODO`·`<TBD>` 같은 literal이 here-string에 있으면 commit 전 `if ($msg -match '<[^>]*채움>') { throw ... }` 같은 명시 검사. 또는 변수(`$releaseUrl`/`$smokeResult`)로 메시지 생성 후 변수 미정의 시 throw
- [ ] **§7/§8 self-check 부분 흡수와 완전 흡수 구분** — Codex N차 finding 추적표·5축 self-check에 ✅ 표기는 완전 흡수만. 부분 흡수(검증 항목 일부 누락 등)는 🔶 또는 별도 row
- [ ] **strict allowlist 표 검증** — allowlist에 "검사 절차 reference"·"history record" 같은 모호한 사유는 금지. line/pattern/literal 단위 식별 + 사유 한 줄

### 축 5 — Scope 안/밖 명시적 결정

MASTER_PLAN scope 외 항목은 침묵하지 말고 **drop/include**를 명시:

- **drop**: §0 Scope 외 또는 §5 리스크에 "Phase N scope 외 — Phase M+에서 재평가" 같은 사유 기록
- **include**: batch에 step 추가 + acceptance/exit gate에 흡수

체크리스트:
- [ ] MASTER_PLAN scope 외인데 plan에서 다룰 후보 항목을 모두 식별했는가
- [ ] 각 후보를 drop/include 둘 중 하나로 명시 결정했는가
- [ ] drop된 항목에 사유 기록이 있는가
- [ ] include한 항목이 batch acceptance/exit gate에 정확히 반영됐는가

---

## 메타 패턴 v1.0 — Phase 위상 변화 인지

가장 큰 사고 위험은 **phase의 위상이 바뀌는 시점에 이전 phase 패턴을 답습**하는 것. 새 phase plan 착수 전 해당 phase가 "위상 변화" 시점인지 먼저 판단:

| 차원 | dev/검증 phase | release/public phase |
|---|---|---|
| 작업 결과 | 다음 phase 입력 | tag·milestone — 영구 marker |
| 실패 비용 | 다시 하면 됨 | partial state = 사고 |
| 사실 출처 | 이전 phase 문서 | 현재 repo state + 외부 state |
| 표현 모호 | 운영성 비용만 | 사고 위험 |
| Scope 모호 | 다음 plan에 미룸 | 다시 못 만짐 |

위상 변화의 트리거 신호:
- 첫 GitHub push, 첫 태그, 첫 release
- 첫 외부 announcement 또는 외부 사용자 인지
- public consumer가 직접 만지게 되는 산출물 (Skills ZIP, GitHub Release page, 패키지 publish)
- 되돌릴 수 없는 외부 의존성 변경 (DB 스키마, API 계약)

위상 변화 phase는 5축 모두를 **이전 phase 대비 한 단계 위 해상도**로 적용. 단순히 finding 개별 대응이 아니라 "이 plan은 위상이 다르다"는 인식 자체가 필요.

위상 변화 phase에서 plan 작성 시 명시적 drop/include 결정이 필요한 추가 후보(개인 1인 repo라도 적어도 "drop"으로 plan에 한 줄 기록):
- **branch protection** — main 보호, force-push 금지 등 GitHub repo settings
- **commit/tag signing** — GPG sign, signed tag (release tag의 진위)
- **DCO·signed-off-by** — contributor agreement 흔적
- **GitHub security settings** — Dependabot, secret scanning, code scanning
- **rate-limit·announcement** — release notes 외에 외부 공지 채널 사용 여부

---

## 메타 패턴 v1.1 — 주장(prose) vs 구현(code) 일치

phase8-plan v2가 v1 BLOCK 회고로 5축을 흡수했지만 **prose로만 흡수**해 같은 finding 수의 새 종류 finding이 다시 발생. 가이드라인 자체의 한계 노출.

**증상**: plan에 `try/finally`, `atomic`, `preflight + restore`, `idempotency` 같은 패턴을 산문으로 적었는데 실제 명령·코드 블록·exit code 검사·preflight view 분기 등 **그 산문을 강제하는 구현 디테일이 없음**.

**원칙**: plan에 어떤 control-flow 패턴을 prose로 적었으면 그 prose 옆에 그 패턴을 강제하는 **명령 블록·코드 블록·preflight 절차**를 한 짝으로 배치한다.

| Prose 표현 | 함께 박혀야 하는 구현 |
|---|---|
| "try/finally", "finally restore" | `$ErrorActionPreference='Stop'` + `try { ... } finally { ... }` + 외부 CLI 후 `if ($LASTEXITCODE -ne 0)` 검사 (PS) / `set -euo pipefail` + `trap '...' EXIT` (bash) |
| "atomic push" | `git push --atomic origin main <tag>` + atomic 미지원 시 fallback 트리거 조건(에러 메시지/exit code 한정) |
| "preflight snapshot" | snapshot 디렉토리 생성·복사 명령 + snapshot 파일 위치 기록 + 검증 후 정리 |
| "idempotent retry" | 재실행 전 `view`/`list` preflight + 결과별 `create`/`edit`/`delete` 분기. 단순 `--verify-tag` 같은 옵션은 idempotency 보장 X |
| "release 후 검증" | release/tag push 후 fresh check (예: GitHub source 재설치 smoke를 release commit 기준으로 한 번 더) |
| "BLOCK 절차" | 단계 수 정확. "5단계"라 적었으면 5개 항목. 단계 sequence(revoke first, force-push 후 등) 명시 |

이 짝짓기가 빠지면 5축 흡수가 표면적이라 같은 종류 BLOCK이 반복됨.

---

## 메타 패턴 v1.2 — 주장 강도 vs 구현 정밀도 일치 + plan 본문 예시 vs 실 실행 진실 분리

phase8-plan v3는 v1.1 가이드라인을 적용해 wrapper·try/finally·flag·regex를 모두 짝으로 박았지만, **자기참조 BLOCK loop**(plan 본문에 박힌 본인 PC 사용자명/email/절대경로가 plan 자신의 게이트 8P pre-commit hook + 8A retroactive grep을 위반)이 새로 노출됐다. v4는 본문 자기참조 sanitize를 적용했지만, patch 누적이 5축 strict 기준을 흔들리게 한 결과 새 차원의 finding이 등장(8 → 9건, 살짝 역행).

v4 finding의 공통 패턴:
- prose에서 강한 단언("0 finding", "동일 구조", "functional equivalent", "결과 흡수")을 박았는데 그 단언을 enforce하는 검사 코드/검증 step이 누락 또는 약함
- release-bound 문서를 file 단위 allowlist로 우회 — 진짜 누설도 그 파일 안에서는 통과
- commit 메시지·release-checklist 본문에 `<...채움>` literal placeholder 또는 `gitleaks 8.30.x` hardcoded 진술이 release commit에 박힘

v1.2는 두 차원으로 분리:

### v1.2-A — 주장 강도 vs 구현 정밀도 일치

**원칙**: prose에 강한 단언을 박을 때 그 단언을 강제하는 검사 step과 1:1 짝으로 박는다. 짝이 없으면 단언을 약화하거나 검사 step을 추가한다.

| 강한 단언 | 함께 박혀야 하는 검사 |
|---|---|
| "0 finding" / "전수" | file 단위 allowlist 금지. line/pattern/literal 단위 식별 + 검사 코드가 자연어 정의를 1:1 cover. release-bound 문서도 0 finding 대상 |
| "§X와 동일 구조" / "functional equivalent" | 두 코드 블록의 검증 항목을 line-by-line 대조. subset이면 "동일"이 아니라 "subset"으로 약화 |
| "preflight view" / "exit code 분기" | 사후 검증(`view --json url` 등)도 `$LASTEXITCODE` 명시 검사 |
| "atomic primary, fallback 한정" | fallback 트리거 정규식 옆에 실 도구의 stderr 메시지(`fatal: the receiving end does not support --atomic push` 등) 주석으로 고정 |
| "결과 흡수" (commit 메시지·CHANGELOG) | placeholder를 변수(`$releaseUrl`/`$smokeResult`)로 생성 + commit 전 placeholder 잔존 grep BLOCK |
| "self-check ✅" | 부분 흡수(검증 항목 일부 누락)는 🔶, 완전 흡수만 ✅ |
| "wrapper 함수 재정의 (다른 PS 세션)" | 두 inline 정의가 byte-for-byte 동일한지 grep diff step 또는 단일 helper file dot-source |

### v1.2-B — Plan 본문 예시 vs 실 실행 진실 분리

**원칙**: plan은 작성 시점 사실로 짠 문서다. 미래 실 실행 결과를 본문에 hardcode 금지. release-bound 문서(release commit에 박히는 release-checklist·CHANGELOG·README 등)에서 특히 strict.

미래 실 실행 결과로 분류해야 하는 값:
- 도구의 specific version (`gitleaks 8.30.x`) — winget이 newer 버전 설치 가능
- commit SHA, release URL, GitHub Release object id — 실 실행 후에만 확정
- finding count (`0 finding`이라 본문에 단언) — 실 실행 결과로 PASS/FAIL 분기되는 값이지 plan 본문에 미리 단언할 값 X (단언이 PASS 가정 prose면 BLOCK 시 모순)
- 실행 일시·날짜 — `2026-04-2X` 같은 placeholder는 OK이지만 specific date hardcode 금지
- finding 메타("의도된 노출 N곳") — N이 실 실행 결과 의존이면 placeholder

치환 방식:
- 변수 (`$realVersion = (gitleaks version).Trim()`) + 치환 step
- placeholder (`<8A 실 실행 후 채움>`) + commit 전 잔존 grep BLOCK
- "실 실행 후 정확값으로 갱신" step 명시

체크리스트:
- [ ] release-bound 문서 본문의 specific version·SHA·URL·날짜·finding count 중 hardcode된 것이 있는가
- [ ] 있다면 (a) 변수 + 치환 step (b) placeholder + 잔존 grep BLOCK (c) "실 실행 후 갱신" step 셋 중 하나가 짝으로 박혔는가
- [ ] commit 메시지 here-string에 literal placeholder가 있는가? 있다면 commit 전 grep BLOCK이 짝으로 박혔는가

---

## 출처 및 근거

본 문서는 phase8-plan v1·v2·v3·v4 네 차례 BLOCK 회고와 self-review를 메타 분석해 추출.

- **v1.0 시드** (2026-04-25):
  - phase8-plan v1 Codex 1차 (High 7, Low 5, BLOCK)
  - Claude self-review (Critical 10, Minor 3)
  - 공통 테마 → 5축 + 메타 패턴 v1.0 (위상 변화 인지)
- **v1.1 보강** (2026-04-25):
  - phase8-plan v2 Codex 2차 (High 7, Low 4, BLOCK)
  - 메타 패턴 v1.1 — 주장(prose) vs 구현(code) 일치
- **v1.2 보강** (2026-04-25):
  - phase8-plan v3 Codex 3차 (High 5, Low 3, BLOCK) — 자기참조 BLOCK loop 노출
  - phase8-plan v4 Codex 4차 (High 5, Low 4, BLOCK) — patch 누적 역행 (8 → 9건)
  - 메타 패턴 v1.2-A — 주장 강도 vs 구현 정밀도 일치
  - 메타 패턴 v1.2-B — plan 본문 예시 vs 실 실행 진실 분리
  - 축 1 strict 보강 (line/pattern allowlist, release-bound 본문 hardcode 금지)
  - 축 4 보강 (placeholder 잔존 grep BLOCK, self-check 부분/완전 흡수 구분)

각 phase plan의 raw Codex 리뷰 결과는 해당 plan §7에 누적 보존되며, plan archive 시 함께 이관됨. 본 문서는 그 raw 결과에서 **재현 가능한 패턴만 추상화**한 영구 reference.

---

## 적용 이력

| Phase | 본 문서 적용 단계 | 결과 |
|---|---|---|
| Phase 8 v1 | 가이드라인 부재. v1 작성 직후 self-review에서 5축 추출 → 본 문서 v1.0 시드 | v1 BLOCK (Codex 1차 12건) |
| Phase 8 v2 | v1.0 가이드라인을 적용해 작성. 5축 self-check 표 첨부 | v2 BLOCK (Codex 2차 11건, 종류 다름) → v1.1 시드 |
| Phase 8 v3 | v1.1 가이드라인 적용. wrapper·try/finally·flag·regex 짝짓기 완성 | v3 BLOCK (Codex 3차 8건, 자기참조 BLOCK loop 노출) → v1.2 시드 일부 |
| Phase 8 v4 | v1.1 가이드라인 + v3 finding 흡수 patch 누적. 본문 자기참조 sanitize | v4 BLOCK (Codex 4차 9건, 8 → 9 살짝 역행) → v1.2 시드 완성 |
| Phase 8 v5 | **v1.2 가이드라인 전면 적용** — 주장 강도/구현 정밀도, plan 본문 예시/실 실행 진실, line/pattern allowlist, placeholder grep BLOCK | TBD (Codex 5차 대기) |
| Phase 9+ | v1 작성 직후 v1.2+ 가이드라인 self-review → Codex 리뷰 흐름 | TBD |

새 finding 패턴이 추가되면 본 §과 5축 체크리스트·메타 패턴을 동시 갱신. **plan 작성 도중 가이드라인 변경 금지** — moving target 방지. 갱신은 새 phase plan 착수 직전 또는 plan 한 라운드(v_n) 마감 시점에만.
