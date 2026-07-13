# pgAdmin - 데이터베이스 관리 도구

**[↑ 위로](README.md)** | **[← 이전](06-ingestion-script.md)** | **[다음 →](08-dockerizing-ingestion.md)**

`pgcli`는 편리한 도구지만 복잡한 쿼리나 데이터베이스 관리에는 사용하기 번거롭습니다. [`pgAdmin`은 웹 기반 도구](https://www.pgadmin.org/)로, 데이터베이스에 더 편하게 접근하고 관리할 수 있게 해줍니다.

pgAdmin을 Postgres 컨테이너와 함께 컨테이너로 실행할 수 있지만, 두 컨테이너가 서로를 찾을 수 있으려면 같은 _가상 네트워크_ 에 있어야 합니다.

## pgAdmin 컨테이너 실행하기

```bash
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  dpage/pgadmin4
```

`-v pgadmin_data:/var/lib/pgadmin` 볼륨 매핑은 pgAdmin 설정(서버 연결, 환경설정)을 저장해 주므로, 컨테이너를 재시작할 때마다 다시 설정할 필요가 없습니다.

### 파라미터 설명

* 이 컨테이너에는 두 개의 환경 변수가 필요합니다: 로그인 이메일과 비밀번호. 이 예제에서는 `admin@admin.com`과 `root`를 사용합니다.
* pgAdmin은 웹 앱이고 기본 포트는 80입니다. 충돌 가능성을 피하기 위해 로컬호스트의 8085 포트에 매핑합니다.
* 실제 이미지 이름은 `dpage/pgadmin4`입니다.

**참고:** 아직은 동작하지 않습니다. pgAdmin이 PostgreSQL 컨테이너를 볼 수 없기 때문입니다. 두 컨테이너가 같은 Docker 네트워크에 있어야 합니다!

## Docker 네트워크

`pg-network`라는 이름의 가상 Docker 네트워크를 만들어 봅시다:

```bash
docker network create pg-network
```

> 나중에 `docker network rm pg-network` 명령으로 네트워크를 삭제할 수 있습니다. 기존 네트워크는 `docker network ls`로 확인할 수 있습니다.

### 같은 네트워크에서 컨테이너 실행하기

두 컨테이너를 모두 중지하고 네트워크 설정을 추가해 다시 실행합니다:

```bash
# 네트워크에서 PostgreSQL 실행
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18

# 다른 터미널에서, 같은 네트워크로 pgAdmin 실행
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```

* Postgres 컨테이너와 마찬가지로 pgAdmin에도 네트워크와 이름을 지정합니다.
* 컨테이너 이름(`pgdatabase`와 `pgadmin`) 덕분에 네트워크 안에서 컨테이너들이 서로를 찾을 수 있습니다.

## pgAdmin을 PostgreSQL에 연결하기

이제 웹 브라우저에서 `http://localhost:8085`로 접속하면 pgAdmin이 열립니다. 컨테이너 실행 시 사용한 이메일과 비밀번호로 로그인하세요.

1. 브라우저를 열고 `http://localhost:8085`로 이동
2. 이메일 `admin@admin.com`, 비밀번호 `root`로 로그인
3. "Servers" 우클릭 → Register → Server
4. 설정:
   - **General 탭**: Name: `Local Docker`
   - **Connection 탭**:
     - Host: `pgdatabase` (컨테이너 이름)
     - Port: `5432`
     - Username: `root`
     - Password: `root`
5. 저장

이제 pgAdmin 인터페이스로 데이터베이스를 탐색할 수 있습니다!

**[↑ 위로](README.md)** | **[← 이전](06-ingestion-script.md)** | **[다음 →](08-dockerizing-ingestion.md)**
