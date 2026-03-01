#!/usr/bin/env bash
set -euo pipefail

# Synchronize .fpof-state.json with actual artifacts under output/.
# Usage:
#   scripts/sync-state.sh           # write updates
#   scripts/sync-state.sh --check   # exit non-zero when drift exists

MODE="write"
if [[ "${1:-}" == "--check" ]]; then
  MODE="check"
fi

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

collect_phase_files() {
  local phase="$1"
  if [[ ! -d "${OUTPUT_DIR}" ]]; then
    printf '[]'
    return
  fi

  find "${OUTPUT_DIR}" -type f -name "${phase}_*" -print \
    | sed "s#^${PROJECT_ROOT}/##" \
    | sort \
    | jq -R . \
    | jq -s .
}

required_count() {
  case "$1" in
    plan) echo 4 ;;
    design) echo 4 ;;
    do) echo 5 ;;
    check) echo 4 ;;
    act) echo 1 ;;
    *) echo 1 ;;
  esac
}

PLAN_FILES="$(collect_phase_files plan)"
DESIGN_FILES="$(collect_phase_files design)"
DO_FILES="$(collect_phase_files do)"
CHECK_FILES="$(collect_phase_files check)"
ACT_FILES="$(collect_phase_files act)"

PLAN_REQUIRED="$(required_count plan)"
DESIGN_REQUIRED="$(required_count design)"
DO_REQUIRED="$(required_count do)"
CHECK_REQUIRED="$(required_count check)"
ACT_REQUIRED="$(required_count act)"

TMP_FILE="$(mktemp)"

jq \
  --argjson plan_files "${PLAN_FILES}" \
  --argjson design_files "${DESIGN_FILES}" \
  --argjson do_files "${DO_FILES}" \
  --argjson check_files "${CHECK_FILES}" \
  --argjson act_files "${ACT_FILES}" \
  --argjson plan_required "${PLAN_REQUIRED}" \
  --argjson design_required "${DESIGN_REQUIRED}" \
  --argjson do_required "${DO_REQUIRED}" \
  --argjson check_required "${CHECK_REQUIRED}" \
  --argjson act_required "${ACT_REQUIRED}" \
  '
  def phase_status($count; $required):
    if $count == 0 then
      "not_started"
    elif $count < $required then
      "in_progress"
    else
      "completed"
    end;

  def phase_pct($count; $required):
    if $required <= 0 then 0
    else (($count * 100 / $required) | floor | if . > 100 then 100 else . end)
    end;

  .pdca.phases.plan.artifacts = $plan_files
  | .pdca.phases.design.artifacts = $design_files
  | .pdca.phases.do.artifacts = $do_files
  | .pdca.phases.check.artifacts = $check_files
  | .pdca.phases.act.artifacts = $act_files
  | .pdca.phases.plan.status = phase_status(($plan_files | length); $plan_required)
  | .pdca.phases.design.status = phase_status(($design_files | length); $design_required)
  | .pdca.phases.do.status = phase_status(($do_files | length); $do_required)
  | .pdca.phases.check.status = phase_status(($check_files | length); $check_required)
  | .pdca.phases.act.status = phase_status(($act_files | length); $act_required)
  | .pdca.phases.plan.completion_pct = phase_pct(($plan_files | length); $plan_required)
  | .pdca.phases.design.completion_pct = phase_pct(($design_files | length); $design_required)
  | .pdca.phases.do.completion_pct = phase_pct(($do_files | length); $do_required)
  | .pdca.phases.check.completion_pct = phase_pct(($check_files | length); $check_required)
  | .pdca.phases.act.completion_pct = phase_pct(($act_files | length); $act_required)
  | .pdca.current_phase =
      if .pdca.phases.plan.status != "completed" then "plan"
      elif .pdca.phases.design.status != "completed" then "design"
      elif .pdca.phases.do.status != "completed" then "do"
      elif .pdca.phases.check.status != "completed" then "check"
      elif .pdca.phases.act.status != "completed" then "act"
      else "act"
      end
  ' "${STATE_FILE}" > "${TMP_FILE}"

if cmp -s "${STATE_FILE}" "${TMP_FILE}"; then
  echo "sync-state: no changes"
  rm -f "${TMP_FILE}"
  exit 0
fi

if [[ "${MODE}" == "check" ]]; then
  echo "sync-state: drift detected"
  rm -f "${TMP_FILE}"
  exit 2
fi

mv "${TMP_FILE}" "${STATE_FILE}"
echo "sync-state: updated ${STATE_FILE}"
