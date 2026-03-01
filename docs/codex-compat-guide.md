# FPOF Codex 호환 가이드

원래 Claude Code 기준으로 설계된 시스템을 유지하면서, Codex에서도 동일한 운영 절차를 실행하기 위한 가이드입니다.

## 원칙
- `.claude/` 구조와 기존 슬래시 명령 문서는 그대로 유지
- Codex에서는 자동 훅 대신 `scripts/` 명령을 직접 실행
- 상태 파일(`.fpof-state.json`)은 `output/` 기준으로 주기적으로 동기화

## 제공 스크립트
- `scripts/status.sh`: 현재 상태 요약 출력
- `scripts/sync-state.sh`: 산출물 스캔 후 상태 파일 동기화
- `scripts/sync-state.sh --check`: 드리프트 감지(변경 필요 시 non-zero 종료)
- `scripts/route-skill.sh "요청문"`: 기존 라우팅 훅 수동 실행
- `scripts/check-output.sh "output/..."`: 기존 체크 훅 수동 실행
- `scripts/task-agent.sh <agent-id> ...`: PDCA 외부 온디맨드 태스크 실행
- `scripts/convert-office.sh --in --out`: 문서 포맷 변환 엔진

## Makefile 단축 명령
```bash
make status
make sync-state
make sync-check
make route-skill PROMPT="26SS 트렌드 분석해줘"
make check-output INPUT="output/26SS/_season/plan_trend-brief.md"
make convert IN=docs/report.docx OUT=docs/report.pdf
```

## On-demand Task Agents (PDCA 분리)
- `format-converter`
  - 목적: `pptx/pdf/xlsx/docx` 포맷 변환
  - 호출: 수동 전용 (`make convert` 또는 `scripts/task-agent.sh`)
  - 비고: `.claude/hooks/route-skill.sh` 자동 라우팅 대상이 아님

## 동기화 정책
- 산출물 판정 기준: 파일명 접두사 `plan_`, `design_`, `do_`, `check_`, `act_`
- 스캔 위치: `output/` 전체 하위 폴더
- 갱신 항목:
  - `pdca.phases.*.artifacts`
  - `pdca.phases.*.status`
  - `pdca.phases.*.completion_pct`
  - `pdca.current_phase`
- 품질 게이트(`quality_gates`) 값은 자동 변경하지 않음
