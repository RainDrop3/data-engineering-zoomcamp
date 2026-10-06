# Module 5 학습 TODO

> 목표: 지금까지 따로 배운 수집(Week 2 Kestra) · 변환(Week 4 dbt) · 오케스트레이션 · 품질 체크를 하나의 데이터 플랫폼(Bruin)에서 다뤄본다. NYC taxi 데이터로 ingestion → staging → reports 3계층 pipeline을 직접 완성하고, materialization 전략·변수·lineage를 익힌다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 사전 준비

- [ ] [README.md](README.md) 훑어보기 — 전체 흐름 파악
- [ ] git 설치 확인 — Bruin은 프로젝트가 git으로 초기화되어 있어야 동작함
- [ ] VS Code 또는 Cursor 준비
- [ ] 이번 모듈은 **로컬 DuckDB**로 진행 — GCP/BigQuery 불필요 (Bruin Cloud 배포만 예외)

> 💡 Module 4를 Local(DuckDB) 경로로 했다면 환경이 거의 그대로 재사용됩니다.

## 1. 개념 잡기

- [ ] [5.1 Bruin 소개](https://youtu.be/f6vg7lGqZx0) 영상 시청 → [01 노트](notes/01-introduction.md)
  - [ ] 모던 데이터 스택 4요소 정리: 수집 / 변환 / 오케스트레이션 / 품질·거버넌스
  - [ ] 지금까지 배운 도구와 대응시켜 보기: 수집=dlt·Kestra, 변환=dbt, 오케스트레이션=Kestra·Airflow
  - [ ] "도구 대여섯 개 대신 하나"의 장단점 생각해 보기

## 2. 설치와 첫 프로젝트

- [ ] [5.2 Bruin 시작하기](https://youtu.be/JJwHKSidX_c) 영상 시청 → [02 노트](notes/02-getting-started.md)
- [ ] Bruin CLI 설치: `curl -LsSf https://getbruin.com/install/cli | sh`
  - [ ] ⚠️ Windows라면 PowerShell이 아니라 **Git Bash나 WSL**에서 실행 (`| sh` 형식이라서)
- [ ] `bruin version`으로 설치 확인
- [ ] VS Code/Cursor에 **Bruin 확장** 설치 — render 패널, lineage 탭 사용
- [ ] `bruin init default my-first-pipeline`으로 첫 프로젝트 생성
  - [ ] ⚠️ 이 저장소 안에 만든다면 중첩된 `.git`이 생기지 않았는지 확인
- [ ] 생성된 구조 확인: `.bruin.yml` / `pipeline.yml` / `assets/`
- [ ] ⚠️ `.bruin.yml`이 `.gitignore`에 들어 있는지 확인 — connection과 secret이 담기는 파일
- [ ] Bruin 패널에서 asset 세 종류 실행해 보기
  - [ ] Python asset (`my_python_asset.py`)
  - [ ] YAML ingestor asset (`players.asset.yml`) — Chess.com → DuckDB
  - [ ] SQL asset (`player_stats.sql`) — 품질 체크 포함
- [ ] `bruin validate .` → `bruin run .` 순서로 CLI에서도 실행해 보기

## 3. 핵심 개념 (Core Concepts)

> 💡 README에는 맨 뒤에 있지만, **4번 pipeline 구축 전에 보는 편이** 템플릿 TODO를 채우기 훨씬 수월합니다. 영상이 3~7분으로 짧습니다.

- [ ] [Projects](https://www.youtube.com/watch?v=YWDjnSxbBtY) → [노트](notes/06-core-01-projects.md)
  - [ ] `.bruin.yml`의 environment와 connection 구조
  - [ ] 기본 environment를 dev로 두는 이유 (프로덕션 오실행 방지)
- [ ] [Pipelines](https://www.youtube.com/watch?v=uzp_DiR4Sok) → [노트](notes/06-core-02-pipelines.md)
  - [ ] **pipeline 하나 = 스케줄 하나** — asset을 묶는 기준
  - [ ] connection은 project에서 정의하고 pipeline에서 골라 쓰는 이유 (보안 격리)
- [ ] [Assets](https://www.youtube.com/watch?v=ZElY5SoqrwI) → [노트](notes/06-core-03-assets.md)
  - [ ] asset = definition(설정) + content(코드)
  - [ ] 파일 경로로부터 asset 이름이 추론되는 규칙 (`assets/staging/x.sql` → `staging.x`)
- [ ] [Variables](https://www.youtube.com/watch?v=XCx0nDmhhxA) → [노트](notes/06-core-04-variables.md)
  - [ ] 내장 변수 `start_date` / `end_date`가 스케줄에 따라 어떻게 정해지는지
  - [ ] 커스텀 변수 정의와 `--var`로 덮어쓰기
- [ ] [Commands](https://www.youtube.com/watch?v=3nykPEs_V7E) → [노트](notes/06-core-05-commands.md)
  - [ ] `run` / `validate` / `lineage` / `query` 용도 정리
  - [ ] `--upstream` / `--downstream` 차이 (dbt의 `+model` / `model+`와 대응)
- [ ] ⚠️ **06-core 노트의 코드 예시는 실제 문법과 다름** — 아래 차이를 알고 읽기
  - [ ] `@bruin.asset(...)` 데코레이터 → 실제로는 SQL은 `/* @bruin ... @bruin */`, Python은 `"""@bruin ... @bruin"""` 블록
  - [ ] Python의 `BRUIN_VAR_START_DATE` / `BRUIN_VAR_TAXI_TYPES` → 실제로는 `BRUIN_START_DATE`, 커스텀 변수는 `BRUIN_VARS`(JSON)
  - [ ] `variables:`를 `- name:` 리스트로 쓴 예시 → 실제로는 JSON Schema 형식의 맵 (`taxi_types: {type: array, ...}`)
  - [ ] 실습은 [03 노트](notes/03-nyc-taxi-pipeline.md)와 템플릿 주석의 문법을 따를 것

## 4. NYC Taxi pipeline 구축 (이 모듈의 핵심)

- [ ] [5.3 End-to-End Pipeline](https://youtu.be/q0k_iz9kWsI) 영상 시청 → [03 노트](notes/03-nyc-taxi-pipeline.md)
- [ ] `bruin init zoomcamp my-taxi-pipeline`으로 템플릿 받기
- [ ] 생성된 `README.md` 읽기 — TODO 기반 과제 안내
- [ ] 3계층 아키텍처 이해: ingestion(raw) → staging(정제·join) → reports(집계)

### 4-1. 설정 파일

- [ ] `.bruin.yml` — DuckDB connection `duckdb-default` 정의
- [ ] `pipeline/pipeline.yml` TODO 채우기
  - [ ] `name`, `schedule`, `start_date`
  - [ ] `default_connections: duckdb: duckdb-default`
  - [ ] `taxi_types` 변수 — `type: array`, `items: {type: string}`, `default`

### 4-2. Ingestion 계층

- [ ] `ingestion/trips.py` 작성
  - [ ] `materialization: {type: table, strategy: append}`
  - [ ] `materialize()`가 DataFrame을 반환 → 적재는 Bruin이 처리
  - [ ] `BRUIN_START_DATE` / `BRUIN_END_DATE`로 기간 받기
  - [ ] `BRUIN_VARS`(JSON)에서 `taxi_types` 읽기
  - [ ] 기간 내 월 목록을 만들어 parquet 파일 다운로드
- [ ] `requirements.txt` 확인 (pandas, requests, pyarrow, python-dateutil)
- [ ] `ingestion/payment_lookup.asset.yml` — `type: duckdb.seed`로 CSV 적재
  - [ ] `payment_type_id`에 `not_null` + `unique` 체크

### 4-3. Staging 계층

- [ ] `staging/trips.sql` 작성
  - [ ] `depends:` — `ingestion.trips`, `ingestion.payment_lookup`
  - [ ] `strategy: time_interval` + `incremental_key: pickup_datetime`
  - [ ] ⚠️ `WHERE`로 **같은 시간 구간**(`{{ start_datetime }}` ~ `{{ end_datetime }}`)을 필터링 — 안 하면 중복 발생
  - [ ] `QUALIFY ROW_NUMBER()`로 복합 키 기준 중복 제거
  - [ ] payment lookup `LEFT JOIN`
  - [ ] `custom_checks`로 행 수 > 0 검사

### 4-4. Reports 계층

- [ ] `reports/trips_report.sql` 작성
  - [ ] `depends: staging.trips`
  - [ ] `time_interval` + `incremental_key: trip_date`, `time_granularity: date`
  - [ ] 날짜 · taxi 유형 · 결제 유형별 trip 수 / 총 요금 / 평균 요금 집계
  - [ ] `trip_count`에 `non_negative` 체크

### 4-5. 실행과 검증

- [ ] `bruin validate ./pipeline/pipeline.yml`
- [ ] **짧은 기간으로 먼저** 실행: `--start-date 2022-01-01 --end-date 2022-02-01`
- [ ] `bruin query`로 각 계층 테이블 행 수 확인
- [ ] Bruin 패널의 **lineage 탭**에서 실행 순서 확인 (ingestion 병렬 → staging → reports)
- [ ] `--var`로 `taxi_types`를 바꿔 green도 수집해 보기
- [ ] `--full-refresh`로 처음부터 다시 빌드해 보기
- [ ] materialization 전략 6가지 정리
  - [ ] `table` / `append` / `merge` / `time_interval` / `delete+insert` / `create+replace`
  - [ ] dbt의 materialization(table / view / incremental)과 비교해 보기

## 5. Bruin MCP와 AI 에이전트 (선택)

- [ ] [5.4 Bruin MCP](https://youtu.be/224xH7h8OaQ) 영상 시청 → [04 노트](notes/04-bruin-mcp.md)
- [ ] MCP 등록 — Claude Code라면 `claude mcp add bruin -- bruin mcp`
- [ ] 에이전트에게 pipeline 질문해 보기 ("어느 asset에서 집계하고 있어?")
- [ ] 자연어로 데이터 조회해 보기 ("trip 수가 가장 많았던 날은?")
- [ ] (선택) 새 디렉토리에 템플릿 README의 프롬프트로 pipeline 전체를 생성해 보고 직접 만든 것과 비교

> 💡 직접 4번을 끝낸 뒤에 해보세요. 에이전트가 만든 코드를 검토할 수 있는 눈이 생긴 다음이어야 의미가 있습니다.

## 6. Bruin Cloud 배포 (선택)

- [ ] [5.5 Bruin Cloud](https://youtu.be/uBqjLEwF8rc) 영상 시청 → [05 노트](notes/05-bruin-cloud.md)
- [ ] Bruin Cloud 가입 + organization 생성
- [ ] GitHub 저장소 연결 (직접 연결 권장)
- [ ] 클라우드 connection 설정 — **로컬과 같은 connection 이름** 사용
  - [ ] ⚠️ 로컬 `duckdb.db` 파일은 클라우드에서 쓸 수 없음 → MotherDuck이나 BigQuery 같은 클라우드 connection 필요
- [ ] pipeline **enable** → 직전 interval run이 자동 생성되는지 확인
- [ ] asset 상태 · 품질 체크 결과 · lineage 모니터링

## 7. 숙제

- [ ] [Homework](../cohorts/2026/05-data-platforms/homework.md) 풀기 — 개념 문제 7개
  - [ ] Q1 프로젝트 필수 구조 / Q2 materialization 전략 / Q3 변수 덮어쓰기
  - [ ] Q4 downstream 실행 / Q5 품질 체크 / Q6 lineage 명령 / Q7 최초 실행 플래그
- [ ] 노트만 보고 고르지 말고 **실제 명령을 실행해** 답을 확인하기 (특히 Q3, Q4, Q7)
  - [ ] ⚠️ Q3의 `--var` 값은 셸마다 따옴표 처리가 다르니 실제로 돌려볼 것
- [ ] 완성한 pipeline을 GitHub에 push (`.bruin.yml` 제외 확인!)
- [ ] [제출 폼](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw5)에 답안 + GitHub 링크 제출

## 8. 정리

- [ ] `duckdb.db` 파일 정리 — 여러 달 수집하면 용량 큼
- [ ] (Cloud) 연습용 pipeline disable — 스케줄대로 계속 돌지 않게
- [ ] (Cloud) MotherDuck/BigQuery에 만든 연습 테이블 정리
- [ ] 최종 Bruin 프로젝트 커밋

---

## 다음 단계

Module 5를 마치면 → `06-batch/` (Spark로 대용량 batch 처리)

## 팁

- 이 모듈의 핵심은 Bruin 문법 자체보다 **데이터 플랫폼이 무엇을 하나로 묶는가**입니다. asset, 의존성 DAG, lineage, 품질 체크, environment 분리, incremental 처리 — 모두 dbt·Airflow·Dagster에서도 그대로 통하는 개념입니다.
- dbt와 대응시켜 보면 빨리 익힙니다: `ref()` → `depends:`, `dbt test` → `checks:`, `+model+` → `--upstream`/`--downstream`, `dbt build --full-refresh` → `bruin run --full-refresh`.
- **실행 전에는 항상 `bruin validate`** — 순환 의존성, 깨진 참조, 없는 connection을 실행 없이 잡아줍니다. dbt의 `dbt compile`과 같은 습관입니다.
- 첫 실행은 반드시 **한 달 정도의 짧은 기간**으로 하세요. 기간 없이 돌리면 `start_date`부터 전부 받아오느라 오래 걸립니다.
- SQL asset의 Jinja 변수가 어떻게 치환되는지 헷갈리면 VS Code의 **Bruin Render 패널**로 컴파일된 쿼리를 확인하세요.
- 06-core 노트와 03 노트의 문법이 다를 때는 **03 노트와 템플릿 주석이 정답**입니다 (3번 ⚠️ 참고).
- 막히면 [DataTalksClub Slack](https://datatalks.club/slack.html)이나 [Bruin Slack](https://getbruin.com/)에 질문하거나 README 하단의 커뮤니티 노트를 참고하세요.
