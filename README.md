# rwang-workbench

A personal Claude Code plugin marketplace curating general-purpose skills, commands, hooks, and agents from the broader ecosystem plus self-authored workflows.

> **Status:** v0.1.0-alpha (scaffolded). Vendored content arrives in Phase 4; native workflows in Phase 5. See [docs/CHANGELOG.md](docs/CHANGELOG.md).

## Packs

| Pack | Domain |
|---|---|
| `analysis-pack` | Data analysis, SNA, trend reports, standalone HTML build |
| `productivity-pack` | Git sync, PR review, plugin development, hookify automation, documentation |

`game-design-pack` is currently deferred per the §2.3.1 gate (MASTER_PLAN v1.5). See [docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md) §8.

## Prerequisites

### Python 3.x on PATH as `python`

`productivity-pack`의 훅은 `python` 명령이 Python 3.x를 가리킨다고 가정합니다.

**OS별 상태:**
- **Windows** (공식 Python installer): 기본 충족 (`python` = Python 3).
- **macOS** (Homebrew `python@3.x` 또는 Xcode): 기본 충족.
- **Ubuntu 22.04+ / 최신 Linux**: `python3`은 있으나 `python` symlink는 선택적. `sudo apt install python-is-python3` 1회 권장.
- **Ubuntu 20.04 이하 / `python` = Python 2 환경**: 훅이 Python 2로 실행되면 ImportError 발생 → hookify 원본의 graceful skip 로직(`pretooluse.py:22-29`)으로 **조용히 스킵**. 메인 Claude Code 동작은 손상되지 않으나 훅 기능(보안 규칙 엔진 등)은 비활성 상태.

### 플랫폼 한계 투명 고지

Claude Code는 현재 크로스 플랫폼 훅 실행을 미완전 지원합니다:
- Windows native installer에서 `bash` 훅이 WSL 스텁으로 해석되는 미해결 버그: Claude Code Issue [#37634](https://github.com/anthropics/claude-code/issues/37634), [#18527](https://github.com/anthropics/claude-code/issues/18527)
- `plugin.json` 시스템 prerequisite 필드·`shell:` 옵션 공식 스키마 미정의

본 플러그인은 위 제약 안에서 **Anthropic hookify 원본 설계 철학(graceful skip)**을 그대로 따릅니다. upstream 개선 이후 재평가 예정.

### 수동 확인 (선택)

설치 후 Python 버전 확인:
- Git Bash: `python --version`
- PowerShell: `python --version`

Python 3.x가 표시되지 않으면 위 OS별 가이드에 따라 조치.

## Install (local, pre-release)

```
/plugin marketplace add rwang2gun/rwang-workbench
/plugin install analysis-pack@rwang-workbench
/plugin install productivity-pack@rwang-workbench
```

Packs are installed independently. No cross-pack runtime dependencies.

## Recommended external plugins

`productivity-pack` recommends the [`codex`](https://github.com/openai/codex-plugin-cc) plugin as an external dependency rather than vendoring it. See [docs/RECOMMENDED_PLUGINS.md](docs/RECOMMENDED_PLUGINS.md) for the rationale and install steps. The `/productivity-pack:check-recommended` command (Phase 5) will report install status.

## Design

The full design doc — vendoring principles, license compatibility, pack split rationale, roadmap — lives in [docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md). Phase 1 inventory and Phase 2 selection are archived alongside.

## License

MIT. See [LICENSE](LICENSE). Vendored third-party components retain their original licenses — see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
