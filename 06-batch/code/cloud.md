## 클라우드에서 Spark 실행하기

### Google Cloud Storage 연결하기 

GCS에 데이터 업로드:

```bash
gsutil -m cp -r pq/ gs://dtc_data_lake_de-zoomcamp-nytaxi/pq
```

GCS 연결용 jar를 원하는 위치(예: `lib` 폴더)에 다운로드하세요:

**참고**: Hadoop용 GCS connector의 다른 버전은 [Cloud Storage connector ](https://cloud.google.com/dataproc/docs/concepts/connectors/cloud-storage#connector-setup-on-non-dataproc-clusters)를 참고하세요.

```bash
gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar ./lib/
```

설정이 담긴 노트북은 [09_spark_gcs.ipynb](09_spark_gcs.ipynb)를 보세요

(안내해 준 Alvin Do에게 감사드립니다!)


### 로컬 클러스터와 Spark-Submit

stand-alone 클러스터 만들기 ([문서](https://spark.apache.org/docs/latest/spark-standalone.html)):

```bash
./sbin/start-master.sh
```

worker 만들기:

```bash
URL="spark://de-zoomcamp.europe-west1-b.c.de-zoomcamp-nytaxi.internal:7077"
./sbin/start-slave.sh ${URL}

# 최신 버전의 spark에서는 이것을 사용:
#./sbin/start-worker.sh ${URL}
```

노트북을 스크립트로 변환:

```bash
jupyter nbconvert --to=script 06_spark_sql.ipynb
```

스크립트를 수정한 다음 실행:

```bash 
python 06_spark_sql.py \
    --input_green=data/pq/green/2020/*/ \
    --input_yellow=data/pq/yellow/2020/*/ \
    --output=data/report-2020
```

클러스터에서 스크립트를 실행하려면 `spark-submit`을 사용하세요

```bash
URL="spark://de-zoomcamp.europe-west1-b.c.de-zoomcamp-nytaxi.internal:7077"

spark-submit \
    --master="${URL}" \
    06_spark_sql.py \
        --input_green=data/pq/green/2021/*/ \
        --input_yellow=data/pq/yellow/2021/*/ \
        --output=data/report-2021
```

### Dataproc

스크립트를 GCS에 업로드:

```bash
gsutil -m cp -r 06_spark_sql.py gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql.py
```

job 파라미터:

* `--input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2021/*/`
* `--input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2021/*/`
* `--output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2021`


Google Cloud SDK로 dataproc에 제출하기
([링크](https://cloud.google.com/dataproc/docs/guides/submit-job#dataproc-submit-job-gcloud))

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=europe-west6 \
    gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql.py \
    -- \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2020/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2020/*/ \
        --output=gs://dtc_data_lake_de-zoomcamp-nytaxi/report-2020
```

### BigQuery

스크립트를 GCS에 업로드:

```bash
gsutil -m cp -r 06_spark_sql_big_query.py gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql_big_query.py
```

결과를 BigQuery에 쓰기 ([문서](https://cloud.google.com/dataproc/docs/tutorials/bigquery-connector-spark-example#pyspark)):

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=europe-west6 \
    --jars=gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar \
    gs://dtc_data_lake_de-zoomcamp-nytaxi/code/06_spark_sql_big_query.py \
    -- \
        --input_green=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/green/2020/*/ \
        --input_yellow=gs://dtc_data_lake_de-zoomcamp-nytaxi/pq/yellow/2020/*/ \
        --output=trips_data_all.reports-2020
```

최신 Spark 버전과 BigQuery connector 사이에 문제가 있을 수 있습니다. Spark 버전별 jar 파일 다운로드 링크는 여기서 찾을 수 있습니다:
[Spark와 BigQuery connector](https://github.com/GoogleCloudDataproc/spark-bigquery-connector)

**참고**: Dataproc on GCE 2.1+ 이미지에는 Spark BigQuery connector가 미리 설치되어 있습니다: [DataProc Release 2.2](https://cloud.google.com/dataproc/docs/concepts/versioning/dataproc-release-2.2). 따라서 job 제출 시 jar 파일을 포함할 필요가 없습니다.