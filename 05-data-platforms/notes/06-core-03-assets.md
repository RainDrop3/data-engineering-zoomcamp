# 5.6 - 핵심 개념: Assets

🎥 [Bruin Core Concepts | Assets](https://www.youtube.com/watch?v=ZElY5SoqrwI) (6:11)

## Asset이란?

**Asset**은 특정 작업을 수행하는 단일 파일입니다. 거의 언제나 목적지 데이터베이스의 테이블이나 뷰를 생성하거나 갱신하는 일과 관련됩니다.

각 asset 파일은 두 부분으로 이루어집니다:

1. **Definition** (설정) - 메타데이터, 이름, 유형, connection
2. **Content** (코드) - 실제로 실행할 SQL, Python, R 코드

## Asset 유형

| 유형 | 설명 | 사용 사례 |
|------|-------------|----------|
| **Python** | Python 스크립트 | 수집, 데이터 처리, ML 모델 |
| **SQL** | SQL 쿼리 | 변환, 집계 |
| **YAML/Seed** | 파일 기반 테이블 | 참조 데이터, 정적 lookup |
| **R** | R 스크립트 | 통계 분석, R 전용 워크플로 |

## Asset 이름

asset 이름은 다음 중 하나로 정해집니다:
1. 데코레이터에서 **명시적으로 정의**
2. **파일 경로로부터 추론** (기본 동작)

**관례:** asset을 schema/dataset 단위로 묶습니다:
- `assets/raw/trips_raw.py` → `raw.trips_raw` 테이블 생성
- `assets/staging/trips_summary.sql` → `staging.trips_summary` 테이블 생성

## SQL Asset 예시

```sql
@bruin.asset(
    name="staging.trips_summary",
    type="sql",
    connection="duckdb-default",
    materialization="table"
)

SELECT
    pickup_date,
    COUNT(*) as trip_count,
    SUM(fare_amount) as total_fare
FROM raw.trips_raw
WHERE pickup_date >= '{{ start_date }}'
  AND pickup_date < '{{ end_date }}'
GROUP BY pickup_date
```

### Materialization 전략

| 전략 | 동작 |
|----------|----------|
| `table` | 매 실행마다 테이블을 다시 생성 |
| `view` | 뷰를 생성 (데이터는 저장하지 않음) |
| `insert` | 기존 테이블에 새 데이터를 덧붙임 |
| `incremental` | 키 컬럼 기준의 똑똑한 merge |

## Python Asset 예시 (수집)

```python
@bruin.asset(
    name="raw.trips_raw",
    type="python",
    connection="duckdb-default"
)
def ingest_trips():
    import requests
    import pandas as pd

    # API에 접속해 데이터 가져오기
    response = requests.get("https://api.example.com/trips")
    data = response.json()

    # pandas DataFrame 반환
    # 데이터베이스로의 materialization은 Bruin이 처리
    return pd.DataFrame(data)
```

## YAML/Seed Asset 예시

```yaml
@bruin.asset(
    name="lookup.taxi_types",
    type="seed",
    connection="duckdb-default"
)

path: reference_data/taxi_types.csv
```

로컬 CSV 파일을 읽어 목적지 데이터베이스에 테이블을 만들기만 합니다.

## Lineage와 의존성

asset은 자신이 무엇을 읽는지에 따라 의존성을 자동으로 정의합니다:

- Asset B가 Asset A의 테이블을 읽으면, **B는 A에 의존**합니다
- VS Code 확장에서 시각화됨
- 실행 시 순서를 정하는 데 사용됨

```sql
-- 이 asset은 raw.trips_raw에 의존합니다
@bruin.asset(name="staging.trips_summary", type="sql")
SELECT * FROM raw.trips_raw  -- 의존성을 만듦
```

## 빠른 참조

```bash
# 특정 asset 실행
bruin run ./pipeline.yml --asset raw.trips_raw

# asset과 그 하류 의존성 전부 실행
bruin run ./pipeline.yml --asset raw.trips_raw --downstream

# asset과 그 상류 의존성 전부 실행
bruin run ./pipeline.yml --asset staging.trips_summary --upstream

# asset의 lineage 보기
bruin lineage ./pipeline.yml --asset raw.trips_raw
```

## 더 읽을거리

- [Bruin 문서 - Assets](https://getbruin.com/docs/bruin/assets/definition-schema.html)
- [Materialization 전략](https://getbruin.com/docs/bruin/assets/materialization.html)
