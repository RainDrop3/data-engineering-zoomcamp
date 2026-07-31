# Module 3 학습 TODO

> 목표: BigQuery를 data warehouse로 다뤄본다. GCS의 파일을 external table로 연결하고, materialized 테이블을 만들고, partitioning과 clustering으로 스캔량과 비용을 줄이는 법을 익힌다. 마지막으로 BigQuery ML로 모델을 학습·배포해 본다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 사전 준비

- [ ] Module 1, 2 완료 확인 — GCP 프로젝트, 서비스 계정 키, `GOOGLE_APPLICATION_CREDENTIALS` 설정
- [ ] IAM 역할 확인: BigQuery Admin, Storage Admin, Storage Object Admin
- [ ] `gcloud auth login` / `bq --version`으로 CLI 동작 확인
- [ ] GCS 버킷과 BigQuery 데이터셋이 살아있는지 확인 (없으면 Module 1의 Terraform이나 콘솔에서 생성)
- [ ] [슬라이드](https://docs.google.com/presentation/d/1a3ZoBAXFk8-EhUsd7rAZd-5p_HpltkzSeujjRGB2TAI/edit?usp=sharing) 훑어보기
- [ ] [README.md](README.md) 훑어보기 — 전체 흐름 파악

## 1. Data Warehouse와 BigQuery

- [ ] [Data Warehouse와 BigQuery](https://youtu.be/jrHljAoD6nM) 영상 시청
  - [ ] OLTP vs OLAP 차이 정리
  - [ ] Data Lake vs Data Warehouse 차이 정리
  - [ ] BigQuery의 서버리스 구조와 요금 모델(스캔한 바이트 기준) 이해하기
- [ ] [big_query.sql](big_query.sql) 따라 실행하기 (BigQuery 콘솔에서)
  - [ ] 공개 데이터셋 조회 (`bigquery-public-data.new_york_citibike`)
  - [ ] GCS 파일을 참조하는 **external table** 생성
  - [ ] external table로부터 **파티션 없는** 테이블 생성
  - [ ] external table로부터 **파티션** 테이블 생성
  - [ ] ⚠️ SQL 안의 `taxi-rides-ny.nytaxi`, `gs://nyc-tl-data/...`를 **본인 프로젝트/버킷 이름으로 바꾸기**

## 2. Partitioning과 Clustering

- [ ] [Partitioning vs Clustering](https://youtu.be/-CqXf7vhhDs) 영상 시청
- [ ] 같은 쿼리를 non-partitioned / partitioned 테이블에서 실행하고 **추정 스캔량 비교** (1.6GB → ~106MB)
- [ ] `INFORMATION_SCHEMA.PARTITIONS`로 파티션별 행 수 확인
- [ ] partition + cluster 테이블 생성 후 스캔량 비교 (1.1GB → ~864MB)
- [ ] 정리해 보기: 언제 partition을 쓰고 언제 cluster를 쓰는가?
  - [ ] partition: 날짜/정수 범위 기준으로 **필터링**할 때
  - [ ] cluster: 카디널리티가 높은 컬럼으로 **필터·정렬**할 때
  - [ ] partition은 최대 4,000개, cluster는 최대 4개 컬럼(순서 중요)

## 3. BigQuery 모범 사례

- [ ] [Best practices](https://youtu.be/k81mLJVX08w) 영상 시청
  - [ ] 비용 절감: `SELECT *` 지양, 쿼리 실행 전 추정 비용 확인, 파티션 테이블 사용
  - [ ] 성능 향상: 큰 테이블을 JOIN 왼쪽에, WHERE로 먼저 걸러내기, ORDER BY는 마지막에

## 4. BigQuery 내부 구조

- [ ] [Internals of BigQuery](https://youtu.be/eduHi1inM4s) 영상 시청
  - [ ] Colossus(스토리지), Jupiter(네트워크), Dremel(쿼리 실행), Borg(컴퓨트) 역할 정리
  - [ ] 컬럼 기반 저장(column-oriented) 방식이 왜 스캔량을 줄이는지 이해하기

## 5. 심화: BigQuery ML (선택)

- [ ] [Machine Learning in BigQuery](https://youtu.be/B-WtpB0PuG4) 영상 시청
- [ ] [big_query_ml.sql](big_query_ml.sql) 따라 실행하기
  - [ ] ML용 테이블 생성 (컬럼 타입 캐스팅)
  - [ ] `CREATE MODEL`로 linear regression 모델 학습
  - [ ] `ML.FEATURE_INFO` / `ML.EVALUATE` / `ML.PREDICT` / `ML.EXPLAIN_PREDICT` 실행
  - [ ] 하이퍼파라미터 튜닝 모델 학습해 보기
- [ ] [Deploying ML model from BigQuery](https://youtu.be/BjARzEWaznU) 영상 시청
- [ ] [extract_model.md](extract_model.md) 따라 모델 추출 후 TensorFlow Serving으로 배포
  - [ ] `bq extract`로 모델을 GCS에 내보내기 → 로컬로 복사
  - [ ] `docker run tensorflow/serving`으로 서빙
  - [ ] `curl`로 예측 요청 보내보기

## 6. 보너스: GCS로 데이터 직접 적재하기 (선택)

- [ ] [extras/README.md](extras/README.md) 읽기
- [ ] `uv sync` 후 `uv run python web_to_gcs.py` 실행 — CSV를 parquet으로 변환해 GCS에 업로드
- [ ] ⚠️ 스크립트 안의 버킷 이름을 본인 것으로 수정하기

## 7. 숙제

- [ ] [Homework](../cohorts/2026/03-data-warehouse/homework.md) 풀기
- [ ] 데이터 준비: 2024년 **1~6월** Yellow Taxi **Parquet** 파일 6개를 GCS 버킷에 적재
  - [ ] [load_yellow_taxi_data.py](../cohorts/2026/03-data-warehouse/load_yellow_taxi_data.py) 또는 [DLT_upload_to_GCP.ipynb](../cohorts/2026/03-data-warehouse/DLT_upload_to_GCP.ipynb) 사용
  - [ ] ⚠️ orchestrator(Kestra 등)로 BigQuery에 바로 적재하지 말 것 — GCS까지만
  - [ ] 버킷에 파일 6개가 모두 있는지 확인
- [ ] external table 생성 (`format = 'PARQUET'` 사용!)
- [ ] partition/cluster 없는 materialized 테이블 생성
- [ ] 각 질문 풀이 — 콘솔 우측 상단의 **추정 스캔 바이트** 표시를 활용
  - [ ] Q1 레코드 개수 / Q2 external vs materialized 스캔량 / Q3 컬럼 기반 저장
  - [ ] Q4 fare_amount = 0 개수 / Q5 partition·cluster 전략 / Q6 partition 효과
  - [ ] Q7 external table 저장 위치 / Q8 clustering 모범 사례 / Q9 `count(*)` 스캔량
- [ ] 풀이 SQL을 저장소에 커밋 ([big_query_hw.sql](big_query_hw.sql) 참고 — 2019 FHV 예전 버전 예시)
- [ ] [제출 폼](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw3)에 답안 + GitHub 링크 제출

## 8. 정리

- [ ] 실습용 BigQuery 테이블 / 모델 삭제 (특히 파티션 테이블 여러 개)
- [ ] 필요 없는 GCS 객체 삭제 (비용 방지!)
- [ ] 로컬에서 띄운 `tensorflow/serving` 컨테이너 정리

---

## 다음 단계

Module 3을 마치면 → `04-analytics-engineering/` (dbt와 analytics engineering)으로 진행

## 팁

- BigQuery 콘솔은 쿼리를 실행하기 **전에** 우측 상단에 "This query will process X"로 추정 스캔량을 보여줍니다. 이번 모듈의 거의 모든 문제가 이 숫자를 읽는 연습입니다.
- 실행 후 실제 처리량은 **Job information** 탭의 `Bytes processed`에서 확인하세요. 캐시된 결과는 0 B로 나오니 비교할 때 주의하세요.
- external table은 데이터가 GCS에 그대로 있고 BigQuery는 참조만 합니다. 그래서 통계 정보가 없어 추정 스캔량이 0 MB로 나오는 경우가 많습니다.
- 강의 SQL의 프로젝트·데이터셋 이름(`taxi-rides-ny.nytaxi`)은 강사 환경 기준입니다. 그대로 실행하면 권한 오류가 나니 꼭 본인 것으로 바꾸세요.
- 무료 티어는 매월 1TB 쿼리 + 10GB 스토리지입니다. `SELECT *`로 큰 테이블을 훑는 습관만 피하면 이 모듈은 무료 범위 안에서 끝납니다.
- 숙제 데이터는 CSV가 아니라 **Parquet**입니다. external table 생성 시 `format = 'PARQUET'`을 빠뜨리지 마세요.
- 막히면 [DataTalksClub Slack](https://datatalks.club/slack.html)에 질문하거나 README 하단의 커뮤니티 노트를 참고하세요.
