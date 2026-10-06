# 5.6 - 핵심 개념: Variables

🎥 [Bruin Core Concepts | Variables](https://www.youtube.com/watch?v=XCx0nDmhhxA) (6:03)

## Variable이란?

**Variable**은 pipeline run이 생성될 때마다 동적으로 초기화됩니다. pipeline을 파라미터화하고 실행 시점에 동적인 값을 넘길 수 있게 해줍니다.

## Variable 유형

### 1. 내장 변수

Bruin이 항상 자동으로 제공합니다:

| 변수 | 설명 |
|----------|-------------|
| `start_date` | 스케줄된 interval의 시작 |
| `end_date` | 스케줄된 interval의 끝 |

이 날짜들은 pipeline의 스케줄에 따라 정해집니다:

| 스케줄 | 시작 날짜 | 종료 날짜 |
|----------|------------|----------|
| **Monthly** | 그 달의 첫날 | 그 달의 마지막 날 |
| **Daily** | 하루의 시작 | 하루의 끝 |
| **Hourly** | 그 시간의 시작 | 그 시간의 끝 |

#### SQL Asset - Jinja 형식

SQL에서는 Jinja 템플릿으로 변수를 주입합니다:

```sql
@bruin.asset(name="staging.monthly_trips", type="sql")
SELECT *
FROM raw.trips
WHERE pickup_date >= '{{ start_date }}'
  AND pickup_date < '{{ end_date }}'
```

VS Code의 **Bruin Render 패널**을 사용하면 실제 값이 들어간 컴파일된 쿼리를 볼 수 있습니다.

#### Python Asset - 환경 변수

Python에서는 환경 변수로 변수에 접근합니다:

```python
import os
from datetime import datetime

@bruin.asset(name="raw.monthly_data", type="python")
def ingest_monthly_data():
    start_date = os.environ['BRUIN_VAR_START_DATE']
    end_date = os.environ['BRUIN_VAR_END_DATE']

    # 날짜를 파싱해 특정 기간의 데이터를 가져오는 데 사용
    start = datetime.fromisoformat(start_date)
    end = datetime.fromisoformat(end_date)

    # 범위 안의 월을 순회
    # ...
```

### 2. 커스텀 변수

pipeline 수준에서 설정하는 사용자 정의 변수입니다.

#### `pipeline.yml`에 정의

```yaml
variables:
  - name: taxi_types
    type: array
    default:
      - "yellow"
```

#### 실행 시점에 덮어쓰기

run을 생성할 때 기본값을 바꿉니다:

```bash
bruin run ./pipeline.yml --var taxi_types=["green","fhv"]
```

#### Python에서 커스텀 변수 접근하기

```python
import os
import json

@bruin.asset(name="example.asset", type="python")
def example_asset():
    # 커스텀 변수에는 BRUIN_VAR_ 접두사가 붙음
    taxi_types_json = os.environ['BRUIN_VAR_TAXI_TYPES']
    taxi_types = json.loads(taxi_types_json)

    # 코드에서 변수 사용
    for taxi_type in taxi_types:
        # taxi 유형별로 처리
        pass
```

## VS Code 확장 패널

VS Code/Cursor의 Bruin 패널에서:

1. **Variable Override** - 실행 전에 커스텀 변수 값 설정
2. **Bruin Render** - Jinja 템플릿이 실제 값으로 어떻게 컴파일되는지 확인
3. **Run Configuration** - 날짜, environment, 변수 설정

## 실전 활용 사례

| 활용 사례 | 설명 |
|----------|-------------|
| **날짜 기반 파티셔닝** | 특정 기간의 데이터 추출 |
| **멀티테넌트 처리** | 같은 pipeline을 고객별로 실행 |
| **파라미터화된 변환** | 변수에 따라 로직 변경 |
| **A/B 테스트** | 코드 변경 없이 다른 설정을 테스트 |

## 빠른 참조

```bash
# 날짜를 지정해 실행
bruin run ./pipeline.yml --start-date 2020-01-01 --end-date 2020-01-31

# 변수 덮어쓰기로 실행 (array)
bruin run ./pipeline.yml --var taxi_types=["green","fhv"]

# 변수 덮어쓰기로 실행 (string)
bruin run ./pipeline.yml --var customer_id=12345

# full refresh로 실행 (materialization에 영향)
bruin run ./pipeline.yml --full-refresh

# 종료 날짜를 exclusive로 설정
bruin run ./pipeline.yml --exclusive-end-date
```

## 더 읽을거리

- [Bruin 문서 - Variables](https://getbruin.com/docs/bruin/core-concepts/variables.html)
- [Pipeline 실행 옵션](https://getbruin.com/docs/bruin/commands/run.html)
