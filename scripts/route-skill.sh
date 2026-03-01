#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOK_SCRIPT="${PROJECT_ROOT}/.claude/hooks/route-skill.sh"

if [[ ! -x "${HOOK_SCRIPT}" ]]; then
  echo "route hook not executable: ${HOOK_SCRIPT}" >&2
  exit 1
fi

PROMPT="${*:-}"
"${HOOK_SCRIPT}" "${PROMPT}"

