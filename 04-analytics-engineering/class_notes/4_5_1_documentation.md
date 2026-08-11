# DE Zoomcamp 4.5.1 — 문서화(Documentation)

> 📄 영상: [Documentation](https://www.youtube.com/watch?v=UqoWyMjcqrA)  
> 📄 공식 문서: [Documentation](https://docs.getdbt.com/docs/build/documentation)  
> 📄 Model properties: [Model properties](https://docs.getdbt.com/reference/model-properties)

model은 다 만들었습니다. 이제 다른 사람들이 그것이 무슨 일을 하는지 실제로 이해할 수 있게 만들 차례입니다. 이 영상은 dbt의 문서화 시스템이 어떻게 동작하는지 — 무엇을 쓰고, 어디에 쓰고, dbt가 그것으로 무엇을 하는지 — 를 다룹니다.

---

## 문서가 사는 곳 — YAML 파일

source를 다루면서 이미 YAML 파일을 봤습니다. 하지만 YAML은 raw 데이터가 어디 있는지 선언하는 것 이상을 합니다 — **프로젝트 전체를 문서화하는 주된 장소**이기도 합니다.

가장 흔한 관례는 디렉토리마다 `schema.yml`이라는 파일 하나를 두는 것입니다. 어떤 팀은 **model당 YAML 파일 하나**를 선호합니다 — 그것도 괜찮고, 프로젝트가 커질 때 감당하기 어려워지는 걸 막아줍니다. 이 강의에서는 `schema.yml`을 씁니다.

> 📄 [Model properties — full reference](https://docs.getdbt.com/reference/model-properties)

---

## 무엇을 문서화할 수 있는가

dbt의 거의 모든 것을 문서화할 수 있습니다. 무엇을 문서화하든 구조는 같은 패턴입니다:

### Sources

이미 `sources.yml`이 있습니다 — source 자체와 그 안의 각 테이블에 description을 추가할 수 있습니다.

```yaml
version: 2

sources:
  - name: staging
    description: >
      Raw NYC taxi trip data loaded from BigQuery external tables.
      Contains both yellow and green taxi trip records for 2019-2020.
    database: production
    schema: trips_data_all
    
    tables:
      - name: green_tripdata
        description: >
          Green taxi trip records. Green taxis operate primarily in
          outer boroughs (outside Manhattan).
          
      - name: yellow_tripdata
        description: Yellow taxi trips, primarily from Manhattan
```

### Models

`schema.yml`에서는 `sources:` 대신 `models:`를 씁니다. 발상은 같습니다 — 각 model에 이름과 description을 주고, 컬럼까지 파고듭니다.

```yaml
version: 2

models:
  - name: dim_zones
    description: >
      Zone lookup table containing LocationID, borough, zone name and service zone.
      One row per taxi zone in NYC.
    columns:
      - name: locationid
        description: Primary key for taxi zones
        tests:
          - unique
          - not_null
      
      - name: borough
        description: NYC borough name (Manhattan, Queens, Brooklyn, Bronx, Staten Island, EWR)
      
      - name: zone
        description: Taxi zone name/neighborhood
      
      - name: service_zone
        description: Service zone type (Yellow, Green, or Airports)
```

### Columns
각 model 아래에 모든 컬럼을 다음과 함께 나열할 수 있습니다:
- **name** — 실제 컬럼명과 일치해야 함
- **description** — 무엇을 뜻하는지
- **data_type** — 어떤 타입이어야 하는지 (정보 제공용이며 강제되지 않음)
- **tests** — 다음 영상에서 다루지만 자리는 여기입니다
- **meta** — 커스텀 key-value 태그 (아래에서 더 설명)

### Macros와 seeds
같은 YAML 패턴으로 이것들도 문서화할 수 있습니다. 동일한 `version: 2` 헤더에 최상위 키만 다릅니다.

---

## 여러 줄 description

description에 한 줄 이상이 필요하면 YAML의 **파이프 연산자**(`|`)나 **부등호 연산자**(`>`)를 쓰세요. 그 아래 들여쓴 모든 것이 description의 일부가 됩니다. `>`는 줄바꿈을 공백으로 접고, `|`는 줄바꿈을 보존합니다.

```yaml
version: 2

models:
  - name: fct_trips
    description: |
      Fact table containing all taxi trips from both yellow and green taxis.
      
      This is the core analytical table for trip-level analysis.
      Each row represents a single trip with:
      - Trip identifiers and service type
      - Pickup and dropoff locations and timestamps
      - Trip details (distance, passenger count, etc.)
      - Payment information and amounts
      
      Data is filtered for 2019-2020 only and excludes records
      with unknown pickup or dropoff locations.
```

---

## Meta 태그 — 커스텀 메타데이터

`meta` 필드로 임의의 key-value 쌍을 어떤 컬럼이나 model에든 붙일 수 있습니다. 미리 정해진 집합은 없습니다 — 무엇이 중요한지는 여러분과 팀이 정합니다. 흔한 예:

- **PII** — 개인식별정보가 담긴 컬럼을 표시
- **owner** — 이 데이터 자산의 책임자, 문제가 생기면 누구에게 연락할지
- **importance** — 어떤 컬럼이나 model이 핵심이고 어떤 것이 참고용인지 표시

이것들은 dbt의 실행 방식에 영향을 주지 않습니다. 순전히 거버넌스, 발견 가능성(discoverability), 그리고 팀이 프로젝트를 탐색하는 데 도움을 주기 위한 것입니다.

---

## 문서 생성하고 보기

명령어 두 개를 순서대로 실행합니다:

### `dbt docs generate`
- 모든 것을 컴파일합니다 — YAML description, model 코드, 그리고 웨어하우스에서 온 메타데이터(실제 컬럼 타입, 테이블 크기 등) — 를 JSON 파일 하나로
- **dbt Cloud**에서는 자동으로 일어납니다. 체크박스도 있습니다
- **dbt Core**에서는 직접 실행해야 합니다

### `dbt docs serve`
- 생성된 JSON을 받아 로컬 웹사이트를 띄웁니다 (기본 `localhost:8080`)
- **dbt Core**를 쓸 때만 필요합니다 — dbt Cloud는 문서를 대신 호스팅해 줍니다
- 다른 사람이 보게 하려면 어딘가에 호스팅해야 합니다 (S3, Netlify 등)

### 문서 사이트가 보여주는 것
- **Model 코드** — 여러분이 작성한 Jinja 버전과 실제로 데이터베이스에 나가는 컴파일된 SQL 양쪽
- **컬럼 정보** — 타입, description, 추가한 모든 것
- **Lineage 그래프** — source를 초록색으로 시작해 최종 mart model까지 이어지는 시각적 DAG. 무엇이 무엇에 의존하는지, 변경이 하류의 무언가를 깨뜨릴지 정확히 볼 수 있습니다
- **프로젝트 구조** — 폴더 뷰와 데이터베이스 뷰를 전환

예쁜 데이터 카탈로그라기보다는 **기술 문서** 도구에 가깝습니다. 비기술 이해관계자를 위한 Looker나 Confluent의 데이터 카탈로그 같은 것을 대체하지는 못합니다. 하지만 model을 만드는 사람들에게는 정말로 유용합니다 — 어떤 데이터 자산이 있고, 어떻게 연결되며, 어떻게 동작하는지 한눈에 볼 수 있습니다.
