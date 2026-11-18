### Python을 사용한 Stream-Processing

이 문서에서는 여러 Python 라이브러리(`kafka-python`,`confluent-kafka`,`pyspark`, `faust`)를 사용한
stream processing 정보를 다룹니다.

이 Python 모듈은 다음 모듈로 나뉩니다.

####  1. Docker
Docker 모듈에는 Kafka와 Spark를 Docker 컨테이너에서 실행하기 위한 Dockerfile과 docker-compose 정의가 들어 있습니다.
필요한 서비스를 설정하는 것은 이후 모듈을 실행하기 위한 선행 단계입니다.

#### 2. Kafka Producer - Consumer 예제
- `kafka-python` 라이브러리를 사용하는 [Json Producer-Consumer 예제](json_example)
- `confluent-kafka` 라이브러리를 사용하는 [Avro Producer-Consumer 예제](avro_example)

이 두 예제 모두 Kafka 서비스가 실행 중이어야 하므로, [docker-README](docker/README.md)의
단계를 먼저 진행하세요.

각 예제 폴더에서 producer-consumer 예제를 실행하려면 다음 명령을 실행하세요.
```bash
# Start producer script
python3 producer.py
# Start consumer script
python3 consumer.py
```





