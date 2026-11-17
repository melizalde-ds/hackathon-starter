#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

branch=$(git symbolic-ref --short -q HEAD || true)
if [[ $branch != "main" ]]; then
  echo "evidence.sh runs on main only, so parallel branches never conflict on docs/evidence. You are on '${branch:-detached HEAD}'." >&2
  exit 1
fi

remote=$(git remote get-url origin 2>/dev/null || true)
remote=${remote%.git}
remote=${remote/#git@github.com:/https://github.com/}

link() {
  local sha=$1
  if [[ $remote == https://* ]]; then
    printf '[%s](%s/commit/%s)' "${sha:0:7}" "$remote" "$sha"
  else
    printf '`%s`' "${sha:0:7}"
  fi
}

trim() {
  local value=$1
  value=${value#"${value%%[![:space:]]*}"}
  printf '%s' "${value%"${value##*[![:space:]]}"}"
}

mkdir -p docs/evidence
rm -f docs/evidence/*.md
all=()

while IFS=$'\t' read -r sha date values; do
  [[ -n $values ]] || continue
  IFS=$'\x1f' read -ra entries <<<"$values"
  for entry in "${entries[@]}"; do
    IFS='|' read -r sponsor metric source <<<"$entry"
    sponsor=$(trim "$sponsor")
    sponsor=${sponsor,,}
    metric=$(trim "$metric")
    source=$(trim "${source:-}")
    [[ -n $sponsor && -n $metric && ${metric,,} != "none" ]] || continue
    [[ $sponsor =~ ^[a-z0-9_-]+$ ]] || continue

    suffix="$metric${source:+ ($source)}"
    all+=("- $date $(link "$sha") **$sponsor**: $suffix")

    file=docs/evidence/$sponsor.md
    [[ -f $file ]] || printf '# Evidence: %s\n\nNewest first. Built by `scripts/evidence.sh` from commit trailers.\n\n' "$sponsor" >"$file"
    printf '%s\n' "- $date $(link "$sha"): $suffix" >>"$file"
  done
done < <(git log --format='%H%x09%ad%x09%(trailers:key=Evidence,valueonly,separator=%x1f)' --date=short)

{
  printf '# Evidence\n\nNewest first. Built by `scripts/evidence.sh` from `Evidence:` commit trailers. Per sponsor: `docs/evidence/`.\n\n'
  if ((${#all[@]})); then printf '%s\n' "${all[@]}"; else echo "No evidence yet."; fi
} >docs/evidence.md

echo "Wrote docs/evidence.md and ${#all[@]} entries under docs/evidence/"
