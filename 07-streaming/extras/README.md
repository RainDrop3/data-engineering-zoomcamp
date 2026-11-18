# 보충 streaming 예제

이전 코스 연도의 추가 stream processing 예제입니다. 메인 workshop에 포함되지는 않지만
참고 자료로 유용할 수 있습니다.


## python/

Irem Erturk가 다양한 라이브러리를 사용해 만든 Python Kafka 예제입니다.

- [json_example/](python/json_example) - JSON serialization과 함께
  `kafka-python`을 사용하는 producer와 consumer
- [avro_example/](python/avro_example) - Avro serialization 및 Schema Registry와 함께
  `confluent-kafka`를 사용하는 producer와 consumer
- [redpanda_example/](python/redpanda_example) - JSON 예제와 같지만
  Kafka 대신 Redpanda를 대상으로 실행하며, 로컬
  docker-compose 설정이 포함되어 있습니다
- [streams-example/faust/](python/streams-example/faust) - Kafka Streams용 Python 라이브러리인
  [Faust](https://faust-streaming.github.io/faust/)를 사용한 stream processing.
  windowing, branching, counting 예제가 포함되어 있습니다.
- [streams-example/pyspark/](python/streams-example/pyspark) - Kafka에서 데이터를 읽는 Spark
  Structured Streaming, Jupyter notebook 포함
- [streams-example/redpanda/](python/streams-example/redpanda) - PySpark 예제와 같지만
  broker로 Redpanda를 사용합니다
- [docker/](python/docker) - 로컬에서 Kafka와 Spark cluster를 실행하기 위한
  Docker Compose 파일
- [resources/](python/resources) - 샘플 데이터(rides.csv)와 Avro schema


## pyflink/

Irem Erturk의 PyFlink workshop입니다. Apache Flink 1.x, Makefile 기반 워크플로,
PostgreSQL sink, Docker Compose 설정을 사용합니다.
[Zach Wilson과 함께한 2025 스트림](https://www.youtube.com/watch?v=P2loELMUUeI)은
Alexey가 Flink 2.2, uv, 단계별 README를 사용해 현재의
[2026 workshop](../workshop/)으로 다시 작성했습니다.


## ksqldb/

[commands.md](ksqldb/commands.md) - Kafka topic을 대상으로 stream 생성, 필터링,
그룹화, windowed aggregation을 수행하는 ksqlDB 쿼리 예제입니다.
theory 섹션의 [ksqlDB and Connect 동영상](../theory/#kafka-streams)에 대응하는 자료입니다.
