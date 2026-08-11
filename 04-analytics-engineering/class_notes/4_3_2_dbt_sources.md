# DE Zoomcamp 4.3.2 — dbt Sources

> 📄 영상: [dbt Sources](https://www.youtube.com/watch?v=7CrrXazV_8k)  
> 📄 공식 문서: [Sources](https://docs.getdbt.com/docs/build/sources)  
> 📄 모범 사례: [How we structure our dbt projects — Staging](https://docs.getdbt.com/best-practices/how-we-structure/03-staging)

이 영상은 raw 데이터가 실제로 어디에 있는지 dbt에게 알려주는 방법을 다룹니다. source는 변환이 일어나기 전에 어떤 테이블에서 데이터를 가져올지 dbt가 아는 수단입니다. 이 영상의 모든 내용은 4.3.1에서 셋업한 `models/staging/` 폴더 안에서 이뤄집니다.

---

## Source 정의하기

### `sources.yml`
- raw 데이터가 어디에 있는지 dbt에게 알려주는 `models/staging/` 안의 **YAML 파일**
- 파일 **이름**은 임의입니다 — 흔한 선택은 `sources.yml`, `_sources.yml`(맨 위로 정렬되도록 밑줄), 또는 출처를 딴 `bigquery_sources.yml` 같은 이름입니다
- source에 **name**을 붙이는데 이것도 임의입니다. 라벨이라고 생각하세요: `raw`, `raw_data`, 또는 `google_analytics_data`나 `finance_data`처럼 더 서술적인 이름
- 그다음 임의가 **아닌** 세 필드를 제공합니다 — 웨어하우스와 정확히 일치해야 합니다:
  - **database** — 데이터베이스 이름 또는 GCP 프로젝트
  - **schema** — 해당 데이터베이스 안의 schema 또는 BigQuery dataset
  - **tables** — 참조하려는 개별 테이블들

```yaml
sources:
  - name: nytaxi
    database: taxi_rides_ny # 또는 여러분의 GCP 프로젝트 이름
    schema: prod # 또는 여러분의 BigQuery dataset 이름
    
    tables:
      - name: green_tripdata
      - name: yellow_tripdata
```

> 📄 [Sources — full reference](https://docs.getdbt.com/docs/build/sources)

### 로컬(DuckDB) vs BigQuery — 무엇이 어디에 들어가는가

database, schema, tables의 의미는 셋업에 따라 달라집니다:

| 필드 | 로컬 (DuckDB) | BigQuery |
|---|---|---|
| **database** | `taxi_rides_ny` | 여러분의 GCP Project ID |
| **schema** | `main` | 여러분의 BigQuery Dataset 이름 (예: `trips_data_all`) |
| **tables** | `green_tripdata`, `yellow_tripdata` | 동일한 테이블 이름 |

- 기본 로컬 셋업을 따랐다면 이 이름들은 그대로 정확할 것입니다
- BigQuery를 쓴다면 테이블 이름이 실제 dataset에 있는 것과 맞는지 한 번 더 확인하세요

---

## Model에서 Source 사용하기

### `source()` 함수
- 테이블의 전체 경로를 하드코딩하는 대신(예: `FROM production.trips_data_all.green_tripdata`) **`source()`** 함수를 사용합니다
- **Jinja macro**입니다 — 이중 중괄호 `{{ }}`로 알아볼 수 있습니다
- 두 개의 인자를 받습니다:
  - **source 이름** — YAML에 정의한 것 (예: `staging`)
  - **테이블 이름** — YAML의 `tables` 아래에 넣은 것과 정확히 일치해야 함
- 프로젝트 어딘가에 일치하는 source 선언이 담긴 YAML 파일이 있으면 컴파일 시점에 올바르게 해석됩니다

```sql
select * from {{ source('staging', 'green_tripdata') }}
```

- preview를 실행하면 raw 테이블 데이터가 돌아오는 것을 볼 수 있습니다
- 이게 동작한다면 기반이 갖춰진 것입니다 — 나머지 모든 것이 이 위에 쌓입니다

---

## 제대로 된 Staging Model 만들기

### 명명 규칙
- staging model 파일명 앞에 **`stg_`**를 붙여 어느 계층에 속하는지 분명히 하세요
- 그래서 `green_tripdata.sql`은 `stg_green_tripdata.sql`이 됩니다
- 다른 흔한 접두사: intermediate는 `int_`, 최종 mart model은 아무것도 안 붙이기도 합니다

### 컬럼 이름 바꾸고 순서 정리하기
- 모든 컬럼을 명시적으로 나열하고 **더 깔끔한 alias**를 부여하세요
- **순서**에 의도를 담으세요 — 논리적인 묶음을 따라야 합니다:
  - **식별자 먼저** — `vendor_id`, `trip_id` 등 ID인 것들
  - **timestamp 다음** — `pickup_datetime`, `dropoff_datetime`
  - **trip 상세** — `passenger_count`, `trip_distance`, `trip_type`
  - **결제 정보 마지막** — `fare_amount`, `extra`, `mta_tax`, `tip_amount`, `tolls_amount`, `total_amount`, `payment_type`

### 데이터 타입을 명시적으로 cast하기
- source가 준 타입에 의존하지 말고, 실제로 원하는 타입으로 전부 cast하세요:
  - ID → `integer`
  - Timestamp → `timestamp`
  - 개수(Count) → `integer`
  - 금액 → `numeric` 또는 `float` (플랫폼에 따라 다름)

```sql
with tripdata as (
  select *
  from {{ source('staging','green_tripdata') }}
  where vendorid is not null 
),

renamed as (
  select
      -- identifiers
      cast(vendorid as integer) as vendorid,
      cast(ratecodeid as integer) as ratecodeid,
      cast(pulocationid as integer) as pickup_locationid,
      cast(dolocationid as integer) as dropoff_locationid,
      
      -- timestamps
      cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
      cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,
      
      -- trip info
      store_and_fwd_flag,
      cast(passenger_count as integer) as passenger_count,
      cast(trip_distance as numeric) as trip_distance,
      cast(trip_type as integer) as trip_type,
      
      -- payment info
      cast(fare_amount as numeric) as fare_amount,
      cast(extra as numeric) as extra,
      cast(mta_tax as numeric) as mta_tax,
      cast(tip_amount as numeric) as tip_amount,
      cast(tolls_amount as numeric) as tolls_amount,
      cast(ehail_fee as numeric) as ehail_fee,
      cast(improvement_surcharge as numeric) as improvement_surcharge,
      cast(total_amount as numeric) as total_amount,
      cast(payment_type as integer) as payment_type,
      {{ get_payment_type_description('payment_type') }} as payment_type_description
  from tripdata
)

select * from renamed
```

---

## 필터링에 대한 한마디

- 일반적인 권장은 staging model을 source의 **1:1 복사본**으로 유지하는 것입니다 — 같은 행 수, 같은 컬럼 수, 정리만 된 상태
- 다만 이 데이터셋에는 데이터 품질 이슈가 몇 가지 있어서(나중에 다룹니다), **`vendor_id IS NULL`**인 행을 여기 staging에서 걸러내는 것이 합리적입니다
- 관례에서 벗어나는 것이지만, 이 프로젝트에서는 실용적인 선택입니다

---

## 연습 과제

**yellow tripdata** 테이블에 대해 같은 작업을 하세요. 컬럼이 green과 거의 동일하므로 그리 고통스럽지 않을 것입니다. 끝나면 다음이 갖춰져 있어야 합니다:
- 두 테이블을 선언한 `sources.yml`
- `stg_green_tripdata.sql` staging model
- `stg_yellow_tripdata.sql` staging model
