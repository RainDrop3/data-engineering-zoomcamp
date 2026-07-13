# 파이프라인 도커라이징

**[↑ 위로](README.md)** | **[← 이전](02-virtual-environment.md)** | **[다음 →](04-postgres-docker.md)**

이제 스크립트를 컨테이너화해 봅시다. 다음과 같은 `Dockerfile` 파일을 생성합니다:

## pip을 사용하는 간단한 Dockerfile

```dockerfile
# 기반이 될 베이스 Docker 이미지
FROM python:3.13.11-slim

# 필요한 패키지를 설치해 이미지를 구성합니다. 여기서는 pandas
RUN pip install pandas pyarrow

# 컨테이너 안의 작업 디렉터리 설정
WORKDIR /app
# 스크립트를 컨테이너로 복사. 첫 번째는 원본 파일, 두 번째는 대상 경로
COPY pipeline.py pipeline.py

# 컨테이너가 실행될 때 가장 먼저 할 일을 정의
# 이 예제에서는 그냥 스크립트를 실행합니다
ENTRYPOINT ["python", "pipeline.py"]
```

**설명:**

- `FROM`: 베이스 이미지 (Python 3.13)
- `RUN`: 빌드 중에 명령어 실행
- `WORKDIR`: 작업 디렉터리 설정
- `COPY`: 이미지 안으로 파일 복사
- `ENTRYPOINT`: 기본으로 실행할 명령어

### 빌드와 실행

이미지를 빌드해 봅시다:

```bash
docker build -t test:pandas .
```

* 이미지 이름은 `test`, 태그는 `pandas`가 됩니다. 태그를 지정하지 않으면 기본값인 `latest`가 사용됩니다.

이제 컨테이너를 실행하면서 인자를 넘겨 파이프라인이 그 값을 받도록 할 수 있습니다:

```bash
docker run -it test:pandas some_number
```

파이프라인 스크립트를 단독으로 실행했을 때와 같은 출력이 나와야 합니다.

> 참고: 이 안내는 `pipeline.py`와 `Dockerfile`이 같은 디렉터리에 있다고 가정합니다. Docker 명령어도 이 파일들이 있는 디렉터리에서 실행해야 합니다.

## uv를 사용하는 Dockerfile

uv는 어떨까요? pip 대신 uv를 사용해 봅시다:

```dockerfile
# 슬림한 Python 3.13 이미지로 시작
FROM python:3.13.10-slim

# 공식 uv 이미지에서 uv 바이너리 복사 (멀티 스테이지 빌드 패턴)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# 작업 디렉터리 설정
WORKDIR /app

# 설치된 패키지를 사용할 수 있도록 가상환경을 PATH에 추가
ENV PATH="/app/.venv/bin:$PATH"

# 의존성 파일을 먼저 복사 (레이어 캐싱에 유리)
COPY "pyproject.toml" "uv.lock" ".python-version" ./
# 락 파일 기준으로 의존성 설치 (재현 가능한 빌드 보장)
RUN uv sync --locked

# 애플리케이션 코드 복사
COPY pipeline.py pipeline.py

# 엔트리 포인트 설정
ENTRYPOINT ["uv", "run", "python", "pipeline.py"]
```

**[↑ 위로](README.md)** | **[← 이전](02-virtual-environment.md)** | **[다음 →](04-postgres-docker.md)**
