# 5.6 - 핵심 개념: Projects

🎥 [Bruin Core Concepts | Projects](https://www.youtube.com/watch?v=YWDjnSxbBtY) (3:03)

## Project란?

**Project**는 Bruin 데이터 pipeline 전체를 만드는 루트 디렉토리입니다. 모든 데이터 asset, 설정, connection을 정리하는 토대 역할을 합니다.

## 프로젝트 초기화

CLI 도구가 디렉토리 구조를 이해하고 파일을 올바르게 탐색할 수 있도록 프로젝트는 `bruin init`으로 초기화해야 합니다.

```bash
bruin init zoomcamp my-pipeline
cd my-pipeline
```

## `.bruin.yml` 파일

프로젝트 루트에 있는 이 파일은 environment, connection, secret을 정의합니다.

**중요:** secret을 보호하기 위해 이 파일은 항상 `.gitignore`에 추가됩니다. 로컬에만 두고 절대 저장소에 push해서는 안 됩니다.

### Environments

여러 단계에 맞춰 서로 다른 environment를 정의합니다:

```yaml
default_environment: default

environments:
  default:
    connections:
      duckdb:
        - name: duckdb-default
          path: duckdb.db
      motherduck:
        - name: motherduck
          token: <your-token>

  production:
    connections:
      bigquery:
        - name: bq-prod
          project: my-project
          dataset: production
```

**이점:**
- 프로덕션 자격 증명을 노출하지 않고 로컬이나 서버에서 pipeline 실행
- 팀마다 서로 다른 connection 접근 권한을 가질 수 있음
- 기본값을 `dev` environment로 두어 실수로 프로덕션에서 실행되는 것을 방지

### Connection 유형

내장 connection:
- DuckDB, MotherDuck
- PostgreSQL, MySQL
- BigQuery, Redshift, Snowflake
- 커스텀 connection (API 키, secret 등용)

### 기본 Environment

기본으로 사용할 environment를 지정합니다:

```yaml
default_environment: dev
```

이렇게 하면 명시적으로 프로덕션을 지정하지 않는 한 pipeline이 개발 환경에서 실행됩니다.

## 빠른 참조

```bash
# 새 프로젝트 초기화
bruin init zoomcamp my-pipeline

# 프로젝트로 이동
cd my-pipeline

# 프로젝트가 유효한지 확인
bruin validate .
```

## 더 읽을거리

- [Bruin 문서 - Projects](https://getbruin.com/docs/bruin/core-concepts/project.html)
- [Bruin GitHub - Templates](https://github.com/bruin-data/bruin/tree/main/templates)
