# Architecture

This document is a quick-reference index. The full design — principles, pack split rationale, vendoring rules, phase roadmap — lives in [MASTER_PLAN_v1.5.md](MASTER_PLAN_v1.5.md).

## Repo layout

```
rwang-workbench/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── analysis-pack/
│   │   └── .claude-plugin/plugin.json
│   └── productivity-pack/
│       └── .claude-plugin/
│           ├── plugin.json
│           └── recommends.json
├── scripts/          (Phase 6: validate-plugins.ps1)
├── docs/
├── LICENSE
├── THIRD_PARTY_NOTICES.md
├── README.md
└── .gitignore
```

## Pack domains

- **analysis-pack** — data analysis, SNA, trend reports, standalone HTML build
- **productivity-pack** — Git sync, PR review, plugin development, hookify automation

`game-design-pack` is deferred per §2.3.1 gate (vendored 0 + new-authored confirmed 1 < 2).

## Key principles (abstract from MASTER_PLAN)

- **L0/L1 inclusion only** — project-specific (L2) assets stay out of packs.
- **No cross-pack dependencies** — each pack is standalone.
- **Vendoring metadata** — every imported file carries `vendored-from` / `original-version` / `modified` headers (§3.5).
- **External dependencies** — declared in `recommends.json` (machine-readable) and `docs/RECOMMENDED_PLUGINS.md` (human-readable). Claude Code does not auto-read `recommends.json`; it is consumed by `/productivity-pack:check-recommended` in Phase 5.
