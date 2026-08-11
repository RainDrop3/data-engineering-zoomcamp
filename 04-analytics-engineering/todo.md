 # Module 4 학습 TODO

> 목표: DWH에 적재된 raw 데이터를 dbt로 변환해 분석용 모델을 만든다. staging → intermediate → marts 계층을 직접 쌓아 올리고, source/ref로 의존성 그래프를 만들고, seed·macro로 중복을 없애고, test와 문서로 신뢰할 수 있는 파이프라인을 완성한다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 가장 먼저 — 경로부터 정하기 ⚠️

이 모듈은 **두 갈래로 갈리며, 첫 단추를 잘못 끼우면 되돌리기 번거롭습니다.** 나머지 모든 단계가 이 선택에 달려 있으니 여기부터 결정하세요.

- [ ] 아래 표를 보고 경로 선택

| | 🏠 Local (DuckDB + dbt Core) | ☁️ Cloud (BigQuery + dbt Platform) |
|---|---|---|
| Module 3 선행 | **불필요** | 필요 |
| 데이터 적재 | 스크립트가 전부 처리 | 직접 적재 (yellow+green 2019~2020) |
| 비용 | 무료 | BigQuery 과금 (무료 티어 내 가능) |
| RAM 요구 | 16GB 권장, 8GB는 OOM 위험 | 무관 |
| 강의 영상 | 강의 기본 경로 | 대안 영상 별도 제공 |

- [ ] **Local을 골랐다면** → 1번 건너뛰고 [2. Local Setup](#2-local-setup으로-가는-경우)로
- [ ] **Cloud를 골랐다면** → [1. 데이터 적재](#1-cloud-경로-데이터-적재-cloud만)부터

> 💡 판단 기준: RAM이 16GB 미만이면 Cloud가 편합니다. 반대로 BigQuery 과금이 부담되거나 dbt Core의 동작 원리를 제대로 보고 싶다면 Local입니다. 강의는 Local(DuckDB + dbt Core)을 기본으로 진행합니다.

---

## 1. Cloud 경로: 데이터 적재 (Cloud만)

- [ ] ⚠️ **Module 3 데이터는 재사용되지 않음**을 인지하기
  - Module 3 숙제 = 2024년 yellow만 / Module 4 = **2019~2020년 yellow + green**
- [ ] BigQuery `nytaxi` 데이터셋 준비 (없으면 생성)
- [ ] yellow tripdata 2019년 12개월 적재
- [ ] yellow tripdata 2020년 12개월 적재
- [ ] green tripdata 2019년 12개월 적재
- [ ] green tripdata 2020년 12개월 적재
- [ ] ⚠️ 데이터는 반드시 [DataTalksClub 저장소](https://github.com/DataTalksClub/nyc-tlc-data/releases)에서 받기
  - NYC TLC 공식 사이트 데이터는 소급 수정되어 숙제 정답과 값이 다릅니다
- [ ] BigQuery 콘솔에서 `green_tripdata`, `yellow_tripdata` 테이블 확인
- [ ] 데이터셋 **location** 메모해두기 (dbt 설정에서 똑같이 써야 함)

> 💡 Module 3의 `extras/web_to_gcs_with_progress_bar.py`에서 yellow/green·2019/2020 네 줄의 주석을 풀면 그대로 재사용할 수 있습니다.

## 2. Local Setup으로 가는 경우

- [ ] [local_setup.md](setup/local_setup.md) 읽기
- [ ] DuckDB 설치 (CLI 또는 `pip install duckdb`)
- [ ] `pip install dbt-duckdb` — dbt-core와 DuckDB adapter가 함께 설치됨
- [ ] `~/.dbt/profiles.yml` 작성 (dev/prod 두 target)
  - [ ] RAM에 맞춰 `memory_limit` 조정 — 전체 RAM의 약 50%
- [ ] 적재 스크립트 실행 — yellow+green 2019~2020을 받아 parquet 변환 후 DuckDB `prod` schema에 적재
- [ ] `dbt debug`로 연결 확인
- [ ] (VS Code) **dbt Power User by AltimateAI** 확장 설치
  - [ ] ⚠️ dbt Labs 공식 확장은 Fusion 전용이라 dbt Core에서 안 됨

## 2'. Cloud Setup으로 가는 경우

- [ ] [cloud_setup.md](setup/cloud_setup.md) 읽기
- [ ] service account 권한 확인 (BigQuery Data Editor / Job User / User)
- [ ] service account JSON 키 준비
- [ ] dbt Platform 가입 (무료 Developer 플랜)
- [ ] 새 프로젝트 생성 — 이름 `taxi_rides_ny`
- [ ] BigQuery 연결 설정
  - [ ] JSON 키 업로드
  - [ ] Dataset: `dbt_prod`
  - [ ] ⚠️ Location을 `nytaxi` 데이터셋과 **동일하게** 설정
  - [ ] Maximum Bytes Billed로 상한 걸어두기 (폭주 쿼리 방지)
- [ ] **Test Connection** 통과 확인
- [ ] Git 저장소 연결 (dbt 관리 / 본인 GitHub 중 택1)
- [ ] Development 환경이 자동 생성되었는지 확인

---

## 3. 개념 잡기 (코딩 전)

- [ ] [Analytics Engineering 소개](https://www.youtube.com/watch?v=HxMIsPrIyGQ) 영상 시청
- [ ] [데이터 모델링 소개](https://www.youtube.com/watch?v=uF76d5EmdtU) 영상 시청 → [4_1_1 노트](class_notes/4_1_1_analytics_engineering_basics.md)
  - [ ] analytics engineer가 메우는 "공백"이 무엇인지 정리
  - [ ] ETL vs ELT 차이 — dbt는 ELT의 어디에 있는가
  - [ ] Fact(동사) vs Dimension(명사), star schema
  - [ ] 주방 비유: 저장고(staging) → 주방(processing) → 홀(presentation)
- [ ] [dbt란?](https://www.youtube.com/watch?v=gsKuETFJr54) 영상 시청 → [4_1_2 노트](class_notes/4_1_2_what_is_dbt.md)
  - [ ] `dbt run`이 내부에서 하는 3단계 이해하기
- [ ] [dbt Core vs Cloud](https://www.youtube.com/watch?v=auzcdLRyEIk) 영상 시청 → [4_2_1 노트](class_notes/4_2_1_dbt_core_vs_dbt_cloud.md)
  - [ ] dbt Fusion이 뭔지, 왜 DuckDB는 아직 지원 안 되는지

## 4. 프로젝트 구조와 Sources

- [ ] [dbt 프로젝트 구조](https://www.youtube.com/watch?v=2dYDS4OQbT0) 영상 시청 → [4_3_1 노트](class_notes/4_3_1_dbt_project_structure.md)
  - [ ] `dbt_project.yml`이 왜 가장 중요한 파일인지
  - [ ] staging / intermediate / marts 세 계층의 역할 구분
  - [ ] seeds와 snapshots는 각각 어떤 문제의 우회책인가
- [ ] [dbt Sources](https://www.youtube.com/watch?v=7CrrXazV_8k) 영상 시청 → [4_3_2 노트](class_notes/4_3_2_dbt_sources.md)
- [ ] `models/staging/sources.yml` 작성 — database / schema / tables
  - [ ] ⚠️ Local이면 database=`taxi_rides_ny`, schema=`main` / Cloud면 GCP 프로젝트 ID와 dataset 이름
- [ ] `{{ source() }}`로 raw 테이블 조회해보기 (preview로 데이터가 나오는지)
- [ ] `stg_green_tripdata.sql` 작성
  - [ ] 컬럼 명시적 나열 + alias
  - [ ] 순서: 식별자 → timestamp → trip 정보 → 결제 정보
  - [ ] 타입 명시적 cast
- [ ] `stg_yellow_tripdata.sql` 작성 (연습 과제)

## 5. Models — 계층 쌓기

- [ ] [dbt Models](https://www.youtube.com/watch?v=JQYz-8sl1aQ) 영상 시청 → [4_4_1 노트](class_notes/4_4_1_dbt_models.md)
- [ ] **`source()` vs `ref()` 구분 확실히 하기** — 이 모듈의 핵심 분기점
  - [ ] `ref()`가 의존성 그래프를 자동으로 만든다는 점 이해
- [ ] `int_trips_unioned.sql` 작성 — green + yellow union
- [ ] union 에러 만나고 고치기 (컬럼 수 불일치)
  - [ ] `trip_type` → yellow에 `1` 하드코딩 (길거리 호출만 가능하므로)
  - [ ] `ehail_fee` → yellow에 `0` 하드코딩
  - [ ] 왜 이런 차이가 나는지 **비즈니스 맥락**으로 설명해보기
- [ ] `int_trips.sql` 확인 — 중복 제거 로직

## 6. Seeds와 Macros

- [ ] [Seeds and Macros](https://www.youtube.com/watch?v=lT4fmTDEqVk) 영상 시청 → [4_4_2 노트](class_notes/4_4_2_dbt_seeds_and_macros.md)
- [ ] `dbt seed` 실행 — `taxi_zone_lookup.csv`, `payment_type_lookup.csv`
- [ ] `dim_zones.sql` 작성 — seed를 `ref()`로 참조
- [ ] macro 이해하기 — `get_vendor_data`, `safe_cast`, `get_trip_duration_minutes`
  - [ ] CASE WHEN 인라인 대비 macro의 이점 3가지 정리
- [ ] `dim_vendors.sql` 확인
- [ ] **`fct_trips.sql` 작성** (연습 과제 — 이 모듈의 산)
  - [ ] trip당 한 행
  - [ ] 고유한 `trip_id` (primary key) 부여
  - [ ] 중복 찾아내고 원인 파악해서 제거
  - [ ] `payment_type` 을 seed로 enrich
- [ ] `fct_monthly_zone_revenue.sql` — reporting 모델

## 7. Tests

- [ ] [dbt Tests](https://www.youtube.com/watch?v=bvZ-rJm7uMU) 영상 시청 → [4_5_2 노트](class_notes/4_5_2_dbt_tests.md)
- [ ] 다섯 가지 테스트 유형 구분해서 정리
  - [ ] singular — `tests/`에 SQL, 행이 반환되면 실패
  - [ ] source freshness — source YAML의 `freshness` 블록
  - [ ] generic — 내장 4종 (`unique` / `not_null` / `accepted_values` / `relationships`)
  - [ ] unit — mock 입력과 기대 출력 (dbt 1.8+)
  - [ ] model contract — 형태가 안 맞으면 빌드 자체를 차단
- [ ] `schema.yml`에 generic test 추가
- [ ] singular test 하나 직접 작성해보기
- [ ] `dbt test` 실행해서 통과/실패 확인

## 8. 문서화와 Packages

- [ ] [Documentation](https://www.youtube.com/watch?v=UqoWyMjcqrA) 영상 시청 → [4_5_1 노트](class_notes/4_5_1_documentation.md)
- [ ] `schema.yml`에 model·컬럼 description 채우기
- [ ] `dbt docs generate` 실행
- [ ] `dbt docs serve` 실행 후 **lineage 그래프** 확인 (Cloud는 자동)
- [ ] [dbt Packages](https://www.youtube.com/watch?v=KfhUA9Kfp8Y) 영상 시청 → [4_5_3 노트](class_notes/4_5_3_dbt_packages.md)
- [ ] `packages.yml` 확인 후 `dbt deps` 실행
- [ ] `dbt_utils.generate_surrogate_key` 사용해보기
- [ ] 알아둘 package 정리: dbt-utils / dbt-codegen / dbt-expectations

## 9. 명령어 총정리

- [ ] [dbt Commands](https://www.youtube.com/watch?v=t4OeWHW3SsA) 영상 시청 → [4_6_1 노트](class_notes/4_6_1_dbt_commands.md)
- [ ] `dbt compile` — 공짜로 Jinja 에러 잡기, 컴파일된 SQL 직접 열어보기
- [ ] `dbt build` — run+test+seed+snapshot, DAG 인식
- [ ] `dbt retry` — 실패 지점부터 재개
- [ ] `--select` graph 연산자 연습
  - [ ] `+model` (상류) / `model+` (하류) / `+model+` (양방향)
- [ ] `--target prod` / `--full-refresh` / `--fail-fast` 용도 정리

## 10. 숙제

- [ ] [Homework](../cohorts/2026/04-analytics-engineering/homework.md) 풀기
- [ ] ⚠️ 숙제는 **[FHV 2019 데이터](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)도 추가로** 필요 — 미리 적재해두기 (질문 6용)
- [ ] ⚠️ **`dbt build --target prod`** 로 빌드 (기본 `dev` 아님!)
- [ ] `fct_trips`, `dim_zones`, `fct_monthly_zone_revenue` 생성 확인
- [ ] `stg_fhv_tripdata` staging 모델 새로 작성 (질문 6)
- [ ] 각 질문 풀이
- [ ] [제출 폼](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw4)에 답안 + GitHub 링크 제출

## 11. 정리

- [ ] (Cloud) 실습용 BigQuery 데이터셋 정리 — `dbt_prod_*` schema들
- [ ] (Local) `data/` 디렉토리와 `.duckdb` 파일 정리 — 용량 큼
- [ ] 최종 dbt 프로젝트 커밋

---

## 다음 단계

Module 4를 마치면 → `05-data-platforms/` (Bruin으로 적재·변환·오케스트레이션·품질을 한 플랫폼에서)

## 팁

- 이 모듈에서 가장 자주 막히는 지점은 **`source()`와 `ref()`를 헷갈리는 것**입니다. raw 테이블(YAML에 선언한 것)만 `source()`, 나머지 dbt model은 전부 `ref()`입니다.
- 뭔가 바꿀 때마다 `dbt run` 대신 **`dbt compile`을 먼저** 돌리세요. 공짜이고, Jinja 오류를 훨씬 빨리 잡아줍니다.
- `dbt build`가 중간에 실패하면 처음부터 다시 돌리지 말고 **`dbt retry`**를 쓰세요. 실패 지점부터 이어갑니다.
- DuckDB에서 OOM이 나면 [duckdb_troubleshooting.md](setup/duckdb_troubleshooting.md)를 보세요. `memory_limit` 조정 → `--select`로 하나씩 빌드 → `dbt retry` 순서로 대응하면 대부분 풀립니다.
- 숙제가 window function과 CTE를 집중적으로 다룹니다. 자신 없다면 [SQL 복습](refreshers/SQL.md)을 먼저 보세요.
- 강의 영상은 Local(DuckDB) 기준으로 진행되지만, 개념은 Cloud에도 그대로 전이됩니다. 경로가 달라도 영상은 다 보세요.
- 막히면 [DataTalksClub Slack](https://datatalks.club/slack.html)에 질문하거나 README 하단의 커뮤니티 노트를 참고하세요.
