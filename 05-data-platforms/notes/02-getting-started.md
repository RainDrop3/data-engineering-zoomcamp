# 5.2 - Bruin 시작하기

## 설치

Bruin CLI 설치:

```bash
curl -LsSf https://getbruin.com/install/cli | sh
bruin version
```

VS Code나 Cursor용 Bruin 확장을 설치하세요. IDE에서 바로 asset과 pipeline을 실행할 수 있는 Bruin render 패널이 추가됩니다.

## Bruin MCP

Bruin은 MCP(Model Context Protocol) 서버를 제공합니다. 이를 IDE(Cursor, VS Code)에 추가하면 AI 에이전트를 사용해 pipeline을 만들 수 있습니다. IDE 설정 > Tools and MCP에서 Bruin MCP를 추가하세요.

### VS Code용 Bruin MCP 통합

 저장소 루트에 새 파일 `mcp.json` 만들기:
프로젝트의 루트 디렉토리(`.git` 폴더나 `package.json`과 같은 위치)에 `mcp.json`이라는 새 파일을 만드세요.

설정 추가하기:
`mcp.json` 파일을 열고 아래 JSON 설정을 붙여 넣으세요:

```json
{
  "servers": {
    "bruin": {
      "type": "stdio",
      "command": "bruin",
      "args": [
        "mcp"
      ]
    }
  },
  "inputs": []
}
```

이 설정은 VS Code가 `bruin mcp` 명령을 실행하도록 지시해, Bruin MCP 서버와 표준 입출력(stdio) 연결을 맺게 합니다.

## 프로젝트 초기화

```bash
bruin init default my-first-pipeline
cd my-first-pipeline
```

템플릿으로부터 프로젝트를 만들고, git을 초기화하고, `.gitignore`를 추가하고, `bruin.yaml` 파일을 생성합니다.

Bruin은 프로젝트가 git으로 초기화되어 있어야 합니다. `bruin init` 명령이 이를 자동으로 처리합니다.

## 프로젝트 구조

```text
my-first-pipeline/
├── .bruin.yml              # environment와 connection 설정
├── pipeline.yml            # pipeline 이름, 스케줄, 기본 connection
└── assets/
    ├── players.asset.yml   # Ingestr asset (데이터 수집)
    ├── player_stats.sql    # 품질 체크가 포함된 SQL asset
    └── my_python_asset.py  # Python asset
```

### .bruin.yml

- 로컬에만 둡니다 (`.gitignore`에 자동 추가됨)
- 절대 저장소에 push하지 마세요 — 데이터베이스 connection과 secret이 들어 있습니다
- environment(default, production, staging 등)를 정의합니다
- 각 environment 아래에 connection(예: DuckDB, Chess.com, 커스텀 secret)을 정의합니다

```yaml
default_environment: default

environments:
  default:
    connections:
      duckdb:
        - name: duckdb-default
          path: duckdb.db
```

### pipeline.yml

pipeline을 설정합니다: 이름, 스케줄, 기본 connection, 시작 날짜.

```yaml
name: my-pipeline
schedule: daily
start_date: "2022-01-01"
default_connections:
  duckdb: duckdb-default
```

## Asset 유형

### Python asset

가장 단순한 형태: 이름이 붙은 Python 스크립트로, 데이터를 출력하거나 처리합니다. IDE의 Bruin 패널에서 실행합니다.

### YAML ingestor asset

Bruin의 내장 ingestor를 사용합니다. 소스 connection, 목적지, 테이블을 정의합니다. 많은 내장 소스와 목적지를 지원합니다: Redshift, MySQL, Postgres, Motherduck, BigQuery 등. 목적지 데이터베이스/테이블이 없으면 자동으로 생성합니다.

### SQL asset

데이터베이스에 SQL 쿼리를 실행합니다. 다른 asset에 대한 의존성을 정의하면, 의존 대상이 끝났을 때 이 asset이 자동으로 실행됩니다.

## Interval과 incremental 수집

- `start_date`와 `end_date` 파라미터를 설정해 특정 기간의 데이터를 수집합니다
- Bruin은 이 값들을 코드에 주입할 수 있는 변수로 제공합니다
- 내장 수집 asset은 시작/종료 날짜를 자동으로 사용합니다

## 의존성과 lineage

- asset 간 의존성을 정의해 올바른 순서로 실행되게 합니다
- 첫 asset이 완료되면 그에 의존하는 다음 asset을 자동으로 트리거합니다
- Bruin은 이 의존성으로부터 lineage 그래프를 만듭니다

## 핵심 CLI 명령어

| 명령어 | 용도 |
|---------|---------|
| `bruin validate <path>` | 실행하지 않고 문법과 의존성을 검사 |
| `bruin run <path>` | pipeline 또는 개별 asset 실행 |
| `bruin run --downstream` | asset과 그 하류 의존성 전부 실행 |
| `bruin run --full-refresh` | 테이블을 비우고 처음부터 다시 빌드 |
| `bruin lineage <path>` | asset 의존성 보기 |
| `bruin query --connection <conn> --query "..."` | ad-hoc SQL 쿼리 실행 |
