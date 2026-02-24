#!/bin/bash
# ============================================================
# FPOF 완료 후 체크 장치 (Post-Completion Check Hook)
# PostToolUse(Write) → output/ 경로 감지 → 체크리스트 리마인더
# "혹시 이것도 확인했어?" 스타일의 상기 장치
# ============================================================

TOOL_INPUT="$1"
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# output/ 경로에서 파일명 추출
FILE_PATH=$(echo "$TOOL_INPUT" | grep -oE 'output/[^ "]+' | head -1)

# output/ 경로가 아니면 조용히 종료
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

FILENAME=$(basename "$FILE_PATH")

# ── 경로/파일명 → 체크리스트 매핑 ────────────────────────

CHECKLIST=""

# Plan 산출물
if echo "$FILE_PATH" | grep -qiE "plan/.*trend|trend.*brief"; then
  CHECKLIST="- 글로벌/로컬 트렌드가 구분되어 있는가?
- 와키윌리 DNA와의 접점이 명시되어 있는가?
- 데이터 소스가 표기되어 있는가?"

elif echo "$FILE_PATH" | grep -qiE "plan/.*brand|season.*theme|concept"; then
  CHECKLIST="- 시즌 테마가 brand.config.json의 DNA와 일치하는가?
- 타겟 페르소나와의 연결이 명확한가?
- 경쟁사 대비 차별화 포인트가 있는가?"

elif echo "$FILE_PATH" | grep -qiE "plan/.*md|champion|category.*mix"; then
  CHECKLIST="- 카테고리별 SKU 배분이 합리적인가?
- 챔피언 상품이 시즌 테마와 연결되는가?
- 가격대가 brand.config.json 기준 이내인가?"

elif echo "$FILE_PATH" | grep -qiE "plan/.*line.*sheet|sku.*list"; then
  CHECKLIST="- 모든 SKU에 사이즈/컬러 브레이크다운이 있는가?
- OTB 수량이 MD 전략과 일치하는가?
- 원가 타겟이 설정되어 있는가?"

# Design 산출물
elif echo "$FILE_PATH" | grep -qiE "design/.*mood|moodboard"; then
  CHECKLIST="- 시즌 컨셉과 무드보드의 연결성이 명확한가?
- 컬러 팔레트가 visual-identity.json과 일치하는가?
- IP 캐릭터 활용 방향이 포함되었는가?"

elif echo "$FILE_PATH" | grep -qiE "design/.*spec|design.*dev"; then
  CHECKLIST="- 도식화/디테일이 충분히 기술되었는가?
- 소재/원부자재 정보가 포함되었는가?
- 사이즈 스펙이 categories.json 기준과 맞는가?"

elif echo "$FILE_PATH" | grep -qiE "design/.*visual|design/.*image|design/.*look"; then
  CHECKLIST="- 생성 이미지가 visual-identity.json 톤과 일치하는가?
- 프롬프트 히스토리가 기록되었는가?
- 참고용임이 명시되었는가?"

# Do 산출물
elif echo "$FILE_PATH" | grep -qiE "do/.*tech.*pack|do/.*bom"; then
  CHECKLIST="- BOM이 완전한가? (원단, 부자재, 라벨, 패키징)
- 봉제 사양이 구체적인가?
- 사이즈 스펙 테이블이 포함되었는가?"

elif echo "$FILE_PATH" | grep -qiE "do/.*cost|do/.*ve"; then
  CHECKLIST="- 원가율이 타겟 이내인가?
- VE 제안이 품질에 영향을 주지 않는가?
- 마진 시뮬레이션이 포함되었는가?"

elif echo "$FILE_PATH" | grep -qiE "do/.*imc|do/.*marketing|do/.*campaign"; then
  CHECKLIST="- 캠페인 타임라인이 현실적인가?
- 채널별 예산 배분이 명시되었는가?
- KPI 목표치가 설정되었는가?"

elif echo "$FILE_PATH" | grep -qiE "do/.*copy|do/.*caption|do/.*pdp"; then
  CHECKLIST="- 톤앤매너가 tone-manner.json과 일치하는가?
- 타겟 페르소나에 맞는 언어를 사용했는가?
- CTA가 포함되었는가?"

elif echo "$FILE_PATH" | grep -qiE "do/.*viral|do/.*influencer|do/.*launch"; then
  CHECKLIST="- 인플루언서 티어 구분이 명확한가?
- 런칭 시퀀스 타임라인이 현실적인가?
- 예산 범위가 설정되었는가?"

# Check 산출물
elif echo "$FILE_PATH" | grep -qiE "check/.*sales|check/.*kpi|check/.*analysis"; then
  CHECKLIST="- 실제 데이터에 기반한 분석인가?
- KPI 달성률이 수치로 표현되었는가?
- 개선 포인트가 도출되었는가?"

elif echo "$FILE_PATH" | grep -qiE "check/.*report|check/.*summary"; then
  CHECKLIST="- Plan~Do 전 과정이 요약되었는가?
- Top 성과/개선 항목이 명시되었는가?
- 다음 시즌 추천 액션이 포함되었는가?"

else
  # 기본 체크리스트 (특정 매핑 없을 때)
  CHECKLIST="- 브랜드 프리셋(visual-identity, tone-manner)과 일치하는가?
- .fpof-state.json 업데이트가 필요한가?"
fi

# ── 결과 출력 ─────────────────────────────────────────────

cat <<EOF
[FPOF CHECK] $FILENAME
$CHECKLIST
- .fpof-state.json artifacts 업데이트가 필요한가?
EOF
