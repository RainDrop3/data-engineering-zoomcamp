# 5.4 - AI 에이전트와 함께 Bruin MCP 사용하기

## Bruin MCP란?

MCP는 **Model Context Protocol**의 약자입니다. Bruin MCP는 AI 에이전트(Cursor, VS Code, Claude 등)가 Bruin과 통신하는 방법입니다 — 문서를 조회하고, 여러분 대신 명령을 실행하고, 코드를 살펴보고, 문제를 해결하고, 데이터를 분석합니다.

Bruin MCP와 AI 에이전트로 할 수 있는 것:

- pipeline 코드와 asset 설정 작성
- 문서와 메타데이터 작성
- 오류 해결과 디버깅
- 자연어로 쿼리를 실행하고 데이터 분석
- pipeline 로직과 구조에 대해 질문

## Bruin MCP 설치하기

먼저 [Bruin CLI가 설치](https://getbruin.com/docs/bruin/getting-started/introduction/installation)되어 있는지 확인하세요.

### Cursor

**Settings → Tools & MCP → New MCP Server**로 가서 다음을 추가하세요:

```json
{
  "mcpServers": {
    "bruin": {
      "command": "bruin",
      "args": ["mcp"]
    }
  }
}
```

실패/오류가 표시되면 IDE를 닫았다가 다시 여세요 — "Bruin enabled"가 보여야 합니다.

### VS Code (Copilot)

프로젝트 폴더에 `.vscode/mcp.json`을 만드세요:

```json
{
  "servers": {
    "bruin": {
      "command": "bruin",
      "args": ["mcp"]
    }
  }
}
```

### Claude Code

```bash
claude mcp add bruin -- bruin mcp
```

다른 에이전트 설정과 문제 해결은 전체 [Bruin MCP 문서](https://getbruin.com/docs/bruin/getting-started/bruin-mcp)를 참고하세요.

## MCP로 pipeline 구축하기

### 템플릿 프롬프트 사용하기

zoomcamp 템플릿의 README에는 AI 에이전트에게 주면 pipeline 전체를 처음부터 끝까지 만들어 주는 예시 프롬프트가 들어 있습니다:

```bash
bruin init zoomcamp my-taxi-pipeline
```

생성된 `README.md`를 여세요 — 에이전트에 붙여 넣으면 pipeline 전체의 뼈대를 자동으로 잡아 주는 프롬프트가 들어 있습니다.

### 에이전트가 하는 일

pipeline 프롬프트를 받으면 에이전트는:

1. 모든 pipeline asset 생성 (ingestion, staging, reports)
2. materialization 전략과 의존성 설정
3. 품질 체크와 컬럼 메타데이터 설정
4. `bruin validate`로 pipeline 검증
5. 테스트용 날짜 범위로 pipeline 실행
6. 쿼리 로직을 검증하는 custom check 실행
7. `bruin query`로 검증 쿼리 실행

### 단계적으로 작업하기

실제로는 한 번에 전부 생성하기보다 asset 하나씩 작업하는 편이 나을 수 있습니다. 그러면 모든 설계 결정에 직접 관여할 수 있습니다:

- ingestion asset을 먼저 만들고 테스트
- 그다음 staging 계층 구축
- 그다음 reports 계층 추가
- 각 단계마다 품질 체크를 검토하고 조정

## 에이전트로 데이터 조회하기

pipeline이 실행되고 나면 에이전트와 대화하듯 데이터를 조회할 수 있습니다:

**예시 질문:**
- "staging 테이블을 조회해서 며칠 치 데이터가 있는지 알려줘"
- "trip 수와 총 요금이 가장 높았던 날은 언제야?"
- "어느 asset에서 데이터를 집계하고 있어?"

에이전트는 pipeline의 맥락을 이해합니다 — 테이블 구조를 알고, SQL 쿼리를 작성할 수 있고, 각 asset의 로직을 설명할 수 있습니다. 이런 데 유용합니다:

- SQL을 직접 쓰지 않는 ad hoc 분석
- 익숙하지 않은 pipeline 로직 이해
- 데이터 검증과 문제 해결
- 기존 pipeline에 새 팀원 온보딩
