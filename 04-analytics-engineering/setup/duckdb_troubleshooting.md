# DuckDB Out of Memory 에러 문제 해결

dbt build 명령을 실행하다 `Out of Memory` 에러가 난다면 당황하지 마세요. RAM이 제한된 머신에서 특히 흔한 문제입니다. 이 가이드는 왜 그런 일이 일어나는지, 그리고 무엇을 할 수 있는지 설명합니다.

## 왜 이런 일이 일어나나?

DuckDB는 **in-process 데이터베이스**입니다. 원격 서버가 아니라 여러분 컴퓨터의 메모리(RAM) 안에서 돌아간다는 뜻입니다. 이 프로젝트에서 쓰는 NYC taxi 데이터셋은 24개월치 yellow와 green taxi 데이터에 걸쳐 **수천만 행**을 담고 있습니다. dbt가 model을 빌드할 때 DuckDB는 이 데이터를 로드하고, 변환하고, 써야 합니다 (전부 로컬 RAM을 사용해서요).

어떤 연산은 다른 것보다 메모리를 더 많이 씁니다:

| 연산 | 비싼 이유 | 발생 위치 |
|---|---|---|
| window function과 함께 쓰는 `QUALIFY` | 전체 데이터셋을 메모리에서 정렬하고 파티셔닝해야 함 | `int_trips.sql` (중복 제거) |
| 큰 테이블에 대한 `UNION ALL` | 두 개의 큰 데이터셋을 하나로 결합 | `int_trips_unioned.sql` |
| Surrogate key 생성 (`generate_surrogate_key`) | 전체 데이터셋에 대해 해시 계산 | `int_trips.sql` |
| 큰 fact table에 대한 `JOIN` | trip을 zone으로 풍부하게 만들 때 메모리 사용량 증가 | `fct_trips.sql` |

## 사용 가능한 RAM 확인하기

문제 해결에 앞서 무엇을 가지고 작업하는지 파악하세요. 보통 설정 메뉴에서 확인할 수 있습니다.

대략적인 기준:

- **4 GB RAM**: OOM이 날 가능성이 매우 높습니다. GitHub Codespaces나 Cloud Setup을 고려하세요.
- **8 GB RAM**: 일부 model에서 OOM이 날 수 있습니다. 메모리 설정을 조정하거나 GitHub Codespaces를 사용하세요.
- **16 GB 이상**: 기본 설정으로 괜찮을 것입니다.

## 옵션 A: GitHub Codespaces나 Cloud Setup 사용

로컬 머신에 RAM이 부족하다면, 가장 쉬운 해결책은 DuckDB를 로컬에서 돌리는 것 자체를 피하는 것입니다.

### GitHub Codespaces

프로젝트를 **GitHub Codespace**에서 실행하세요. 무료 티어에 **4코어 / 8 GB RAM** 머신이 포함되고, 개인 계정의 월 무료 할당량 내에서 **8코어 / 16 GB RAM**도 사용 가능합니다. 16 GB 머신이면 아래의 우회책 없이도 이 프로젝트 전체를 편안히 돌릴 수 있습니다.

시작하려면:

1. GitHub의 [강의 저장소](https://github.com/DataTalksClub/data-engineering-zoomcamp)로 이동합니다.
2. **Code** > **Codespaces** > **Create codespace on main**을 클릭합니다.
3. 최적의 경험을 위해 **8코어** 머신 타입을 선택합니다.

Codespaces에는 Python, pip, git이 미리 설치되어 있어 셋업이 최소한으로 끝납니다.

### Cloud Setup (BigQuery)

또는 **Cloud Setup (BigQuery)** 경로를 사용하세요. BigQuery는 Google 서버에서 돌아가므로 로컬 RAM은 중요하지 않습니다. [Cloud Setup 가이드](cloud_setup.md)를 참고하세요.

## 옵션 B: 로컬 머신에서 돌아가게 만들기

프로젝트를 로컬에서 돌리고 싶다면 아래 단계를 따라 메모리 사용량을 줄이세요.

### Step 1: `profiles.yml`에서 DuckDB 메모리 설정 조정

`~/.dbt/profiles.yml`이 DuckDB가 쓸 수 있는 메모리 양을 제어합니다. 조정할 수 있는 것들:

- **`memory_limit`**: 기본적으로 DuckDB는 시스템 RAM의 최대 80%까지 쓰려고 합니다. 합리적으로 들리지만 운영체제, 브라우저, IDE, 다른 앱들도 메모리가 필요합니다. DuckDB가 너무 많이 차지하면 OS가 프로세스를 죽일 수 있습니다 — 그게 바로 OOM 에러입니다. 명시적 한도(대략 **전체 RAM의 50%**)를 설정하면 나머지에 충분한 여유가 남습니다. 8 GB라면 `'4GB'`를 시도해 보세요.
- **`threads`**: 몇 개의 **dbt model**을 병렬로 빌드할지 제어합니다. `threads`를 `1`로 낮추면 동시에 도는 model이 줄어 전체 메모리 압박이 줄어듭니다.
- **`preserve_insertion_order: false`**: 행 순서를 유지할 필요가 없다고 DuckDB에 알려 메모리를 절약합니다.

### Step 2: 실패 후에는 `dbt retry` 사용

`dbt build`가 도중에 실패했다면 **전부 처음부터 다시 빌드할 필요가 없습니다.** 다음을 사용하세요:

```bash
dbt retry
```

이 명령은 마지막 실행이 멈춘 지점부터 이어받아, 실패했거나 건너뛴 model만 실행합니다. OOM 에러가 model 하나를 죽였을 때 매우 유용합니다 — 문제를 고친 뒤, 이미 성공한 model을 다시 돌리지 않고 재시도하면 됩니다.

### Step 3: `--select`로 선택적으로 빌드

프로젝트 전체를 한 번에 빌드하는 대신 model을 하나씩 빌드해 최대 메모리 사용량을 줄이세요:

```bash
dbt build --select stg_yellow_tripdata --target prod
dbt build --select stg_green_tripdata --target prod
dbt build --select int_trips_unioned --target prod
dbt build --select int_trips --target prod
dbt build --select fct_trips --target prod
```

이렇게 하면 DuckDB가 한 번에 한 model만 다루면 됩니다.

### Step 4: incremental model 활용

이 프로젝트의 `fct_trips` model은 이미 **incremental**로 설정되어 있습니다. 첫 전체 빌드 이후에는 전체 데이터셋을 다시 처리하는 대신 **새 레코드만** 처리한다는 뜻입니다.

첫 전체 빌드가 OOM으로 실패했지만 일부 model이 성공했다면 `dbt retry`(Step 2)를 사용하세요. `fct_trips`가 한 번 빌드되고 나면 이후 실행은 메모리 부담이 훨씬 가벼워집니다.

## DuckDB 성능 모범 사례

다음 팁은 [DuckDB 공식 성능 가이드](https://duckdb.org/docs/guides/performance/environment.html)에서 왔습니다:

1. **다른 애플리케이션을 닫으세요**: 브라우저, IDE, 다른 앱들이 RAM을 두고 경쟁합니다. `dbt build` 전에 필요 없는 것을 닫으세요.
2. **SSD를 사용하세요**: DuckDB는 메모리가 부족하면 디스크로 spill합니다. SSD는 이 spill-to-disk 과정을 HDD보다 훨씬 빠르게 만듭니다.
3. **가능하면 Docker 안에서 실행하지 마세요**: Docker 컨테이너에는 시스템 전체 RAM보다 낮을 수 있는 메모리 한도가 있습니다. Docker를 꼭 써야 한다면 컨테이너의 메모리 한도를 올리세요.

## 그래도 막힌다면?

위의 모든 것을 시도했는데도 프로젝트를 빌드할 수 없다면 [강의 Slack 채널](https://datatalks-club.slack.com/)에 도움을 요청하세요. RAM, OS, 그리고 정확한 에러 메시지를 함께 적어주세요.
