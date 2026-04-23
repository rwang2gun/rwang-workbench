#!/bin/bash
# vendored-from: https://github.com/anthropics/claude-plugins-public/tree/main/plugins/plugin-dev
# vendored-at: 2026-04-23
# original-version: marketplace-sha:cf62a6c02dc03db88da8eb7c61bdb9fd88da6326, plugin-version:unset
# modified: none

# Example PreToolUse hook for validating Bash commands
# This script demonstrates bash command validation patterns

set -euo pipefail

# Read input from stdin
input=$(cat)

# Extract command
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Validate command exists
if [ -z "$command" ]; then
  echo '{"continue": true}' # No command to validate
  exit 0
fi

# Check for obviously safe commands (quick approval)
if [[ "$command" =~ ^(ls|pwd|echo|date|whoami)(\s|$) ]]; then
  exit 0
fi

# Check for destructive operations
if [[ "$command" == *"rm -rf"* ]] || [[ "$command" == *"rm -fr"* ]]; then
  echo '{"hookSpecificOutput": {"permissionDecision": "deny"}, "systemMessage": "Dangerous command detected: rm -rf"}' >&2
  exit 2
fi

# Check for other dangerous commands
if [[ "$command" == *"dd if="* ]] || [[ "$command" == *"mkfs"* ]] || [[ "$command" == *"> /dev/"* ]]; then
  echo '{"hookSpecificOutput": {"permissionDecision": "deny"}, "systemMessage": "Dangerous system operation detected"}' >&2
  exit 2
fi

# Check for privilege escalation
if [[ "$command" == sudo* ]] || [[ "$command" == su* ]]; then
  echo '{"hookSpecificOutput": {"permissionDecision": "ask"}, "systemMessage": "Command requires elevated privileges"}' >&2
  exit 2
fi

# Approve the operation
exit 0
