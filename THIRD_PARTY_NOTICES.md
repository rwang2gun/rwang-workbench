# Third-Party Notices

This project vendors components from the following Claude Code plugins. Each entry lists the plugin name, the pack it was incorporated into, the original license, and the source. Version / commit hash values were captured during Phase 4 Source Lock (per MASTER_PLAN §3.5).

All plugins listed below are released under Apache-2.0 (verified in Phase 1 catalog, 2026-04-23; re-verified in Phase 4 Source Lock against each plugin's `LICENSE` file).

Version notes:
- `marketplace-sha:` is the checkout hash of the `anthropics/claude-plugins-official` marketplace cache on the build machine (`~/.claude/plugins/marketplaces/claude-plugins-official/.gcs-sha`, 2026-04-23).
- `plugin-version:` is the `version` field of each plugin's `.claude-plugin/plugin.json`, or `unset` if that field is absent. Each vendored file's vendoring header records this value as well.

| Plugin | Pack | Original License | plugin-version | marketplace-sha | Source URL |
|---|---|---|---|---|---|
| claude-code-setup | productivity-pack | Apache-2.0 | `1.0.0` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup |
| claude-md-management | productivity-pack | Apache-2.0 | `1.0.0` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management |
| hookify | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-public/tree/main/plugins/hookify |
| mcp-server-dev | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev |
| playground | analysis-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-official/tree/main/plugins/playground |
| plugin-dev | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-public/tree/main/plugins/plugin-dev |
| session-report | analysis-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-official/tree/main/plugins/session-report |
| commit-commands | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-public/tree/main/plugins/commit-commands |
| feature-dev | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-public/tree/main/plugins/feature-dev |
| pr-review-toolkit | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-public/tree/main/plugins/pr-review-toolkit |
| security-guidance | productivity-pack | Apache-2.0 | `unset` | `cf62a6c02dc03db88da8eb7c61bdb9fd88da6326` | https://github.com/anthropics/claude-plugins-public/tree/main/plugins/security-guidance |

Note on the dual `anthropics/claude-plugins-public` vs `anthropics/claude-plugins-official` URLs: the six `public` plugins appear in both Anthropic repositories, but were resolved from the `official` marketplace cache on the build machine. Each plugin's homepage (first listed in the upstream `marketplace.json`) is preserved above, and every vendored file's `vendored-from` header uses this same URL.

---

**Modifications applied to vendored content (Phase 4):**

Four files carry `modified: minor` in their vendoring headers. All other vendored files are `modified: none` (content byte-identical to upstream aside from the prepended vendoring header):

| File | Modification |
|---|---|
| `plugins/productivity-pack/agents/code-reviewer-feature.md` | Frontmatter `name:` renamed from `code-reviewer` to `code-reviewer-feature` to resolve collision with the pr-review-toolkit agent of the same name. Body unchanged. |
| `plugins/productivity-pack/agents/code-reviewer-pr.md` | Frontmatter `name:` renamed from `code-reviewer` to `code-reviewer-pr`. Body unchanged. |
| `plugins/productivity-pack/commands/feature-dev.md` | Agent invocation updated (`code-reviewer` → `code-reviewer-feature`) to match rename. |
| `plugins/productivity-pack/commands/review-pr.md` | Agent invocation updated (`code-reviewer` → `code-reviewer-pr`) to match rename. |
| `plugins/productivity-pack/hooks/hooks.json` | Merged from two upstream `hooks.json` files (hookify + security-guidance) into a single manifest covering both hook groups. No comment/header possible in standard JSON. |

---

**External dependency (not vendored):**

- `codex` (openai/codex-plugin-cc, Apache-2.0) — recommended via `plugins/productivity-pack/.claude-plugin/recommends.json`. See [docs/RECOMMENDED_PLUGINS.md](docs/RECOMMENDED_PLUGINS.md) for the rationale.
