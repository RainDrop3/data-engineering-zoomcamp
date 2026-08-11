# DE Zoomcamp 4.4.1 — dbt Models

> 📄 영상: [dbt Models](https://www.youtube.com/watch?v=JQYz-8sl1aQ)  
> 📄 공식 문서: [SQL models](https://docs.getdbt.com/docs/build/sql-models)  
> 📄 ref() 함수: [About ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)

staging은 끝났습니다. 여기서부터는 컴퓨터 앞에서 SQL만 타이핑하는 일이 아닙니다 — 실제로 **데이터를 탐색하고**, 그 안에 무엇이 있는지 이해하고, **비즈니스 맥락**을 얻어야 합니다. 실제 조직에서는 흔한 데이터 품질 이슈가 무엇인지, 정상적인 행은 어떻게 생겼는지 이해할 때까지 샅샅이 쿼리해보고, 코드값이 무엇을 뜻하는지 그리고 어떤 행이 언제 생기는지 사람들과 이야기하는 것을 뜻합니다. 그렇게 얻은 이해가 결국 SQL로 인코딩됩니다.

---

## 우리가 만들려는 것은?

코드를 쓰기 전에 최종 결과물이 어떤 모습이어야 하는지 생각해보면 도움이 됩니다. marts에는 보통 두 가지를 원합니다:

### 리포트와 대시보드
- 중요한 대시보드나 데이터 애플리케이션이 있다면 — 특히 수작업이나 스프레드시트 관리가 많이 필요한 것이라면 — dbt model이 되어야 한다는 신호입니다
- 예: **위치별 월 매출**이라는 데이터셋을 쓰는 대시보드가 있다고 상상해보세요. 제대로 만들고 버전 관리하고 싶은 대상입니다

### 차원 모델(Dimensional model)
- 리포트를 넘어서 제대로 된 **star schema**를 원합니다 — 데이터 웨어하우스에서 보게 되는 종류의 구조
- 알아야 할 두 가지 핵심 테이블 유형:
  - **Fact table** — 이벤트/프로세스당 한 행. trip당 한 행, 판매당 한 행, 주문당 한 행. `fct_` 접두사로 명명 (예: `fct_trips`)
  - **Dimension table** — 엔티티의 속성. `dim_` 접두사로 명명 (예: `dim_zones`. `dim_vendors`는 여기서 다루지 않음)
- 좋은 star schema의 힘: "몇 개인가?" 류의 질문에 답하는 게 사소해집니다. *zone이 몇 개인가?* → `dim_zones`에 `COUNT(*)`. *trip이 몇 개인가?* → `fct_trips`에 `COUNT(*)`. 단순하고 초점이 분명한 테이블들을 필요할 때 join하면 됩니다

### 이 강의에서 만들 것
- `dim_zones` — zone/위치 속성  
- `fct_trips` — trip당 한 행 (yellow + green 통합)
- zone별 월 매출 리포트 model (`models/core/` 폴더 안)

---

## source() vs ref() — 핵심 구분

강의에서 중요한 순간입니다. 지금까지는 raw 데이터를 가져오는 데 `{{ source() }}`를 썼습니다. 하지만 그건 sources YAML에 선언된 것들 — 즉 dbt 바깥에 있는 raw 테이블 — 에**만** 씁니다.

model의 입력이 **다른 dbt model**이라면 대신 `{{ ref() }}`를 씁니다.

- `{{ source('name', 'table') }}` → YAML에 정의된 raw 데이터
- `{{ ref('model_name') }}` → 다른 dbt model

> 📄 [ref() — full reference](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)

이 구분이 중요한 이유는 `ref()`가 내부적으로 유용한 일을 하나 더 하기 때문입니다: **의존성 그래프**를 자동으로 만들어 줍니다. model B가 model A를 ref하면 A가 먼저 실행되어야 한다는 걸 dbt가 압니다. 실행 순서를 직접 관리할 필요가 전혀 없습니다.

---

## intermediate 계층 — 왜 존재하는가

`fct_trips`가 yellow와 green trip 데이터의 union이 되기를 원합니다. 하지만 그 union을 fact model 안에서 직접 하면 지저분해집니다. 그래서 대신 **intermediate model**에 넣습니다 — raw도 아니고, 최종 사용자에게 노출할 준비도 안 된 것.

- 관례: intermediate model에는 `int_` 접두사  
- 이 경우: `int_trips_unioned.sql`
- 중간 작업을 marts 밖에 두자는 발상입니다. marts에는 소비 준비가 된 것만 있어야 합니다

```sql
with green_data as (
    select *, 
        'Green' as service_type 
    from {{ ref('stg_green_tripdata') }}
), 

yellow_data as (
    select *, 
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 

trips_unioned as (
    select * from green_data
    union all
    select * from yellow_data
)

select * from trips_unioned
```

---

## union 문제 — yellow와 green은 동일하지 않다

두 staging model을 union하려 하면 실패합니다. 에러: *set operation can only be applied with expressions with the same number of columns*. 알고 보니 green에는 yellow에 없는 **추가 컬럼 두 개**가 있습니다:

### `trip_type`
- 값은 `1` 또는 `2`
- `1` = 길거리 호출(street hail, 손 흔들어 택시를 잡는 것)
- `2` = 전화나 앱으로 예약
- yellow taxi는 **이 컬럼이 없습니다.** 법적으로 yellow taxi는 길거리에서 잡는 방법밖에 없기 때문입니다 — 항상 type 1입니다
- 해결: yellow staging model에 `trip_type`을 추가하고 `1`(street hail)로 하드코딩

### `ehail_fee` (e-hail 요금)
- 앱을 통해 택시를 요청할 때 적용될 수 있는 추가 요금
- 실제로는 이 데이터 대부분이 null입니다 — 기능이 vendor마다 일관되게 구현되어 있지 않습니다
- yellow taxi는 정의상 e-hail 요금이 **절대** 없습니다
- 해결: yellow staging model에 `ehail_fee`를 추가하고 `0`으로 하드코딩

```sql
-- green schema에 맞추기 위해 수정한 stg_yellow_tripdata.sql
with tripdata as (
  select *
  from {{ source('staging','yellow_tripdata') }}
  where vendorid is not null 
),

renamed as (
    select
        -- identifiers
        cast(vendorid as integer) as vendor_id,
        cast(ratecodeid as integer) as ratecode_id,
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,
        
        -- timestamps
        cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
        cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
        
        -- trip info
        store_and_fwd_flag,
        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,
        cast(1 as integer) as trip_type,  -- Yellow는 street-hail만 존재
        
        -- payment info
        cast(fare_amount as numeric) as fare_amount,
        cast(extra as numeric) as extra,
        cast(mta_tax as numeric) as mta_tax,
        cast(tip_amount as numeric) as tip_amount,
        cast(tolls_amount as numeric) as tolls_amount,
        cast(0 as numeric) as ehail_fee,  -- Yellow는 ehail이 없음
        cast(improvement_surcharge as numeric) as improvement_surcharge,
        cast(total_amount as numeric) as total_amount,
        cast(payment_type as integer) as payment_type,
    from tripdata
)

select * from renamed
```

참고: 이 컬럼들을 staging에서 바로 추가하는 것은 엄밀히 말하면 "1:1 복사" 규칙에서 벗어나는 일입니다. 여기서는 단순함을 위해 그렇게 했지만, 더 엄격한 프로젝트라면 intermediate 계층에서 처리했을 것입니다.

**schema를 맞춘 뒤의 union:**

```sql
-- models/staging/int_trips_unioned.sql
with green_data as (
    select *, 
        'Green' as service_type 
    from {{ ref('stg_green_tripdata') }}
), 

yellow_data as (
    select *, 
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 

trips_unioned as (
    select * from green_data
    union all
    select * from yellow_data
)

select * from trips_unioned
```

---

## 비즈니스 맥락이 중요한 이유

yellow와 green의 컬럼 불일치는 단순한 기술적 문제가 아니라 **비즈니스 이야기**입니다. yellow와 green taxi가 존재하는 이유는 NYC 택시 면허 제도 때문입니다: yellow cab은 Manhattan에 머물고, green cab은 외곽 자치구(outer borough) 사람들도 택시를 탈 수 있도록 만들어졌습니다. 그 맥락을 이해해야 `trip_type`과 `ehail_fee`를 어떻게 다룰지 — 기술적으로만이 아니라 의미적으로도 — 올바른 판단을 내릴 수 있습니다.

analytics engineering에서 단순히 SQL을 쓰는 단계를 넘어 데이터가 실제로 무엇을 나타내는지 이해하기 시작하는 지점이 바로 여기입니다.
