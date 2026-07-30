# Module 4 숙제: dbt로 하는 Analytics Engineering

이번 숙제에서는 `04-analytics-engineering/taxi_rides_ny/`의 dbt 프로젝트를 사용해 NYC taxi 데이터를 변환하고, 모델을 조회해서 문제에 답합니다.

## 설정

1. [설정 가이드](../../../04-analytics-engineering/setup/)에 따라 dbt 프로젝트를 설정하세요
2. 2019-2020년 Green/Yellow taxi 데이터와 2019년 FHV 운행 데이터를 여러분의 warehouse에 적재하세요 ([dtc github](https://github.com/DataTalksClub/nyc-tlc-data/)의 정적 테이블을 사용하세요. tlc의 공식 테이블은 값이 수시로 바뀌므로 사용하지 마세요)
3. `dbt build --target prod`를 실행해 모든 모델을 생성하고 테스트를 수행하세요

> **참고:** dbt는 기본적으로 `dev` 타깃을 사용합니다. 아래 숙제 쿼리를 위해서는 production 데이터셋에 모델을 빌드해야 하므로 반드시 `--target prod`를 사용해야 합니다.

빌드가 성공하면 warehouse에 `fct_trips`, `dim_zones`, `fct_monthly_zone_revenue` 같은 모델이 있어야 합니다.

---

### 질문 1. dbt Lineage와 실행

다음과 같은 구조의 dbt 프로젝트가 주어졌다고 합시다:

```
models/
├── staging/
│   ├── stg_green_tripdata.sql
│   └── stg_yellow_tripdata.sql
└── intermediate/
    └── int_trips_unioned.sql (depends on stg_green_tripdata & stg_yellow_tripdata)
```

`dbt run --select int_trips_unioned`를 실행하면 어떤 모델들이 빌드되나요?

- `stg_green_tripdata`, `stg_yellow_tripdata`, `int_trips_unioned` (upstream 의존성)
- `int_trips_unioned`에 대해 upstream과 downstream 의존성을 가진 모든 모델
- `int_trips_unioned`만
- `int_trips_unioned`, `int_trips`, `fct_trips` (downstream 의존성)

---

### 질문 2. dbt 테스트

`schema.yml`에 다음과 같이 generic 테스트를 설정했다고 합시다:

```yaml
columns:
  - name: payment_type
    data_tests:
      - accepted_values:
          arguments:
            values: [1, 2, 3, 4, 5]
            quote: false
```

여러분의 모델 `fct_trips`는 몇 달째 성공적으로 실행되어 왔습니다. 그런데 소스 데이터에 새로운 값 `6`이 나타났습니다.

`dbt test --select fct_trips`를 실행하면 어떻게 되나요?

- 모델이 변경되지 않았으므로 dbt가 테스트를 건너뜁니다
- dbt가 테스트를 실패 처리하고 0이 아닌 종료 코드를 반환합니다
- dbt가 새로운 값에 대한 경고와 함께 테스트를 통과시킵니다
- dbt가 새로운 값을 포함하도록 설정을 업데이트합니다

---

### 질문 3. `fct_monthly_zone_revenue`의 레코드 개수 세기

dbt 프로젝트를 실행한 뒤 `fct_monthly_zone_revenue` 모델을 조회하세요.

`fct_monthly_zone_revenue` 모델의 레코드 개수는 몇 개인가요?

- 12,998
- 14,120
- 12,184
- 15,421

---

### 질문 4. Green Taxi 최고 실적 zone (2020년)

`fct_monthly_zone_revenue` 테이블을 사용해, 2020년 **Green** taxi 운행에서 **총 매출**(`revenue_monthly_total_amount`)이 가장 높았던 승차 zone을 찾으세요.

매출이 가장 높았던 zone은 어디인가요?

- East Harlem North
- Morningside Heights
- East Harlem South
- Washington Heights South

---

### 질문 5. Green Taxi 운행 횟수 (2019년 10월)

`fct_monthly_zone_revenue` 테이블을 사용할 때, 2019년 10월 Green taxi의 **총 운행 횟수**(`total_monthly_trips`)는 몇 건인가요?

- 500,234
- 350,891
- 384,624
- 421,509

---

### 질문 6. FHV 데이터용 staging 모델 만들기

2019년 **For-Hire Vehicle (FHV)** 운행 데이터를 위한 staging 모델을 만드세요.

1. [2019년 FHV 운행 데이터](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)를 data warehouse에 적재하세요
2. 다음 요구사항을 만족하는 staging 모델 `stg_fhv_tripdata`를 만드세요:
   - `dispatching_base_num IS NULL`인 레코드는 걸러내기
   - 프로젝트의 명명 규칙에 맞게 필드 이름 변경하기 (예: `PUlocationID` → `pickup_location_id`)

`stg_fhv_tripdata`의 레코드 개수는 몇 개인가요?

- 42,084,899
- 43,244,693
- 22,998,722
- 44,112,187

---

## 풀이 제출하기

- 제출 폼: <https://courses.datatalks.club/de-zoomcamp-2026/homework/hw4>

=======

## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

### LinkedIn 게시물 예시

```
🚀 Week 4 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 4 - Analytics Engineering with dbt. Learned how to:

✅ Build transformation models with dbt
✅ Create staging, intermediate, and fact tables
✅ Write tests to ensure data quality
✅ Understand lineage and model dependencies
✅ Analyze revenue patterns across NYC zones

Transforming raw data into analytics-ready models - the T in ELT!

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시

```
📈 Module 4 of Data Engineering Zoomcamp done!

- Analytics Engineering with dbt
- Transformation models & tests
- Data lineage & dependencies
- NYC taxi revenue analysis

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
