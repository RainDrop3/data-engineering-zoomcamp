# Apache Flink Training
Apache Flink Streaming Pipelines

## :pushpin: 시작하기 

### :whale: 설치

이 저장소를 실행하려면 다음 구성 요소를 설치해야 합니다.

1. [Docker](https://docs.docker.com/get-docker/) (필수)
2. [Docker compose](https://docs.docker.com/compose/install/#installation-scenarios) (필수)
3. Make (권장) -- 아래를 참고하세요
    - 대부분의 Linux 배포판과 macOS에는 `make`가 기본으로 설치되어 있습니다. 시스템에 `make`가 설치되어 있는지 확인하려면 터미널이나 명령 프롬프트에서 `make --version` 명령을 실행하세요. 설치되어 있다면 버전 정보가 표시됩니다. 
    - 설치되어 있지 않다면 아래 안내를 따라 해 보거나, `Makefile`의 명령을 터미널이나 명령 프롬프트에 복사해 붙여넣어 직접 실행해도 됩니다.

        ```bash
        # On Ubuntu or Debian:
        sudo apt-get update
        sudo apt-get install build-essential

        # On CentOS or Fedora:
        sudo dnf install make

        # On macOS:
        xcode-select --install

        # On windows:
        choco install make # uses Chocolatey, https://chocolatey.org/install
        ```

### :computer: 로컬 설정

`pyflick` 폴더에 있는지 확인하세요.

```bash
cd 07-streaming/pyflink
```

## :boom: pipeline 실행

1. Docker image를 빌드하고 `docker-compose.yml` 파일에 정의된 서비스(PostgreSQL 데이터베이스와 Flink cluster 포함)를 배포합니다. 이 과정에서 Flink가 Kafka 메시지를 기록할 sink 테이블 `processed_events`도 함께 생성됩니다(생성되어야 합니다).

    ```bash
    make up

    #// if you dont have make, you can run:
    # docker compose up --build --remove-orphans  -d
    ```

    **:star: 다음 단계로 넘어가기 전에 Flink UI가 [http://localhost:8081/](http://localhost:8081/) 에서 실행될 때까지 기다리세요.** _Docker image를 처음 빌드할 때는 5분에서 30분까지 걸릴 수 있습니다. image를 삭제하지 않았다면 이후 빌드는 몇 초면 끝납니다._

    :information_source: image 빌드가 끝나면 Docker가 job manager와 task manager 서비스를 자동으로 시작합니다. 1분 정도 걸립니다. Docker desktop에서 컨테이너 로그를 확인하여 아래 줄이 보이면 다음 단계로 넘어가도 됩니다.

    ```
    taskmanager Successful registration at resource manager akka.tcp://flink@jobmanager:6123/user/rpc/resourcemanager_* under registration id <id_number>
    ```

2. 이제 Flink cluster가 실행 중이니 드디어 PyFlink job을 실행할 차례입니다! :smile:

    ```bash
    make job

    #// if you dont have make, you can run:
    # docker-compose exec jobmanager ./bin/flink run -py /opt/job/start_job.py -d
    ```

    약 1분 후 job이 제출되었다는 메시지(예: `Job has been submitted with JobID <job_id_number>`)가 표시됩니다. 이제 [Flink UI](http://localhost:8081/#/job/running)로 돌아가 job이 실행 중인 것을 확인하세요! :tada:


3. 작업을 마치면 아래 명령으로 Docker 리소스를 중지하거나 정리할 수 있습니다.

    ```bash
    make stop # to stop running services in docker compose
    make down # to stop and remove docker compose services
    make clean # to remove the docker container and dangling images
    ```

    :grey_exclamation: PostgreSQL 컨테이너 안의 `/var/lib/postgresql/data` 디렉터리는 로컬 머신의 `./postgres-data` 디렉터리에 마운트되어 있습니다. 즉 컨테이너를 재시작하거나 삭제해도 데이터가 유지되므로, 컨테이너를 중지하거나 삭제하더라도 컨테이너 안에 기록한 데이터를 잃지 않습니다.

------

:information_source: 사용 가능한 모든 make 명령과 그 기능을 보려면 다음을 실행하세요.

```bash
make help
```

이 글을 작성하던 시점에 사용 가능한 명령은 다음과 같습니다.

```bash

Usage:
  make <target>

Targets:
  help                 Show help with `make help`
  db-init              Builds and runs the PostgreSQL database service
  build                Builds the Flink base image with pyFlink and connectors installed
  up                   Builds the base Docker image and starts Flink cluster
  down                 Shuts down the Flink cluster
  job                  Submit the Flink job
  stop                 Stops all services in Docker compose
  start                Starts all services in Docker compose
  clean                Stops and removes the Docker container as well as images with tag `<none>`
  psql                 Runs psql to query containerized postgreSQL database in CLI
  postgres-die-mac     Removes mounted postgres data dir on local machine (mac users) and in Docker
  postgres-die-pc      Removes mounted postgres data dir on local machine (PC users) and in Docker
```
