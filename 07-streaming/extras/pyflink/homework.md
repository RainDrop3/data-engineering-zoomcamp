# Homework

이번 homework에서는 Taxi 데이터를 사용합니다.
- Green 2019-10 데이터는 [여기](https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz)에서 받습니다.


## Red Panda, Flink Job Manager, Flink Task Manager, Postgres 시작하기 

homework 폴더에 `docker-compose.yml` 파일이 있습니다([여기](https://github.com/redpanda-data-blog/2023-python-gsg/blob/main/docker-compose.yml)에서 가져온 것입니다).

이 파일을 homework 디렉터리에 복사한 뒤 다음을 실행하세요.

```bash
docker-compose up
```

(detached 모드로 실행하려면 `-d`를 추가하세요)

`localhost:8081`에 접속하면 Flink Job Manager를 볼 수 있습니다.

[DBeaver](https://dbeaver.io/)로 Postgres에 연결하세요.

접속 정보는 다음과 같습니다.
- Username `postgres`
- Password `postgres`
- Database `postgres`
- Host `localhost`
- Port `5432`


DBeaver에서 다음 쿼리를 실행하여 첫 이벤트를 받을 Postgres landing zone을 생성하세요.
```sql 
CREATE TABLE processed_events (
    test_data INTEGER,
    event_timestamp TIMESTAMP
)
```


## Question 1. Kafka server에 연결하기

나중에 topic에 데이터를 보낼 수 있도록
먼저 서버에 연결할 수 있는지 확인해야 합니다.

먼저 kafka connector를 설치합니다(별도의 virtual environment를
사용할지는 자유입니다).

```bash
pip install kafka-python
```

solution 폴더에서 jupyter notebook을 시작하거나
스크립트를 만들어도 됩니다.

서버에 연결해 봅시다.

```python
import json
import time 

from kafka import KafkaProducer

def json_serializer(data):
    return json.dumps(data).encode('utf-8')

server = 'localhost:9092'

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=json_serializer
)

producer.bootstrap_connected()
```

## Question 3: Trip Data 보내기

* green csv.gz 파일을 읽습니다
* 다음 컬럼만 필요합니다
  * `'lpep_pickup_datetime',`
  * `'lpep_dropoff_datetime',`
  * `'PULocationID',`
  * `'DOLocationID',`
  * `'passenger_count',`
  * `'trip_distance',`
  * `'tip_amount'`

* `green-trips` topic을 만들고 `load_taxi_data.py`로 그곳에 데이터를 보냅니다
* 몇 초가 걸렸나요? (정수로 반올림해도 됩니다)
* 코드에 sleep을 넣지 않도록 하세요

## Question 4: Sessionization Window 만들기

* `aggregation_job.py`를 복사해 `session_job.py`로 이름을 바꿉니다
* `green-trips`에서 읽도록 하고 schema를 고정합니다
* gap이 5분인 [session window](https://nightlies.apache.org/flink/flink-docs-master/docs/dev/datastream/operators/windows/)를 사용합니다
* `lpep_dropoff_datetime` 시간을 watermark로 사용하고 허용 오차는 5초로 합니다
* 택시 운행이 가장 길게 끊김 없이 이어진 pickup 및 drop off 위치는 어디인가요?




