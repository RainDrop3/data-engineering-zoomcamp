
## MacOS

여기서는 macOS에 Spark 4.x를 설치하는 방법을 보여드립니다.
macOS 15(Sequoia)에서 테스트했지만, 다른 버전에서도
동작할 겁니다.


### Java 설치하기

Spark 4.x는 Java 17이 필요합니다. [Homebrew](https://brew.sh/)가 설치되어 있는지 확인한 뒤 OpenJDK 17을 설치하세요:

```bash
brew install openjdk@17
```

`.zshrc`(또는 `.bash_profile`)에 다음 환경 변수를 추가하세요:

```bash
export JAVA_HOME=$(brew --prefix openjdk@17)
export PATH="$JAVA_HOME/bin:$PATH"
```

Java가 제대로 동작하는지 확인하세요:

```bash
java --version
```

출력 (예시):

```
openjdk 17.0.14 2026-01-21
OpenJDK Runtime Environment Homebrew (build 17.0.14+0)
OpenJDK 64-Bit Server VM Homebrew (build 17.0.14+0, mixed mode, sharing)
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

두 방법 모두 PySpark와 함께 번들된 Spark 배포판을 설치합니다 — Spark를 따로 다운로드할 필요가 없습니다.

> 이전에 Spark 3.x를 설치했고 `.zshrc`나 `.bash_profile`에 `SPARK_HOME`이 설정되어 있다면(예: 로컬 Spark 디렉토리를 가리키는), 그 줄을 지우세요. PySpark 4.x는 자체 Spark를 번들로 포함하므로 `SPARK_HOME`이 더 이상 필요 없습니다. 예전 `SPARK_HOME`이 남아 있으면 PySpark 4.x가 예전 JAR를 불러와 실패합니다.


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

`WARNING: Using incubator modules: jdk.incubator.vector` 같은 경고가 보일 수 있습니다 — 무시해도 됩니다.
