#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOK_SCRIPT="${PROJECT_ROOT}/.claude/hooks/check-output.sh"

if [[ ! -x "${HOOK_SCRIPT}" ]]; then
  echo "check-output hook not executable: ${HOOK_SCRIPT}" >&2
  exit 1
fi

INPUT="${*:-}"
"${HOOK_SCRIPT}" "${INPUT}"

