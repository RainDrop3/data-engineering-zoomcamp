# Module 3 숙제: Data Warehousing & BigQuery

이번 숙제에서는 BigQuery와 Google Cloud Storage를 다루는 연습을 합니다.

숙제를 제출할 때는 여러분의 GitHub 저장소 또는 다른 공개 코드 호스팅
사이트의 링크도 함께 포함해야 합니다.

이 저장소에는 숙제를 푸는 코드가 들어있어야 합니다.

풀이가 코드 파일(예: python 파일)이 아니라 SQL이나 셸 명령어라면,
저장소의 README 파일에 직접 포함시키세요.

## 데이터

이번 숙제에서는 2024년 1월부터 6월까지의 Yellow Taxi Trip Records를 사용합니다(1년 전체 데이터가 아닙니다).

Parquet 파일은 여기에 있는 New York City Taxi Data에서 받을 수 있습니다:

https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## 데이터 적재하기

다음 스크립트를 사용해 GCS 버킷에 데이터를 적재할 수 있습니다:

- Python 스크립트: [load_yellow_taxi_data.py](./load_yellow_taxi_data.py)
- DLT를 사용하는 Jupyter notebook: [DLT_upload_to_GCP.ipynb](./DLT_upload_to_GCP.ipynb)

GCS Admin 권한을 가진 서비스 계정을 생성하거나 Google SDK로 인증되어 있어야 하며, 스크립트의 버킷 이름을 수정해야 합니다.

Kestra, Mage, Airflow, Prefect 같은 orchestration 도구를 사용하고 있더라도, orchestrator로 BigQuery에 데이터를 적재하지는 마세요.

시작하기 전에 GCS 버킷에 6개 파일이 모두 보이는지 확인하세요.

참고: external table을 생성할 때 PARQUET 옵션을 사용해야 합니다.


## BigQuery 설정

Yellow Taxi Trip Records를 사용해 external table을 생성하세요.

Yellow Taxi Trip Records를 사용해 BQ에 (일반/materialized) 테이블을 생성하세요(이 테이블은 partition이나 cluster를 적용하지 마세요).



## 질문 1. 레코드 개수 세기

2024년 Yellow Taxi 데이터의 레코드 개수는 몇 개인가요?
- 65,623
- 840,402
- 20,332,093
- 85,431,289


## 질문 2. 읽는 데이터양 추정

두 테이블 모두에 대해 전체 데이터셋의 고유한 PULocationID 개수를 세는 쿼리를 작성하세요.

이 쿼리를 External Table과 Table에서 실행할 때 읽게 될 데이터의 **추정량**은 각각 얼마인가요?

- External Table은 18.82 MB, Materialized Table은 47.60 MB
- External Table은 0 MB, Materialized Table은 155.12 MB
- External Table은 2.14 GB, Materialized Table은 0MB
- External Table은 0 MB, Materialized Table은 0MB

## 질문 3. 컬럼 기반 저장 방식 이해하기

BigQuery에서 (external table이 아닌) 테이블에서 PULocationID를 조회하는 쿼리를 작성하세요. 이제 같은 테이블에서 PULocationID와 DOLocationID를 조회하는 쿼리를 작성하세요.

추정 바이트 수가 다른 이유는 무엇인가요?
- BigQuery는 컬럼 기반 데이터베이스라서 쿼리에서 요청한 특정 컬럼만 스캔합니다. 두 개의 컬럼(PULocationID, DOLocationID)을 조회하면
한 개의 컬럼(PULocationID)을 조회할 때보다 더 많은 데이터를 읽어야 하므로, 처리되는 추정 바이트 수가 더 큽니다.
- BigQuery는 여러 스토리지 파티션에 데이터를 중복 저장하므로, 한 개 대신 두 개의 컬럼을 선택하면 테이블을 두 번 스캔해야 해서
처리되는 추정 바이트가 두 배가 됩니다.
- BigQuery는 첫 번째로 조회된 컬럼을 자동으로 캐싱하므로, 두 번째 컬럼을 추가하면 처리 시간은 늘어나지만 추정 스캔 바이트에는 영향이 없습니다.
- 여러 컬럼을 선택하면 BigQuery가 그들 사이에 암묵적인 join 연산을 수행해서 처리되는 추정 바이트가 늘어납니다

## 질문 4. 요금이 0인 운행 세기

fare_amount가 0인 레코드는 몇 개인가요?
- 128,210
- 546,578
- 20,188,016
- 8,333

## 질문 5. Partitioning과 clustering

쿼리가 항상 tpep_dropoff_datetime을 기준으로 필터링하고 결과를 VendorID로 정렬한다면, Big Query에서 최적화된 테이블을 만드는 가장 좋은 전략은 무엇인가요? (이 전략으로 새 테이블을 생성하세요)

- tpep_dropoff_datetime으로 Partition, VendorID로 Cluster
- tpep_dropoff_datetime으로 Cluster, VendorID로 Cluster
- tpep_dropoff_datetime으로 Cluster, VendorID로 Partition
- tpep_dropoff_datetime으로 Partition, VendorID로 Partition


## 질문 6. Partition의 이점

tpep_dropoff_datetime이 2024-03-01부터 2024-03-15 사이(양끝 포함)인 고유한 VendorID를
조회하는 쿼리를 작성하세요.


from 절에 앞서 만든 materialized 테이블을 사용하고 추정 바이트를 기록하세요. 이제 from 절의 테이블을 질문 5에서 만든 partitioned 테이블로 바꾸고 처리되는 추정 바이트를 기록하세요. 이 값들은 각각 얼마인가요?


가장 가까운 답을 고르세요.


- non-partitioned 테이블 12.47 MB, partitioned 테이블 326.42 MB
- non-partitioned 테이블 310.24 MB, partitioned 테이블 26.84 MB
- non-partitioned 테이블 5.87 MB, partitioned 테이블 0 MB
- non-partitioned 테이블 310.31 MB, partitioned 테이블 285.64 MB


## 질문 7. External table의 저장 위치

여러분이 생성한 External Table의 데이터는 어디에 저장되나요?

- Big Query
- Container Registry
- GCP Bucket
- Big Table

## 질문 8. Clustering 모범 사례

Big Query에서는 항상 데이터를 cluster하는 것이 모범 사례이다:
- True
- False


## 질문 9. 테이블 스캔 이해하기

점수 없음: 여러분이 만든 materialized 테이블에 대해 `SELECT count(*)` 쿼리를 작성하세요. 읽을 것으로 추정되는 바이트는 얼마인가요? 그 이유는 무엇인가요?


## 풀이 제출하기

제출 폼: https://courses.datatalks.club/de-zoomcamp-2026/homework/hw3


## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

### LinkedIn 게시물 예시

```
🚀 Week 3 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 3 - Data Warehousing with BigQuery. Learned how to:

✅ Create external tables from GCS bucket data
✅ Build materialized tables in BigQuery
✅ Partition and cluster tables for performance
✅ Understand columnar storage and query optimization
✅ Analyze NYC taxi data at scale

Working with 20M+ records and learning how partitioning reduces query costs!

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시

```
📊 Module 3 of Data Engineering Zoomcamp done!

- BigQuery & GCS
- External vs materialized tables
- Partitioning & clustering
- Query optimization

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
