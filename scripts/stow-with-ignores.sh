#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ignore_args=()

while IFS= read -r pattern; do
  [[ -z "$pattern" || "$pattern" == \#* ]] && continue
  ignore_args+=(--ignore="$pattern")
done < "$repo_root/.stow-local-ignore"

exec stow "${ignore_args[@]}" "$@"
