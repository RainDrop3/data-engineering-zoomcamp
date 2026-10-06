
## Linux

여기서는 Linux에 Spark 4.x를 설치하는 방법을 보여드립니다.
Ubuntu 24.04(WSL 포함)에서 테스트했지만, 다른 Linux 배포판에서도
동작할 겁니다


### Java 설치하기

Spark 4.x는 Java 17 또는 21이 필요합니다. 가장 간단한 방법은 패키지 매니저로 설치하는 것입니다:

```bash
sudo apt update
sudo apt install default-jdk
```

동작하는지 확인하세요:

```bash
java --version
```

출력 (예시):

```
openjdk 21.0.10 2026-01-20
OpenJDK Runtime Environment (build 21.0.10+7-Ubuntu-124.04)
OpenJDK 64-Bit Server VM (build 21.0.10+7-Ubuntu-124.04, mixed mode, sharing)
```

`JAVA_HOME` 설정 (`.bashrc`나 `.zshrc`에 추가):

```bash
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH="${JAVA_HOME}/bin:${PATH}"
```


### PySpark

Python 패키지 관리에는 [uv](https://docs.astral.sh/uv/)를 권장합니다:

```bash
uv init
uv add pyspark
```

그다음 `uv run`으로 스크립트를 실행합니다:

```bash
uv run python your_script.py
```

또는 pip을 쓸 수도 있습니다:

```bash
pip install pyspark
```

두 방법 모두 PySpark와 함께 번들된 Spark 배포판을 설치합니다 - Spark를 따로 다운로드할 필요가 없습니다.


### 테스트하기

테스트 스크립트 `test_spark.py`를 만드세요:

```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()

print(f"Spark version: {spark.version}")

df = spark.range(10)
df.show()

spark.stop()
```

실행하세요:

```bash
uv run python test_spark.py
```

