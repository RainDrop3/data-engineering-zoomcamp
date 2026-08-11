# SQL 복습

### 목차


- [Window Functions](#window-funtions)
    - [Row Number](#row-number)
    - [Rank and Dense Rank](#rank-and-dense-rank)    
    - [Lag and Lead](#lag-and-lead)   
    - [Percentile Cont](#percentile-cont)         
- [Common Table Expression](#common-table-expression)
- [dbt models and CTEs](#dbt-models-and-ctes)



## Window Functions    

window function은 특정 "window", 즉 데이터의 부분집합 안에서 현재 행과 관련된 테이블 행들의 집합에 걸쳐 계산을 수행합니다. 집계 함수(SUM(), AVG(), COUNT() 등)로 할 수 있는 계산과 비슷합니다.

하지만 일반적인 집계 함수와 달리, window function을 쓴다고 해서 행들이 하나의 출력 행으로 묶이지 않습니다 — 각 행은 개별 정체성을 유지합니다.


**문법:**

```sql
FUNCTION() OVER (PARTITION BY column_name ORDER BY column_name)
```

window function은 항상 두 개의 구성 요소를 가집니다. 여기 두 번째 부분이 window를 정의합니다:

```sql
OVER (PARTITION BY column_name ORDER BY column_name)
```

여기서 window란 함수를 적용할 때 데이터를 어떤 시각으로 바라볼 것인가를 뜻합니다.

- PARTITION BY: 결과 집합을 그룹으로 나눕니다 (선택).

- ORDER BY: 파티션 안에서 행을 처리하는 순서를 정의합니다.


**흔한 Window Function들:**

순위 함수(Ranking Functions):

- ROW_NUMBER(): 파티션 안에서 고유한 행 번호를 부여합니다.
- RANK(): ROW_NUMBER()와 비슷하지만, 중복 값에는 같은 순위를 주고 번호를 건너뜁니다.
- DENSE_RANK(): RANK()와 비슷하지만 번호에 빈틈이 생기지 않습니다.

Window Function으로 쓰는 집계 함수:

- SUM() OVER(): 누적 합계를 계산합니다.
- AVG() OVER(): 이동 평균을 계산합니다.

Lag와 Lead 함수:

- LAG(): 이전 행의 값을 가져옵니다.
- LEAD(): 다음 행의 값을 가져옵니다.

### Row Number

ROW_NUMBER()는 이름 그대로의 일을 합니다 — 주어진 행의 번호를 보여줍니다. 1부터 시작해 window 문의 ORDER BY 부분에 따라 행에 번호를 매깁니다. PARTITION BY 절을 쓰면 각 파티션마다 다시 1부터 세기 시작합니다.

**문법:**

```sql
ROW_NUMBER() OVER (PARTITION BY column_name ORDER BY column_name)
```

**흔한 용도:**

- 중복 제거: ROW_NUMBER()로 중복 행을 식별하고, 행 번호가 1보다 큰 행을 걸러내 하나만 남길 수 있습니다.

- 데이터 순위 매기기: 특정 기준으로 행에 순위를 매기되 고유한 행 번호가 필요할 때 사용합니다.

- 최신 레코드 선택: PARTITION BY와 조합하면 카테고리별 가장 최근 항목을 고르는 데 도움이 됩니다.

**예제 1:**

```sql

SELECT 
  total_amount,
  ROW_NUMBER() OVER (ORDER BY total_amount DESC) AS ranking

FROM `greentaxi_trips` 
LIMIT 10;

```

이 쿼리는 테이블에서 total_amount가 가장 높은 상위 10개 값을 순위를 나타내는 행 번호와 함께 반환합니다.


| total_amount | ranking |
|--------|--------|
| 4012.3 | 1      |
| 2878.3 | 2      |
| 2438.8 | 3      |
| 2156.3 | 4      |
| 2109.8 | 5      |
| 2017.3 | 6      |
| 1971.05| 7      |
| 1958.8 | 8      |
| 1762.8 | 9      |
| 1600.8 | 10     |

ROW_NUMBER()로 생성된 컬럼은 임시이며 원본 테이블을 수정하지 않습니다. 쿼리 결과의 데이터에 적용된 계산일 뿐입니다.

**예제 2:**

앞의 쿼리를 수정해 pick up location ID로 파티션을 추가해 봅시다.

```sql

SELECT 

  total_amount,
  PULocationID,
  ROW_NUMBER() OVER (PARTITION BY PULocationID ORDER BY total_amount DESC) AS ranking

FROM `greentaxi_trips` 
LIMIT 10;

```

이 SQL 쿼리는 각 PULocationID 그룹 안에서 total_amount 내림차순을 기준으로 각 행에 순위를 부여합니다:

| total_amount | PULocationID | ranking |
|-----------|-----------|-----------|
| 8.51      | 224       | 432       |
| 8.3       | 224       | 433       |
| 8.3       | 224       | 434       |
| 7.3       | 224       | 435       |
| 3.3       | 224       | 436       |
| 86.42     | 234       | 1         |
| 73.5      | 234       | 2         |
| 62.7      | 234       | 3         |
| 61.94     | 234       | 4         |
| 61.94     | 234       | 5         |

PARTITION BY 절을 쓰면 각 파티션마다 다시 1부터 세기 시작합니다.

### Rank and Dense Rank

ROW_NUMBER(), RANK(), DENSE_RANK()는 지정된 순서를 기준으로 행에 순위를 부여하는 window function입니다. 다만 순위를 매기는 컬럼에 중복 값이 있을 때 서로 다르게 동작합니다.

RANK()는 순위를 부여하되 동점이 있으면 번호를 건너뜁니다. DENSE_RANK()는 RANK()와 비슷하지만 동점이 있어도 번호를 건너뛰지 않습니다.

예를 들어:

| Score | ROW_NUMBER() | RANK() | DENSE_RANK() |
|-------|--------------|--------|--------------|
| 95    | 1            | 1      | 1            |
| 90    | 2            | 2      | 2            |
| 90    | 3            | 2      | 2            |
| 85    | 4            | 4      | 3            |


### Lag and Lead

행을 앞이나 뒤의 행과 비교하는 것이 유용할 때가 많습니다. LAG나 LEAD를 쓰면 self-join 없이 다른 행에서 값을 끌어오는 컬럼을 만들 수 있습니다. 어느 컬럼에서 가져올지, 몇 행 떨어진 곳에서 가져올지만 지정하면 됩니다. LAG는 이전 행에서, LEAD는 다음 행에서 가져옵니다.


**문법:**

```sql

LAG(expression) OVER (PARTITION BY partition_expression ORDER BY order_expression)
```

- expression: 이전 행에서 값을 가져오고 싶은 컬럼
- offset (선택): 현재 행에서 몇 행 뒤를 볼지. 기본값은 1이며 바로 이전 행을 봅니다.
- PARTITION BY (선택): 결과 집합을 파티션으로 나눠 각 파티션에 함수를 개별 적용합니다.
- ORDER BY: 행이 처리되는 순서를 지정합니다.

**예제:**

```sql

SELECT 

lpep_pickup_datetime,
total_amount,
LAG(total_amount) OVER (ORDER BY lpep_pickup_datetime) as prev_total_amount,
LEAD(total_amount) OVER (ORDER BY lpep_pickup_datetime) as next_total_amount

FROM `greentaxi_trips` 
ORDER BY lpep_pickup_datetime

```

이 쿼리는 lpep_pickup_datetime, total_amount, 이전 trip의 total_amount, 다음 trip의 total_amount를 가져옵니다.

| lpep_pickup_datetime      | total_amount | prev_total_amount | next_total_amount |
|---------------------------|--------------|-------------------|-------------------|
| 2008-12-31 23:33:38 UTC   | 7.3          | 6.3               | 5.3               |
| 2008-12-31 23:42:31 UTC   | 5.3          | 7.3               | 14.55             |
| 2008-12-31 23:47:51 UTC   | 14.55        | 5.3               | 19.55             |
| 2008-12-31 23:57:46 UTC   | 19.55        | 14.55             | 9.8               |
| 2009-01-01 00:00:00 UTC   | 9.8          | 19.55             | 81.3              |


### Percentile Cont

value_expression에 대해 지정된 백분위수 값을 선형 보간으로 계산합니다.

**문법:**

```sql

PERCENTILE_CONT(value_expression, percentile ) OVER (PARTITION BY partition_expression)
```

**예제:**

각 고유한 pickup location(PULocationID)별로 total_amount의 90 백분위수를 계산해 봅시다.

```sql

SELECT 
  PULocationID,
  total_amount,
  PERCENTILE_CONT(total_amount, 0.9 ) OVER (PARTITION BY PULocationID) AS p90

FROM `greentaxi_trips` 

```

- PERCENTILE_CONT(total_amount, 0.9): total_amount의 90 백분위수(p90)를 계산합니다
- PARTITION BY PULocationID: 계산을 PULocationID별로 묶어, 90 백분위수가 각 위치마다 따로 계산되게 합니다.


쿼리 결과는 다음과 같습니다:

| PULocationID | total_amount  | p90  |
|------|-------|-------|
| 224  | 17.3    | 51.9  |
| 224  | 20.67    | 51.9  |
| 224  | 21    | 51.9  |
| 224  | 26.06 | 51.9  |
| 224  | 27.13 | 51.9  |
| 224  | 40.14 | 51.9  |
| 224  | 55.46 | 51.9  |
| 224  | 25.74 | 51.9  |
| 224  | 27.02 | 51.9  |
| 224  | 37    | 51.9  |


P90 값은 본질적으로 값의 90%가 그 아래에 놓이는 금액입니다. 이 표에서 P90은 51.9로 일정한데, 이는 위치 "224"에서 total amount의 90%가 51.9 미만이라는 뜻입니다.


## Common Table Expression

CTE(Common Table Expression의 줄임말)는 쿼리 안의 쿼리 같은 것입니다. WITH 문으로 결과를 담는 임시 테이블을 만들어 복잡한 쿼리를 더 읽기 쉽고 유지보수하기 좋게 만들 수 있습니다. 이 임시 테이블은 메인 쿼리가 도는 동안에만 존재합니다.

CTE와 subquery는 모두 강력한 도구이고 비슷한 목표를 달성하는 데 쓸 수 있지만, 사용 사례와 장점이 다릅니다. 차이점은 CTE가 세션 전체에서 재사용 가능하고 더 읽기 쉽다는 것입니다.

쿼리 시작 부분에 CTE를 선언하면 코드 가독성이 높아져 분석 로직을 더 명확하게 파악할 수 있습니다.

**문법:**

```sql

WITH cte_name AS (
    SELECT column1, column2
    FROM some_table
    WHERE condition
)
SELECT * FROM cte_name;
```

**예제: total_amount가 두 번째로 큰 trip을 찾아봅시다**

```sql

WITH cte AS(

  SELECT
  lpep_pickup_datetime,
  total_amount,
  RANK() OVER (ORDER BY total_amount DESC) AS rank

  FROM `greentaxi_trips` 

)


SELECT * FROM cte WHERE rank = 2;

```

이 쿼리는 cte라는 이름의 Common Table Expression(CTE)으로 시작합니다. RANK() window function을 써서 total_amount 내림차순(가장 높은 것부터 낮은 것 순)으로 각 행에 순위(rank)를 부여합니다.

이제 메인 쿼리에서 CTE를 사용합니다: ```SELECT * FROM cte WHERE rank = 2;```

쿼리 결과:


| lpep_pickup_datetime      | total_amount | rank | 
|---------------------------|--------------|-------------------|
| 2019-10-10 15:22:49 UTC  | 2878.3        | 2             | 

## dbt models and CTEs

CTE와 window function은 dbt를 다루는 module 4에서 많이 쓰입니다. dbt model에서의 적용 예를 봅시다.

**예제:**

FHV 데이터셋에서 시작해, trip duration과 90 백분위수를 계산해 데이터를 풍부하게 만드는 dbt model을 만들고 싶다고 가정합시다.

```sql

WITH trip_duration_calculated AS (

    SELECT
        *,
        timestamp_diff(dropOff_datetime, pickup_datetime, second) as trip_duration

    FROM `fhv_trips`
)

SELECT 

    PUlocationID,
    trip_duration,
    PERCENTILE_CONT(trip_duration, 0.90) OVER (PARTITION BY PUlocationID) AS trip_duration_p90


FROM trip_duration_calculated


```

**Step 1: CTE 이해하기**

WITH 절이 trip_duration_calculated라는 CTE를 만듭니다. 이 CTE는 fhv_trips 테이블의 모든 컬럼을 담은 임시 테이블 역할을 합니다. 추가로 각 운행의 trip duration을 계산합니다.

**Step 2: CTE와 Window Function을 사용하는 메인 쿼리**

이 쿼리는 window function을 써서 각 PUlocationID별 trip duration의 90 백분위수를 계산합니다:

PARTITION BY PUlocationID 절은 백분위수 계산이 각 고유한 PUlocationID마다 따로 수행되도록 보장합니다.

백분위수 90은 trip의 90%가 이 값 이하의 duration을 가진다는 뜻입니다.

**쿼리 결과는 다음과 같습니다:**

| PUlocationID | trip_duration | trip_duration_p90 |
|-------------|---------------|--------------------|
| 190         | 451           | 2170.0            |
| 190         | 1373          | 2170.0            |
| 190         | 817           | 2170.0            |
| 190         | 589           | 2170.0            |
| 190         | 1648          | 2170.0            |
| 32          | 546           | 1988.0            |
| 32          | 151           | 1988.0            |
| 32          | 1752          | 1988.0            |
| 32          | 2426          | 1988.0            |
| 32          | 888           | 1988.0            |


- PUlocationID = 190이면 trip의 90%가 duration ≤ 2170.0초입니다.
- PUlocationID = 32면 trip의 90%가 duration ≤ 1988.0초입니다.
