# SQL 복습

**[↑ 위로](README.md)** | **[← 이전](09-docker-compose.md)** | **[다음 →](11-cleanup.md)**

[![](images/thumbnail-QEcps_iskgg.jpg)](https://youtu.be/QEcps_iskgg&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=10)

사전 준비: 지금까지 순서대로 진행했다면, pgdatabase와 pgAdmin이 Docker Compose로 이미 실행 중일 것입니다.

준비가 되면 http://localhost:8085/browser/ 로 이동해 pgAdmin에 접속하세요.
새 테이블이 보이지 않으면 서버나 데이터베이스에서 우클릭해 새로고침(Refresh)하는 것을 잊지 마세요.

이제 쿼리를 시작해 봅시다!

## Inner Join

### 암시적(Implicit) INNER JOIN

Yellow Taxi 테이블과 Zones Lookup 테이블 조인하기 (암시적 INNER JOIN):

```sql
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM
    yellow_taxi_trips t,
    zones zpu,
    zones zdo
WHERE
    t."PULocationID" = zpu."LocationID"
    AND t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

### 명시적(Explicit) INNER JOIN

```sql
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM
    yellow_taxi_trips t
JOIN
-- INNER JOIN이라고 써도 되지만 덜 쓰입니다. JOIN이라고만 쓰면 postgreSQL은 암묵적으로 INNER JOIN으로 이해합니다
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

## 데이터 품질 점검

### NULL인 Location ID 확인하기

```sql
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    "PULocationID",
    "DOLocationID"
FROM
    yellow_taxi_trips
WHERE
    "PULocationID" IS NULL
    OR "DOLocationID" IS NULL
LIMIT 100;
```

### Zones 테이블에 없는 Location ID 확인하기

```sql
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    "PULocationID",
    "DOLocationID"
FROM
    yellow_taxi_trips
WHERE
    "DOLocationID" NOT IN (SELECT "LocationID" from zones)
    OR "PULocationID" NOT IN (SELECT "LocationID" from zones)
LIMIT 100;
```

## LEFT, RIGHT, OUTER JOIN

일부 Location ID가 어느 한쪽 테이블에 없을 때 LEFT, RIGHT, OUTER JOIN 사용하기:

```sql
DELETE FROM zones WHERE "LocationID" = 142;

SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM
    yellow_taxi_trips t
LEFT JOIN
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

```sql
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM
    yellow_taxi_trips t
RIGHT JOIN
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

```sql
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM
    yellow_taxi_trips t
OUTER JOIN
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;
```

## GROUP BY

### 일별 운행 횟수 계산하기

```sql
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1)
FROM
    yellow_taxi_trips
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
LIMIT 100;
```

## ORDER BY

### 날짜순 정렬

```sql
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1)
FROM
    yellow_taxi_trips
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
ORDER BY
    "day" ASC
LIMIT 100;
```

### 횟수순 정렬

```sql
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1) AS "count"
FROM
    yellow_taxi_trips
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
ORDER BY
    "count" DESC
LIMIT 100;
```

## 기타 집계 함수

```sql
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1) AS "count",
    MAX(total_amount) AS "total_amount",
    MAX(passenger_count) AS "passenger_count"
FROM
    yellow_taxi_trips
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
ORDER BY
    "count" DESC
LIMIT 100;
```

## 여러 필드로 그룹화하기

```sql
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    "DOLocationID",
    COUNT(1) AS "count",
    MAX(total_amount) AS "total_amount",
    MAX(passenger_count) AS "passenger_count"
FROM
    yellow_taxi_trips
GROUP BY
    1, 2
ORDER BY
    "day" ASC,
    "DOLocationID" ASC
LIMIT 100;
```

**[↑ 위로](README.md)** | **[← 이전](09-docker-compose.md)** | **[다음 →](11-cleanup.md)**
