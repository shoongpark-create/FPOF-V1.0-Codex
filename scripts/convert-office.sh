#!/usr/bin/env bash
set -euo pipefail

# Office/PDF converter for on-demand task usage.
# Supported target formats: pdf, docx, xlsx, pptx
#
# Usage:
#   scripts/convert-office.sh --in input.docx --out output.pdf
#   scripts/convert-office.sh input.docx output.pdf

usage() {
  cat <<'EOF'
Usage:
  scripts/convert-office.sh --in <input-file> --out <output-file>
  scripts/convert-office.sh <input-file> <output-file>

Supported target extensions:
  .pdf, .docx, .xlsx, .pptx

Notes:
  - Requires LibreOffice CLI (`soffice`).
  - Cross-family conversions (e.g. xlsx -> docx) may fail by LibreOffice capabilities.
EOF
}

IN_FILE=""
OUT_FILE=""

if [[ $# -eq 2 ]] && [[ "${1:-}" != "--in" ]]; then
  IN_FILE="$1"
  OUT_FILE="$2"
else
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --in)
        IN_FILE="${2:-}"
        shift 2
        ;;
      --out)
        OUT_FILE="${2:-}"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "unknown option: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
fi

if [[ -z "${IN_FILE}" || -z "${OUT_FILE}" ]]; then
  usage
  exit 1
fi

if [[ ! -f "${IN_FILE}" ]]; then
  echo "input file not found: ${IN_FILE}" >&2
  exit 1
fi

if ! command -v soffice >/dev/null 2>&1; then
  echo "soffice not found. install LibreOffice first." >&2
  exit 1
fi

in_abs="$(cd "$(dirname "${IN_FILE}")" && pwd)/$(basename "${IN_FILE}")"
out_dir="$(cd "$(dirname "${OUT_FILE}")" && pwd)"
out_name="$(basename "${OUT_FILE}")"
out_ext="${out_name##*.}"
out_ext_lower="$(echo "${out_ext}" | tr '[:upper:]' '[:lower:]')"

case "${out_ext_lower}" in
  pdf)
    convert_to="pdf"
    ;;
  docx)
    convert_to="docx:MS Word 2007 XML"
    ;;
  xlsx)
    convert_to="xlsx:Calc MS Excel 2007 XML"
    ;;
  pptx)
    convert_to="pptx:Impress MS PowerPoint 2007 XML"
    ;;
  *)
    echo "unsupported target extension: .${out_ext_lower}" >&2
    exit 1
    ;;
esac

tmp_base="$(basename "${in_abs}")"
tmp_stem="${tmp_base%.*}"
tmp_ext="${out_ext_lower}"
tmp_converted="${out_dir}/${tmp_stem}.${tmp_ext}"
out_abs="${out_dir}/${out_name}"

soffice --headless --convert-to "${convert_to}" --outdir "${out_dir}" "${in_abs}" >/dev/null 2>&1 || {
  echo "conversion failed: ${in_abs} -> ${out_abs}" >&2
  exit 1
}

if [[ ! -f "${tmp_converted}" ]]; then
  echo "converter output not found: ${tmp_converted}" >&2
  exit 1
fi

if [[ "${tmp_converted}" != "${out_abs}" ]]; then
  mv "${tmp_converted}" "${out_abs}"
fi

echo "converted: ${in_abs} -> ${out_abs}"

