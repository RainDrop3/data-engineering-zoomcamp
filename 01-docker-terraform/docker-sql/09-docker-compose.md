# Docker Compose

**[↑ 위로](README.md)** | **[← 이전](08-dockerizing-ingestion.md)** | **[다음 →](10-sql-refresher.md)**

`docker-compose`를 사용하면 하나의 설정 파일로 여러 컨테이너를 실행할 수 있어서, 복잡한 `docker run` 명령어를 각각 따로 실행할 필요가 없습니다.

Docker compose는 YAML 파일을 사용합니다. 다음은 `docker-compose.yaml` 파일입니다:

```yaml
services:
  pgdatabase:
    image: postgres:18
    environment:
      POSTGRES_USER: "root"
      POSTGRES_PASSWORD: "root"
      POSTGRES_DB: "ny_taxi"
    volumes:
      - "ny_taxi_postgres_data:/var/lib/postgresql"
    ports:
      - "5432:5432"

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: "admin@admin.com"
      PGADMIN_DEFAULT_PASSWORD: "root"
    volumes:
      - "pgadmin_data:/var/lib/pgadmin"
    ports:
      - "8085:80"



volumes:
  ny_taxi_postgres_data:
  pgadmin_data:
```

### 설명

* 네트워크를 지정할 필요가 없습니다. `docker compose`가 알아서 처리해 주기 때문입니다: 모든 컨테이너(파일에서는 "서비스"라고 부름)가 같은 네트워크 안에서 실행되며, 각자의 이름(이 예제에서는 `pgdatabase`와 `pgadmin`)으로 서로를 찾을 수 있습니다.
* `docker run` 명령어의 나머지 세부 사항들(환경 변수, 볼륨, 포트)은 YAML 문법에 맞게 파일에 그대로 기술되어 있습니다.

## Docker Compose로 서비스 시작하기

이제 `docker-compose.yaml`이 있는 디렉터리에서 다음 명령어를 실행하면 Docker compose를 실행할 수 있습니다. 이전에 실행한 컨테이너들이 모두 중지되어 있는지 확인하세요:

```bash
docker-compose up
```

### 백그라운드(Detached) 모드

컨테이너를 포그라운드가 아닌 백그라운드에서 실행하고 싶다면(터미널을 계속 사용할 수 있도록), detached 모드로 실행할 수 있습니다:

```bash
docker-compose up -d
```

## 서비스 중지하기

포그라운드 모드로 실행 중일 때는 `Ctrl+C`를 눌러 컨테이너를 종료해야 합니다. 올바른 종료 방법은 다음 명령어입니다:

```bash
docker-compose down
```

## 기타 유용한 명령어

```bash
# 로그 보기
docker-compose logs

# 중지하고 볼륨까지 삭제
docker-compose down -v
```

## Docker Compose의 장점

- 명령어 하나로 모든 서비스 시작
- 자동 네트워크 생성
- 손쉬운 설정 관리
- 선언적(declarative) 인프라

## Docker Compose 환경에서 수집 스크립트 실행하기

`docker compose`로 Postgres와 pgAdmin을 실행한 상태에서 도커라이징한 수집 스크립트를 다시 실행하려면, Docker compose가 컨테이너들을 위해 생성한 가상 네트워크의 이름을 찾아야 합니다.

```bash
# 네트워크 확인:
docker network ls

# pipeline_default입니다 (디렉터리 이름에 따라 다를 수 있음)
# 이제 스크립트를 실행합니다:
docker run -it --rm\
  --network=pipeline_default \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-pass=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_trips
```

**[↑ 위로](README.md)** | **[← 이전](08-dockerizing-ingestion.md)** | **[다음 →](10-sql-refresher.md)**
