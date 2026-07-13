# Docker로 PostgreSQL 실행하기

**[↑ 위로](README.md)** | **[← 이전](03-dockerizing-pipeline.md)** | **[다음 →](05-data-ingestion.md)**

이제 진짜 데이터 엔지니어링을 해봅시다. 이를 위해 Postgres 데이터베이스를 사용합니다.

별도의 설치 과정 없이 컨테이너화된 Postgres를 실행할 수 있습니다. 몇 가지 _환경 변수_ 와 데이터를 저장할 _볼륨_ 만 제공하면 됩니다.

## 컨테이너에서 PostgreSQL 실행하기

Postgres가 데이터를 저장할 폴더를 원하는 위치에 만드세요. 여기서는 예시로 `ny_taxi_postgres_data` 폴더를 사용합니다. 컨테이너는 다음과 같이 실행합니다:

```bash
docker run -it --rm \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18
```

### 파라미터 설명

* `-e`는 환경 변수를 설정합니다 (사용자, 비밀번호, 데이터베이스 이름)
* `-v ny_taxi_postgres_data:/var/lib/postgresql`는 **네임드 볼륨(named volume)** 을 생성합니다
  * Docker가 이 볼륨을 자동으로 관리합니다
  * 컨테이너를 삭제해도 데이터가 유지됩니다
  * 볼륨은 Docker의 내부 저장소에 저장됩니다
* `-p 5432:5432`는 컨테이너의 5432 포트를 호스트의 5432 포트에 매핑합니다
* `postgres:18`은 PostgreSQL 18 버전을 사용합니다 (2025년 12월 기준 최신)

### 다른 방법 - 바인드 마운트(Bind Mount)

먼저 디렉터리를 만든 뒤 매핑합니다:

```bash
mkdir ny_taxi_postgres_data

docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18
```

### 네임드 볼륨 vs 바인드 마운트

* **네임드 볼륨** (`이름:/경로`): Docker가 관리, 더 간편함
* **바인드 마운트** (`/호스트/경로:/컨테이너/경로`): 호스트 파일시스템에 직접 매핑, 더 세밀한 제어 가능

## PostgreSQL에 접속하기

컨테이너가 실행 중이면 [pgcli](https://www.pgcli.com/)로 데이터베이스에 접속할 수 있습니다.

pgcli 설치:

```bash
uv add --dev pgcli
```

`--dev` 플래그는 이 패키지를 개발용 의존성(프로덕션에서는 필요 없음)으로 표시합니다. `pyproject.toml`의 메인 `dependencies` 섹션 대신 `[dependency-groups]` 섹션에 추가됩니다.

이제 pgcli로 Postgres에 접속합니다:

```bash
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

* `uv run`은 가상환경 컨텍스트에서 명령어를 실행합니다
* `-h`는 호스트입니다. 로컬에서 실행 중이므로 `localhost`를 사용합니다.
* `-p`는 포트입니다.
* `-u`는 사용자 이름입니다.
* `-d`는 데이터베이스 이름입니다.
* 비밀번호는 명령어에 포함하지 않으며, 실행 후 입력하라는 안내가 나옵니다.

비밀번호를 물어보면 `root`를 입력하세요.

## 기본 SQL 명령어

몇 가지 SQL 명령어를 실행해 봅시다:

```sql
-- 테이블 목록 보기
\dt

-- 테스트 테이블 생성
CREATE TABLE test (id INTEGER, name VARCHAR(50));

-- 데이터 삽입
INSERT INTO test VALUES (1, 'Hello Docker');

-- 데이터 조회
SELECT * FROM test;

-- 종료
\q
```

**[↑ 위로](README.md)** | **[← 이전](03-dockerizing-pipeline.md)** | **[다음 →](05-data-ingestion.md)**
