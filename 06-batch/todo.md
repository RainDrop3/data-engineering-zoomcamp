# Module 6 학습 TODO

> 목표: Spark로 대용량 데이터를 batch 처리하는 법을 익힌다. PySpark DataFrame과 Spark SQL로 taxi 데이터를 변환하고, GroupBy·Join이 클러스터 내부에서 어떻게 동작하는지(shuffle) 이해하고, 마지막으로 GCS·Dataproc·BigQuery와 연결해 클라우드에서 실행해 본다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 가장 먼저 — 실행 환경 정하기 ⚠️

Windows에서는 Spark를 **어디서 돌릴지**가 이 모듈의 첫 관문입니다. 나머지 단계가 모두 여기에 달려 있으니 먼저 정하세요.

- [ ] 아래 표를 보고 환경 선택

| | 🪟 Windows 네이티브 (Git Bash) | 🐧 WSL (Ubuntu) |
|---|---|---|
| 설치 가이드 | [setup/windows.md](setup/windows.md) | [setup/linux.md](setup/linux.md) |
| 기본 실습 (6.1~6.5) | 가능 | 가능 |
| 로컬 클러스터 `sbin/*.sh` (6.6.2) | ⚠️ Spark 실행 스크립트가 Windows 미지원 | 가능 |
| YARN ([hadoop-yarn.md](setup/hadoop-yarn.md)) | 불가 — 문서도 WSL을 안내 | 가능 |
| 파일 쓰기 (parquet 저장) | `winutils.exe` / `HADOOP_HOME` 관련 에러가 흔히 보고됨 | 문제 없음 |

- [ ] **Windows 네이티브를 골랐다면** → [2. 설치](#2-설치)의 Windows 항목대로
- [ ] **WSL을 골랐다면** → [2. 설치](#2-설치)의 WSL 항목대로

> 💡 판단 기준: 강의 영상과 예제 스크립트는 Linux 기준입니다. 6.6의 로컬 클러스터까지 따라 하려면 WSL이 편합니다. 숙제만 빠르게 끝낼 거라면 Windows 네이티브로도 충분하고, parquet 저장에서 막히면 그때 WSL로 넘어가도 됩니다.

## 1. 개념 잡기

- [ ] [README.md](README.md) 훑어보기 — 전체 흐름 파악
- [ ] [6.1.1 Batch Processing 소개](https://youtu.be/dcHe5Fl3MF8) 영상 시청
  - [ ] batch vs streaming 차이 정리 (Module 7과 대비)
  - [ ] batch job을 무엇으로 만들고 어떻게 스케줄링하는지 (Python, SQL, Spark + Airflow 등)
  - [ ] batch의 장단점: 다루기 쉽고 재실행이 쉬움 ↔ 지연(latency)
- [ ] [6.1.2 Spark 소개](https://youtu.be/FhaqbEOuQ8U) 영상 시청
  - [ ] Spark가 무엇이고 언제 쓰는지 — SQL로 표현하기 어려운 처리, data lake 위의 처리
  - [ ] Spark vs SQL 엔진(BigQuery 등)의 쓰임새 구분

## 2. 설치

- [ ] [6.2.1 Spark 설치 (Linux)](https://youtu.be/hqUbB9c8sKg) 영상 시청 (선택 — 영상은 Spark 3.x 기준, 가이드는 4.x 기준)
- [ ] Java 확인
  - [ ] 이 PC에는 이미 **JDK 21**이 있음 (`JAVA_HOME=C:\Program Files\Java\jdk-21.0.10`) — Spark 4.x는 Java 17/21을 지원하므로([linux.md](setup/linux.md) 기준) 그대로 써볼 수 있음
  - [ ] (WSL) WSL 안에는 따로 `sudo apt install default-jdk` 필요
- [ ] PySpark 설치 — `uv init` → `uv add pyspark` (Spark가 번들로 함께 설치됨, 별도 다운로드 불필요)
  - [ ] ⚠️ 이 PC의 기본 Python은 3.14 — PySpark 버전에 따라 미지원일 수 있으니, 문제가 생기면 `uv python pin 3.12`로 낮추기
- [ ] ⚠️ 예전 Spark 3.x의 `SPARK_HOME`이 남아 있다면 삭제 (남아 있으면 PySpark 4.x가 예전 JAR를 불러와 실패)
- [ ] `test_spark.py` 실행해서 `spark.version`과 `df.show()` 출력 확인
  - [ ] (Windows) 방화벽 허용 팝업 → 허용
  - [ ] `jdk.incubator.vector` 경고는 무시
- [ ] Jupyter 준비 — `uv add jupyter` 후 `uv run jupyter notebook` (강의 실습이 대부분 노트북)
- [ ] ⚠️ Git Bash에는 `wget`이 없음 → 가이드의 `wget URL`은 `curl -LO URL`로 바꿔 실행
- [ ] 설치가 끝내 안 되면 [Google Colab](https://medium.com/gitconnected/launch-spark-on-google-colab-and-connect-to-sparkui-342cad19b304) 대안 (단, 로컬 셋업을 먼저 시도할 것)

## 3. Spark SQL과 DataFrame

- [ ] [6.3.1 Spark/PySpark 첫걸음](https://youtu.be/r_Sf6fCB40c) 영상 시청 → [04_pyspark.ipynb](code/04_pyspark.ipynb)
  - [ ] `SparkSession` 만들기, CSV 읽기
  - [ ] schema 직접 지정하기 (`StructType`) — pandas로 추론하거나 `inferSchema=true`
  - [ ] `repartition()` 후 parquet으로 저장 — partition 수 = 출력 파일 수
  - [ ] **Spark UI (`localhost:4040`)** 에서 job/stage 확인
- [ ] [6.3.2 Spark DataFrame](https://youtu.be/ti3aC1m3rE8) 영상 시청
  - [ ] **transformation(lazy) vs action(eager)** 구분 — `select`/`filter`는 실행 안 됨, `show`/`write`에서 실행
  - [ ] `select`, `filter`, `withColumn`
  - [ ] UDF 만들어 쓰기 — SQL로 표현하기 어려운 로직
- [ ] [6.3.3 (선택) Yellow/Green 데이터 준비](https://youtu.be/CI3P4tAtru4) 영상 시청 → [05_taxi_schema.ipynb](code/05_taxi_schema.ipynb)
  - [ ] [download_data.sh](code/download_data.sh)로 2020·2021 yellow/green CSV 받기 (`bash download_data.sh yellow 2020` 형식)
  - [ ] ⚠️ 스크립트가 `wget`을 쓰므로 Git Bash라면 `curl -L -o ${LOCAL_PATH} ${URL}`로 수정해서 실행
  - [ ] schema 지정해 parquet으로 변환 → `data/pq/{yellow,green}/{year}/{month}/`
- [ ] [6.3.4 Spark에서 SQL 쓰기](https://youtu.be/uAlp2VuZZPY) 영상 시청 → [06_spark_sql.ipynb](code/06_spark_sql.ipynb)
  - [ ] green + yellow 컬럼 맞춰 union (Module 4의 `int_trips_unioned`와 같은 작업)
  - [ ] `createOrReplaceTempView` → `spark.sql()`로 쿼리 (강의 코드의 `registerTempTable`은 deprecated된 예전 API)
  - [ ] `coalesce()`로 출력 파일 수 줄이기

## 4. Spark 내부 구조

- [ ] [6.4.1 Spark 클러스터의 구조](https://youtu.be/68CipcZt7ZA) 영상 시청
  - [ ] driver / master / executor 역할 정리
  - [ ] 데이터 지역성(data locality)과 클라우드 스토리지(GCS/S3)를 쓰면서 달라진 점
- [ ] [6.4.2 GroupBy](https://youtu.be/9qrDsY_2COo) 영상 시청 → [07_groupby_join.ipynb](code/07_groupby_join.ipynb)
  - [ ] GroupBy가 2개 stage로 나뉘는 이유 — 파티션별 부분 집계 → **shuffle** → 최종 집계
  - [ ] Spark UI에서 stage와 shuffle 크기 확인
- [ ] [6.4.3 Join](https://youtu.be/lu7TrqAWuH4) 영상 시청
  - [ ] 큰 테이블끼리 join → sort-merge join (shuffle 발생)
  - [ ] 큰 테이블 + 작은 테이블 join → **broadcast join** (shuffle 없음, zones lookup이 예시)

## 5. RDD (선택)

- [ ] [6.5.1 RDD 연산](https://youtu.be/Bdu-xIrF3OM) 영상 시청 → [08_rdds.ipynb](code/08_rdds.ipynb)
  - [ ] DataFrame이 RDD 위에 만들어졌다는 점 이해
  - [ ] `map` / `filter` / `reduceByKey`로 GroupBy를 직접 구현해 보기
- [ ] [6.5.2 mapPartitions](https://youtu.be/k3uB2K99roI) 영상 시청
  - [ ] 파티션 단위로 처리하는 이유 (예: 파티션마다 ML 모델 한 번 로드)

## 6. 클라우드에서 Spark 실행하기

- [ ] [cloud.md](code/cloud.md) 읽기
- [ ] ⚠️ 문서의 버킷(`dtc_data_lake_de-zoomcamp-nytaxi`), 리전(`europe-west6`), 클러스터 이름은 강사 환경 기준 — **본인 것으로 바꾸기**
- [ ] [6.6.1 GCS 연결하기](https://youtu.be/Yyz293hBVcQ) 영상 시청 → [09_spark_gcs.ipynb](code/09_spark_gcs.ipynb)
  - [ ] `gsutil -m cp -r`로 parquet을 GCS에 업로드
  - [ ] GCS connector jar 다운로드 후 `SparkConf`에 설정
  - [ ] `gs://` 경로로 직접 읽어 보기
- [ ] [6.6.2 로컬 Spark 클러스터](https://youtu.be/HXBwSlXo5IA) 영상 시청
  - [ ] ⚠️ `sbin/*.sh` 스크립트는 Windows 미지원 → WSL에서 진행
  - [ ] `start-master.sh` → `start-worker.sh` (⚠️ 영상의 `start-slave.sh`는 최신 Spark에서 이름이 바뀜)
  - [ ] `jupyter nbconvert --to=script`로 노트북을 스크립트로 변환
  - [ ] `argparse`로 입력·출력 경로를 파라미터화 ([06_spark_sql.py](code/06_spark_sql.py) 참고)
  - [ ] `spark-submit --master=...`로 제출
- [ ] [6.6.3 Dataproc 클러스터](https://youtu.be/osAiAYahvh8) 영상 시청
  - [ ] Dataproc 클러스터 생성 (single node면 충분)
  - [ ] 스크립트를 GCS에 올리고 `gcloud dataproc jobs submit pyspark`로 제출
  - [ ] ⚠️ 서비스 계정에 Dataproc 권한 필요
- [ ] [6.6.4 Spark와 BigQuery 연결](https://youtu.be/HIm2BOj8C0Q) 영상 시청
  - [ ] [06_spark_sql_big_query.py](code/06_spark_sql_big_query.py)로 결과를 BigQuery 테이블에 쓰기
  - [ ] Dataproc 2.1+ 이미지는 BigQuery connector가 내장 → `--jars` 생략 가능

## 7. 심화: Spark on YARN (선택)

- [ ] [hadoop-yarn.md](setup/hadoop-yarn.md) 읽기 — README 영상에는 없는 참고 자료
- [ ] ⚠️ WSL 전용 (ssh localhost, Hadoop 바이너리 필요)
- [ ] 단일 노드 YARN 띄우고 `localhost:8088` 확인
- [ ] `--master yarn`으로 spark-submit

## 8. 숙제

- [ ] [Homework](../cohorts/2026/06-batch/homework.md) 풀기
- [ ] 데이터 준비: **2025년 11월 Yellow parquet** + `taxi_zone_lookup.csv`
  - [ ] Git Bash라면 `wget` 대신 `curl -LO`
- [ ] ⚠️ `code/homework.ipynb`는 **예전 기수의 숙제**(FHV, 2월 기준) — 2026 숙제와 질문이 다르니 헷갈리지 말 것
- [ ] 각 질문 풀이
  - [ ] Q1 `spark.version` 출력
  - [ ] Q2 `repartition(4)` → parquet 저장 → 생성된 `.parquet` 파일 평균 크기
  - [ ] Q3 11월 15일에 **시작된** 운행 수 (pickup 기준)
  - [ ] Q4 가장 긴 운행 시간 (시간 단위)
  - [ ] Q5 Spark UI 포트
  - [ ] Q6 zone lookup을 temp view로 등록 → 빈도가 가장 낮은 승차 zone
- [ ] 풀이 노트북/스크립트를 저장소에 커밋
- [ ] [제출 폼](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw6)에 답안 + GitHub 링크 제출

## 9. 정리

- [ ] ⚠️ **Dataproc 클러스터 삭제** — 켜 두면 계속 과금됨 (이 모듈에서 가장 비싼 실수)
- [ ] GCS에 올린 parquet / 리포트 / 스크립트 정리
- [ ] 실습용 BigQuery 테이블 정리 (`reports-2020` 등)
- [ ] 로컬 `data/` 디렉토리 정리 — 2년치 yellow/green은 용량 큼
- [ ] (WSL) 로컬 클러스터 master/worker 종료 — `stop-worker.sh`, `stop-master.sh`

---

## 다음 단계

Module 6을 마치면 → `07-streaming/` (Kafka(Redpanda) + Flink로 실시간 처리)

## 팁

- Spark는 **lazy**합니다. `filter`나 `select`만으로는 아무 일도 일어나지 않고, `show()`·`count()`·`write` 같은 action에서 비로소 실행됩니다. "왜 이 줄은 바로 끝나지?" 싶으면 이것 때문입니다.
- 막히면 먼저 **Spark UI(`localhost:4040`)** 를 여세요. job → stage → task 순서로 보면 어디서 시간이 걸리는지, shuffle이 얼마나 일어나는지 바로 보입니다.
- 강의 노트북은 Spark 3.0 기준으로 만들어졌고 설치 가이드는 4.x 기준입니다. DataFrame API는 거의 같지만, 스크립트 이름(`start-slave.sh` → `start-worker.sh`)이나 출력 경로처럼 사소한 차이는 있을 수 있습니다.
- 노트북 안의 경로(`/home/alexey/...`)는 강사 환경입니다. 본인 경로로 바꾸세요.
- Module 4의 dbt 작업과 비교해 보면 좋습니다. green/yellow union, revenue 집계를 SQL(dbt)과 DataFrame(Spark) 양쪽으로 해 보면 각 도구가 언제 나은지 감이 옵니다.
- Windows에서 parquet 저장 시 `HADOOP_HOME` / `winutils.exe` 관련 에러가 나면 오래 붙잡지 말고 WSL로 옮기는 게 빠릅니다. README 커뮤니티 노트의 khanh의 Windows 설치 영상도 참고하세요.
- 막히면 [DataTalksClub Slack](https://datatalks.club/slack.html)에 질문하거나 README 하단의 커뮤니티 노트를 참고하세요.
