# Docker 소개

**[↑ 위로](README.md)** | **[← 이전](README.md)** | **[다음 →](02-virtual-environment.md)**

Docker는 _컨테이너화 소프트웨어_ 로, 가상 머신과 비슷하게 소프트웨어를 격리할 수 있지만 훨씬 더 가볍습니다.

Docker 이미지는 우리의 소프트웨어(여기서는 데이터 파이프라인)를 실행하도록 정의한 컨테이너의 _스냅샷_ 입니다. Docker 이미지를 Amazon Web Services나 Google Cloud Platform 같은 클라우드 제공업체로 내보내면 그곳에서 컨테이너를 실행할 수 있습니다.

## 왜 Docker인가?

Docker는 다음과 같은 장점을 제공합니다:

- 재현성(Reproducibility): 어디서나 동일한 환경
- 격리(Isolation): 애플리케이션이 독립적으로 실행됨
- 이식성(Portability): Docker가 설치된 곳이라면 어디서든 실행 가능

Docker는 다양한 상황에서 사용됩니다:

- 통합 테스트: CI/CD 파이프라인
- 클라우드에서 파이프라인 실행: AWS Batch, Kubernetes 잡
- Spark: 대규모 데이터 처리를 위한 분석 엔진
- 서버리스: AWS Lambda, Google Functions

## 기본 Docker 명령어

Docker 버전 확인:

```bash
docker --version
```

간단한 컨테이너 실행:

```bash
docker run hello-world
```

좀 더 복잡한 것을 실행해 봅시다:

```bash
docker run ubuntu
```

아무 일도 일어나지 않습니다. `-it` 모드로 실행해야 합니다:

```bash
docker run -it ubuntu
```

컨테이너 안에는 `python`이 없으니 설치해 봅시다:

```bash
apt update && apt install python3
python3 -V
```

## 상태가 없는(Stateless) 컨테이너

중요: Docker 컨테이너는 상태를 저장하지 않습니다(stateless). 컨테이너 안에서 변경한 내용은 컨테이너를 종료하고 다시 시작하면 저장되지 않습니다.

컨테이너를 나갔다가 다시 사용하면 변경 사항이 사라져 있습니다:

```bash
docker run -it ubuntu
python3 -V
```

이것은 호스트 시스템에 영향을 주지 않기 때문에 좋은 점입니다. 예를 들어 이런 위험한 짓을 했다고 해봅시다:

```bash
docker run -it ubuntu
rm -rf / # 여러분의 컴퓨터에서는 절대 실행하지 마세요!
```

다음에 다시 실행하면 모든 파일이 원래대로 돌아와 있습니다.

## 컨테이너 관리하기

하지만 이것이 _완전히_ 맞는 말은 아닙니다. 상태는 어딘가에 저장됩니다. 중지된 컨테이너들을 확인할 수 있습니다:

```bash
docker ps -a
```

그중 하나를 재시작할 수도 있지만, 좋은 습관이 아니므로 하지 않겠습니다. 이 컨테이너들은 공간을 차지하므로 삭제합시다:

```bash
docker rm $(docker ps -aq)
```

다음부터는 실행할 때 `--rm`을 추가합니다:

```bash
docker run -it --rm ubuntu
```

## 다양한 베이스 이미지

`hello-world`와 `ubuntu` 외에도 다른 베이스 이미지들이 있습니다. 예를 들어 Python:

```bash
docker run -it --rm python:3.9.16
# -slim을 붙이면 더 작은 버전을 받을 수 있습니다
```

이 이미지는 `python`을 실행합니다. bash를 사용하고 싶다면 `entrypoint`를 덮어써야 합니다:

```bash
docker run -it \
    --rm \
    --entrypoint=bash \
    python:3.9.16-slim
```

## 볼륨(Volumes)

지금까지 Docker를 사용하면 어떤 컨테이너든 재현 가능한 방식으로 초기 상태로 복원할 수 있다는 것을 배웠습니다. 그렇다면 데이터는 어떻게 할까요? 흔히 사용하는 방법이 _볼륨(volumes)_ 입니다.

`test` 폴더에 데이터를 만들어 봅시다:

```bash
mkdir test
cd test
touch file1.txt file2.txt file3.txt
echo "Hello from host" > file1.txt
cd ..
```

이제 폴더 안의 파일들을 보여주는 간단한 스크립트 `test/list_files.py`를 만들어 봅시다:

```python
from pathlib import Path

current_dir = Path.cwd()
current_file = Path(__file__).name

print(f"Files in {current_dir}:")

for filepath in current_dir.iterdir():
    if filepath.name == current_file:
        continue

    print(f"  - {filepath.name}")

    if filepath.is_file():
        content = filepath.read_text(encoding='utf-8')
        print(f"    Content: {content}")
```

이제 이 폴더를 Python 컨테이너에 매핑해 봅시다:

```bash
docker run -it \
    --rm \
    -v $(pwd)/test:/app/test \
    --entrypoint=bash \
    python:3.9.16-slim
```

컨테이너 안에서 다음을 실행합니다:

```bash
cd /app/test
ls -la
cat file1.txt
python list_files.py
```

호스트 머신의 파일들을 컨테이너 안에서 접근할 수 있는 것을 확인할 수 있습니다!

**[↑ 위로](README.md)** | **[← 이전](README.md)** | **[다음 →](02-virtual-environment.md)**
