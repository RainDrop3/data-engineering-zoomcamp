# 숙제

이번 숙제에서는 Kafka(Redpanda)와 PyFlink로 streaming을 연습합니다.

Kafka를 그대로 대체할 수 있는 Redpanda를 사용합니다. 같은
프로토콜을 구현하고 있어서 어떤 Kafka 클라이언트 라이브러리든 수정 없이 동작합니다.

이번 숙제에서는 2025년 10월 Green Taxi Trip 데이터를 사용합니다:

- [green_tripdata_2025-10.parquet](https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet)


## 설정

[워크숍](../../../07-streaming/workshop/)과 동일한 인프라를 사용합니다.

설정 안내를 따라 Docker 이미지를 빌드하고 서비스를 시작하세요:

```bash
cd 07-streaming/workshop/
docker compose build
docker compose up -d
```

이렇게 하면 다음이 준비됩니다:

- Redpanda (Kafka 호환 broker) — `localhost:9092`
- Flink Job Manager — http://localhost:8081
- Flink Task Manager
- PostgreSQL — `localhost:5432` (사용자: `postgres`, 비밀번호: `postgres`)

이전에 워크숍을 진행해서 오래된 컨테이너/볼륨이 남아있다면,
깨끗하게 다시 시작하세요:

```bash
docker compose down -v
docker compose build
docker compose up -d
```

참고: 컨테이너 이름(`workshop-redpanda-1` 등)은 디렉터리 이름이
`workshop`이라고 가정합니다. 이름을 바꿨다면 그에 맞게 조정하세요.


## 질문 1. Redpanda 버전

Redpanda 컨테이너 안에서 `rpk version`을 실행하세요:

```bash
docker exec -it workshop-redpanda-1 rpk version
```

실행 중인 Redpanda의 버전은 무엇인가요?


## 질문 2. Redpanda로 데이터 보내기

`green-trips`라는 topic을 생성하세요:

```bash
docker exec -it workshop-redpanda-1 rpk topic create green-trips
```

이제 이 topic으로 green taxi 데이터를 보내는 producer를 작성하세요.

parquet 파일을 읽고 다음 컬럼만 남기세요:

- `lpep_pickup_datetime`
- `lpep_dropoff_datetime`
- `PULocationID`
- `DOLocationID`
- `passenger_count`
- `trip_distance`
- `tip_amount`
- `total_amount`

각 행을 딕셔너리로 변환해서 `green-trips` topic으로 보내세요.
datetime 컬럼을 처리해야 합니다 — JSON으로 직렬화하기 전에 문자열로
변환하세요.

전체 데이터셋을 보내고 flush하는 데 걸리는 시간을 측정하세요:

```python
from time import time

t0 = time()

# send all rows ...

producer.flush()

t1 = time()
print(f'took {(t1 - t0):.2f} seconds')
```

데이터를 보내는 데 얼마나 걸렸나요?

- 10 seconds
- 60 seconds
- 120 seconds
- 300 seconds


## 질문 3. Consumer - 운행 거리

`green-trips` topic의 모든 메시지를 읽는 Kafka consumer를 작성하세요
(`auto_offset_reset='earliest'`로 설정).

`trip_distance`가 5.0킬로미터를 초과하는 운행이 몇 건인지 세어보세요.

`trip_distance` > 5인 운행은 몇 건인가요?

- 6506
- 7506
- 8506
- 9506


## Part 2: PyFlink (질문 4-6)

PyFlink 문제에서는 워크숍 코드를 green taxi 데이터에 맞게 수정하게 됩니다.
워크숍과의 주요 차이점:

- Topic 이름: `green-trips` (`rides` 대신)
- datetime 컬럼이 `lpep_` 접두사 사용 (`tpep_` 대신)
- 타임스탬프를 epoch 밀리초가 아닌 문자열로 처리해야 함

source DDL에서 문자열 타임스탬프를 Flink 타임스탬프로 변환할 수 있습니다:

```sql
lpep_pickup_datetime VARCHAR,
event_timestamp AS TO_TIMESTAMP(lpep_pickup_datetime, 'yyyy-MM-dd HH:mm:ss'),
WATERMARK FOR event_timestamp AS event_timestamp - INTERVAL '5' SECOND
```

Flink 작업을 실행하기 전에 결과를 담을 PostgreSQL 테이블을
미리 만들어 두세요.

Flink 작업에 대한 중요한 참고사항:

- 작업 파일은 `workshop/src/job/`에 두세요 — 이 디렉터리는
  Flink 컨테이너의 `/opt/src/job/`에 마운트됩니다
- 작업 제출 명령어:
  `docker exec -it workshop-jobmanager-1 flink run -py /opt/src/job/your_job.py`
- `green-trips` topic은 partition이 1개이므로, Flink 작업에서 parallelism을
  1로 설정하세요(`env.set_parallelism(1)`). parallelism이 더 높으면
  놀고 있는 consumer subtask 때문에 watermark가 진행되지 않습니다.
- Flink streaming 작업은 계속 실행됩니다. PostgreSQL에 결과가 나타날 때까지
  1~2분 정도 실행되도록 두었다가 결과를 조회하세요.
  작업은 http://localhost:8081 의 Flink UI에서 취소할 수 있습니다.
- topic에 데이터를 여러 번 보냈다면, 중복을 피하기 위해
  topic을 삭제하고 다시 생성하세요:
  `docker exec -it workshop-redpanda-1 rpk topic delete green-trips`


## 질문 4. Tumbling window - 승차 위치

`green-trips`에서 읽어서 5분 tumbling window로 `PULocationID`별
운행 횟수를 세는 Flink 작업을 만드세요.

결과를 다음 컬럼을 가진 PostgreSQL 테이블에 저장하세요:
`window_start`, `PULocationID`, `num_trips`.

작업이 모든 데이터를 처리한 뒤 결과를 조회하세요:

```sql
SELECT PULocationID, num_trips
FROM <your_table>
ORDER BY num_trips DESC
LIMIT 3;
```

단일 5분 window에서 운행이 가장 많았던 `PULocationID`는 무엇인가요?

- 42
- 74
- 75
- 166


## 질문 5. Session window - 가장 긴 연속 구간

`lpep_pickup_datetime`을 event time으로 사용하고 watermark 허용치를 5초로 두어,
`PULocationID`에 대해 5분 gap의 session window를 사용하는
또 다른 Flink 작업을 만드세요.

session window는 서로 5분 이내에 도착한 이벤트들을 묶습니다.
5분을 넘는 간격이 생기면 window가 닫힙니다.

결과를 PostgreSQL 테이블에 저장하고, 가장 긴 session(단일 session에서
운행이 가장 많은)을 가진 `PULocationID`를 찾으세요.

가장 긴 session에는 몇 건의 운행이 있었나요?

- 12
- 31
- 51
- 81


## 질문 6. Tumbling window - 최대 팁

1시간 tumbling window를 사용해 (모든 위치를 통틀어) 시간당 총
`tip_amount`를 계산하는 Flink 작업을 만드세요.

총 팁 금액이 가장 높았던 시간대는 언제인가요?

- 2025-10-01 18:00:00
- 2025-10-16 18:00:00
- 2025-10-22 08:00:00
- 2025-10-30 16:00:00


## 풀이 제출하기

- 제출 폼: https://courses.datatalks.club/de-zoomcamp-2026/homework/hw7


## 공개적으로 학습하기 (Learning in public)

배운 것을 공유하는 것을 권장합니다.
이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

## LinkedIn 게시물 예시

```
Week 7 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 7 - Streaming with PyFlink. Learned how to:

- Set up Redpanda as a Kafka replacement
- Build Kafka producers and consumers in Python
- Create tumbling and session windows in Flink
- Analyze real-time taxi trip data with stream processing

Here's my homework solution: <LINK>

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

## Twitter/X 게시물 예시

```
Module 7 of Data Engineering Zoomcamp done!

- Kafka producers and consumers
- PyFlink tumbling and session windows
- Real-time taxi data analysis
- Redpanda as Kafka replacement

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
