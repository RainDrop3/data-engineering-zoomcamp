# DE Zoomcamp 4.5.2 — dbt Tests

> 📄 영상: [dbt Tests](https://www.youtube.com/watch?v=bvZ-rJm7uMU)  
> 📄 공식 문서: [Data tests](https://docs.getdbt.com/docs/build/data-tests) | [Unit tests](https://docs.getdbt.com/docs/build/unit-tests) | [Model contracts](https://docs.getdbt.com/docs/mesh/govern/model-contracts)

대시보드의 잘못된 KPI, 리포트의 이상한 숫자 — 원인은 사실 둘뿐입니다: 기반 데이터가 예상과 달랐거나, SQL을 잘못 짰거나. analytics engineer로서 둘 중 무엇인지 구분할 수 없다면, 엄밀히 말해 둘 다 여러분 잘못입니다. test는 이것을 선제적으로 관리하는 수단입니다. dbt는 꽤 큰 테스트 옵션 묶음을 제공하고, 이 영상은 그 전부를 훑습니다.

---

## 1. Singular test

가장 단순한 종류의 테스트입니다. 평범한 SQL 쿼리를 작성해 `tests/` 디렉토리에 넣으면 끝 — 그게 테스트가 됩니다.

로직은 직관적입니다: **쿼리가 행을 하나라도 반환하면 테스트 실패.** "나쁜" 경우를 select하는 쿼리를 쓰는 것이죠. 0개 행이 돌아오면 모두 정상이라는 뜻입니다.

```sql
-- tests/assert_positive_fare_amount.sql
-- Fare amounts should always be positive

select
    tripid,
    fare_amount
from {{ ref('fct_trips') }}
where fare_amount <= 0
```

조직에 매우 특수한 일회성 비즈니스 규칙에 좋습니다 — 어떤 generic test도 기본으로 다뤄주지 않을 종류의 것들이죠.

> 📄 [Singular data tests — docs](https://docs.getdbt.com/docs/build/data-tests#singular-data-tests)

---

## 2. Source freshness test

이것은 별도 파일이 아니라 source YAML 안에 들어갑니다. source에 `freshness` 블록을 추가하고 어떤 컬럼이 데이터가 마지막으로 적재된 시점을 나타내는지 dbt에게 알려줍니다. 그다음 `dbt source freshness`를 실행하면 그 timestamp가 충분히 최근인지 dbt가 검사합니다.

`warn_after`와 `error_after` 임계값을 둘 다 설정할 수 있습니다 — 하나는 경고용, 하나는 실제 실패용.

```yaml
version: 2

sources:
  - name: staging
    database: production
    schema: trips_data_all
    tables:
      - name: green_tripdata
        loaded_at_field: lpep_pickup_datetime
        freshness:
          warn_after: {count: 6, period: hour}
          error_after: {count: 12, period: hour}
      
      - name: yellow_tripdata
        loaded_at_field: tpep_pickup_datetime
        freshness:
          warn_after: {count: 6, period: hour}
          error_after: {count: 12, period: hour}
```

어디서나 보이는 것은 아니지만, 데이터가 오래되면 실제 문제가 생기는 파이프라인에서는 생명줄입니다.

> 📄 [Source freshness — docs](https://docs.getdbt.com/reference/resource-properties/freshness)

---

## 3. Generic test

이것이 핵심입니다 — dbt 프로젝트에서 가장 흔히 보게 될 테스트 유형입니다. generic test는 컬럼 description 바로 옆 YAML에 정의합니다. 파라미터화되어 있고 재사용 가능해서, 로직을 한 번 쓰고 필요한 만큼 여러 컬럼과 model에 적용합니다.

### 내장된 네 가지 generic test

dbt는 정확히 네 개를 제공합니다:

- **unique** — 이 컬럼에 중복 값 없음
- **not_null** — null 허용 안 함
- **accepted_values** — 컬럼 값이 정의된 목록 안에 있어야 함
- **relationships** — 이 컬럼의 모든 값이 다른 model에 존재해야 함 (참조 무결성)

```yaml
version: 2

models:
  - name: stg_green_tripdata
    description: Staged green taxi data
    columns:
      - name: tripid
        description: Primary key for trips
        tests:
          - unique
          - not_null
      
      - name: vendorid
        tests:
          - not_null
      
      - name: payment_type
        description: Payment method code
        tests:
          - accepted_values:
              values: [1, 2, 3, 4, 5, 6]
      
      - name: pickup_locationid
        description: Taxi zone where trip started
        tests:
          - relationships:
              to: ref('taxi_zone_lookup')
              field: locationid
```

> 📄 [Generic data tests — docs](https://docs.getdbt.com/docs/build/data-tests#generic-data-tests)

### 직접 custom generic test 작성하기

네 개로는 모든 것을 다룰 수 없습니다. 직접 작성할 수 있습니다 — `tests/generic/`에 두는 SQL 파일입니다. 문법은 Jinja test 블록을 쓰고, dbt가 이를 인식해 내장 test처럼 쓸 수 있게 해줍니다.

```sql
-- tests/generic/test_positive_values.sql
{% test positive_values(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
```

**schema.yml에서의 사용:**
```yaml
models:
  - name: fct_trips
    columns:
      - name: fare_amount
        tests:
          - positive_values
      
      - name: trip_distance
        tests:
          - positive_values
```

그리고 한 가지 — 생각보다 custom test를 많이 쓸 필요는 없을 겁니다. dbt 커뮤니티가 이미 오픈소스 package(dbt-utils, dbt-expectations 등)에 엄청나게 많이 만들어 두었습니다. 직접 만들기 전에 확인해볼 만합니다.

> 📄 [Writing custom generic tests — docs](https://docs.getdbt.com/best-practices/writing-custom-generic-tests)

---

## 4. Unit test

dbt v1.8부터 사용 가능합니다(2024년 중반 출시). unit test는 실제 데이터로 웨어하우스를 건드리지 않고 SQL 로직을 고립된 상태로 테스트하게 해줍니다.

발상은 이렇습니다: 작은 mock 입력 행 묶음과 기대 출력 행을 정의합니다. dbt가 그 mock에 대해 model의 SQL을 실행하고 출력이 명시한 것과 일치하는지 검사합니다. 복잡한 로직 — rolling window, 정규식, 엣지 케이스 — 에 특히 편리합니다. 실제 데이터에 아직 나타나지도 않은 시나리오를 테스트할 수 있기 때문입니다.

```yaml
version: 2

unit_tests:
  - name: test_payment_type_mapping
    description: Test that payment type codes map to correct descriptions
    model: stg_green_tripdata
    given:
      - input: source('staging', 'green_tripdata')
        rows:
          - {tripid: '1', payment_type: 1}
          - {tripid: '2', payment_type: 2}
          - {tripid: '3', payment_type: 5}
    expect:
      rows:
        - {tripid: '1', payment_type_description: 'Credit card'}
        - {tripid: '2', payment_type_description: 'Cash'}
        - {tripid: '3', payment_type_description: 'Unknown'}
```

unit test는 `models/` 디렉토리의 YAML에 정의하며, 현재는 SQL model만 지원합니다. 입력이 정적이므로 프로덕션에서 돌릴 이유가 없습니다 — 개발과 CI에서 사용하세요.

2026년 초 기준으로 unit test는 약 18개월간 제공되어 왔고, 특히 변환 로직이 복잡하거나 데이터 품질 요구가 엄격한 팀에서 채택이 늘고 있습니다. 로직 오류가 프로덕션 데이터에 닿기 전에 잡고 싶은 CI/CD 파이프라인에서 특히 유용합니다.

> 📄 [Unit tests — docs](https://docs.getdbt.com/docs/build/unit-tests)

---

## 5. Model contract

이 영상에서 다루는 마지막 유형이고, 다른 것들과 조금 다릅니다. model contract는 나쁜 데이터를 사후에 잡아내는 것이 아니라, 정의된 형태와 맞지 않으면 **애초에 model이 빌드되지 않게 막는** 것입니다.

기대하는 컬럼, 데이터 타입, 그리고 선택적으로 제약 조건을 YAML에 정의합니다. 그다음 model의 config에서 `contract: enforced: true`를 켭니다. 그때부터 model의 출력이 맞지 않으면 — 잘못된 컬럼명, 잘못된 타입, 누락된 컬럼 — dbt가 아무것도 materialize하기 전에 에러를 냅니다.

```yaml
version: 2

models:
  - name: fct_trips
    config:
      contract:
        enforced: true
    columns:
      - name: tripid
        data_type: string
        constraints:
          - type: not_null
          - type: unique
      
      - name: pickup_datetime
        data_type: timestamp
        constraints:
          - type: not_null
      
      - name: service_type
        data_type: string
      
      - name: total_amount
        data_type: numeric
```

이 발상은 **data contract** 개념에서 왔습니다 — 이해관계자와 마주 앉아 출력 데이터셋이 어떤 모습이어야 하는지(컬럼명, 타입, freshness 기대치) 합의하고, contract가 그 합의를 자동으로 강제합니다. 누군가 그것을 깨는 방식으로 model을 바꾸면 즉시 알게 됩니다.

> 📄 [Model contracts — docs](https://docs.getdbt.com/docs/mesh/govern/model-contracts)
