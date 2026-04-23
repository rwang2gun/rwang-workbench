---
name: block-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf
action: block
---

<!--
vendored-from: https://github.com/anthropics/claude-plugins-public/tree/main/plugins/hookify
vendored-at: 2026-04-23
original-version: marketplace-sha:cf62a6c02dc03db88da8eb7c61bdb9fd88da6326, plugin-version:unset
modified: none
-->


⚠️ **Dangerous rm command detected!**

This command could delete important files. Please:
- Verify the path is correct
- Consider using a safer approach
- Make sure you have backups
