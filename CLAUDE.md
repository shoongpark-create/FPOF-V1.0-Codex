# FPOF — 와키윌리 패션 하우스 오케스트레이션

> AI가 와키윌리 브랜드의 시즌 기획부터 런칭까지를 함께 운영하는 시스템입니다.
> 패션 실무자가 자연어로 지시하면, AI가 브랜드 지식을 기반으로 실무 산출물을 만듭니다.

## 세션 시작 시 반드시
1. `.fpof-state.json` 읽기 — 현재 시즌, PDCA 단계, 진행 상황 파악
2. 현재 단계에 맞는 프리셋 파일 참조

## 핵심 원칙
1. **계획이 먼저** — "알아서 해"는 금지. 반드시 계획 → 승인 → 실행 순서.
2. **브랜드 보이스 준수** — 고객 대면 콘텐츠는 반드시 `tone-manner.json` 참조.
3. **한 번에 하나씩** — 큰 작업은 쪼개서 진행. 완료 후 상태 업데이트.
4. **완료 전 셀프 체크** — 작업 완료 선언 전에 누락/오류 스스로 점검.
5. **상태 기록** — 의미 있는 진전이 있으면 `.fpof-state.json` 업데이트.
6. **참고자료가 진실** — 브랜드 정보를 지어내지 말 것. 프리셋 JSON 기반으로만.

## 브랜드: 와키윌리 (Wacky Willy)
- **컨셉**: Kitsch Street & IP Universe
- **코어 타겟**: 18~25세 자유로운 트렌드리더
- **비전**: K-컬처 기반 글로벌 문화 브랜드 (2029 NO.1 K-Lifestyle Brand)
- **뮤즈**: 지젤

## 브랜드 지식 베이스 (presets/wacky-willy/)
| 파일 | 내용 | 언제 참조 |
|------|------|----------|
| `brand.config.json` | DNA, 비전, 포지셔닝, 5대 경영목표, 로드맵 | 전략/기획 작업 시 |
| `personas.json` | UNI/WOMAN 페르소나, 고객 데이터 인사이트 | 타겟 관련 의사결정 시 |
| `tone-manner.json` | 톤앤매너, 채널별 톤, 브랜드 어휘 | 카피/콘텐츠 작성 시 |
| `visual-identity.json` | 컬러, 타이포, 그래픽 스타일 | 비주얼 작업 시 |
| `categories.json` | 유니/우먼스/용품 카테고리, 상품 전략 | 상품 기획 시 |
| `channels.json` | 6개 채널 매출/목표/성장률 | 유통/마케팅 전략 시 |
| `ip-bible.json` | 키키+11 캐릭터, 그룹(A/B/C), 관계도 | IP/캐릭터 활용 시 |

## 패션 하우스 에이전시 (agents/)
실무자의 자연어 요청을 해석하여 적합한 에이전시와 담당자가 작업합니다.

| 에이전시 | 담당 | 매뉴얼 | 스킬 |
|----------|------|--------|------|
| **전략기획실** | 시즌 기획, 트렌드, MD 전략 | `agents/strategy-planning/` | `skills/strategy/season-planning.md` |
| **크리에이티브 스튜디오** | 무드보드, 디자인, 비주얼 | `agents/creative-studio/` | `skills/creative/design-development.md` |
| **프로덕트 랩** | 테크팩, 원가, QC | `agents/product-lab/` | `skills/product/techpack-production.md` |
| **마케팅 쇼룸** | IMC, 화보/영상, 카피, 바이럴 | `agents/marketing-showroom/` | `skills/marketing/campaign-content.md` |
| **데이터 인텔리전스** | 매출 분석, 인사이트, 지식 아카이빙 | `agents/data-intelligence/` | `skills/data/analysis-insight.md` |
| **QC 본부** | 품질 검증, 갭 분석 | `agents/quality-control/` | `skills/quality/quality-gate.md` |

## 자연어 → 에이전시 라우팅
요청의 키워드와 의도를 파악하여 적합한 에이전시를 호출합니다.

| 이런 말을 하면 | 이 에이전시가 담당 | 참조할 프리셋 |
|---------------|-------------------|-------------|
| 트렌드, 시즌 기획, 포지셔닝, SKU | 전략기획실 | brand.config, categories |
| 무드보드, 디자인, 프린트, 컬러, 비주얼 | 크리에이티브 스튜디오 | visual-identity, ip-bible |
| 테크팩, 원가, BOM, QC, 사이즈 | 프로덕트 랩 | categories |
| 마케팅, 캠페인, GTM, 채널 믹스 | 마케팅 쇼룸 → 마케팅 디렉터 | channels, personas |
| 화보, 영상, 촬영, 룩북, 숏폼 | 마케팅 쇼룸 → 콘텐츠 디렉터 | visual-identity, tone-manner |
| 카피, 상품 설명, 캡션, 스토리 | 마케팅 쇼룸 → 패션 에디터 | tone-manner, ip-bible |
| 인플루언서, 바이럴, 시딩, 런칭 | 마케팅 쇼룸 → 소셜 전략 디렉터 | personas, channels |
| 매출, KPI, 분석, 성과, 데이터 | 데이터 인텔리전스 → 트렌드 애널리스트 | channels, brand.config |
| 왜 잘 팔렸어?, 실패 원인, 인사이트, 플레이북 | 데이터 인텔리전스 → 인사이트 아키텍트 | knowledge/ |
| 검수, 갭 분석, 품질 체크, 보고서 | QC 본부 | (해당 단계 산출물) |

## 시즌 사이클 (PDCA)
현재 시즌의 단계를 `.fpof-state.json` → `pdca.current_phase`에서 확인.

| 단계 | 에이전시 | 하는 일 | 스킬 |
|------|---------|---------|------|
| **Plan** | 전략기획실 | 트렌드, 시즌 컨셉, MD 전략, 라인시트 | `season-planning.md` |
| **Design** | 크리에이티브 스튜디오 + 프로덕트 랩 | 무드보드, 디자인, 비주얼, 원가 검증 | `design-development.md` |
| **Do** | 프로덕트 랩 + 마케팅 쇼룸 | 테크팩, 캠페인, 콘텐츠, 런칭 | `techpack-production.md` + `campaign-content.md` |
| **Check** | 데이터 인텔리전스 | 매출 분석, 인사이트, 지식 아카이빙 | `analysis-insight.md` |
| **Act** | 관련 에이전시 | 갭 기반 개선 | `quality-gate.md` |

## 산출물 저장 규칙
- 위치: `output/[시즌코드]/[단계]/`
- 예시: `output/26SS/plan/trend-brief.md`
- 파일명: 한글 가능, 내용을 알 수 있게

## 참고자료 (docs/)
- `(참고자료) Fashion_PDCA_Orchestration_Framework.md` — 전체 시스템 아키텍처
- `(참고자료) 와키윌리(Wacky Willy) 브랜드 전략 보고서.md` — 브랜드 전략 원문
- `(참고자료) 와키윌리_IP_바이블.md` — IP 캐릭터 세계관 원문
- `(참고자료) 와키윌리 코어타겟.md` — 코어 타겟 정의 원문
- `(참고자료) 와키윌리 사업부 경영목표.md` — 5대 경영목표 원문

## 5대 경영목표 (2026)
1. 브랜드 아이덴티티 정립 — 코어타겟 매출 비중, 인지도/선호도
2. 히트상품 + IMC 강화 — 상위 20% 매출 기여 ≥50%, 캠페인 ROAS
3. QR 비중 확대 — QR 매출 비중, 인시즌 리드타임
4. 용품 라인업 경쟁력 — 용품 매출 비중, 우먼스 용품 비중
5. 글로벌 대응 강화 — 글로벌 매출 달성률, 해외 재구매 비중
