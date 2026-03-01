#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_FILE="${PROJECT_ROOT}/.fpof-state.json"
OUTPUT_DIR="${PROJECT_ROOT}/output"

if [[ ! -f "${STATE_FILE}" ]]; then
  echo "state file not found: ${STATE_FILE}" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed" >&2
  exit 1
fi

echo "[FPOF STATUS]"
jq -r '
  "brand: \(.active_brand)",
  "season: \(.current_season)",
  "phase: \(.pdca.current_phase)",
  "cycle: \(.pdca.cycle_count)",
  "",
  "phases:",
  "  - plan: \(.pdca.phases.plan.status) (\(.pdca.phases.plan.completion_pct)%) artifacts=\(.pdca.phases.plan.artifacts | length)",
  "  - design: \(.pdca.phases.design.status) (\(.pdca.phases.design.completion_pct)%) artifacts=\(.pdca.phases.design.artifacts | length)",
  "  - do: \(.pdca.phases.do.status) (\(.pdca.phases.do.completion_pct)%) artifacts=\(.pdca.phases.do.artifacts | length)",
  "  - check: \(.pdca.phases.check.status) (\(.pdca.phases.check.completion_pct)%) artifacts=\(.pdca.phases.check.artifacts | length)",
  "  - act: \(.pdca.phases.act.status) (\(.pdca.phases.act.completion_pct)%) artifacts=\(.pdca.phases.act.artifacts | length)",
  "",
  "quality gates:",
  "  - QG1: \(.pdca.quality_gates.QG1.status)",
  "  - QG2: \(.pdca.quality_gates.QG2.status)",
  "  - QG3: \(.pdca.quality_gates.QG3.status)",
  "  - QG4: \(.pdca.quality_gates.QG4.status)"
' "${STATE_FILE}"

if [[ -d "${OUTPUT_DIR}" ]]; then
  echo ""
  echo "output files by phase-prefix:"
  for phase in plan design do check act; do
    count="$(find "${OUTPUT_DIR}" -type f -name "${phase}_*" | wc -l | tr -d ' ')"
    echo "  - ${phase}: ${count}"
  done
fi

