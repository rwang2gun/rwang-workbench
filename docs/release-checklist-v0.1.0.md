# Release Checklist — v0.1.0

> 목적: MASTER_PLAN v1.5 §4.5 Public 전환 게이트 8개 항목 통과 증빙 + Phase 8 결정 기록.
> 실행일: 2026-04-25
> 본 문서가 가리키는 release: tag `v0.1.0` (Phase 8C-post에서 push). git history에서 `git log v0.1.0 -1`로 commit sha 조회 가능.
> 본 문서는 8A commit 상태 그대로 release tag까지 유지 — 후속 수정 placeholder 없음.

## §4.5 게이트 8개 항목

- [x] 라이선스 검토 — LICENSE: MIT. vendored 11개 모두 Apache-2.0(Phase 1·4 재확인). 호환 OK.
- [x] `THIRD_PARTY_NOTICES.md` — Phase 3 작성, Phase 4 데이터 채움.
- [x] 시크릿 스캔 — gitleaks 8.30.1, `dir` 모드 0 finding / `git` 모드 0 finding (2026-04-25 21:24:32 +09:00).
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