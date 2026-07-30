# API에서 Warehouse까지: dlt로 하는 AI 기반 Data Ingestion

**Data Engineering Zoomcamp 2026** 워크숍에 오신 것을 환영합니다!

이 워크숍에서는 AI 기반 IDE를 사용해 완전한 데이터 파이프라인을 구축합니다. 간단한 프롬프트만으로 API에서 로컬 data warehouse까지 [dlt](https://dlthub.com/docs)(data load tool)로 연결할 수 있습니다. 코드 생성은 AI가 처리하고, 여러분은 결과에 집중하면 됩니다.

## 무엇을 만들게 되나요

이 워크숍이 끝나면 다음을 갖게 됩니다:

1. [Open Library API](https://openlibrary.org/developers/api)에서 데이터를 추출하는 동작하는 dlt 파이프라인
2. DuckDB에 저장된 정규화된 관계형 테이블
3. 데이터를 조회하고, 들여다보고, 시각화하는 능력
4. 데이터 엔지니어링에 AI 기반 개발을 활용해 본 경험

**API 키가 필요 없습니다!** Open Library API는 완전히 개방되어 있고 인증이 필요 없습니다. 바로 시작할 수 있습니다.

---

## 사전 준비

워크숍 전에 다음이 준비되어 있는지 확인하세요:

### 1. dlt가 하는 일 이해하기 (입문자에게 권장)

dlt와 이 라이브러리가 하는 일이 익숙하지 않다면, 워크숍 전에 포함된 Jupyter 노트북을 읽어보시길 권합니다.

**[Google Colab에서 노트북 열기](https://colab.research.google.com/github/anair123/data-engineering-zoomcamp/blob/workshop/dlt_2026/cohorts/2026/workshops/dlt/dlt_Pipeline_Overview.ipynb)**

노트북은 dlt를 단계별로 설명합니다:

- dlt의 source와 pipeline이 무엇인지
- 데이터가 Extract, Normalize, Load를 거쳐 어떻게 이동하는지
- 적재된 데이터를 어떻게 들여다보는지

이 개념들을 이해하면 에이전트가 생성한 코드가 실제로 무슨 일을 하는지 파악하는 데 도움이 됩니다.

> 워크숍을 따라가기 위해 저장소를 clone할 필요는 없습니다. `dlt init` 명령어가 필요한 모든 것을 만들어 줍니다.

### 2. 에이전틱 IDE

context를 이해하고 자연어로부터 코드를 생성할 수 있는 AI 기반 코드 에디터가 필요합니다. 권장 도구:

| IDE | 설명 |
|-----|-------------|
| [**Cursor**](https://cursor.sh) | AI 지원이 내장된 VS Code 포크 (권장) |
| [Windsurf](https://codeium.com/windsurf) | 대안이 되는 에이전틱 IDE |
| [VS Code + GitHub Copilot](https://github.com/features/copilot) | 동작하지만 통합도가 낮음 |

### 3. Python 3.11+

```bash
python --version  # Should be 3.11 or higher
```

### 4. uv (권장) 또는 pip

빠른 의존성 관리를 위해 [uv](https://docs.astral.sh/uv/)를 사용합니다:

```bash
# Install uv (if you don't have it)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

## 워크숍 진행 안내

### 1단계: 새 프로젝트 폴더 만들기

파이프라인을 위한 새 폴더를 만들고 Cursor(또는 선호하는 에이전틱 IDE)에서 여세요:

```bash
mkdir my-dlt-pipeline
cd my-dlt-pipeline
```

### 2단계: dlt MCP 서버 설정 추가하기

사용하는 IDE에 맞는 설정을 고르세요:

Cursor - **Settings → Tools & MCP → New MCP Server**로 이동해 다음을 추가하세요:

```json
{
  "mcpServers": {
    "dlt": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "dlt[duckdb]",
        "--with",
        "dlt-mcp[search]",
        "python",
        "-m",
        "dlt_mcp"
      ]
    }
  }
}
```

VS Code (Copilot) - 프로젝트 폴더에 `.vscode/mcp.json`을 만드세요:

```json
{
  "servers": {
    "dlt": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "dlt[duckdb]",
        "--with",
        "dlt-mcp[search]",
        "python",
        "-m",
        "dlt_mcp"
      ]
    }
  }
}
```

Claude Code - 터미널에서 실행하세요:

```bash
claude mcp add dlt -- uv run --with "dlt[duckdb]" --with "dlt-mcp[search]" python -m dlt_mcp
```

이렇게 하면 dlt MCP 서버가 활성화되어, AI가 dlt 문서와 코드 예제, 그리고 여러분의 파이프라인 메타데이터에 접근할 수 있게 됩니다.

### 3단계: dlt Workspace 설치하기

```bash
pip install "dlt[workspace]"
```

### 4단계: dlt 프로젝트 초기화하기

```bash
dlt init dlthub:open_library duckdb
```

Open Library를 위한 파이프라인 파일과 설정이 생성됩니다. 이제 프롬프트를 시작하는 데 필요한 모든 것이 준비되었습니다.

> 📖 **참고:** [Open Library Workspace Instructions](https://dlthub.com/workspace/source/open-library)

### 5단계: 에이전트에게 파이프라인 구축과 실행을 요청하기

여기서 마법이 일어납니다. `dlt init` 명령어는 사용할 수 있는 샘플 프롬프트도 함께 만들어 줍니다. 시작을 위한 예시는 다음과 같습니다:

```
Please generate a REST API Source for Open Library API, as specified in @open_library-docs.yaml
Start with endpoint(s) books and skip incremental loading for now.
Place the code in open_library_pipeline.py and name the pipeline open_library_pipeline.
If the file exists, use it as a starting point.
Do not add or modify any other files.
Use @dlt rest api as a tutorial.
After adding the endpoints, allow the user to run the pipeline with python open_library_pipeline.py and await further instructions.
```

목적에 맞게 프롬프트를 자유롭게 수정하세요. 에이전트는 다음을 수행합니다:
1. 파이프라인 코드 생성
2. 파이프라인 실행
3. 로컬 DuckDB 데이터베이스로 데이터 적재

이 모든 것이 프롬프트 하나로 이뤄집니다.

### 6단계: 에이전트와 함께 디버깅하기

오류가 발생하면 채팅에 붙여넣고 AI가 해결하도록 하세요. 이것이 AI 기반 개발의 힘입니다. 막히지 않고 빠르게 반복할 수 있습니다.

### 7단계: dlt 대시보드로 파이프라인 데이터 확인하기

파이프라인이 성공적으로 실행되면, 대시보드를 띄워 데이터와 메타데이터를 확인하세요:

```bash
dlt pipeline open_library_pipeline show
```

웹 앱이 열리고 다음을 할 수 있습니다:
- 파이프라인 상태와 실행 이력 보기
- 스키마, 테이블, 컬럼 탐색하기
- 적재된 데이터 조회하기
- 문제 디버깅하기

> 📖 **참고:** [dlt Dashboard Documentation](https://dlthub.com/docs/general-usage/dashboard)

### 8단계: 채팅으로 파이프라인 확인하기

dlt MCP 서버를 설정해 두었다면, AI에게 파이프라인에 대해 직접 물어볼 수 있습니다:

> "파이프라인에서 어떤 테이블이 생성됐어?"  
> "books 테이블의 스키마를 보여줘."  
> "몇 개의 행이 적재됐어?"

에이전트가 여러분의 파이프라인 메타데이터에 접근할 수 있으므로 이런 질문에 답할 수 있습니다.

### 9단계 (보너스): marimo + ibis로 시각화 만들기

[marimo](https://marimo.io/) 노트북과 [ibis](https://ibis-project.org/)로 인터랙티브한 리포트를 만들어 분석을 한 단계 더 발전시켜 보세요.

에이전트에게 시각화를 만들어 달라고 요청하세요:

> "책 수 기준 상위 10명의 저자를 시각화하는 marimo 노트북을 만들어줘. 데이터 접근에는 ibis를 사용해. 참고: https://dlthub.com/docs/general-usage/dataset-access/marimo"

문서 링크를 함께 주면 에이전트가 올바른 스택을 사용합니다.

노트북 실행하기:

```bash
# Edit mode (for development)
marimo edit your_notebook.py

# Run mode (view the report)
marimo run your_notebook.py
```

> 📖 **참고:** [Explore Data with marimo](https://dlthub.com/docs/general-usage/dataset-access/marimo)

---

## 숙제

시연을 봤으니 이제 여러분 차례입니다!

안내는 [dlt_homework.md](dlt_homework.md)를 참고하세요.

---

## 참고 자료

| 자료 | 링크 |
|----------|------|
| dlt 문서 | [dlthub.com/docs](https://dlthub.com/docs) |
| Open Library Workspace 가이드 | [dlthub.com/workspace/source/open-library](https://dlthub.com/workspace/source/open-library) |
| dlt Dashboard 문서 | [dlthub.com/docs/general-usage/dashboard](https://dlthub.com/docs/general-usage/dashboard) |
| marimo + dlt 가이드 | [dlthub.com/docs/general-usage/dataset-access/marimo](https://dlthub.com/docs/general-usage/dataset-access/marimo) |
| Open Library API | [openlibrary.org/developers/api](https://openlibrary.org/developers/api) |

---

*Data Engineering Zoomcamp 2026을 위한 [dltHub](https://dlthub.com)의 워크숍*
