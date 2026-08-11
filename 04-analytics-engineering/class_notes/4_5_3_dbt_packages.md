# DE Zoomcamp 4.5.3 — dbt Packages

> 📄 영상: [dbt Packages](https://www.youtube.com/watch?v=KfhUA9Kfp8Y)  
> 📄 공식 문서: [Packages](https://docs.getdbt.com/docs/build/packages)  
> 📄 Package Hub: [hub.getdbt.com](https://hub.getdbt.com)

dbt 커뮤니티를 강하게 만드는 것 중 하나가 package입니다. dbt package는 기본적으로 자기 완결적인 dbt 프로젝트입니다 — 자체 macro, test, model, source를 갖고 있죠. 다만 스스로 쓰는 대신 다른 사람들이 자기 프로젝트에 가져다 쓸 수 있도록 배포합니다. Python 라이브러리를 생각하되 dbt용이라고 보면 됩니다. 이 영상은 가장 유용한 package들과 실제로 설치하고 사용하는 법을 다룹니다.

---

## 알아둘 만한 package들

### dbt-utils

가장 대표적인 것. dbt Labs가 유지보수하므로 관리가 잘 되고 안심하고 쓸 수 있습니다. 흔한 SQL 유틸리티를 macro로 잔뜩 묶어 놓았습니다 — surrogate key 생성, 중복 제거, pivot, 안전한 나눗셈, URL 파라미터 추출 같은 것들. 대부분 한 번쯤은 직접 짜봤을 법한 것들이죠.

진짜 강점은 **크로스 데이터베이스 호환성**입니다. dbt-utils의 macro는 웨어하우스에 맞는 SQL 방언으로 컴파일됩니다. 그래서 같은 macro가 BigQuery, DuckDB, Snowflake 등에서 동작합니다 — 코드를 따로 관리할 필요가 없습니다.

### dbt-codegen

YAML 노가다를 크게 줄여주는 시간 절약 도구. codegen은 두 가지를 합니다:

- **SQL에서 YAML 생성** — model이나 source를 가리키면 모든 컬럼이 나열된 `schema.yml`을 자동 생성합니다. 수백 개의 컬럼명을 손으로 칠 일이 없어집니다.
- **YAML에서 SQL 생성** — 그 반대. YAML 명세를 주면 dbt 관례를 따르는 staging model SQL 파일을 생성합니다 (이름 변경용 단일 CTE, 적절한 파일명 등).

### dbt-project-evaluator

여러분의 dbt 프로젝트를 모범 사례에 비추어 점수 매깁니다. 관례를 잘 따르고 있는지 빠르게 점검하고 싶은 팀에 좋습니다.

### dbt-audit-helper

리팩터링할 때 유용합니다. 기존 model과 새 model을 비교해 같은 결과를 내는지 검증합니다 — 같은 컬럼, 같은 행 수, 같은 값. 기존 SQL을 다시 쓸 때의 불안을 덜어줍니다.

### dbt-expectations

커스텀 test를 거의 불필요하게 만드는 물건입니다. 생각할 수 있는 거의 모든 assertion을 다루는 미리 만들어진 generic test의 방대한 라이브러리입니다 — 행 수, 값 범위, 일관된 대소문자, 정규식 매칭, 근사 동등성 등등. 실무에서 무언가를 테스트해야 한다면 dbt-expectations에 이미 있을 가능성이 매우 높습니다.

> 📄 [dbt-expectations on the Package Hub](https://hub.getdbt.com/calogica/dbt_expectations/latest/)

### 웨어하우스별 package

허브에는 특정 플랫폼에 맞춘 package도 많습니다 — Snowflake, BigQuery 등. 보통 지출 모니터링, 모범 사례 평가, 제약 조건 적용, 또는 semantic view 같은 플랫폼 고유 기능을 다루는 model이나 macro가 들어 있습니다.

---

## 신뢰에 대한 한마디

dbt Hub의 package는 dbt Labs의 검증 과정을 거쳤습니다 — 대체로 안전하게 쓸 수 있습니다. Hub에 없이 GitHub에 떠다니는 package는요? 프로젝트에 넣기 전에 실제로 무슨 일을 하는지 더 자세히 살펴보세요.

---

## package 설치하는 법 — 데모

영상은 dbt-utils를 설치해 surrogate key를 생성하는 과정을 보여줍니다. 워크플로는 이렇습니다:

### 1. packages.yml 만들기

dbt 프로젝트 루트(`dbt_project.yml`과 같은 위치)에 `packages.yml` 파일을 만듭니다. package를 선언하고 버전을 고정합니다.

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

### 2. `dbt deps` 실행

package를 다운로드하고 설치합니다. 실행 후 두 가지가 나타납니다:

- `package-lock.yml` 파일 — 정확히 무엇이 설치되었는지에 대한 해시가 담깁니다. 팀원 모두가 같은 버전을 쓰도록 버전 관리에 커밋하세요.
- `dbt_packages/` 디렉토리 — 설치된 package 코드가 사는 곳입니다. 기본적으로 git에서 무시됩니다(다른 사람의 소스 코드를 저장소에 커밋하고 싶지는 않으니까요). 다만 macro가 어떻게 동작하는지 궁금하면 들여다볼 수 있습니다.

### 3. 사용하기

설치되면 package의 macro를 바로 쓸 수 있습니다. 표준 Jinja 문법에 package 이름을 접두사로 붙여 호출합니다.

**이전 (수동 surrogate key):**
```sql
select
    -- Manual concatenation approach
    concat(
        cast(vendorid as string), '-',
        cast(lpep_pickup_datetime as string)
    ) as tripid,
    vendorid,
    pickup_datetime
from {{ source('staging', 'green_tripdata') }}
```

**이후 (dbt_utils.generate_surrogate_key 사용):**
```sql
select
    -- Clean, cross-database macro
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    vendorid,
    pickup_datetime
from {{ source('staging', 'green_tripdata') }}
```

이게 전부입니다. 나머지는 macro가 처리합니다 — 대상 웨어하우스에 맞는 SQL로 컴파일됩니다 (BigQuery면 MD5 해시, Snowflake면 hash 함수 등).

> 📄 [dbt deps command — docs](https://docs.getdbt.com/reference/commands/deps)
