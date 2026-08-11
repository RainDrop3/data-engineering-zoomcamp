# DE Zoomcamp 4.4.2 — dbt Seeds와 Macros

> 📄 영상: [dbt Seeds and Macros](https://www.youtube.com/watch?v=lT4fmTDEqVk)  
> 📄 Seeds 문서: [Seeds](https://docs.getdbt.com/docs/build/seeds)  
> 📄 Macros 문서: [Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros)

union model은 끝났지만, 지금 vendor ID와 location ID는 그저 숫자 — 의미 없는 코드값일 뿐입니다. 이 영상은 그 데이터를 풍부하게 만드는 방법을 다룹니다. 두 가지 dbt 기능이 등장합니다: lookup 데이터를 들여오는 **seed**, 그리고 재사용 가능한 SQL 로직을 여기저기 복붙하지 않아도 되게 만드는 **macro**.

---

## 문제 — 사방이 코드값

`vendor_id`를 조회하면 1과 2라는 값이 나옵니다. 이들은 실제 회사에 대응합니다:
- **1** → Creative Mobile Technologies
- **2** → VeriFone Inc.

위치도 마찬가지입니다 — 이름, borough, 좌표 등을 가질 수 있는 265개의 location ID. raw 데이터에는 그런 정보가 전혀 없습니다. 그럼 어떻게 추가할까요?

---

## Seeds — lookup 데이터 들여오기

### seed란
- **CSV 파일을 업로드**해 dbt model로 쓸 수 있게 만드는 방법
- CSV를 `seeds/` 디렉토리에 넣고 `dbt seed`를 실행하면, 다른 model과 똑같이 조회 가능해집니다
- `{{ ref('filename') }}`으로 참조합니다 — 다른 model과 동일합니다

### 언제 쓰는가
- 아직 웨어하우스 어디에도 없는 **lookup table**
- 데이터를 제대로 적재할 쓰기 권한이 없는 경우
- 제대로 된 적재를 확정하기 전의 빠른 실험이나 로컬 테스트
- 작고 정적인 데이터셋

### 언제 쓰면 안 되는가
- **기밀 데이터는 절대 커밋하지 마세요** — seed는 git 저장소에 들어갑니다
- 데이터를 **작게** 유지하세요 — git에 큰 CSV가 있으면 pull과 push가 느려집니다
- 소스에서 제대로 적재할 수 있다면 그렇게 하세요. seed는 빠르고 거친 우회책입니다

> 📄 [Seeds — full reference](https://docs.getdbt.com/docs/build/seeds)

---

## dim_zones — seed를 실제로 사용하기

taxi zone lookup CSV에는 필요한 것이 정확히 들어 있습니다: location ID, borough, zone 이름, service area. `seeds/`에 넣고 `dbt seed`를 실행하면 바로 쓸 수 있습니다.

이제 `dim_zones`를 만듭니다. model은 단순히 seed에서 select하고 컬럼 이름을 더 깔끔하게 바꿉니다.

```sql
select
    locationid as location_id,
    borough,
    zone,
    service_zone
from {{ ref('taxi_zone_lookup') }}
```

이걸로 끝 — 첫 번째 dimension table 완성입니다. 무거운 일은 seed가 해줬습니다.

---

## dim_vendors — CASE WHEN 문제 (이 프로젝트에서 구현하지는 않지만 학습용으로 보여줌)

vendor의 경우, intermediate union model에서 `ref()`로 distinct `vendor_id`를 뽑아올 수 있습니다. 충분히 쉽습니다. 하지만 vendor **이름**으로 데이터를 풍부하게 만들고 싶습니다.

### 순진한 접근: CASE WHEN
그냥 인라인으로 쓸 수도 있습니다:

```sql
with vendors as (
    select distinct vendorid
    from {{ ref('stg_green_tripdata') }}
)

select
    vendorid,
    case 
        when vendorid = 1 then 'Creative Mobile Technologies, LLC'
        when vendorid = 2 then 'VeriFone Inc.'
        else 'Unknown'
    end as vendor_name
from vendors
```

동작은 합니다. 하지만 진짜 문제가 있습니다: **새 vendor가 생기거나 vendor가 이름을 바꾸면 어떻게 될까요?** 이 파일을 열어 CASE 블록을 찾아 줄을 하나 더 추가해야 합니다. 그리고 프로젝트의 다른 곳에서 같은 매핑이 필요하면 전체를 복붙하게 됩니다. 결국 누군가는 복사본 중 하나를 갱신하는 걸 잊습니다.

### 더 나은 접근: macro

macro가 dbt의 답입니다. **재사용 가능한 SQL 함수**라고 생각하세요 — Python 함수와 같은 발상이지만 SQL 조각을 위한 것입니다.

> 📄 [Jinja and macros — full reference](https://docs.getdbt.com/docs/build/jinja-macros)

### macro의 동작 방식
- `macros/` 디렉토리 안의 `.sql` 파일에 정의합니다
- SQL 로직을 `{% macro macro_name(argument) %}` ... `{% endmacro %}`로 감쌉니다
- 인자는 함수 파라미터와 똑같이 동작합니다 — 호출할 때 값을 전달합니다
- model에서 `{{ macro_name(argument) }}`로 호출합니다
- dbt가 컴파일해서 펼칩니다 — 최종 SQL은 CASE 블록을 인라인으로 직접 쓴 것과 똑같지만, 소스 코드는 깔끔하게 유지됩니다

```sql
{% macro get_vendor_data(vendor_id_column) %}

{% set vendors = {
    1: 'Creative Mobile Technologies',
    2: 'VeriFone Inc.',
    4: 'Unknown/Other'
} %}

case {{ vendor_id_column }}
    {% for vendor_id, vendor_name in vendors.items() %}
    when {{ vendor_id }} then '{{ vendor_name }}'
    {% endfor %}
end

{% endmacro %}

```

**model에서 macro 사용하기:**

```sql
with trips as (
    select * from {{ ref('fct_trips') }}
),

vendors as (
    select distinct
        vendor_id,
        {{ get_vendor_data('vendor_id') }} as vendor_name
    from trips
)

select * from vendors
```

### 이게 더 나은 이유
- **재사용 가능** — 같은 payment type 로직이 다른 곳에도 필요한가요? macro를 다시 호출하면 됩니다
- **단일 진실 공급원(Single source of truth)** — payment type이 바뀌었나요? macro 한 곳만 갱신하면 어디서나 고쳐집니다
- **테스트 가능** — 로직이 자기 파일에 고립되어 있어 파악하기 쉽습니다

---

## 숙제 미리보기 — fct_trips

fact trips model은 연습 과제로 남겨둡니다. 기대되는 내용은 다음과 같습니다:

- **trip당 한 행** — yellow와 green 통합 (union은 intermediate model에서 이미 완료)
- **기본 키 추가** (`trip_id`) — **고유해야** 합니다
- **중복 찾아 고치기** — 이 데이터셋에는 중복이 꽤 있습니다. 일부는 소스에서 오고, 일부는 union 과정에서 생깁니다. 찾아내고, 왜 생기는지 이해하고, 고치세요
- **`payment_type` 풍부하게 만들기** (저장소에 이를 위한 seed가 있습니다).
