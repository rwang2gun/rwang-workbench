---
description: Show installation status of marketplace-recommended external plugins
allowed-tools: ["Bash"]
---

# /productivity-pack:check-recommended

marketplace의 각 팩 `.claude-plugin/recommends.json`을 읽어 현재 사용자 스코프(`~/.claude/plugins/installed_plugins.json`)에 설치된 상태를 표로 출력한다. 외부 의존을 vendoring 없이 관리하는 MASTER_PLAN §4.6 v0.1 의 조회 명령.

## Steps

1. Bash 도구로 다음을 실행한다:
   ```
   node "${CLAUDE_PLUGIN_ROOT}/scripts/check-recommended.mjs"
   ```
   - Node 16+ 필요. 미설치 시 에러 메시지를 그대로 사용자에게 보여주고 `docs/RECOMMENDED_PLUGINS.md` 참조를 안내한다.
   - 스크립트는 non-blocking: 어떤 단계가 실패해도 exit 0. 표 대신 💡 안내가 나오면 사유를 그대로 전달한다.

2. 출력에 `❌` 행이 있으면 해당 엔트리의 `install_command`를 `docs/RECOMMENDED_PLUGINS.md`에서 확인해 사용자에게 설치 여부를 묻는다. **자동 설치 금지** — 외부 플러그인 설치는 사용자 승인 사안.

3. 출력에 `—` (설치 목록 판독 실패)가 있으면 💡 안내의 사유를 그대로 전달한다. 실 파일을 임의로 고치거나 덮어쓰지 않는다.

## 환경변수 오버라이드 (RWANG_INSTALLED_PLUGINS_PATH)

기본 동작: `~/.claude/plugins/installed_plugins.json`을 읽음.

검증·테스트 용도로 경로 오버라이드:
- Git Bash: `RWANG_INSTALLED_PLUGINS_PATH=/tmp/fixture.json node "${CLAUDE_PLUGIN_ROOT}/scripts/check-recommended.mjs"`
- PowerShell 5.1: `$env:RWANG_INSTALLED_PLUGINS_PATH = "C:\tmp\fixture.json"; node "$env:CLAUDE_PLUGIN_ROOT/scripts/check-recommended.mjs"`

env 설정 시 실제 설치 목록은 읽지 않음. production 경로에서는 env를 설정하지 말 것.

## Not this command's job

- 권장 플러그인을 자동 설치하지 않는다.
- `installed_plugins.json`을 쓰기/수정하지 않는다 (read-only).
- 네트워크 호출을 하지 않는다.
