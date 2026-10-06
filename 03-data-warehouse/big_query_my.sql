-- big_query.sql(강의 원본)을 내 환경에 맞게 고친 실행용 버전
--
--   프로젝트 : my-project-260414-493307
--   데이터셋 : zoomcamp        (europe-west2)
--   버킷     : alsrb-kestra-bucket (EUROPE-WEST2)
--   데이터   : yellow 2019 (12개월), extras/web_to_gcs_with_progress_bar.py 로 적재
--
-- 원본과 달라진 점
--   1. gs://nyc-tl-data 대신 내 버킷을 참조한다.
--      강사 버킷은 소유 프로젝트의 결제 계정이 비활성이라 403이 난다. 권한 문제가 아니라 복구 불가.
--   2. format 이 CSV 가 아니라 PARQUET 이다. 적재 스크립트가 CSV를 parquet으로 변환해 올리기 때문.
--   3. 데이터가 2019년뿐이라 날짜 범위를 2019년 안으로 줄였다.
--      원본의 스캔량 수치(1.6GB, 106MB ...)는 2019+2020 24개월 기준이라 그대로 나오지 않는다.
--      중요한 건 절대값이 아니라 줄어드는 비율이다. 실제 값은 직접 기록할 것.


-- ---------------------------------------------------------------------------
-- 0. 공개 데이터셋 테이블 조회하기 (내 데이터와 무관, 맛보기)
-- ---------------------------------------------------------------------------
SELECT
    station_id,
    name
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
LIMIT 100;


-- ---------------------------------------------------------------------------
-- 1. GCS의 파일을 참조하는 external table 생성하기
--    데이터는 GCS에 그대로 있고 BigQuery는 참조만 한다.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE EXTERNAL TABLE `my-project-260414-493307.zoomcamp.external_yellow_tripdata`
OPTIONS (
    format = 'PARQUET',
    uris = ['gs://alsrb-kestra-bucket/yellow/yellow_tripdata_2019-*.parquet']
);

-- external table에서 yellow trip 데이터 미리보기
SELECT *
FROM `my-project-260414-493307.zoomcamp.external_yellow_tripdata`
LIMIT 10;

-- 전체 행 수 확인 (2019년 12개월이면 8천만 행대가 나온다)
SELECT count(*) AS total_rows
FROM `my-project-260414-493307.zoomcamp.external_yellow_tripdata`;


-- ---------------------------------------------------------------------------
-- 2. external table로부터 파티션 없는 테이블 생성하기 (materialized)
--    여기서부터는 데이터가 BigQuery 안으로 복사된다.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE TABLE `my-project-260414-493307.zoomcamp.yellow_tripdata_non_partitioned` AS
SELECT *
FROM `my-project-260414-493307.zoomcamp.external_yellow_tripdata`;


-- ---------------------------------------------------------------------------
-- 3. external table로부터 파티션 테이블 생성하기
--    2019년 일별 파티션 = 365개. 파티션 상한 4,000개 안쪽이라 문제 없다.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE TABLE `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned`
PARTITION BY DATE(tpep_pickup_datetime) AS
SELECT *
FROM `my-project-260414-493307.zoomcamp.external_yellow_tripdata`;


-- ---------------------------------------------------------------------------
-- 4. 파티션의 효과 비교
--    ★ 실행하지 말고 먼저 콘솔 우측 상단의 "This query will process X" 를 읽을 것.
--      이번 모듈의 핵심은 이 숫자를 읽는 연습이다.
--    한 달치만 필터링하므로 파티션 테이블은 대략 1/12 수준으로 떨어져야 한다.
-- ---------------------------------------------------------------------------

-- (a) 파티션 없는 테이블 → 전체 스캔.  추정 스캔량: ______
SELECT DISTINCT(VendorID)
FROM `my-project-260414-493307.zoomcamp.yellow_tripdata_non_partitioned`
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- (b) 파티션 테이블 → 6월 파티션만 스캔.  추정 스캔량: ______
SELECT DISTINCT(VendorID)
FROM `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned`
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';


-- ---------------------------------------------------------------------------
-- 5. 테이블의 파티션 확인하기
--    파티션별 행 수. 데이터가 고르게 퍼져 있는지 본다.
-- ---------------------------------------------------------------------------
SELECT
    table_name,
    partition_id,
    total_rows
FROM `my-project-260414-493307.zoomcamp.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;


-- ---------------------------------------------------------------------------
-- 6. 파티션 + 클러스터 테이블 생성하기
--    partition = 날짜/정수 범위로 필터링할 때
--    cluster   = 카디널리티 높은 컬럼으로 필터·정렬할 때 (최대 4개, 순서 중요)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE TABLE `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned_clustered`
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT *
FROM `my-project-260414-493307.zoomcamp.external_yellow_tripdata`;


-- ---------------------------------------------------------------------------
-- 7. 클러스터의 효과 비교
--    넓은 날짜 범위 + VendorID 필터. 파티션만으로는 못 줄이는 부분을 클러스터가 줄인다.
--    파티션 때만큼 극적이지 않은 게 정상이다.
-- ---------------------------------------------------------------------------

-- (a) 파티션만.            추정 스캔량: ______
SELECT count(*) AS trips
FROM `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned`
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-01-01' AND '2019-12-31'
  AND VendorID = 1;

-- (b) 파티션 + 클러스터.   추정 스캔량: ______
SELECT count(*) AS trips
FROM `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned_clustered`
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-01-01' AND '2019-12-31'
  AND VendorID = 1;


-- ---------------------------------------------------------------------------
-- 8. 정리 (실습 끝나면 실행 — 스토리지 비용 방지)
--    무료 티어 스토리지는 10GB. 위 테이블 3개가 그 대부분을 먹는다.
--    external table 은 GCS를 참조만 하므로 지워도 원본 parquet은 남는다.
-- ---------------------------------------------------------------------------
-- DROP TABLE `my-project-260414-493307.zoomcamp.yellow_tripdata_non_partitioned`;
-- DROP TABLE `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned`;
-- DROP TABLE `my-project-260414-493307.zoomcamp.yellow_tripdata_partitioned_clustered`;
-- DROP EXTERNAL TABLE `my-project-260414-493307.zoomcamp.external_yellow_tripdata`;
