# Module 2 학습 TODO

> 목표: Kestra로 workflow orchestration을 익히고, NY Taxi 데이터를 로컬 Postgres에 적재하는 ETL 파이프라인과 GCS + BigQuery로 적재하는 ELT 파이프라인을 만들어 본다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 사전 준비

- [ ] Module 1 완료 확인 — Docker, Docker Compose, GCP 서비스 계정, `GOOGLE_APPLICATION_CREDENTIALS` 설정
- [ ] Module 1에서 만든 GCS 버킷과 BigQuery 데이터셋이 살아있는지 확인 (없으면 2.4에서 flow로 생성 가능)
- [ ] 이번 주 영상 재생목록 확인: [YouTube Playlist](https://go.kestra.io/de-zoomcamp/yt-playlist)
- [ ] [README.md](README.md) 훑어보기 — 전체 흐름 파악

## 1. Workflow Orchestration 소개 (2.1)

- [ ] [2.1.1 - Workflow Orchestration이란?](https://youtu.be/-JLnp-iLins) — orchestrator의 역할, 스케줄/이벤트 기반 실행
- [ ] [2.1.2 - Kestra란?](https://youtu.be/ZvVN_NmB_1s) — YAML 기반 flow, 플러그인 생태계
- [ ] 참고: [What is an Orchestrator?](https://go.kestra.io/de-zoomcamp/what-is-an-orchestrator)

## 2. Kestra 시작하기 (2.2)

- [ ] [2.2.1 - Kestra 설치하기](https://youtu.be/wgPxC4UjoLM)
  - [ ] [docker-compose.yml](docker-compose.yml) 확인 — Kestra + Postgres 서비스, 볼륨 설정
  - [ ] `docker compose up -d` 실행
  - [ ] [http://localhost:8080](http://localhost:8080) 접속 확인
  - [ ] 포트 충돌 시 [문제 해결 팁](README.md#문제-해결-팁) 참고 (pgAdmin이 8080을 쓰고 있을 수 있음)
- [ ] [2.2.2 - Kestra 개념](https://youtu.be/MNOKVx8780E)
  - [ ] Flow / Task / Input / Output / Trigger / Execution / Variable / Plugin Default / Concurrency 개념 정리
  - [ ] [`flows/01_hello_world.yaml`](flows/01_hello_world.yaml) 실행 — 위 개념이 한 flow에 모두 들어있음
- [ ] [2.2.3 - Python 코드 orchestration하기](https://youtu.be/VAHm0R_XjqI)
  - [ ] [`flows/02_python.yaml`](flows/02_python.yaml) 실행 — Python 스크립트의 결과를 output으로 받기

## 3. 로컬 ETL 파이프라인: Postgres (2.3)

- [ ] [2.3.1 - 시작용 파이프라인](https://youtu.be/-KmwrCqRhic)
  - [ ] [`flows/03_getting_started_data_pipeline.yaml`](flows/03_getting_started_data_pipeline.yaml) 실행
  - [ ] Gantt 탭과 Logs 탭에서 실행 과정 확인
- [ ] [2.3.2 - Taxi 데이터를 Postgres에 적재하기](https://youtu.be/Z9ZmmwtXDcU)
  - [ ] [`flows/04_postgres_taxi.yaml`](flows/04_postgres_taxi.yaml) 실행
  - [ ] 연/월 input을 바꿔가며 실행해 보기
  - [ ] 월별 테이블 → 최종 테이블 병합(merge) 방식 이해하기
- [ ] [2.3.3 - 스케줄링과 backfill](https://youtu.be/1pu_C_oOAMA)
  - [ ] [`flows/05_postgres_taxi_scheduled.yaml`](flows/05_postgres_taxi_scheduled.yaml) 실행
  - [ ] 2019년 green taxi 데이터로 backfill 실행해 보기 (데이터가 크므로 green만!)

## 4. 클라우드 ELT 파이프라인: GCS + BigQuery (2.4)

- [ ] [2.4.1 - ETL vs ELT](https://youtu.be/E04yurp1tSU) — 클라우드에서 순서를 바꾸는 이유 이해하기
- [ ] [2.4.2 - GCP 설정하기](https://youtu.be/TLGFAOHpOYM)
  - [ ] [`flows/06_gcp_kv.yaml`](flows/06_gcp_kv.yaml)에 KV Store 값 채우기 — `GCP_PROJECT_ID`, `GCP_LOCATION`, `GCP_BUCKET_NAME`, `GCP_DATASET`
  - [ ] ⚠️ `GCP_CREDS` 서비스 계정 키를 Git에 커밋하지 않기
  - [ ] (버킷/데이터셋이 없다면) [`flows/07_gcp_setup.yaml`](flows/07_gcp_setup.yaml)로 생성
- [ ] [2.4.3 - GCS와 BigQuery로 ELT 파이프라인 만들기](https://youtu.be/52u9X_bfTAo)
  - [ ] [`flows/08_gcp_taxi.yaml`](flows/08_gcp_taxi.yaml) 실행
  - [ ] External Table → 월별 테이블 → 메인 테이블 병합 흐름 이해하기
- [ ] [2.4.4 - 스케줄링과 전체 backfill](https://youtu.be/b-6KhfWfk2M)
  - [ ] [`flows/09_gcp_taxi_scheduled.yaml`](flows/09_gcp_taxi_scheduled.yaml) 실행
  - [ ] yellow/green 전체 데이터셋 backfill (클라우드라 로컬과 달리 리소스 걱정 없음)

## 5. 데이터 엔지니어링에 AI 활용하기 (2.5)

- [ ] [2.5.1 - 데이터 엔지니어링에 AI 활용하기](https://youtu.be/GHPtRDAv044)
- [ ] [2.5.2 - ChatGPT로 알아보는 Context Engineering](https://youtu.be/LmnfjGKwnVU)
  - [ ] context 없는 ChatGPT로 Kestra flow 생성해 보고 어떤 오류가 나오는지 관찰
- [ ] [2.5.3 - Kestra의 AI Copilot](https://youtu.be/3IbjHfC8bMg)
  - [ ] [Google AI Studio](https://aistudio.google.com/app/apikey)에서 Gemini API 키 발급
  - [ ] `docker-compose.yml`에 AI 설정 추가 후 Kestra 재시작
  - [ ] 같은 프롬프트로 ChatGPT 결과와 AI Copilot 결과 비교
- [ ] (보너스) [2.5.4 - RAG](https://youtu.be/XuPDQ1UcNyI)
  - [ ] [`flows/10_chat_without_rag.yaml`](flows/10_chat_without_rag.yaml) 실행 — RAG 없이
  - [ ] [`flows/11_chat_with_rag.yaml`](flows/11_chat_with_rag.yaml) 실행 — RAG 적용
  - [ ] 두 출력 비교하기

## 6. 보너스: 클라우드 배포 (2.6, 선택)

- [ ] [Install Kestra on Google Cloud](https://go.kestra.io/de-zoomcamp/gcp-install) 읽기
- [ ] [Using Git in Kestra](https://go.kestra.io/de-zoomcamp/git) — Git 저장소에서 flow 자동 동기화
- [ ] Secrets와 KV Store로 민감 정보 분리하기

## 7. 숙제

- [ ] [Homework](../cohorts/2026/02-workflow-orchestration/homework.md) 풀기

## 8. 정리

- [ ] 실습이 끝나면 `docker compose down`으로 컨테이너 정리
- [ ] 필요 없는 GCS 객체 / BigQuery 테이블 삭제 (비용 방지!)

---

## 다음 단계

Module 2를 마치면 → `03-data-warehouse/` (BigQuery와 data warehouse)로 진행

## 팁

- Kestra 이미지는 `kestra/kestra:v1.1`, Postgres는 `postgres:18`로 **버전을 고정**하세요. `develop` 태그는 개발 버전이라 버그가 있을 수 있습니다.
- backfill은 데이터 양이 많아 오래 걸립니다. 로컬 Postgres 단계(2.3)에서는 green taxi 2019년으로만 제한하세요.
- flow는 UI에 직접 붙여넣어도 되고, [README의 curl 명령어](README.md#kestra에-flow-추가하기)로 한 번에 import할 수도 있습니다.
- `BigQueryError ... CSV table references column position 17` 류의 오류는 스키마 문제가 아니라 파일 전송이 덜 된 경우가 대부분입니다. 다시 실행하면 해결됩니다.
- 막히면 [DataTalksClub Slack](https://datatalks.club/slack.html) 또는 [Kestra Slack](http://kestra.io/slack)에 질문하세요.
