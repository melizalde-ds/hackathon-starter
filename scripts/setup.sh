#!/usr/bin/env bash
set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1
git config core.hooksPath .githooks
echo "Git hooks: .githooks"

missing=0
for tool in gh gitleaks docker; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "ok       $tool"
  else
    echo "missing  $tool"
    missing=1
  fi
done

if command -v gh >/dev/null 2>&1 && ! gh auth status >/dev/null 2>&1; then
  echo "gh is not logged in. Run: gh auth login"
  missing=1
fi

exit "$missing"
