# DE Zoomcamp 4.3.1 — dbt 프로젝트 구조

> 📄 영상: [dbt Project Structure](https://www.youtube.com/watch?v=2dYDS4OQbT0)  
> 📄 공식 문서: [About dbt projects](https://docs.getdbt.com/docs/build/projects)  
> 📄 모범 사례: [How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)

`dbt init`을 실행하면 dbt가 자동으로 파일과 폴더 묶음을 만들어 줍니다. 이 영상은 각각을 훑으며 용도를 설명합니다. 아래 구조는 dbt Core와 dbt Cloud 양쪽에 적용됩니다 (DuckDB 데이터베이스 파일과 `data/` 폴더는 로컬 전용 산출물이라 여기서는 무시해도 됩니다).

---

## 최상위 파일 & 폴더

### `analysis/`
- 이해관계자와 굳이 공유하고 싶지 않은 **일회성 SQL 스크립트**를 두는 곳
- 모두가 많이 쓰지는 않지만, **데이터 품질 리포트**나 **관리용 점검** 같은 데 편리합니다
- 스크래치패드라고 생각하세요 — 데이터 품질 문제가 얼마나 심한지 조사하고 싶다면 여기에 SQL 스크립트를 던져두면 됩니다

### `dbt_project.yml`
- **dbt 프로젝트에서 가장 중요한 파일**
- dbt 명령어를 실행할 때마다 dbt는 이 파일을 가장 먼저 찾습니다 — 없으면 명령어가 실패합니다
- 담고 있는 핵심 항목:
  - 프로젝트 이름
  - profile 이름 (`profiles.yml`과 일치해야 함 — dbt Core 사용자에게 매우 중요)
  - 기본 materialization
  - 변수(Variables)
- 프로젝트 전역 기본값과 설정을 지정하는 곳이기도 합니다

> 📄 [dbt_project.yml reference](https://docs.getdbt.com/reference/dbt_project.yml)

### `macros/`
- macro는 **재사용 가능한 함수**처럼 동작합니다 (Python 함수나 UDF와 유사)
- 여러 곳에서 **같은 SQL 로직을 반복**하고 있다는 걸 깨달았을 때, 또는 **로직 한 조각을 한 곳에 캡슐화**하고 싶을 때 사용하세요
- 장점:
  - 테스트가 쉬움 (작고 고립된 덩어리를 테스트하므로)
  - 정의가 바뀌어도 한 곳만 고치면 됨
- 흔한 사용 사례:
  - **달력 변환** (예: 표준 날짜를 회사의 회계 달력으로 변환)
  - 시간이 지나며 바뀔 수 있는 **세율이나 규제 정의**
  - 여러 model에 중복되면 안 되는 재사용 가능한 비즈니스 로직

> 📄 [Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros)

### `models/`
- **가장 중요한 디렉토리** — 모든 SQL 변환 로직이 여기 들어갑니다
- dbt는 이를 **세 개의 하위 폴더**로 나눌 것을 권장합니다 (아래 참조)

### `README.md`
- 표준적인 프로젝트 문서 — 누군가 프로젝트를 열었을 때 가장 먼저 보는 것
- dbt가 기본 파일을 만들어 주지만 대부분의 팀은 이를 커스터마이즈합니다
- 넣으면 좋은 것:
  - 프로젝트 실행 방법
  - 자격 증명이나 온보딩이 필요한지 여부
  - 연락처 정보
  - 설치/셋업 가이드

### `seeds/`
- **CSV나 flat 파일을 업로드**해 데이터베이스에 dbt model로 적재하는 곳
- **빠르고 거친(quick-and-dirty)** 접근으로 여겨집니다 — 가능하다면 소스 단계에서 제대로 적재하는 편이 낫습니다
- 유용한 경우:
  - **Lookup table**
  - 빠른 실험이나 프로토타입
  - 데이터 적재를 완전히 확정하기 전에 이해관계자에게 뭔가 보여줄 때
- 적절한 권한이 없거나, 실험 중 데이터가 자주 바뀔 것으로 예상될 때 사용하세요

> 📄 [Seeds](https://docs.getdbt.com/docs/build/seeds)

### `snapshots/`
- 특정한 문제를 해결합니다: 소스 테이블에 **자기 자신을 덮어쓰는** 컬럼이 있는데 **이력을 보존**해야 하는 경우
- 예: `current_status` 컬럼이 항상 최신 상태만 보여주는 `orders` 테이블. 분석 관점에서는 각 상태가 *언제* 바뀌었는지 알고 싶습니다
- 동작 방식: snapshot은 **특정 시점의 테이블 "사진"**을 찍습니다. 실행할 때마다 값이 바뀌었으면 이전 값을 덮어쓰지 않고 timestamp와 함께 새 행을 기록합니다
- seed와 마찬가지로 이것도 **우회책**입니다 — 이상적으로는 소스 단계에서 해결해야 합니다. 하지만 소스를 통제할 수 없다면 snapshot이 잘 작동합니다

> 📄 [Snapshots](https://docs.getdbt.com/docs/build/snapshots)

### `tests/`
- SQL assertion으로 작성하는 **singular test**를 두는 곳
- 로직은 단순합니다: **쿼리가 0개보다 많은 행을 반환하면 dbt build가 실패**합니다
- 강의에 나온 예: 어떤 클라이언트는 차량 timestamp가 하루당 정확히 24시간을 커버하도록 보장해야 했습니다. 총 시간이 24에서 벗어나는 날이 있는지 검사하는 테스트 쿼리로, 실수로 들어간 필터나 잘못된 join 같은 로직 오류를 일찍 잡아냈습니다
- dbt에서 테스트하는 여러 방법 중 하나이지만, singular test는 표준 schema test에 들어맞지 않는 **커스텀 비즈니스 규칙**에 특히 좋습니다

> 📄 [Data tests (singular & generic)](https://docs.getdbt.com/docs/build/data-tests)

---

## `models/`의 하위 폴더

dbt는 model을 세 계층으로 조직할 것을 권장합니다:

### `staging/`
- 두 가지를 담습니다:
  - **Source 정의** — raw 데이터가 데이터베이스 어디에 있는지 dbt에게 알려줌
  - **Staging model** — 각 source 테이블의 **1:1 복사본**으로, **최소한의 정리**만 적용
- 최소한의 정리란 이런 것들입니다:
  - 데이터 타입 고치기
  - 컬럼 이름 바꾸기
  - 명백히 빈 행 걸러내기
  - 불필요한 컬럼 제거
  - 값 표준화
- **1:1을 유지**하세요 — raw source와 같은 행 수, 같은 컬럼 수. 이 규칙을 깨는 게 가끔 편리하긴 하지만 예외여야 합니다

### `intermediate/`
- **raw도 아니고** 최종 사용자에게 **노출할 준비도 안 된** 모든 것
- 다음을 위한 포괄 영역:
  - 복잡한 join
  - 무거운 정리나 표준화
  - 데이터 품질 처리
- 여기 무엇이 들어가야 하는지에 대한 엄격한 지침은 없습니다 — staging이나 marts에 딱 들어맞지 않으면 intermediate에 속합니다

### `marts/`
- 모든 **최종적이고 소비 준비가 된** 테이블이 있는 곳
- marts에 있다면 **최종 사용자에게 준비된** 것입니다
- 잘 관리되는 dbt 프로젝트에서는 **오직 marts 테이블만** BI 도구, analyst, 비즈니스 이해관계자에게 노출되어야 합니다 — 그 외에는 아무것도
- 보통 담고 있는 것:
  - 대시보드에 바로 쓸 수 있는 테이블
  - 제대로 모델링되고 깨끗한 테이블
  - 흔히 star schema이지만 반드시 그럴 필요는 없음

---

## 관례에 대한 한마디

`staging → intermediate → marts` 구조는 dbt의 권장 사항이지 필수는 아닙니다. 강사는 다음과 같은 팀들을 봤다고 합니다:
- **Medallion architecture** 명명: `bronze`, `silver`, `gold`
- 번호를 매긴 계층: `first`, `second`, `third`, `last`
- 그 밖의 커스텀 관례

조직에 이미 관례가 있다면 그것을 따르세요. 없다면 dbt의 기본 구조를 유지하세요 — 잘 설계되어 있고 이 강의가 사용하는 방식입니다.
