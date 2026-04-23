---
name: warn-console-log
enabled: true
event: file
pattern: console\.log\(
action: warn
---

<!--
vendored-from: https://github.com/anthropics/claude-plugins-public/tree/main/plugins/hookify
vendored-at: 2026-04-23
original-version: marketplace-sha:cf62a6c02dc03db88da8eb7c61bdb9fd88da6326, plugin-version:unset
modified: none
-->


🔍 **Console.log detected**

You're adding a console.log statement. Please consider:
- Is this for debugging or should it be proper logging?
- Will this ship to production?
- Should this use a logging library instead?
