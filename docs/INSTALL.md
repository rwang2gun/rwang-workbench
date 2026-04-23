# Install

## Prerequisites

- Claude Code CLI installed and authenticated
- `gh` CLI (for future `commit-commands` flows)
- Windows PowerShell or compatible shell

## Add the marketplace

```
/plugin marketplace add rwang2gun/rwang-workbench
```

For local development (cloning this repo):

```
git clone https://github.com/rwang2gun/rwang-workbench.git
/plugin marketplace add [absolute path to clone]
```

## Install packs (each is independent)

```
/plugin install analysis-pack@rwang-workbench
/plugin install productivity-pack@rwang-workbench
```

## Recommended external plugins

`productivity-pack` lists `codex` as a recommended external plugin:

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
```

See [RECOMMENDED_PLUGINS.md](RECOMMENDED_PLUGINS.md) for the full list and rationale.

## Verify

After Phase 5 ships `/productivity-pack:check-recommended`, run it to see a table of recommended plugin install status. Until then, check manually:

```
/plugin list
```

## Uninstall / disable

```
/plugin uninstall analysis-pack@rwang-workbench
/plugin disable productivity-pack@rwang-workbench
```

## Troubleshooting

- **`/plugin marketplace add` warning about unknown field** — only expected on pre-release fixtures; production `plugin.json` uses standard fields only.
- **`recommends.json` not picked up** — this file is not read by Claude Code itself; it is consumed by `/productivity-pack:check-recommended` (Phase 5).
