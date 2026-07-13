# 수집 스크립트 도커라이징

**[↑ 위로](README.md)** | **[← 이전](07-pgadmin.md)** | **[다음 →](09-docker-compose.md)**

이제 수집 스크립트를 Docker에서 실행할 수 있도록 컨테이너화해 봅시다.

## Dockerfile

`pipeline/Dockerfile`은 수집 스크립트를 컨테이너화하는 방법을 보여줍니다:

```dockerfile
FROM python:3.13.11-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

WORKDIR /code
ENV PATH="/code/.venv/bin:$PATH"

COPY pyproject.toml .python-version uv.lock ./
RUN uv sync --locked

COPY ingest_data.py .

ENTRYPOINT ["uv", "run", "python", "ingest_data.py"]
```

### 설명

- `FROM python:3.13.11-slim`: 용량이 작은 슬림 Python 3.13 이미지로 시작
- `COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/`: 공식 uv 이미지에서 uv 바이너리 복사
- `WORKDIR /code`: 컨테이너 안의 작업 디렉터리 설정
- `ENV PATH="/code/.venv/bin:$PATH"`: 가상환경을 PATH에 추가
- `COPY pyproject.toml .python-version uv.lock ./`: 의존성 파일을 먼저 복사 (캐싱에 유리)
- `RUN uv sync --locked`: 락 파일 기준으로 모든 의존성 설치 (재현 가능한 빌드 보장)
- `COPY ingest_data.py .`: 수집 스크립트 복사
- `ENTRYPOINT ["uv", "run", "python", "ingest_data.py"]`: 수집 스크립트를 실행하도록 엔트리 포인트 설정

## Docker 이미지 빌드하기

```bash
cd pipeline
docker build -t taxi_ingest:v001 .
```

## 컨테이너화된 수집 스크립트 실행하기

```bash
docker run -it \
  --network=pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-pass=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_trips
```

### 중요한 참고 사항

* Docker가 Postgres 컨테이너를 찾을 수 있도록 네트워크를 지정해야 합니다. 네트워크 옵션은 이미지 이름보다 앞에 와야 합니다.
* Postgres가 별도의 컨테이너에서 실행 중이므로, host 인자는 Postgres의 컨테이너 이름(`pgdatabase`)을 가리켜야 합니다.
* 원한다면 미리 pgAdmin에서 테이블을 삭제해도 되지만, 스크립트가 기존 테이블을 자동으로 교체합니다.

**[↑ 위로](README.md)** | **[← 이전](07-pgadmin.md)** | **[다음 →](09-docker-compose.md)**
