# Recommended External Plugins

This file is the human-readable source of truth for external plugins that `rwang-workbench` recommends but does **not** vendor. The machine-readable counterpart is `plugins/<pack>/.claude-plugin/recommends.json`.

Per MASTER_PLAN v1.5 §3.6, some plugins are kept external when any of the following apply:
- Large set (15+ components)
- Actively maintained upstream
- License risk
- Already well-established in the ecosystem

## Initial setup (one-liner)

After adding the `rwang-workbench` marketplace, install the recommended externals in one go:

```
/plugin marketplace add openai/codex-plugin-cc && /plugin install codex@openai-codex
```

Then run `/productivity-pack:check-recommended` to confirm. The command reads each pack's `recommends.json` + `~/.claude/plugins/installed_plugins.json` and prints a table. It never writes and never auto-installs.

## productivity-pack

### codex

| Field | Value |
|---|---|
| Source | [`openai/codex-plugin-cc`](https://github.com/openai/codex-plugin-cc) |
| License | Apache-2.0 |
| Install | `/plugin marketplace add openai/codex-plugin-cc && /plugin install codex@openai-codex` |
| Last verified | 2026-04-23 |
| Required | No |

**Why external:** 14-component set (near the §3.6.1 "15+" threshold), actively maintained by OpenAI, and used daily via `/codex:review` and `codex-rescue`. Vendoring would bloat the repo and add upstream drift burden.

**What it provides:**
- `/codex:review`, `/codex:adversarial-review`, `/codex:rescue`, `/codex:result`, `/codex:status`, `/codex:setup`, `/codex:cancel`
- `codex-rescue` agent
- `codex-cli-runtime`, `codex-result-handling`, `gpt-5-4-prompting` skills (set-internal)
- SessionStart / SessionEnd / Stop hooks

---

## MCP servers (install on request)

External MCP servers are **not** bundled into any pack's `.mcp.json` — users invite secret leaks if we ship server configs with credentials. Instead, ask Claude to install these on demand:

- **draw.io MCP** — diagram rendering/editing. Phase 5 decision (2026-04-24): not bundled. Ask Claude to add it when you need flowcharts or architecture diagrams generated from XML.
- **Google Cloud MCP** — GCP project/resource inspection. Phase 5 decision (2026-04-24): not bundled. Ask Claude to add it when you need budget or resource queries that `gcloud` CLI cannot satisfy inline.

Both are tracked as Phase 9 candidates if `validate-plugins.ps1` (Phase 6) adds a safe path for bundling MCP configs without secrets.

---

## Not recommended (considered and rejected)

- **`github` MCP** — `commit-commands` + `gh` CLI covers daily GitHub automation. Revisit only if a use case arises that `gh` cannot handle (bulk issue ops, Project v2 management, etc.). Tracked in the Phase 2 Deferred queue.

---

## Re-verification policy

Per MASTER_PLAN §5 Phase 9: re-verify `last_verified` **before each release** or **when a `/check-recommended` install failure is reported**. No scheduled calendar check.

When updating: edit both this file and the corresponding `recommends.json` entry.
