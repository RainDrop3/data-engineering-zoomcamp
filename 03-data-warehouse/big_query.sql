-- 공개 데이터셋 테이블 조회하기
SELECT
    station_id,
    name
FROM bigquery-public-data.new_york_citibike.citibike_stations
LIMIT 100;

-- GCS의 파일을 참조하는 external table 생성하기
CREATE OR REPLACE EXTERNAL TABLE `taxi-rides-ny.nytaxi.external_yellow_tripdata`
OPTIONS (
    format = 'CSV',
    uris = [
        'gs://nyc-tl-data/trip data/yellow_tripdata_2019-*.csv',
        'gs://nyc-tl-data/trip data/yellow_tripdata_2020-*.csv'
    ]
);

-- external table에서 yellow trip 데이터 미리보기
SELECT *
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata
LIMIT 10;

-- external table로부터 파티션 없는 테이블 생성하기
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_non_partitioned AS
SELECT *
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- external table로부터 파티션 테이블 생성하기
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
PARTITION BY DATE(tpep_pickup_datetime) AS
SELECT *
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- 파티션의 효과 비교
-- 1.6GB 스캔
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- 약 106MB 스캔
SELECT DISTINCT(VendorID)
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- 테이블의 파티션 확인하기
SELECT
    table_name,
    partition_id,
    total_rows
FROM `nytaxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;

-- 파티션 + 클러스터 테이블 생성하기
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * 
FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;

-- 이 쿼리는 1.1GB를 스캔
SELECT count(*) as trips
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

-- 이 쿼리는 864.5MB를 스캔
SELECT count(*) as trips
FROM taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND VendorID=1;

