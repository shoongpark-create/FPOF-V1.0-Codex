---
type: task-agent
id: format-converter
name: 문서 포맷 변환기
scope: on-demand
trigger: manual-only
skill: skills/task/format-conversion.md
entrypoint: scripts/task-agent.sh format-converter
---

# 문서 포맷 변환기 (Format Converter Task Agent)

> PDCA 시스템과 분리된 유틸리티 태스크 에이전트

## 목적
- `pptx`, `pdf`, `xlsx`, `docx` 포맷 간 변환을 필요할 때만 수행한다.
- 브랜드 전략/PDCA 라우팅과 독립적으로 동작한다.

## 호출 규칙
- 자동 라우팅 대상이 아니다.
- 사용자가 명시적으로 호출할 때만 실행한다.

## 실행 예시
```bash
./scripts/task-agent.sh format-converter --in docs/report.docx --out docs/report.pdf
```

또는
```bash
make convert IN=docs/report.docx OUT=docs/report.pdf
```

## 기술 제약
- 변환 엔진: `soffice` (LibreOffice CLI)
- 지원 대상 확장자(출력): `pdf`, `docx`, `xlsx`, `pptx`
- 문서 계열이 다른 변환(예: `xlsx -> docx`)은 엔진 제약으로 실패할 수 있다.

