# Module 7 학습 TODO

> 목표: 실시간(streaming) 처리의 기본 흐름을 직접 만들어 본다. Redpanda(Kafka 호환 broker)에 Python producer로 이벤트를 보내고, consumer로 읽고, PostgreSQL에 저장해 본 뒤, PyFlink로 tumbling window 집계까지 구현한다. 마지막으로 green taxi 데이터로 숙제를 푼다.
> 이번 모듈은 영상 한 편(라이브 워크숍)과 README 기반의 step-by-step 실습이 중심입니다. Kafka 이론 강의(Java)와 `extras/`는 선택입니다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 가장 먼저 — 실행 환경 정하기 ⚠️

이 모듈은 **Docker Compose로 Redpanda · Flink · PostgreSQL을 띄우는 것**이 전부의 출발점입니다. Spark 때와 달리 Python/Java를 로컬에 깔 필요는 거의 없고, 대신 Docker가 제대로 돌아가야 합니다.

- [ ] Docker Desktop 실행 확인 — `docker version`, `docker compose version`
  - [ ] (Windows) Docker Desktop이 WSL2 백엔드로 동작하는지 확인
  - [ ] Flink 이미지를 빌드하고 컨테이너 3~4개를 동시에 띄우므로 **메모리 여유**가 필요 (Docker Desktop에 4GB 이상 권장)
- [ ] `uv` 설치 확인 — 워크숍이 `uv init` / `uv add` / `uv run`으로 진행됨 (Module 6에서 이미 사용)
- [ ] SQL 클라이언트 하나 정하기 — `uvx pgcli`, DBeaver, pgAdmin, DataGrip 중 편한 것
- [ ] 포트 충돌 확인 — `9092`(Redpanda), `8081`(Flink UI), `5432`(PostgreSQL)
  - [ ] ⚠️ 로컬에 PostgreSQL이나 이전 모듈(Module 1/2)의 postgres 컨테이너가 떠 있으면 `5432`가 겹침 → 먼저 `docker ps`로 확인하고 정리

> 💡 Windows 메모
> - Git Bash에는 `wget`이 없으므로 가이드의 `wget URL`은 `curl -LO URL`로 바꿔 실행합니다. (저장소를 clone했다면 파일이 이미 있어서 다운로드가 필요 없음)
> - `docker exec -it ...`가 Git Bash에서 "the input device is not a TTY"로 실패하면 앞에 `winpty`를 붙이거나 PowerShell/WSL에서 실행합니다.
> - 워크숍의 `watch -n 1 '...'` 명령(late events 실습)은 Git Bash에 없음 → WSL을 쓰거나 같은 SQL을 SQL 클라이언트에서 반복 실행합니다.

## 1. 개념 잡기

- [ ] [README.md](README.md) 훑어보기 — 전체 구성 파악 (워크숍 / 숙제 / Kafka 이론 / extras)
- [ ] [워크숍 영상](https://www.youtube.com/live/YDUgFeHQzJU) 시청 (라이브 영상이라 길다 — README와 함께 보며 필요한 부분 위주로)
  - [ ] batch vs streaming 차이 정리 (Module 6과 대비) — 데이터를 모아서 처리 vs 도착하는 대로 처리
  - [ ] message broker의 역할: producer가 보낸 메시지를 저장하고 consumer에게 전달
  - [ ] 전체 흐름 한 줄로 그려 보기: `Producer (Python) → Kafka (Redpanda) → Flink → PostgreSQL`
- [ ] (선택) Kafka 이론 강의 — [theory/README.md](theory/README.md)의 7.0.1~7.6 (Kafka가 무엇이고 producer/consumer/configuration이 어떻게 동작하는지)
  - [ ] ⚠️ 코드 예제는 Java이고 일부 강의는 Confluent Cloud 기준 — 개념 이해용으로만 보고, 실습은 워크숍 README를 따를 것
  - [ ] (선택) Kafka Streams 강의 7.7~7.12 (stream join, windowing, ksqlDB, Schema registry)

## 2. Redpanda 띄우기 (워크숍 1단계)

- [ ] [워크숍 README](workshop/README.md) 읽기 시작 — 처음부터 만드는 방식이라 순서대로 따라가면 됨
- [ ] 왜 Kafka 대신 Redpanda인가: JVM 없음 · ZooKeeper 없음 · 단일 바이너리
- [ ] `docker-compose.yml`의 Redpanda 설정 이해
  - [ ] 리소스 옵션: `--smp 1`, `--reserve-memory 0M`, `--overprovisioned`, `--node-id 1`
  - [ ] **listener가 2개인 이유** — Docker 내부(`redpanda:29092`)와 내 PC(`localhost:9092`)의 접속 주소가 달라서 (advertised address)
  - [ ] 포트 정리: `9092` 외부 Kafka, `29092` 내부 Kafka (Flink가 나중에 사용), `8082`/`28082` HTTP Proxy(이번엔 안 씀)
- [ ] `docker compose up redpanda -d` → `docker compose ps`로 Up 확인

## 3. Python으로 produce / consume (워크숍 2단계)

- [ ] 프로젝트 준비 — `uv init -p 3.12` → `uv add kafka-python pandas pyarrow` (clone했다면 `uv sync`)
  - [ ] ⚠️ 저장소의 `workshop/.python-version`은 3.13 — 이 PC 기본 Python은 3.14이므로, 패키지 설치 문제가 생기면 `uv python pin 3.12`
- [ ] **Produce** — NYC yellow taxi 데이터를 Kafka topic으로 보내기 ([src/producers/producer.py](workshop/src/producers/producer.py), [src/models.py](workshop/src/models.py))
  - [ ] 데이터 모델(`Ride`)을 만들고 JSON으로 serialize
  - [ ] topic에 메시지가 실제로 들어갔는지 확인 (`rpk topic consume` 등)
- [ ] **Consume** — Python consumer로 topic 읽기 ([src/consumers/consumer.py](workshop/src/consumers/consumer.py))
  - [ ] consumer group과 offset 개념 이해
- [ ] **PostgreSQL에 저장** — consumer가 읽은 이벤트를 DB에 쓰기 ([src/consumers/consumer_postgres.py](workshop/src/consumers/consumer_postgres.py))
  - [ ] `docker compose`에 postgres 서비스 추가, SQL 클라이언트로 접속 (`postgres` / `postgres`)
  - [ ] `processed_events` 테이블 생성 후 행이 쌓이는지 확인
- [ ] 직접 만든 consumer의 한계 정리 — 장애 복구, offset 수동 관리, windowing, sink별 코드 작성 → **그래서 Flink**

## 4. Flink 환경 (워크숍 3단계)

- [ ] **Why Flink?** 이해 — windowing · checkpointing · parallelism · connectors · SQL interface
  - [ ] 대가: JobManager/TaskManager를 상시 운영해야 함 (streaming job은 "서버를 소유하는 것"에 가깝다)
- [ ] Flink Docker 이미지 준비 — [Dockerfile.flink](workshop/Dockerfile.flink), [pyproject.flink.toml](workshop/pyproject.flink.toml), [flink-config.yaml](workshop/flink-config.yaml)
  - [ ] Dockerfile이 하는 일: 공식 Flink 이미지 + Python + PyFlink + connector JAR(Kafka, JDBC, PostgreSQL) + JVM metaspace 설정
  - [ ] ⚠️ Apple Silicon(ARM)이면 [Dockerfile_ARM64.flink](workshop/Dockerfile_ARM64.flink) 사용 — Windows/x86에서는 불필요
- [ ] `docker-compose.yml`에 JobManager와 TaskManager 추가 (하나씩 단계적으로)
- [ ] `docker compose build` → `docker compose up -d`
  - [ ] 첫 빌드는 오래 걸림 (이미지 + JAR 다운로드)
- [ ] Flink 대시보드 [http://localhost:8081](http://localhost:8081) 접속 — TaskManager 1개, 사용 가능한 slot 15개 확인

## 5. Flink job 실습 (워크숍 4단계)

- [ ] **Pass-through job** — consumer가 하던 일을 Flink로 ([src/job/pass_through_job.py](workshop/src/job/pass_through_job.py))
  - [ ] ⚠️ Flink job은 Jupyter가 아니라 `.py` 파일로 만들어 클러스터에 **제출**하는 방식
  - [ ] `docker compose exec jobmanager flink run -py /opt/src/job/pass_through_job.py ...`로 제출
  - [ ] Flink UI에서 job이 RUNNING인지, 데이터가 PostgreSQL에 들어오는지 확인
- [ ] **Offsets — earliest vs latest** 이해
  - [ ] 새 job은 어디서부터 읽는가 (`scan.startup.mode`)
  - [ ] 같은 topic을 다시 처음부터 읽고 싶을 때 어떻게 하는가
- [ ] **Tumbling window 집계** ([src/job/aggregation_job.py](workshop/src/job/aggregation_job.py))
  - [ ] event time과 **watermark**(허용 지연) 개념 이해 — 5초 watermark가 무슨 뜻인지 설명해 보기
  - [ ] 1시간 tumbling window로 시간대별 운행 수·매출 집계 → PostgreSQL 결과 테이블 확인
  - [ ] `PRIMARY KEY`를 지정한 sink가 **upsert**로 동작하는 이유
- [ ] **Late events and upserts** — [src/producers/producer_realtime.py](workshop/src/producers/producer_realtime.py)로 실시간 이벤트 생성
  - [ ] 약 20%의 이벤트가 3~10초 늦게 도착 — 이전 window 집계 값이 나중에 갱신되는 것을 눈으로 확인
  - [ ] ⚠️ 문서의 `watch -n 1 ...`는 Git Bash 미지원 (위 0번 참고)
- [ ] **Window 종류** 구분해서 설명할 수 있게 정리
  - [ ] Tumbling: 고정 크기, 겹치지 않음 (시간당 운행 수)
  - [ ] Sliding(`HOP`): 고정 크기, 겹침 (피크 구간 탐지, 이동 평균)
  - [ ] Session: 비활동 gap 기준으로 닫힘 (사용자 행동 묶기) — 숙제 Q5에서 사용

## 6. Q&A 읽기

워크숍 README 하단의 Q&A는 시험·면접에서 물을 법한 내용입니다.

- [ ] Flink job이 죽었다 다시 시작하면 처음부터 다시 처리하는가? (checkpoint)
- [ ] Kafka consumer만으로는 안 되는가? Flink가 더해 주는 것은?
- [ ] watermark보다 늦게 온 이벤트는 어떻게 되는가?
- [ ] 정말 streaming이 필요한 경우는 언제인가? (micro-batch로 충분한 경우와 비교)
- [ ] Spark Streaming vs Flink Streaming
- [ ] 운영 환경에서 job 제출은 어떻게 하는가?

## 7. (선택) extras 둘러보기

- [ ] [extras/README.md](extras/README.md) — 이전 기수 자료 목록. 필수 아님
- [ ] [extras/python/](extras/python/) — `kafka-python` JSON 예제, `confluent-kafka` + Avro + Schema Registry 예제
  - [ ] Faust(Python 기반 Kafka Streams)와 PySpark Structured Streaming 예제와 비교해 보기
- [ ] [extras/pyflink/](extras/pyflink/) — Flink 1.x + Makefile 기반의 예전 워크숍 (현재 워크숍은 Flink 2.2 + uv로 재작성된 것)
  - [ ] ⚠️ 예전 `homework.md`는 지난 기수의 것 — 2026 숙제와 혼동하지 말 것
- [ ] [extras/ksqldb/commands.md](extras/ksqldb/commands.md) — ksqlDB 쿼리 예시 (stream 생성, 필터, 집계, windowed 집계)

## 8. 숙제

- [ ] [Homework](../cohorts/2026/07-streaming/homework.md) 풀기
- [ ] 환경 준비 — **워크숍과 같은 인프라** 사용 (디렉터리 이름이 `workshop`이어야 컨테이너 이름이 맞음)
  - [ ] `cd 07-streaming/workshop/` → `docker compose build` → `docker compose up -d`
  - [ ] 이전에 워크숍을 돌렸다면 깨끗하게: `docker compose down -v` 후 다시 build/up
- [ ] 데이터: [green_tripdata_2025-10.parquet](https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet) 받기
  - [ ] Git Bash라면 `wget` 대신 `curl -LO`
- [ ] **Part 1: Redpanda / Python**
  - [ ] Q1 `docker exec -it workshop-redpanda-1 rpk version` — Redpanda 버전
  - [ ] Q2 `green-trips` topic 만들기 → 8개 컬럼만 남겨 producer로 전송 → 전송 + flush 소요 시간 측정
    - [ ] ⚠️ datetime 컬럼은 JSON 직렬화 전에 문자열로 변환
  - [ ] Q3 `auto_offset_reset='earliest'` consumer로 전체 읽기 → `trip_distance > 5`인 운행 수
- [ ] **Part 2: PyFlink** (워크숍 코드를 green taxi용으로 수정)
  - [ ] 바꿀 점: topic `green-trips`, 컬럼 접두사 `lpep_`, 타임스탬프가 epoch 밀리초가 아니라 **문자열** (`TO_TIMESTAMP(...)`로 변환)
  - [ ] ⚠️ `env.set_parallelism(1)` — topic partition이 1개라 parallelism이 높으면 watermark가 진행되지 않음
  - [ ] job 파일은 `workshop/src/job/`에 두기 (컨테이너의 `/opt/src/job/`에 마운트됨)
  - [ ] 결과를 담을 PostgreSQL 테이블을 **job 실행 전에** 미리 만들기
  - [ ] Q4 5분 tumbling window로 `PULocationID`별 운행 수 → 단일 window에서 운행이 가장 많은 `PULocationID`
  - [ ] Q5 5분 gap session window(watermark 5초) → 가장 긴 session의 운행 수
  - [ ] Q6 1시간 tumbling window로 시간당 `tip_amount` 합계 → 팁이 가장 많았던 시간대
  - [ ] 결과가 나오는 데 1~2분 걸림 — 기다렸다가 조회, 끝나면 Flink UI(`localhost:8081`)에서 job 취소
  - [ ] topic에 데이터를 여러 번 보냈다면 `rpk topic delete green-trips` 후 재생성 (중복 방지)
- [ ] 풀이 코드(producer, consumer, Flink job)를 저장소에 커밋
- [ ] [제출 폼](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw7)에 답안 + GitHub 링크 제출

## 9. 정리

- [ ] ⚠️ Flink job 취소 확인 — streaming job은 직접 멈추지 않으면 계속 돌며 리소스를 먹음
- [ ] `docker compose down` (PostgreSQL 데이터까지 지우려면 `docker compose down -v`)
- [ ] 안 쓰는 이미지/볼륨 정리 — Flink 이미지가 큼 (`docker image prune`, `docker volume prune`)
- [ ] 다운로드한 parquet 파일 정리
- [ ] (선택) [Learning in public](../learning-in-public.md) — 숙제 README 하단의 LinkedIn/Twitter 예시 참고해 공유

---

## 다음 단계

Module 7까지 마치면 강의의 모든 모듈이 끝납니다 → [`projects/`](../projects/)의 **최종 프로젝트**(capstone) 준비

## 팁

- streaming job은 **끝나지 않습니다.** 제출한 Flink job은 계속 RUNNING 상태라서, 결과를 확인한 뒤 Flink UI에서 직접 취소해야 합니다. "왜 job이 안 끝나지?" 싶으면 정상입니다.
- 막히면 먼저 **Flink UI(`localhost:8081`)** 를 여세요. job 상태, 예외 로그, watermark 진행을 볼 수 있습니다. Spark UI(`4040`)와 같은 역할입니다.
- window 결과가 안 나오면 대개 **watermark가 진행되지 않아서**입니다. 이벤트가 더 안 들어오면 마지막 window는 닫히지 않습니다. parallelism과 partition 수 불일치도 흔한 원인입니다.
- 컨테이너 안에서는 `redpanda:29092`, 내 PC(Python 스크립트)에서는 `localhost:9092`입니다. 접속이 안 되면 어느 쪽에서 실행하고 있는지부터 확인하세요.
- Module 6(batch)과 비교해 보면 좋습니다. 같은 "시간당 집계"를 Spark batch와 Flink tumbling window로 풀어 보면 두 방식의 차이(지연 시간, 늦게 온 데이터 처리)가 잘 보입니다.
- `workshop/live/`는 강사가 라이브로 만든 코드이고, `workshop/` 최상위가 정리된 참고 코드입니다. 둘이 약간 다를 수 있습니다.
- 막히면 [DataTalksClub Slack](https://datatalks.club/slack.html)에 질문하세요.
