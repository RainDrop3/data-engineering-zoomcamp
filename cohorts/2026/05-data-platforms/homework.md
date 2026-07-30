# Module 5 숙제: Bruin으로 하는 Data Platforms

이번 숙제에서는 Bruin을 사용해 데이터 수집부터 리포팅까지 완전한 데이터 파이프라인을 구축합니다.

## 설정

1. Bruin CLI 설치: `curl -LsSf https://getbruin.com/install/cli | sh`
2. zoomcamp 템플릿 초기화: `bruin init zoomcamp my-pipeline`
3. `.bruin.yml`에 DuckDB 연결 설정하기
4. [메인 모듈 README](../../../05-data-platforms/)의 튜토리얼 따라하기

설정을 마치면 동작하는 NYC taxi 데이터 파이프라인이 준비되어 있어야 합니다.

---

### 질문 1. Bruin 파이프라인 구조

Bruin 프로젝트에서 반드시 있어야 하는 파일/디렉터리는 무엇인가요?

- `bruin.yml`과 `assets/`
- `.bruin.yml`과 `pipeline.yml` (asset은 아무 곳에나 둘 수 있음)
- `.bruin.yml`, 그리고 `pipeline.yml`과 `assets/`를 포함한 `pipeline/`
- `pipeline.yml`과 `assets/`만

---

### 질문 2. Materialization 전략

`pickup_datetime`을 기준으로 월별로 정리된 NYC taxi 데이터를 처리하는 파이프라인을 만들고 있습니다. 특정 기간의 데이터를 삭제하고 다시 삽입하는 방식으로 그 구간을 처리하기에 가장 적합한 incremental 전략은 무엇인가요?

- `append` - 항상 새 행을 추가
- `replace` - 전체를 비우고 다시 생성
- `time_interval` - 시간 컬럼을 기준으로 incremental 처리
- `view` - 가상 테이블만 생성

---

### 질문 3. 파이프라인 변수

`pipeline.yml`에 다음과 같은 변수를 정의했습니다:

```yaml
variables:
  taxi_types:
    type: array
    items:
      type: string
    default: ["yellow", "green"]
```

파이프라인을 실행할 때 yellow taxi만 처리하도록 이 값을 덮어쓰려면 어떻게 해야 하나요?

- `bruin run --taxi-types yellow`
- `bruin run --var taxi_types=yellow`
- `bruin run --var 'taxi_types=["yellow"]'`
- `bruin run --set taxi_types=["yellow"]`

---

### 질문 4. 의존성과 함께 실행하기

`ingestion/trips.py` asset을 수정했고, 이 asset과 모든 downstream asset을 실행하려고 합니다. 어떤 명령어를 사용해야 하나요?

- `bruin run ingestion.trips --all`
- `bruin run ingestion/trips.py --downstream`
- `bruin run pipeline/trips.py --recursive`
- `bruin run --select ingestion.trips+`

---

### 질문 5. 품질 검사

trips 테이블의 `pickup_datetime` 컬럼에 NULL 값이 절대 없도록 보장하고 싶습니다. asset 정의에 어떤 품질 검사를 추가해야 하나요?

- `name: unique`
- `name: not_null`
- `name: positive`
- `name: accepted_values, value: [not_null]`

---

### 질문 6. Lineage와 의존성

파이프라인을 구축한 뒤 asset 간의 의존성 그래프를 시각화하려고 합니다. 어떤 Bruin 명령어를 사용해야 하나요?

- `bruin graph`
- `bruin dependencies`
- `bruin lineage`
- `bruin show`

---

### 질문 7. 최초 실행

새로운 DuckDB 데이터베이스에서 Bruin 파이프라인을 처음 실행하려고 합니다. 테이블이 처음부터 새로 생성되도록 하려면 어떤 플래그를 사용해야 하나요?

- `--create`
- `--init`
- `--full-refresh`
- `--truncate`

---

## 풀이 제출하기

- 제출 폼: <https://courses.datatalks.club/de-zoomcamp-2026/homework/hw5>

=======

## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

### LinkedIn 게시물 예시

```
🚀 Week 5 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 5 - Data Platforms with Bruin. Learned how to:

✅ Build end-to-end ELT pipelines with Bruin
✅ Configure environments and connections
✅ Use materialization strategies for incremental processing
✅ Add data quality checks to ensure data integrity
✅ Deploy pipelines from local to cloud (BigQuery)

Modern data platforms in a single CLI tool - no vendor lock-in!

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시

```
📊 Module 5 of Data Engineering Zoomcamp done!

- Data Platforms with Bruin
- End-to-end ELT pipelines
- Data quality & lineage
- Deployment to BigQuery

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
