# NY Taxi 데이터셋과 데이터 수집

**[↑ 위로](README.md)** | **[← 이전](04-postgres-docker.md)** | **[다음 →](06-ingestion-script.md)**

이제 CSV 파일을 읽어서 Postgres로 내보내는 데 사용할 Jupyter Notebook 파일 `notebook.ipynb`를 만들어 보겠습니다.

## Jupyter 설정하기

Jupyter 설치:

```bash
uv add --dev jupyter
```

데이터를 탐색할 Jupyter 노트북을 만들어 봅시다:

```bash
uv run jupyter notebook
```

## NYC Taxi 데이터셋

[NYC TLC Trip Record Data 웹사이트](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)의 데이터를 사용합니다.

구체적으로는 [2021년 1월 Yellow taxi trip records CSV 파일](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz)을 사용합니다.

이 데이터는 원래 csv였지만 나중에 parquet으로 바뀌었습니다. 우리는 (학습 목적으로) 약간의 추가 전처리를 해봐야 하기 때문에 계속 CSV를 사용합니다.

각 필드를 이해하는 데 필요한 데이터 사전(dictionary)은 [여기](https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)에서 볼 수 있습니다.

> 참고: CSV 데이터는 gzip으로 압축된 파일로 저장되어 있습니다. Pandas는 이를 바로 읽을 수 있습니다.

## 데이터 탐색하기

새 노트북을 만들고 다음을 실행합니다:

```python
import pandas as pd

# 데이터 샘플 읽기
prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'
df = pd.read_csv(prefix + 'yellow_tripdata_2021-01.csv.gz', nrows=100)

# 첫 몇 행 표시
df.head()

# 데이터 타입 확인
df.dtypes

# 데이터 형태(행/열 수) 확인
df.shape
```
### 참고
- `nrows=100`으로 처음 100행만 샘플링할 때는 이 부분 데이터의 모든 컬럼 타입이 일관되기 때문에 **아래의 `DtypeWarning`이 나타나지 않습니다**.
- 아래에 나오는 타입 경고를 재현하려면 `nrows=100` 파라미터를 제거하고 전체 데이터셋을 읽으세요.

### 데이터 타입 다루기

다음과 같은 경고가 나타납니다: (이 경고는 사용자에 따라 나중에 나타날 수도 있으니, 아래 안내를 따라 두는 것이 좋습니다)

```
/tmp/ipykernel_25483/2933316018.py:1: DtypeWarning: Columns (6) have mixed types. Specify dtype option on import or set low_memory=False.
```

따라서 타입을 명시해야 합니다:

```python
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

df = pd.read_csv(
    prefix + 'yellow_tripdata_2021-01.csv.gz',
    nrows=100,
    dtype=dtype,
    parse_dates=parse_dates
)
```

## Postgres에 데이터 수집(적재)하기

Jupyter 노트북에서 다음을 수행하는 코드를 작성합니다:

1. CSV 파일 다운로드
2. pandas로 청크 단위로 읽기
3. datetime 컬럼 변환
4. SQLAlchemy를 사용해 PostgreSQL에 데이터 삽입

### SQLAlchemy 설치

```bash
uv add sqlalchemy "psycopg[binary,pool]"
```

### 데이터베이스 연결 생성

```python
from sqlalchemy import create_engine
engine = create_engine('postgresql+psycopg://root:root@localhost:5432/ny_taxi')
```

### DDL 스키마 확인하기

```python
print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))
```

출력:

```sql
CREATE TABLE yellow_taxi_data (
    "VendorID" BIGINT,
    tpep_pickup_datetime TIMESTAMP WITHOUT TIME ZONE,
    tpep_dropoff_datetime TIMESTAMP WITHOUT TIME ZONE,
    passenger_count BIGINT,
    trip_distance FLOAT(53),
    "RatecodeID" BIGINT,
    store_and_fwd_flag TEXT,
    "PULocationID" BIGINT,
    "DOLocationID" BIGINT,
    payment_type BIGINT,
    fare_amount FLOAT(53),
    extra FLOAT(53),
    mta_tax FLOAT(53),
    tip_amount FLOAT(53),
    tolls_amount FLOAT(53),
    improvement_surcharge FLOAT(53),
    total_amount FLOAT(53),
    congestion_surcharge FLOAT(53)
)
```

### 테이블 생성하기

```python
df.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')
```

`head(n=0)`을 사용하면 데이터는 넣지 않고 테이블만 생성합니다.

## 청크 단위로 데이터 수집하기

모든 데이터를 한 번에 삽입하고 싶지는 않습니다. 배치로 나누어 처리하기 위해 이터레이터(iterator)를 사용합시다:

```python
df_iter = pd.read_csv(
    prefix + 'yellow_tripdata_2021-01.csv.gz',
    dtype=dtype,
    parse_dates=parse_dates,
    iterator=True,
    chunksize=100000
)
```

### 청크 순회하기

```python
for df_chunk in df_iter:
    print(len(df_chunk))
```

### 데이터 삽입하기

```python
df_chunk.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
```

### 전체 수집 루프

```python
first = True

for df_chunk in df_iter:

    if first:
        # 테이블 스키마 생성 (데이터 없이)
        df_chunk.head(0).to_sql(
            name="yellow_taxi_data",
            con=engine,
            if_exists="replace"
        )
        first = False
        print("Table created")

    # 청크 삽입
    df_chunk.to_sql(
        name="yellow_taxi_data",
        con=engine,
        if_exists="append"
    )

    print("Inserted:", len(df_chunk))
```

### 다른 방법 (first 플래그 없이)

```python
first_chunk = next(df_iter)

first_chunk.head(0).to_sql(
    name="yellow_taxi_data",
    con=engine,
    if_exists="replace"
)

print("Table created")

first_chunk.to_sql(
    name="yellow_taxi_data",
    con=engine,
    if_exists="append"
)

print("Inserted first chunk:", len(first_chunk))

for df_chunk in df_iter:
    df_chunk.to_sql(
        name="yellow_taxi_data",
        con=engine,
        if_exists="append"
    )
    print("Inserted chunk:", len(df_chunk))
```

## 진행률 표시 추가하기

진행 상황을 볼 수 있도록 `tqdm`을 추가합니다:

```bash
uv add tqdm
```

이터러블(iterable)을 감싸주면 됩니다:

```python
from tqdm.auto import tqdm

for df_chunk in tqdm(df_iter):
    ...
```
전체 청크 수 기준으로 진행률을 보고 싶다면 `tqdm(df_iter)`에 `total` 인자를 추가해야 합니다. 우리 상황에서는 테이블의 전체 행 수를 기준으로 값을 하드코딩하는 것이 실용적인 방법입니다.

## 데이터 확인하기

pgcli로 접속합니다:

```bash
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

그리고 데이터를 탐색해 보세요.

**[↑ 위로](README.md)** | **[← 이전](04-postgres-docker.md)** | **[다음 →](06-ingestion-script.md)**
