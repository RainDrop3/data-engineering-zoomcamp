
# Redpanda와 함께 PySpark Streaming 실행하기

### 1. 사전 준비

문서에 설명된 대로 network와 volume을 만드는 것이 중요하므로, volume과 network가 올바르게 생성되었는지 확인하세요.

```bash
docker volume ls # should list hadoop-distributed-file-system
docker network ls # should list kafka-spark-network 
```

### 2. Docker Network 및 Volume 생성

다른 예제를 따라 하지 않았고 위의 `ls` 단계에서 아무 출력도 나오지 않는다면, 지금 생성하세요.

```bash
# Create Network
docker network create kafka-spark-network

# Create Volume
docker volume create --name=hadoop-distributed-file-system
```

### Producer와 Consumer 실행
```bash
# Run producer
python producer.py

# Run consumer with default settings
python consumer.py
# Run consumer for specific topic
python consumer.py --topic <topic-name>
```

### Streaming 스크립트 실행

spark-submit 스크립트는 streaming.py를 실행하기 전에 필요한 jar가 설치되도록 해 줍니다.

```bash
./spark-submit.sh streaming.py 
```

### 추가 자료
- [Structured Streaming Programming Guide](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html#structured-streaming-programming-guide)
- [Structured Streaming + Kafka Integration](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html#structured-streaming-kafka-integration-guide-kafka-broker-versio)
