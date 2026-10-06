## YARN 위의 Spark

Spark와 Docker 모듈에는 YARN이 필요한데,
YARN은 Hadoop과 함께 제공됩니다. 그래서 Hadoop을 설치해야 합니다

이 문서에서는 Linux를 쓴다고 가정합니다. Windows라면 WSL을 쓰세요. MacOS에서도 (아마) 동작할 겁니다. 

pseudo-distributed 모드로 실행해야 합니다.


### ssh 설정하기

비밀번호를 입력하지 않고 localhost로 `ssh` 접속할 수 있어야 합니다. 다시 말해, 다음을 실행하면 

```bash
ssh localhost
```

ssh 접속이 되어야 합니다. 

안 된다면 `id_rsa.pub` 키를 내 컴퓨터에 접근 가능한 인증 키 목록에 추가하세요:

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
```

(`~/.ssh`에 이미 `id_rsa.pub`가 있다고 가정합니다)

WSL에서는 ssh 서비스를 시작해야 할 수도 있습니다:

```bash
sudo service ssh start
```

### Hadoop 바이너리 다운로드

우리가 쓰는 Spark는 Hadoop 3.2 버전을 기대합니다. 그래서 이 버전을 설치합니다.

[Hadoop 웹사이트](https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz)에서 가장 가까운 미러를 찾으세요. 그리고 다운로드합니다:

```bash
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz
```

압축을 풀고 해당 디렉토리로 이동하세요

```bash
tar xzfv hadoop-3.2.3.tar.gz
cd hadoop-3.2.3/
```


### 단일 노드의 YARN

`etc/hadoop/hadoop-env.sh`에 `JAVA_HOME` 설정:

```bash
echo "export JAVA_HOME=${JAVA_HOME}" >> etc/hadoop/hadoop-env.sh
```

YARN 시작

```bash
./sbin/start-yarn.sh
```

YARN은 8088 포트에서 동작해야 합니다: http://localhost:8088/


### YARN 위에서 Spark 실행하기

spark job을 제출하려면 `master="yarn"`을 사용해야 합니다.

Spark가 YARN 설정 파일을 어디서 찾을지 알아야 하므로 이를 설정합니다:


```bash
export HADOOP_HOME="${HOME}/spark/hadoop-3.2.3"
export YARN_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
```

그런 다음 Jupyter를 실행하거나 spark-submit을 사용하세요.


### Spark와 YARN을 GCS에 연결하기

GCS connector 다운로드:

```bash
gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar .
```

설정 변경:

* `${SPARK_HOME}/conf/spark-defaults.conf` 변경 ([여기]() 참고)
* `${YARN_CONF_DIR}/core-site.xml` 변경 ([여기](config/core-site.xml) 참고)

hadoop property 템플릿:

```xml
  <property>
    <name></name>
    <value></value>
  </property>
```

### Docker로 Spark와 YARN 실행하기

[여기](https://hadoop.apache.org/docs/r3.2.3/hadoop-yarn/hadoop-yarn-site/DockerContainers.html)에서 설정을 복사하세요

spark-submit 실행:

```bash
MOUNTS="$HADOOP_HOME:$HADOOP_HOME:ro,/etc/passwd:/etc/passwd:ro,/etc/group:/etc/group:ro"
IMAGE_ID="pyspark-docker:test"

spark-submit \
    --master yarn \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=${IMAGE_ID} \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=${IMAGE_ID} \
    06_spark_sql.py \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2021/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2021/*/ \
        --output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2021
```



### 출처

* https://hadoop.apache.org/docs/r3.2.3/hadoop-project-dist/hadoop-common/SingleCluster.html
* https://spark.apache.org/docs/latest/configuration.html#custom-hadoophive-configuration
