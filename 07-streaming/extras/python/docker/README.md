
# Docker에서 Spark 및 Kafka Cluster 실행하기

### 1. Spark 실행에 필요한 image 빌드

spark-images를 여러 layer로 나누어 빌드하는 방법에 대한 자세한 내용은
André Perez가 쓴 [Medium blog -Towards Data Science](https://towardsdatascience.com/apache-spark-cluster-on-docker-ft-a-juyterlab-interface-418383c95445)의 블로그 글에서 읽을 수 있습니다.

```bash
# Build Spark Images
./build.sh 
```

### 2. Docker Network 및 Volume 생성

```bash
# Create Network
docker network  create kafka-spark-network

# Create Volume
docker volume create --name=hadoop-distributed-file-system
```

### 3. Docker에서 서비스 실행
```bash
# Start Docker-Compose (within for kafka and spark folders)
docker compose up -d
```
[Kafka Listeners](https://www.confluent.io/blog/kafka-listeners-explained/)에 대한 자세한 설명

[Kafka Listeners](https://www.confluent.io/blog/kafka-listeners-explained/)에 대한 설명

### 4. Docker에서 서비스 중지
```bash
# Stop Docker-Compose (within for kafka and spark folders)
docker compose down
```

### 5. 유용한 명령
```bash
# Delete all Containers
docker rm -f $(docker ps -a -q)

# Delete all volumes
docker volume rm $(docker volume ls -q)
```

