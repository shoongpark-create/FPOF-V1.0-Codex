#!/usr/bin/env bash
set -euo pipefail

# Manual on-demand task agent runner (separate from PDCA system routing).
#
# Example:
#   scripts/task-agent.sh format-converter --in a.docx --out a.pdf

if [[ $# -lt 1 ]]; then
  echo "usage: scripts/task-agent.sh <agent-id> [args...]" >&2
  exit 1
fi

AGENT_ID="$1"
shift

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${AGENT_ID}" in
  format-converter)
    "${SCRIPT_DIR}/convert-office.sh" "$@"
    ;;
  *)
    echo "unknown task agent: ${AGENT_ID}" >&2
    echo "available: format-converter" >&2
    exit 1
    ;;
esac

