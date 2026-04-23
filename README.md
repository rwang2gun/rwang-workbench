# rwang-workbench

A personal Claude Code plugin marketplace curating general-purpose skills, commands, hooks, and agents from the broader ecosystem plus self-authored workflows.

> **Status:** v0.1.0-alpha (scaffolded). Vendored content arrives in Phase 4; native workflows in Phase 5. See [docs/CHANGELOG.md](docs/CHANGELOG.md).

## Packs

| Pack | Domain |
|---|---|
| `analysis-pack` | Data analysis, SNA, trend reports, standalone HTML build |
| `productivity-pack` | Git sync, PR review, plugin development, hookify automation, documentation |

`game-design-pack` is currently deferred per the §2.3.1 gate (MASTER_PLAN v1.5). See [docs/MASTER_PLAN_v1.5.md](docs/MASTER_PLAN_v1.5.md) §8.

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
