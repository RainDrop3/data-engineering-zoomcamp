# 5.6 - 핵심 개념: Commands

🎥 [Bruin Core Concepts | Commands](https://www.youtube.com/watch?v=3nykPEs_V7E) (6:46)

## Bruin CLI 명령어

명령어는 Bruin 프로젝트와 상호작용하는 수단입니다 — pipeline 실행, 설정 검증, 데이터 조회 등.

## `bruin run` - Pipeline 실행

pipeline의 **단일 실행 인스턴스**("run")를 만듭니다.

### 기본 사용법

```bash
bruin run ./pipelines/nyc-taxi/pipeline.yml
```

### 실행 범위 옵션

| 옵션 | 설명 |
|--------|-------------|
| pipeline 전체 | 모든 asset을 의존성 순서대로 실행 |
| 단일 asset | `--asset staging.trips_summary` |
| 상류 포함 | `--asset X --upstream` - X와 그 의존 대상 전부 실행 |
| 하류 포함 | `--asset X --downstream` - X와 X에 의존하는 것 전부 실행 |

### 자주 쓰는 run 플래그

| 플래그 | 설명 |
|------|-------------|
| `--start-date DATE` | 실행 시작 날짜 설정 |
| `--end-date DATE` | 실행 종료 날짜 설정 |
| `--full-refresh` | 테이블을 drop하고 다시 생성 (incremental을 무시) |
| `--exclusive-end-date` | 종료 날짜를 exclusive로 (기본값: inclusive) |
| `--environment ENV` | 특정 environment 사용 (dev/prod) |
| `--var KEY=VALUE` | 커스텀 변수 덮어쓰기 |

### 실행 명령 예시

```bash
# 단순 실행
bruin run ./pipelines/nyc-taxi/pipeline.yml

# 날짜 범위 지정
bruin run ./pipelines/nyc-taxi/pipeline.yml \
  --start-date 2020-01-01 \
  --end-date 2020-01-31

# 변수와 함께 full refresh
bruin run ./pipelines/nyc-taxi/pipeline.yml \
  --full-refresh \
  --var taxi_types=["yellow","green"] \
  --environment default
```

## `bruin validate` - Pipeline 검증

실행 전에 설정 문제를 검사합니다:

```bash
bruin validate ./pipelines/nyc-taxi/pipeline.yml
```

**검증 항목:**
- lineage에 순환 의존성이 없는지
- asset 정의가 올바른지
- connection이 존재하고 제대로 설정되어 있는지
- 깨진 참조가 없는지

**실행 전에는 항상 검증하세요!**

## `bruin lineage` - 의존성 그래프 보기

asset들이 어떻게 연결되어 있는지 시각화합니다:

```bash
bruin lineage ./pipelines/nyc-taxi/pipeline.yml
```

asset 간의 상류·하류 관계를 보여줍니다.

## `bruin query` - 데이터 조회

connection에 ad-hoc 쿼리를 실행합니다:

```bash
bruin query --connection duckdb-default \
  --query "SELECT * FROM ingestion.trips LIMIT 10"
```

## "Run"이란?

**run**은 pipeline 실행의 단일 인스턴스입니다:
- 고유한 시작/종료 시간을 가짐
- 모든 asset을 실행할 수도, 일부만 실행할 수도 있음
- 자체 변수 값을 가짐
- 실행 로그와 결과를 생성

## 전체 그림

Bruin 워크플로 전체:

```
1. Project (루트, 초기화됨)
   └── .bruin.yml (environment, connection)

2. Pipeline (스케줄 단위 그룹)
   └── pipeline.yml (스케줄, 기본 connection, 변수)

3. Assets (실제 작업)
   ├── Python (수집, 처리)
   ├── SQL (변환)
   └── YAML/Seed (정적 데이터)

4. Commands (실행시키기)
   ├── bruin run (실행)
   ├── bruin validate (검사)
   └── bruin query (조회)
```

## 빠른 참조

```bash
# 새 프로젝트 초기화
bruin init zoomcamp my-pipeline

# 실행 전 검증
bruin validate ./pipeline/pipeline.yml

# pipeline 전체 실행
bruin run ./pipeline/pipeline.yml

# 날짜 범위 지정 실행
bruin run ./pipeline/pipeline.yml \
  --start-date 2020-01-01 \
  --end-date 2020-01-31

# 단일 asset을 하류와 함께 실행
bruin run ./pipeline/pipeline.yml \
  --asset raw.trips \
  --downstream

# lineage 보기
bruin lineage ./pipeline/pipeline.yml

# 테이블 조회
bruin query --connection duckdb-default \
  --query "SELECT COUNT(*) FROM staging.trips"
```

## 더 읽을거리

- [Bruin 문서 - CLI 레퍼런스](https://getbruin.com/docs/bruin/commands/overview.html)
- [Bruin GitHub 저장소](https://github.com/bruin-data/bruin)
