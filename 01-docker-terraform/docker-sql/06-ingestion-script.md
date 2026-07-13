# 데이터 수집 스크립트 만들기

**[↑ 위로](README.md)** | **[← 이전](05-data-ingestion.md)** | **[다음 →](07-pgadmin.md)**

이제 노트북을 Python 스크립트로 변환해 봅시다.

## 노트북을 스크립트로 변환하기

```bash
uv run jupyter nbconvert --to=script notebook.ipynb
mv notebook.py ingest_data.py
```

## 완성된 수집 스크립트

click이 통합된 전체 스크립트는 `pipeline/` 디렉터리를 참고하세요. 핵심 구조는 다음과 같습니다:

```python
import pandas as pd
from sqlalchemy import create_engine
from tqdm.auto import tqdm

dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]
```

## Click 통합

이 스크립트는 커맨드라인 인자 파싱에 `click`을 사용합니다:

```python
import click

@click.command()
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--target-table', default='yellow_taxi_data', help='Target table name')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table):
    # 여기에 수집 로직 작성
    pass
```

## 스크립트 실행하기

이 스크립트는 메모리 부족 없이 큰 파일을 효율적으로 처리하기 위해 데이터를 청크 단위(한 번에 100,000행)로 읽습니다.

사용 예시:

```bash
uv run python ingest_data.py \
  --pg-user=root \
  --pg-pass=root \
  --pg-host=localhost \
  --pg-port=5432 \
  --pg-db=ny_taxi \
  --target-table=yellow_taxi_trips
```

**[↑ 위로](README.md)** | **[← 이전](05-data-ingestion.md)** | **[다음 →](07-pgadmin.md)**
