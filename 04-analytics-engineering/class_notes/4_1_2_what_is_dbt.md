# DE Zoomcamp 4.1.2 — dbt란 무엇인가?

> 📄 영상: [What is dbt?](https://www.youtube.com/watch?v=gsKuETFJr54)  
> 📄 공식 문서: [Introduction to dbt](https://docs.getdbt.com/docs/introduction)  
> 📄 dbt Cloud vs Core: [Choose your dbt](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features)

무언가를 만들기 시작하기 전에 dbt를 큰 그림에서 훑어보는 영상입니다. dbt가 무엇이고, 어떤 문제를 풀며, 이 강의에서 어떻게 쓸 것인지. 아직 실습은 없고 틀을 잡는 내용입니다.

---

## dbt란?

dbt는 변환 워크플로 도구입니다. 데이터 웨어하우스 위에 앉아서, raw 데이터를 하류 소비자(analyst, BI 도구, ML 파이프라인 등 깨끗하고 구조화된 데이터가 필요한 무엇이든)에게 쓸모 있는 형태로 바꿔줍니다.

변환을 정의하는 SQL(또는 Python)을 작성하면, 나머지는 dbt가 처리합니다: 컴파일하고, 웨어하우스에 실행하고, 의존성을 관리하고, 결과를 테이블이나 뷰로 저장합니다.

실제 회사 환경이라면 데이터가 사방에서 흘러들어옵니다 — 백엔드 시스템, 프론트엔드 앱, 날씨 데이터 같은 서드파티 API. 이 모든 것이 웨어하우스(BigQuery, Snowflake, Databricks 등)에 적재되고, dbt는 그 raw 데이터를 비즈니스가 실제로 소비할 수 있는 것으로 변환하는 계층입니다.

---

## dbt가 푸는 문제

변환 단계는 늘 있어왔습니다. dbt가 새로 가져온 것은 **분석 코드를 위한 소프트웨어 엔지니어링 모범 사례**입니다. 소프트웨어 엔지니어들은 수년간 해왔지만 분석 세계로 들어올 뚜렷한 경로가 없던 것들이죠:

- **버전 관리(Version control)** — 변환 코드가 다른 코드와 마찬가지로 git에 들어갑니다
- **모듈화(Modularity)** — 거대한 스파게티 쿼리 대신 복잡한 로직을 재사용 가능한 조각으로 나눕니다
- **테스트(Testing)** — 배포할 때마다 함께 도는 자동화된 데이터 품질 검사
- **문서화(Documentation)** — 코드에서 생성됩니다. 금방 낡아버리는 별도 위키가 아닙니다
- **환경(Environments)** — dev와 prod를 분리합니다. 개발자마다 서로 방해하지 않는 자기만의 샌드박스를 갖습니다
- **CI/CD** — 검증과 롤백이 포함된 자동 배포

결과적으로 품질이 높고, 유지보수가 쉽고, 프로덕션에서 덜 깨지는 파이프라인이 됩니다.

---

## 동작 방식 — 메커니즘

SQL 파일을 하나 작성합니다. 평범한 `SELECT` 문처럼 생겼습니다. dbt는 그 파일을 받아서, 웨어하우스의 어디에 들어가야 하는지(어떤 schema, 어떤 dataset, 어떤 환경) 판단하고, 필요한 DDL/DML로 감싸고, 사용한 Jinja 템플릿을 컴파일한 뒤 실행합니다.

`dbt run`을 실행하면:
1. SQL을 컴파일합니다 (`ref()` 호출, `source()` 호출, Jinja macro 등 모든 것을 해석)
2. 컴파일된 SQL을 웨어하우스로 보냅니다
3. 설정한 대로 결과를 table, view, incremental table, 또는 ephemeral CTE로 materialize합니다

`CREATE TABLE` 문을 직접 쓰지 않습니다. `SELECT`만 작성하면 나머지는 dbt가 처리합니다.

---

## dbt Core vs dbt Cloud

dbt를 쓰는 두 가지 방법이 있고, 차이를 이해해둘 만합니다:

### dbt Core

오픈소스. 무료. 로컬 머신(또는 원하는 곳)에 설치해서 터미널에서 명령어를 실행합니다. 다음은 직접 책임져야 합니다:

- dev 환경 셋업
- 프로덕션 실행 오케스트레이션 (Airflow, cron job 등 원하는 것)
- 문서를 접근 가능하게 하려면 직접 호스팅
- 로그와 메타데이터 관리

날것의 엔진입니다. 완전한 제어권을 얻는 대신 주변 인프라를 직접 만들어야 합니다.

### dbt Cloud

내부적으로 dbt Core를 돌리는 SaaS 제품. 다음을 제공합니다:

- 변환을 작성하는 웹 기반 IDE (로컬 개발을 선호하면 Cloud CLI도 가능)
- 환경 관리 — dev/staging/prod를 알아서 처리
- 내장 오케스트레이션 (job 스케줄링, 트리거, 의존성)
- 호스팅되는 문서 (자동 생성 및 서빙)
- 로깅과 관측성(observability)
- 관리와 메타데이터 접근을 위한 API
- 지표를 위한 semantic layer (필요하다면)

소규모 팀이나 개인 학습에 쓸 수 있는 무료 Developer 플랜이 있습니다. 그보다 큰 규모는 유료입니다.

---

## 강의 셋업 — 두 가지 경로

Zoomcamp은 두 가지 선택지를 주고, 영상들이 둘 사이를 오갑니다 (버전 A와 버전 B):

### 옵션 A: BigQuery + dbt Cloud (권장)

- 데이터 웨어하우스: BigQuery (이전 주차에 셋업했다고 가정)
- dbt: dbt Cloud Developer 플랜 (무료 계정, 웹 IDE)
- 로컬 설치 불필요

대부분의 영상이 따라가는 경로입니다. 가장 빠르게 시작할 수 있고, 팀이 실제 프로덕션에서 dbt를 쓰는 방식에 가장 가깝습니다.

### 옵션 B: DuckDB + dbt Core

- 데이터 웨어하우스: DuckDB (로컬 또는 각자 셋업한 방식)
- dbt: 로컬에 설치한 dbt Core
- dev 환경: 각자의 IDE (VS Code 등)
- 오케스트레이션: 별도로 처리해야 합니다 (Airflow, Prefect 등)

직접 손대는 제어권은 더 많지만 셋업이 더 필요합니다.

---

## 프로젝트 흐름

이 모듈이 끝날 즈음 만들어져 있을 것들:

1. 웨어하우스에 있는 raw 데이터 — 이전 주차의 trip 데이터, 그리고 여러 소스를 join하는 것을 보여줄 lookup table
2. 4.1.1의 dimensional modeling 개념을 따라 그 raw 데이터를 제대로 모델링된 테이블로 바꾸는 dbt 변환
3. 최종 결과물을 소비해 비즈니스 이해관계자에게 유용하게 만드는 대시보드

다음 영상들에서 이것을 실제로 셋업하고 단계별로 만들어 나갑니다.
