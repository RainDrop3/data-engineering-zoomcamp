# Module 6: Batch Processing

## 6.1 소개

* :movie_camera: 6.1.1 Batch Processing 소개

[![](images/thumbnail-dcHe5Fl3MF8.jpg)](https://youtu.be/dcHe5Fl3MF8&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=51)

* :movie_camera: 6.1.2 Spark 소개

[![](images/thumbnail-FhaqbEOuQ8U.jpg)](https://youtu.be/FhaqbEOuQ8U&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=52)


## 6.2 설치

[이 안내](setup/)를 따라 Spark를 설치하세요:

* [Windows](setup/windows.md)
* [Linux](setup/linux.md)
* [MacOS](setup/macos.md)

:movie_camera: 6.2.1 (선택) Spark 설치하기 (Linux)

[![](images/thumbnail-hqUbB9c8sKg.jpg)](https://youtu.be/hqUbB9c8sKg&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=53)

위 셋업이 동작하지 않는다면 대안으로 Google Colab에서 Spark를 실행할 수 있습니다.
> [!NOTE]  
> 바로 이 방법으로 넘어가기보다는 로컬 환경을 설정하는 데 시간을 들이는 것을 권합니다

* [Google Colab 안내](https://medium.com/gitconnected/launch-spark-on-google-colab-and-connect-to-sparkui-342cad19b304)
* [Google Colab 시작용 노트북](https://github.com/aaalexlit/medium_articles/blob/main/Spark_in_Colab.ipynb)


## 6.3 Spark SQL과 DataFrame

* :movie_camera: 6.3.1 Spark/PySpark 첫걸음

[![](images/thumbnail-r_Sf6fCB40c.jpg)](https://youtu.be/r_Sf6fCB40c&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=54)

* :movie_camera: 6.3.2 Spark DataFrame

[![](images/thumbnail-ti3aC1m3rE8.jpg)](https://youtu.be/ti3aC1m3rE8&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=55)

* :movie_camera: 6.3.3 (선택) Yellow와 Green Taxi 데이터 준비하기

[![](images/thumbnail-CI3P4tAtru4.jpg)](https://youtu.be/CI3P4tAtru4&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=56)

데이터셋 준비 스크립트 [download_data.sh](code/download_data.sh)

> [!NOTE]  
> csv 파일의 schema를 추론하는 또 다른 방법은(pandas 말고) Spark에서 파일을 읽을 때 `inferSchema` 옵션을 `true`로 설정하는 것입니다.

* :movie_camera: 6.3.4 Spark에서 SQL 쓰기

[![](images/thumbnail-uAlp2VuZZPY.jpg)](https://youtu.be/uAlp2VuZZPY&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=57)


## 6.4 Spark 내부 구조

* :movie_camera: 6.4.1 Spark 클러스터의 구조

[![](images/thumbnail-68CipcZt7ZA.jpg)](https://youtu.be/68CipcZt7ZA&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=58)

* :movie_camera: 6.4.2 Spark의 GroupBy

[![](images/thumbnail-9qrDsY_2COo.jpg)](https://youtu.be/9qrDsY_2COo&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=59)

* :movie_camera: 6.4.3 Spark의 Join

[![](images/thumbnail-lu7TrqAWuH4.jpg)](https://youtu.be/lu7TrqAWuH4&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=60)

## 6.5 (선택) Resilient Distributed Datasets

* :movie_camera: 6.5.1 Spark RDD 연산

[![](images/thumbnail-Bdu-xIrF3OM.jpg)](https://youtu.be/Bdu-xIrF3OM&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=61)

* :movie_camera: 6.5.2 Spark RDD mapPartition

[![](images/thumbnail-k3uB2K99roI.jpg)](https://youtu.be/k3uB2K99roI&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=62)


## 6.6 클라우드에서 Spark 실행하기

* :movie_camera: 6.6.1 Google Cloud Storage 연결하기

[![](images/thumbnail-Yyz293hBVcQ.jpg)](https://youtu.be/Yyz293hBVcQ&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=63)

* :movie_camera: 6.6.2 로컬 Spark 클러스터 만들기

[![](images/thumbnail-HXBwSlXo5IA.jpg)](https://youtu.be/HXBwSlXo5IA&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=64)

* :movie_camera: 6.6.3 Dataproc 클러스터 설정하기

[![](images/thumbnail-osAiAYahvh8.jpg)](https://youtu.be/osAiAYahvh8&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=65)

* :movie_camera: 6.6.4 Spark와 BigQuery 연결하기

[![](images/thumbnail-HIm2BOj8C0Q.jpg)](https://youtu.be/HIm2BOj8C0Q&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=66)


# 숙제

* [2026 숙제](../cohorts/2026/06-batch/homework.md)


# 커뮤니티 노트

<details>
<summary>직접 정리한 노트가 있나요? 여기에 공유할 수 있습니다</summary>

* [Alvaro Navas의 노트](https://github.com/ziritrion/dataeng-zoomcamp/blob/main/notes/5_batch_processing.md)
* [Sandy의 DE 학습 블로그](https://learningdataengineering540969211.wordpress.com/2022/02/24/week-5-de-zoomcamp-5-2-1-installing-spark-on-linux/)
* [Alain Boisvert의 노트](https://github.com/boisalai/de-zoomcamp-2023/blob/main/week5.md)
* [대안: rafik의 docker-compose로 spark 띄우기](https://gist.github.com/rafik-rahoui/f98df941c4ccced9c46e9ccbdef63a03) 
* [Marcos Torregrosa의 블로그 (스페인어)](https://www.n4gash.com/2023/data-engineering-zoomcamp-semana-5-batch-spark)
* [Victor Padilha의 노트](https://github.com/padilha/de-zoomcamp/tree/master/week5)
* [Oscar Garcia의 노트](https://github.com/ozkary/Data-Engineering-Bootcamp/tree/main/Step5-Batch-Processing)
* [HongWei의 노트](https://github.com/hwchua0209/data-engineering-zoomcamp-submission/blob/main/05-batch-processing/README.md)
* Maria Fisher의 [2024 영상 스크립트](https://drive.google.com/drive/folders/1XMmP4H5AMm1qCfMFxc_hqaPGw31KIVcb?usp=drive_link)
* [Manuel Guerra의 2025 노트](https://github.com/ManuelGuerra1987/data-engineering-zoomcamp-notes/blob/main/5_Batch-Processing-Spark/README.md)
* [Gabi Fonseca의 2025 노트](https://github.com/fonsecagabriella/data_engineering/blob/main/05_batch_processing/00_notes.md)
* [Gabi Fonseca의 2025 MacOS Spark 설치 노트 (Anaconda + brew)](https://github.com/fonsecagabriella/data_engineering/blob/main/05_batch_processing/01_env_setup.md)
* [Daniel Lachner의 2025 노트](https://github.com/mossdet/dlp_data_eng/blob/main/Notes/05_01_Batch_Processing_Spark_GCP.pdf)
* [Ajay Katte의 2026 노트](https://github.com/mushroomsandchai/dtdez/tree/main/06_batch_processing/notes)
* [khanh의 2026 Windows PySpark 설치 영상 (pip install 없이)](https://www.youtube.com/watch?v=8OYBW4Lwu60)
* 여기에 노트를 추가하세요 (이 줄 위에)

</details>
