# Local Setup 가이드

이 가이드는 DuckDB와 dbt를 사용해 로컬 analytics engineering 환경을 셋업하는 과정을 안내합니다.

<div align="center">

[![dbt Core](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=for-the-badge&logo=duckdb&logoColor=black)](https://duckdb.org/)

</div>

>[!NOTE]
>*이 가이드는 셋업을 수동으로 하는 방법을 설명합니다. 추가 도전을 원한다면 Docker Compose나 Python 가상환경으로 이 셋업을 해보세요.*

**중요**: 모든 dbt 명령어는 `taxi_rides_ny/` 디렉토리 안에서 실행해야 합니다. 아래 셋업 단계는 다음을 안내합니다:

1. 필요한 도구 설치
2. DuckDB 연결 설정
3. NYC taxi 데이터 적재
4. 모든 것이 동작하는지 검증

## Step 1: DuckDB 설치

DuckDB는 빠른 in-process SQL 데이터베이스로 로컬 분석 워크로드에 잘 맞습니다. DuckDB를 설치하려면 [공식 사이트](https://duckdb.org/docs/installation)에서 사용 중인 운영체제에 맞는 안내를 따르세요.

> [!TIP]
> *DuckDB는 두 가지 방식으로 설치할 수 있습니다. CLI를 설치하거나, 선호하는 프로그래밍 언어의 client API를 설치할 수 있습니다(Python이라면 `pip install duckdb`). 강사 개인적으로는 CLI 설치를 선호하지만 어느 쪽이든 괜찮습니다.*

## Step 2: dbt 설치

```bash
pip install dbt-duckdb
```

이 명령은 다음을 설치합니다:

* `dbt-core`: dbt 코어 프레임워크
* `dbt-duckdb`: dbt용 DuckDB adapter

## Step 3: dbt Profile 설정

이 저장소에는 이미 dbt 프로젝트(`taxi_rides_ny/`)가 들어 있으므로 `dbt init`을 실행할 필요가 없습니다. 대신 DuckDB에 연결하도록 dbt profile을 설정해야 합니다.

### `~/.dbt/profiles.yml` 생성 또는 수정

dbt profile은 데이터베이스에 어떻게 연결할지 dbt에게 알려줍니다. `~/.dbt/profiles.yml` 파일을 다음 내용으로 생성하거나 수정하세요:

```yaml
taxi_rides_ny:
  target: dev
  outputs:
    # DuckDB Development profile
    dev:
      type: duckdb
      path: taxi_rides_ny.duckdb
      schema: dev
      threads: 1
      extensions:
        - parquet
      settings:
        memory_limit: '2GB'
        preserve_insertion_order: false

    # DuckDB Production profile
    prod:
      type: duckdb
      path: taxi_rides_ny.duckdb
      schema: prod
      threads: 1
      extensions:
        - parquet
      settings:
        memory_limit: '2GB'
        preserve_insertion_order: false

# 문제 해결:
# - RAM이 4GB 미만이라면 memory_limit을 '1GB'로 설정해 보세요
# - RAM이 16GB 이상이라면 '4GB'로 올려 빌드를 빠르게 할 수 있습니다
# - 예상 빌드 시간: 대부분의 시스템에서 5~10분
```

## Step 4: 데이터 다운로드 및 적재

dbt profile 설정이 끝났으니 taxi 데이터를 DuckDB에 적재합시다. dbt 프로젝트 디렉토리로 이동해 적재 스크립트를 실행하세요.

```python
import duckdb
import requests
from pathlib import Path

BASE_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download"

def download_and_convert_files(taxi_type):
    data_dir = Path("data") / taxi_type
    data_dir.mkdir(exist_ok=True, parents=True)

    for year in [2019, 2020]:
        for month in range(1, 13):
            parquet_filename = f"{taxi_type}_tripdata_{year}-{month:02d}.parquet"
            parquet_filepath = data_dir / parquet_filename

            if parquet_filepath.exists():
                print(f"Skipping {parquet_filename} (already exists)")
                continue

            # Download CSV.gz file
            csv_gz_filename = f"{taxi_type}_tripdata_{year}-{month:02d}.csv.gz"
            csv_gz_filepath = data_dir / csv_gz_filename

            response = requests.get(f"{BASE_URL}/{taxi_type}/{csv_gz_filename}", stream=True)
            response.raise_for_status()

            with open(csv_gz_filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

            print(f"Converting {csv_gz_filename} to Parquet...")
            con = duckdb.connect()
            con.execute(f"""
                COPY (SELECT * FROM read_csv_auto('{csv_gz_filepath}'))
                TO '{parquet_filepath}' (FORMAT PARQUET)
            """)
            con.close()

            # Remove the CSV.gz file to save space
            csv_gz_filepath.unlink()
            print(f"Completed {parquet_filename}")

def update_gitignore():
    gitignore_path = Path(".gitignore")

    # Read existing content or start with empty string
    content = gitignore_path.read_text() if gitignore_path.exists() else ""

    # Add data/ if not already present
    if 'data/' not in content:
        with open(gitignore_path, 'a') as f:
            f.write('\n# Data directory\ndata/\n' if content else '# Data directory\ndata/\n')

if __name__ == "__main__":
    # Update .gitignore to exclude data directory
    update_gitignore()

    for taxi_type in ["yellow", "green"]:
        download_and_convert_files(taxi_type)

    con = duckdb.connect("taxi_rides_ny.duckdb")
    con.execute("CREATE SCHEMA IF NOT EXISTS prod")

    for taxi_type in ["yellow", "green"]:
        con.execute(f"""
            CREATE OR REPLACE TABLE prod.{taxi_type}_tripdata AS
            SELECT * FROM read_parquet('data/{taxi_type}/*.parquet', union_by_name=true)
        """)

    con.close()
```

이 스크립트는 2019~2020년 yellow와 green taxi 데이터를 다운로드하고, `prod` schema를 만들고, raw 데이터를 DuckDB에 적재합니다. 인터넷 연결 속도에 따라 다운로드에 몇 분이 걸릴 수 있습니다.

## Step 5: dbt 연결 테스트

dbt가 DuckDB 데이터베이스에 연결할 수 있는지 확인하세요:

```bash
dbt debug
```

## Step 6: dbt Power User 확장 설치 (VS Code 사용자)

Visual Studio Code를 쓴다면 dbt 개발 경험을 개선하는 **dbt Power User** 확장을 설치하세요.

### dbt Power User란?

dbt Power User는 다음을 제공하는 VS Code 확장입니다:

* dbt model에 대한 SQL 구문 강조와 포매팅
* 인라인 컬럼 수준 lineage 시각화
* dbt model, source, macro 자동 완성
* 대화형 문서 미리보기
* 에디터에서 바로 model 컴파일 및 실행

### 공식 dbt 확장을 쓰지 않는 이유는?

dbt Labs가 새로운 dbt Fusion 엔진 기반의 공식 VS Code 확장 [dbt Extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt)을 출시했습니다. 하지만 이 확장은 **dbt Fusion을 요구하며** dbt Core를 지원하지 않습니다.

우리는 로컬 개발에 DuckDB와 **dbt Core**를 쓰므로, 커뮤니티가 유지보수하는 **dbt Power User by AltimateAI** 확장이 필요합니다. 이 확장은:

* dbt Core와 매끄럽게 동작합니다 (dbt Cloud 전용이 아님)
* DuckDB를 포함한 모든 dbt adapter를 지원합니다
* 활발히 유지보수되는 오픈소스입니다
* 로컬 개발을 위한 풍부한 기능을 제공합니다

### 설치

1. VS Code를 엽니다
2. Extensions로 이동합니다 (Ctrl+Shift+X / Cmd+Shift+X)
3. "dbt Power User"를 검색합니다
4. **dbt Power User by AltimateAI**를 설치합니다 (dbt Labs 버전이 아님)

또는 [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user)에서 설치하세요.

> [!NOTE]
> 여기까지 하면 로컬 dbt 환경이 완전히 설정되어 사용할 준비가 됩니다. 다음 단계(model 실행, 테스트, 문서 빌드)는 튜토리얼 영상에서 다룹니다.

## 추가 자료

* [DuckDB Documentation](https://duckdb.org/docs/)
* [dbt Documentation](https://docs.getdbt.com/)
* [dbt-duckdb Adapter](https://github.com/duckdb/dbt-duckdb)
* [NYC Taxi Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)
