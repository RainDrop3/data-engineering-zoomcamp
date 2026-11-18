# Redpanda를 사용한 기본 PubSub 예제

이 모듈의 목표는 streaming을 사용하는 capstone project를 제출할 수 있도록 다음 Kafka/Redpanda 개념의 기초를 충분히 이해하는 것입니다.
- clusters
- brokers
- topics
- producers
- consumers and consumer groups
- data serialization and deserialization
- replication and retention
- offsets
- consumer-groups
- 

## 1. 사전 준비

[module-07](./../../../07-streaming/README.md) 동영상을 따라 해 왔다면 이미 `kafka-python` 라이브러리를 설치했을 수 있으니 [Docker](#2-docker) 섹션으로 넘어가도 됩니다.

설치하지 않았다면, 이 Redpanda 강의를 위해 virtual environment에 설치해야 하는 패키지는 이것 하나뿐입니다. 

1. 환경을 활성화합니다
2. `pip install kafka-python`

## 2. Docker

Redpanda cluster를 시작합니다. Redpanda는 단일 binary image이므로 Redpanda로 kafka 개념을 배우기 시작하기가 매우 쉽습니다.

```bash
cd 07-streaming/python/redpanda_example/
docker-compose up -d
```

## 3. RPK alias 설정

Redpanda에는 `Redpanda keeper`를 뜻하는 콘솔 명령 `rpk`가 있습니다. 이는 Redpanda와 함께 제공되는 CLI 도구이며 Docker image에 이미 들어 있습니다. 

Docker 대화형 터미널을 열지 않고도 터미널에서 `rpk`를 사용할 수 있도록 다음 `rpk` alias를 설정하세요. 이 `rpk` alias는 터미널에서 바로 사용할 수 있습니다. 

```bash
alias rpk="docker exec -ti redpanda-1 rpk"
rpk version
```

현재 버전은 `v23.2.26 (rev 328d83a06e)`로 표시됩니다. 이 문서에 공유된 결과와 같은 결과를 얻으려면, `major.minor[.build[.revision]]` 버전 체계에서 중요한 버전 번호는 주 버전인 `v23`입니다.

> [!TIP]
> 2024년 3월 이후에 이 글을 읽고 있고 Docker 파일을 최신 Redpanda image를 사용하도록 업데이트하고 싶다면, [Docker hub](https://hub.docker.com/r/vectorized/redpanda/tags)에 방문해 새 버전 번호를 붙여넣으세요.


## 4. Kafka Producer - Consumer 예제

producer-consumer 예제를 실행하려면 나란히 있는 2개의 탭에서 shell 터미널 2개를 열고 다음 명령을 실행하세요. 각 터미널에서 virtual environment를 활성화해야 합니다.

```bash
# Start consumer script, in 1st terminal tab
python -m consumer.py
# Start producer script, in 2nd terminal tab
python -m producer.py
```

`python -m producer.py` 명령을 다시(그리고 계속) 실행하면, 새로운 `events`가 발생할 때 `consumer` worker 탭이 메시지를 실시간으로 자동 consume하는 것을 볼 수 있습니다.

## 5. Redpanda UI

브라우저에서 [http://localhost:8080](http://localhost:8080) 으로 접속하면 Redpanda Console UI에서 cluster, topic 등도 볼 수 있습니다.


## 6. rpk 명령 용어집

자세한 내용은 [get-started-rpk 블로그 글](https://redpanda.com/blog/get-started-rpk-manage-streaming-data-clusters)을 참고하세요.

```bash
# set alias for rpk
alias rpk="docker exec -ti redpanda-1 rpk"

# get info on cluster
rpk cluster info

# create topic_name with m partitions and n replication factor
rpk topic create [topic_name] --partitions m --replicas n

# get list of available topics, without extra details and with details
rpk topic list
rpk topic list --detailed

# inspect topic config
rpk topic describe [topic_name]

# consume [topic_name]
rpk topic consume [topic_name]

# list the consumer groups in a Redpanda cluster
rpk group list

# get additional information about a consumer group, from above listed result
rpk group describe my-group
```

## 7. 추가 자료

Redpanda University (Redpanda 계정이 필요하며, 무료로 가입해 강의를 들을 수 있습니다)
- [RP101: Getting Started with Redpanda](https://university.redpanda.com/courses/hands-on-redpanda-getting-started)
- [RP102: Stream Processing with Redpanda](https://university.redpanda.com/courses/take/hands-on-redpanda-stream-processing/lessons/37830192-intro)
- [SF101: Streaming Fundamentals](https://university.redpanda.com/courses/streaming-fundamentals)
- [SF102: Kafka building blocks](https://university.redpanda.com/courses/kafka-building-blocks)

Streaming과 Kafka에 대한 기초가 이미 충분하다고 생각한다면 이 보충 강의는 건너뛰어도 좋습니다.

