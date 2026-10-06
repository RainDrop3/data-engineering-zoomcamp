# 5.6 - 핵심 개념: Pipelines

🎥 [Bruin Core Concepts | Pipelines](https://www.youtube.com/watch?v=uzp_DiR4Sok) (3:13)

## Pipeline이란?

**Pipeline**은 실행 스케줄과 설정 요구 사항을 기준으로 asset을 정리하는 그룹화 메커니즘입니다. 한 project 안에 여러 pipeline을 둘 수 있습니다.

## 주요 특징

### 하나의 스케줄

각 pipeline은 **하나의 스케줄**을 가집니다 — 이것이 asset을 함께 묶는 가장 큰 이유입니다:
- 스케줄이 같은 asset은 같은 pipeline에 속합니다
- 흔한 스케줄: `hourly`, `daily`, `monthly`, 또는 cron 표현식

### Pipeline 구조

각 pipeline은 `pipeline.yml` 파일이 들어 있는 자체 폴더를 가집니다:

```text
project/
├── .bruin.yml
├── pipelines/
│   ├── nyc-taxi/
│   │   ├── pipeline.yml
│   │   └── assets/
│   └── another-pipeline/
│       ├── pipeline.yml
│       └── assets/
```

## `pipeline.yml` 파일

```yaml
name: nyc_taxi
schedule: monthly
start_date: "2019-01-01"
default_connections:
  duckdb: duckdb-default
```

### 설정 옵션

| 설정 | 설명 |
|---------|-------------|
| `name` | pipeline 식별자 |
| `schedule` | 언제 실행할지 (cron, daily, monthly 등) |
| `start_date` | pipeline이 활성화되기 시작하는 시점 |
| `default_connections` | 어떤 connection을 사용할지 |
| `variables` | pipeline의 커스텀 변수 |

### Connection 범위 지정

connection은 project 수준(`.bruin.yml`)에서 정의되지만, 각 pipeline은 **자신이 어떤 connection을 사용하는지** 지정합니다.

**이것이 중요한 이유:**
- 큰 조직에서는 팀마다 다른 자격 증명이 필요할 수 있음
- secret의 불필요한 노출을 방지
- 해당 pipeline run에 필요한 connection만 초기화
- 부서 간 보안 격리

## 빠른 참조

```bash
# pipeline 검증
bruin validate ./pipelines/nyc-taxi/pipeline.yml

# pipeline lineage 보기
bruin lineage ./pipelines/nyc-taxi/pipeline.yml

# pipeline 전체 실행
bruin run ./pipelines/nyc-taxi/pipeline.yml
```

## 더 읽을거리

- [Bruin 문서 - Pipelines](https://getbruin.com/docs/bruin/pipelines/definition.html)
- [Pipeline 설정 레퍼런스](https://getbruin.com/docs/bruin/pipelines/definition.html)
