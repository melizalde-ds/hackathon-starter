#!/usr/bin/env bash
set -uo pipefail

input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input")
[[ $command == *"git commit"* ]] || exit 0

cwd=$(jq -r '.cwd // "."' <<<"$input")
cd "$cwd" || exit 0
git rev-parse --verify --quiet main >/dev/null || exit 0

if conflicts=$(git merge-tree --write-tree --name-only --no-messages main HEAD 2>/dev/null); then
  exit 0
fi

files=$(tail -n +2 <<<"$conflicts" | sed '/^$/d' | sort -u)
[[ -n $files ]] || exit 0

message="Merge check: this branch conflicts with main in:
$files
Rebase on main now, while the conflict is small: git fetch origin && git rebase origin/main"

jq -n --arg context "$message" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $context}}'
exit 0
