# 5.3 - NYC Taxi 데이터로 End-to-End 파이프라인 구축하기

## 아키텍처

로컬 호스팅 데이터베이스로 DuckDB를 사용하는 3계층 pipeline:

1. Ingestion 계층: 데이터를 추출해 raw 형태로 저장
2. Staging 계층: 전처리, 정제, 변환, lookup 테이블과 join
3. Reports 계층: 데이터를 집계하고 계산 수행

모든 asset에는 의존성이 있으며, 이것이 Bruin이 오케스트레이션에 사용하는 데이터 lineage를 만듭니다.

## 프로젝트 셋업

zoomcamp 템플릿으로 초기화:

```bash
bruin init zoomcamp my-taxi-pipeline
cd my-taxi-pipeline
```

프로젝트 구조:

```text
zoomcamp/
├── .bruin.yml
├── README.md
└── pipeline/
    ├── pipeline.yml
    └── assets/
        ├── ingestion/
        │   ├── trips.py
        │   ├── requirements.txt
        │   ├── payment_lookup.asset.yml
        │   └── payment_lookup.csv
        ├── staging/
        │   └── trips.sql
        └── reports/
            └── trips_report.sql
```

### .bruin.yml

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

```yaml
name: nyc_taxi
schedule: daily
start_date: "2022-01-01"
default_connections:
  duckdb: duckdb-default
variables:
  taxi_types:
    type: array
    items:
      type: string
    default: ["yellow"]
```

- `start_date`: full refresh로 실행할 때 이 날짜부터 데이터를 처리합니다
- 커스텀 변수: `taxi_types`로 어떤 taxi 유형을 수집할지(yellow, green, 또는 둘 다) 제어합니다
- 변수는 실행 시점에 `--var`로 덮어쓸 수 있습니다

## Ingestion 계층

### Python asset: trips.py

이 Python asset은 NYC taxi API에 접속해 데이터를 추출합니다.

```python
"""@bruin
name: ingestion.trips
type: python
image: python:3.11

materialization:
  type: table
  strategy: append

columns:
  - name: pickup_datetime
    type: timestamp
    description: "When the meter was engaged"
  - name: dropoff_datetime
    type: timestamp
    description: "When the meter was disengaged"
@bruin"""

import os
import json
import pandas as pd

def materialize():
    start_date = os.environ["BRUIN_START_DATE"]
    end_date = os.environ["BRUIN_END_DATE"]
    taxi_types = json.loads(os.environ["BRUIN_VARS"]).get("taxi_types", ["yellow"])

    # 시작일과 종료일 사이의 월 목록 생성
    # 다음 주소에서 parquet 파일 가져오기:
    # https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi_type}_tripdata_{year}-{month}.parquet

    return final_dataframe
```

- `materialize()`는 DataFrame을 반환하고, 목적지에 삽입하는 일은 Bruin이 처리합니다
- `append` 전략: 매 실행마다 기존 행은 건드리지 않고 데이터를 삽입합니다
- 시간 구간에는 `BRUIN_START_DATE` / `BRUIN_END_DATE` 환경 변수를 사용합니다
- `taxi_types` pipeline 변수는 `BRUIN_VARS`에서 읽습니다

### Seed 파일: payment_lookup.asset.yml

seed 파일은 로컬 CSV 파일의 데이터를 데이터베이스로 수집합니다.

```yaml
name: ingestion.payment_lookup
type: duckdb.seed
parameters:
  path: payment_lookup.csv
columns:
  - name: payment_type_id
    type: integer
    description: "Numeric code for payment type"
    primary_key: true
    checks:
      - name: not_null
      - name: unique
  - name: payment_type_name
    type: string
    description: "Human-readable payment type"
    checks:
      - name: not_null
```

payment_lookup.csv:

```csv
payment_type_id,payment_type_name
0,flex_fare
1,credit_card
2,cash
3,no_charge
4,dispute
5,unknown
6,voided_trip
```

품질 체크(`not_null`, `unique`)는 asset이 끝난 뒤 자동으로 실행됩니다.

### requirements.txt

```
pandas
requests
pyarrow
python-dateutil
```

Bruin이 환경을 관리하고 pipeline 안에서 로컬로 의존성을 설치합니다.

## Staging 계층

### SQL asset: staging/trips.sql

```sql
/* @bruin
name: staging.trips
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp

columns:
  - name: pickup_datetime
    type: timestamp
    primary_key: true
    checks:
      - name: not_null

custom_checks:
  - name: row_count_greater_than_zero
    query: |
      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
      FROM staging.trips
    value: 1
@bruin */

SELECT
    t.pickup_datetime,
    t.dropoff_datetime,
    t.pickup_location_id,
    t.dropoff_location_id,
    t.fare_amount,
    t.taxi_type,
    p.payment_type_name
FROM ingestion.trips t
LEFT JOIN ingestion.payment_lookup p
    ON t.payment_type = p.payment_type_id
WHERE t.pickup_datetime >= '{{ start_datetime }}'
  AND t.pickup_datetime < '{{ end_datetime }}'
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY t.pickup_datetime, t.dropoff_datetime,
                 t.pickup_location_id, t.dropoff_location_id, t.fare_amount
    ORDER BY t.pickup_datetime
) = 1
```

- `time_interval` 전략: 해당 시간 구간의 행을 삭제한 다음 쿼리 결과를 삽입합니다
- 중복을 피하려면 `WHERE` 절이 같은 시간 구간으로 필터링해야 합니다
- `QUALIFY ROW_NUMBER()`가 복합 키로 중복을 제거합니다
- `ingestion.trips`와 `ingestion.payment_lookup` 양쪽에 대한 의존성이 있어 수집이 끝난 뒤에 실행됩니다

## Reports 계층

### SQL asset: reports/trips_report.sql

```sql
/* @bruin
name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table
  strategy: time_interval
  incremental_key: trip_date
  time_granularity: date

columns:
  - name: trip_date
    type: date
    primary_key: true
  - name: taxi_type
    type: string
    primary_key: true
  - name: payment_type
    type: string
    primary_key: true
  - name: trip_count
    type: bigint
    checks:
      - name: non_negative
@bruin */

SELECT
    CAST(pickup_datetime AS DATE) AS trip_date,
    taxi_type,
    payment_type_name AS payment_type,
    COUNT(*) AS trip_count,
    SUM(fare_amount) AS total_fare,
    AVG(fare_amount) AS avg_fare
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
  AND pickup_datetime < '{{ end_datetime }}'
GROUP BY 1, 2, 3
```

## 전체 pipeline 실행하기

```bash
# 구조와 정의 검증
bruin validate ./pipeline/pipeline.yml

# 테스트용으로 짧은 날짜 범위로 실행
bruin run ./pipeline/pipeline.yml --start-date 2022-01-01 --end-date 2022-02-01

# full refresh
bruin run ./pipeline/pipeline.yml --full-refresh

# 결과 조회
bruin query --connection duckdb-default --query "SELECT COUNT(*) FROM ingestion.trips"
```

Bruin 패널에서 pipeline YAML 파일을 열고 lineage 탭을 보면 모든 asset과 그 의존성을 확인할 수 있습니다. 실행 순서:

1. ingestion asset이 먼저 실행됨 (trips + lookup, 병렬로)
2. 두 ingestion asset이 모두 끝나면 staging asset이 실행됨
3. staging이 끝나면 report asset이 실행됨

## Materialization 전략 요약

| 전략 | 동작 |
|----------|----------|
| `table` | 매번 테이블을 drop하고 다시 생성 |
| `append` | 기존 행은 건드리지 않고 새 데이터를 삽입 |
| `merge` | 키 컬럼 기준으로 upsert |
| `time_interval` | 날짜 범위의 행을 삭제한 뒤 다시 삽입 |
| `delete+insert` | 일치하는 행을 삭제한 뒤 삽입 |
| `create+replace` | 테이블을 생성하거나 교체 |
