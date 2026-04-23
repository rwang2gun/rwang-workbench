#!/bin/bash
# vendored-from: https://github.com/anthropics/claude-plugins-public/tree/main/plugins/plugin-dev
# vendored-at: 2026-04-23
# original-version: marketplace-sha:cf62a6c02dc03db88da8eb7c61bdb9fd88da6326, plugin-version:unset
# modified: none

# Example PreToolUse hook for validating Write/Edit operations
# This script demonstrates file write validation patterns

set -euo pipefail

# Read input from stdin
input=$(cat)

# Extract file path and content
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Validate path exists
if [ -z "$file_path" ]; then
  echo '{"continue": true}' # No path to validate
  exit 0
fi

# Check for path traversal
if [[ "$file_path" == *".."* ]]; then
  echo '{"hookSpecificOutput": {"permissionDecision": "deny"}, "systemMessage": "Path traversal detected in: '"$file_path"'"}' >&2
  exit 2
fi

# Check for system directories
if [[ "$file_path" == /etc/* ]] || [[ "$file_path" == /sys/* ]] || [[ "$file_path" == /usr/* ]]; then
  echo '{"hookSpecificOutput": {"permissionDecision": "deny"}, "systemMessage": "Cannot write to system directory: '"$file_path"'"}' >&2
  exit 2
fi

# Check for sensitive files
if [[ "$file_path" == *.env ]] || [[ "$file_path" == *secret* ]] || [[ "$file_path" == *credentials* ]]; then
  echo '{"hookSpecificOutput": {"permissionDecision": "ask"}, "systemMessage": "Writing to potentially sensitive file: '"$file_path"'"}' >&2
  exit 2
fi

# Approve the operation
exit 0
