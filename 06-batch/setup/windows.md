## Windows

여기서는 Windows에 Spark 4.x를 설치하는 방법을 보여드립니다.
Windows 10과 11에서 테스트했지만, 다른 버전에서도
동작할 겁니다.

이 튜토리얼에서는 명령줄로 [MINGW](https://www.mingw-w64.org/)/[Git Bash](https://gitforwindows.org/)를 사용합니다.

WSL을 쓴다면 [linux.md](linux.md)의 안내를 따르세요.


### Java 설치하기

Spark 4.x는 Java 17이 필요합니다. Adoptium JDK 17을 다운로드하고 압축을 푸세요:

```bash
wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.18%2B8/OpenJDK17U-jdk_x64_windows_hotspot_17.0.18_8.zip
unzip OpenJDK17U-jdk_x64_windows_hotspot_17.0.18_8.zip -d /c/tools/
```

JDK의 전체 경로는 `/c/tools/jdk-17.0.18+8`이 됩니다.

이제 이를 설정하고 `PATH`에 추가합니다 (`.bashrc`에 추가):

```bash
export JAVA_HOME="/c/tools/jdk-17.0.18+8"
export PATH="${JAVA_HOME}/bin:${PATH}"
```

Java가 제대로 동작하는지 확인하세요:

```bash
java --version
```

출력:

```
openjdk 17.0.18 2026-01-20 LTS
OpenJDK Runtime Environment Temurin-17.0.18+8 (build 17.0.18+8-LTS)
OpenJDK 64-Bit Server VM Temurin-17.0.18+8 (build 17.0.18+8-LTS, mixed mode, sharing)
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

두 방법 모두 PySpark와 함께 번들된 Spark 배포판을 설치합니다 — Spark나 Hadoop을 따로 다운로드할 필요가 없습니다.

> 이전에 Spark 3.x를 설치했고 `.bashrc`에 `SPARK_HOME`이 설정되어 있다면(예: `C:/tools/spark-3.3.2-bin-hadoop3`를 가리키는), 그 줄을 지우세요. PySpark 4.x는 자체 Spark를 번들로 포함하므로 `SPARK_HOME`이 더 이상 필요 없습니다. 예전 `SPARK_HOME`이 남아 있으면 PySpark 4.x가 예전 JAR를 불러와 실패합니다.


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

이 시점에 Windows 방화벽 메시지가 뜰 수 있습니다 — 허용하세요.

`WARNING: Using incubator modules: jdk.incubator.vector` 같은 경고가 보일 수 있습니다 — 무시해도 됩니다.

