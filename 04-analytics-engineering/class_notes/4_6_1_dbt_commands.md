# DE Zoomcamp 4.6.1 — dbt 명령어

> 📄 영상: [dbt Commands](https://www.youtube.com/watch?v=t4OeWHW3SsA)  
> 📄 공식 문서: [dbt command reference](https://docs.getdbt.com/reference/dbt-commands)  
> 📄 선택 문법: [Node selection syntax](https://docs.getdbt.com/reference/node-selection/syntax)

지금까지 시리즈 내내 dbt 명령어를 써왔지만 전부를 제대로 짚고 넘어간 적은 없습니다. 이 영상은 전체 투어입니다 — 실제로 쓰게 될 모든 명령어와 그것들을 강력하게 만드는 플래그들. 북마크해둘 만합니다.

---

## 셋업 명령어 — 한 번만 (또는 필요할 때) 실행

### dbt init

dbt 프로젝트를 처음부터 만듭니다. 전체 디렉토리 구조를 생성합니다 — `models/`, `seeds/`, `snapshots/`, `tests/`, `analysis/` 등 전부. 맨 처음에 딱 한 번만 실행합니다.

### dbt debug

`profiles.yml`이 유효한지, 그리고 dbt가 실제로 웨어하우스에 연결할 수 있는지 확인합니다. 새 환경을 셋업할 때나 연결에 뭔가 이상하다 싶을 때 실행하세요.

### dbt deps

`packages.yml`의 package를 설치합니다. 4.5.3에서 다뤘습니다 — 명령어 목록에도 이렇게 자리하고 있다는 것만 알아두세요.

### dbt clean

`dbt_project.yml`의 `clean-targets`에 나열된 디렉토리를 삭제합니다. 기본값은 `target/`과 `dbt_packages/`입니다. 새로 시작할 때 유용하지만, `dbt_packages/`를 지웠다면 clean 후에 `dbt deps`를 다시 실행해야 한다는 걸 기억하세요. 원한다면 `clean-targets`에 다른 디렉토리를 추가할 수 있습니다.

> 📄 [dbt clean — docs](https://docs.getdbt.com/reference/commands/clean)

---

## 기능별 명령어

범용이라기보다 특정 dbt 기능에 묶인 명령어들입니다.

### dbt seed

`seeds/` 디렉토리의 모든 CSV를 웨어하우스에 적재합니다. 빠르고 단순합니다 — 참조 데이터나 작은 lookup table에 좋습니다.

### dbt snapshot

프로젝트에 정의한 snapshot을 실행합니다. snapshot은 소스 데이터가 시간에 따라 어떻게 변하는지 추적하는 dbt의 방식입니다 (SCD Type 2를 생각하세요). 매일 쓰는 것은 아니지만 필요할 때 거기 있습니다.

### dbt source freshness

소스 데이터가 오래되었는지 검사합니다. source YAML에 `freshness` 블록을 정의했다면(4.5.2에서 다뤘습니다), 실제로 검사를 실행하는 명령어가 이것입니다.

### dbt docs generate / dbt docs serve

`dbt docs generate`는 YAML 문서, model 코드, 웨어하우스 메타데이터를 `target/`의 `catalog.json` 아티팩트로 컴파일합니다. `dbt docs serve`는 로컬 웹사이트(localhost:8080)를 띄워 둘러볼 수 있게 합니다. dbt Cloud에서는 `docs serve`가 필요 없습니다 — 자동으로 처리됩니다. dbt Core 사용자라면 그 문서 사이트를 확장 가능하게 호스팅할 방법을 직접 찾아야 합니다.

> 📄 [dbt docs commands — docs](https://docs.getdbt.com/reference/commands/cmd-docs)

---

## 4대 명령어 — 매일 쓰는 주력

### dbt compile

아무것도 안 하는 것처럼 보이지만 실은 매우 유용합니다. 모든 model을 Jinja, `ref()`, `source()` 호출까지 전부 포함해 받아서, 완전히 해석된 SQL을 `target/compiled/`에 출력합니다. 데이터는 움직이지 않고 웨어하우스에도 닿지 않습니다. 그저 순수한 SQL이 들여다볼 수 있게 놓여 있을 뿐입니다.

왜 할까요? 두 가지 이유입니다. 첫째, Jinja 오류를 잡는 가장 빠른 방법입니다 — `dbt run` 전체를 기다리는 것보다 훨씬 빠릅니다. 둘째, 완전히 공짜입니다 — 컴퓨트도, 웨어하우스 비용도 없습니다. 변경 후에 실행하는 좋은 습관입니다.

> 📄 [dbt compile — docs](https://docs.getdbt.com/reference/commands/compile)

### dbt run

프로젝트의 모든 model을 materialize합니다. view는 view가 되고, table은 table이 되고, incremental model에는 incremental 로직이 적용됩니다 — 설정한 대로요. model은 의존성 순서대로 실행되므로 순서는 dbt가 알아서 정합니다.

model이 만들어지는 걸 보고 싶은 활발한 개발 중에 주로 쓰는 명령어입니다.

> 📄 [dbt run — docs](https://docs.getdbt.com/reference/commands/run)

### dbt test

프로젝트의 모든 테스트를 실행합니다 — generic test, singular test, unit test 전부. 마지막에 통과/실패를 보고합니다. 여기서는 아무것도 빌드되지 않고, 이미 웨어하우스에 있는 것을 검증만 합니다.

> 📄 [dbt test — docs](https://docs.getdbt.com/reference/commands/test)

### dbt build ⭐

가장 중요한 명령어. `dbt run` + `dbt test` + `dbt seed` + `dbt snapshot`을 하나로 묶은 똑똑한 조합입니다. 단순히 순차 실행하는 게 아니라 DAG를 인식합니다. 올바른 순서를 알고, 도중에 무언가 실패하면 어차피 깨질 model에 컴퓨트를 낭비하는 대신 그 실패의 하류 전체를 건너뜁니다.

CI, 프로덕션 실행, 또는 프로젝트 전체가 견고하다는 확신이 필요할 때 원하는 것이 이것입니다.

> 📄 [dbt build — docs](https://docs.getdbt.com/reference/commands/build)

### dbt retry

`dbt build`나 `dbt run`이 도중에 실패했다면 전체를 처음부터 다시 돌리지 마세요. `dbt retry`는 이전 실행의 `run_results.json` 파일을 읽어 실패 지점부터 재실행합니다. 어떤 노드가 실패했는지 자동으로 식별해 그 노드들과 하류 전체를 다시 실행합니다.

동작 방식:
- dbt가 마지막 명령의 `target/run_results.json`을 봅니다
- 실패한 노드와 건너뛴 노드(실패의 하류에 있는 모든 것)를 식별합니다
- 원래 명령의 동일한 선택 기준을 재사용해 그 노드들만 다시 실행합니다
- 이전 명령이 성공적으로 끝났다면 `dbt retry`는 아무 일도 하지 않고 종료됩니다

큰 프로젝트에서, 특히 DAG 깊은 곳의 model 하나가 실패했을 때 시간을 많이 아껴줍니다.

---

## 플래그 — 중요한 것들

### --help / -h

어떤 명령어에서든 동작합니다. `dbt --help`는 전체 목록을, `dbt run --help`는 `run`에 특화된 플래그를 보여줍니다. 표준적인 것이지만 있다는 걸 알아둘 만합니다.

### --version / -V

설치된 dbt 버전을 알려줍니다. 업데이트가 있는지도 알려줍니다.

### --full-refresh / -f

`dbt run`이나 `dbt build`와 함께 씁니다. incremental model이 있으면 평소에는 새 행만 덧붙입니다. `--full-refresh`는 전체를 drop하고 처음부터 다시 빌드합니다. 과거 데이터가 바뀌었거나, 중복이 생겼거나, 그냥 모든 게 깨끗한지 확실히 하고 싶을 때 유용합니다. 대부분의 팀은 정리 차원에서 정기적으로 — 아마 한 달에 한 번 — 이걸 실행합니다.

```bash
dbt run --full-refresh
```

### --fail-fast

더 엄격한 버전의 dbt를 실행합니다. 평소에는 경고가 실행을 멈추지 않지만 `--fail-fast`를 쓰면 멈춥니다. CI나 아무것도 빠져나가지 않게 확실히 하고 싶을 때 좋습니다. 관대하게 두었다가 나중에 놀라는 것보다 크게 실패하는 편이 낫습니다.

### --target / -t

dbt가 어느 profile target에 대해 실행할지 제어합니다. 기본적으로 모든 것이 `dev`에서 실행됩니다. 하지만 재정의할 수 있습니다:

```bash
dbt run --target prod
```

`dbt run`, `dbt build`, `dbt test`, `dbt snapshot` — 웨어하우스에 닿는 거의 모든 명령어에서 동작합니다. 모범 사례: 개발자는 `dev`에서 작업하고, 프로덕션 실행은 `--target prod`를 씁니다.

### --select / -s

이것이 핵심입니다. 전체 대신 프로젝트의 특정 부분만 실행하게 해줍니다. 몇 가지 사용법이 있습니다:

**model 이름으로** — model 이름만 주면 됩니다 (`.sql` 불필요):

```bash
dbt run --select stg_green_tripdata
```

**디렉토리 경로로** — 폴더 안의 모든 것:

```bash
dbt run --select models/staging
```

**tag로:**

```bash
dbt run --select tag:nightly
```

**graph 연산자(+ 기호)와 함께** — 여기서 정말 유용해집니다. `+`로 상류나 하류 의존성을 끌어올 수 있습니다:

```bash
# stg_green_tripdata와 그 모든 상류 의존성 실행
dbt run --select +stg_green_tripdata

# fct_trips와 그 모든 하류 의존성 실행
dbt run --select fct_trips+

# dim_zones와 상류 AND 하류 전부 실행
dbt run --select +dim_zones+
```

- `+my_model` — `my_model`과 그 상류 전부(모든 조상)를 빌드
- `my_model+` — `my_model`과 그 하류 전부(모든 자손)를 빌드
- `+my_model+` — 양방향. 상류 전부, model 자신, 그리고 하류 전부

> 📄 [Graph operators — docs](https://docs.getdbt.com/reference/node-selection/graph-operators)

**state 선택자와 함께** — 무엇이 바뀌었는지 추측하는 대신 dbt가 알아내게 합니다:

```bash
dbt build --select state:modified+ --state ./prod-artifacts
```

- `state:new` — 방금 만든 파일만
- `state:modified` — 마지막 실행 이후 바뀐 모든 것
- 뒤에 `+`를 붙이면 수정된 model의 하류 의존성까지 포함

state 비교의 동작 방식:
- **이전 실행**의 아티팩트가 어딘가 영속적인 곳에 저장되어 있어야 합니다 (지금 쓰고 있는 그 `target/` 디렉토리가 아니라)
- **dbt Cloud**에서는 자동으로 처리됩니다 — 프로덕션 아티팩트가 저장되어 비교에 쓸 수 있습니다
- **dbt Core**에서는 아티팩트(특히 `manifest.json`)를 직접 어딘가에 저장해야 합니다 — 클라우드 버킷, 별도 디렉토리, 버전 관리 등
- `--state`가 그 이전 아티팩트가 있는 곳을 가리키게 합니다
- dbt가 현재 코드를 그 아티팩트와 비교해 무엇이 새롭고 무엇이 수정되었는지 판단합니다

핵심은 *다른 환경의 아티팩트*(보통 프로덕션)나 *과거 시점*과 비교한다는 것입니다 — 지금 빌드해 넣고 있는 디렉토리가 아니라요. 이렇게 하면 마지막 프로덕션 배포 이후 바뀐 것만 실행할 수 있어 CI/CD 워크플로에 엄청나게 유용합니다.

그 JSON 아티팩트를 영속적으로 저장하는 것은 일반적으로도 좋은 습관입니다 — 프로젝트가 시간에 따라 어떻게 진화하는지 분석하는 데 쓸 수 있습니다.

> 📄 [Node selection syntax — docs](https://docs.getdbt.com/reference/node-selection/syntax)
