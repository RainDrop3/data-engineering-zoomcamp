# 숙제: 나만의 dlt 파이프라인 만들기

미리 만들어진 source로 파이프라인을 구축하는 방법을 봤습니다. 이제 **커스텀 API**로 처음부터 직접 만들어 볼 차례입니다.

## 워크숍 자료

* [워크숍 README](README.md)
* [dlt Pipeline Overview 노트북 (Google Colab)](https://colab.research.google.com/github/anair123/data-engineering-zoomcamp/blob/workshop/dlt_2026/cohorts/2026/workshops/dlt/dlt_Pipeline_Overview.ipynb)
* [워크숍 등록 페이지](https://luma.com/hzis1yzp)

## 과제

이번 숙제에서는 커스텀 API에서 NYC taxi 운행 데이터를 DuckDB로 적재하는 dlt 파이프라인을 만들고, 적재한 데이터를 사용해 몇 가지 질문에 답합니다.

## 데이터 소스

커스텀 API(dlt scaffold로 제공되지 않음)의 **NYC Yellow Taxi 운행 데이터**를 다루게 됩니다. 이 데이터셋에는 뉴욕시의 개별 taxi 운행 기록이 담겨 있습니다.

| 속성 | 값 |
|----------|-------|
| Base URL | `https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api` |
| 형식 | 페이지네이션된 JSON |
| 페이지 크기 | 페이지당 1,000개 레코드 |
| 페이지네이션 | 빈 페이지가 반환되면 중단 |

## 설정 안내

이 API는 커스텀(dlt workspace의 scaffold 중 하나가 아님)이므로 설정이 조금 다릅니다.

### 1단계: 새 프로젝트 만들기 (또는 데모 프로젝트 재사용)

워크숍 데모를 따라 하면서 이미 프로젝트 폴더를 만들었다면 그 폴더를 재사용해도 됩니다. 그렇지 않다면 새로 만드세요:

```bash
mkdir taxi-pipeline
cd taxi-pipeline
```

이 폴더를 Cursor(또는 선호하는 에이전틱 IDE)에서 여세요.

### 2단계: dlt MCP 서버 설정하기 (아직 안 했다면)

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

### 3단계: dlt 설치하기

```bash
pip install "dlt[workspace]"
```

### 4단계: 프로젝트 초기화하기

```bash
dlt init dlthub:taxi_pipeline duckdb
```

프로젝트 이름은 원하는 대로 지어도 됩니다. 이 API에는 scaffold가 없으므로, 이 명령어는 다음을 생성합니다:
- dlt 프로젝트 파일
- AI 지원을 위한 Cursor 규칙

**하지만 API 메타데이터가 담긴 YAML 파일은 생성되지 않습니다.** API 정보는 여러분이 직접 제공해야 합니다.

### 5단계: 에이전트에게 프롬프트 주기

이제 AI 어시스턴트로 파이프라인을 구축하세요. scaffold가 없으므로 프롬프트에 API 세부 정보를 직접 제공해야 합니다.

시작을 위한 예시는 다음과 같습니다:

```
Build a REST API source for NYC taxi data.

API details:
- Base URL: https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api
- Data format: Paginated JSON (1,000 records per page)
- Pagination: Stop when an empty page is returned

Place the code in taxi_pipeline.py and name the pipeline taxi_pipeline.
Use @dlt rest api as a tutorial.
```

### 6단계: 실행하고 디버깅하기

파이프라인을 실행하고 동작할 때까지 에이전트와 함께 반복하세요:

```bash
python taxi_pipeline.py
```

---

## 문제

파이프라인이 성공적으로 실행되면, 워크숍에서 다룬 방법들을 사용해 다음을 조사해 보세요:

- **dlt 대시보드**: `dlt pipeline taxi_pipeline show`
- **dlt MCP 서버**: 에이전트에게 파이프라인에 대해 질문하기
- **Marimo 노트북**: 시각화를 만들고 쿼리 실행하기

이 문제들에 답할 때 워크숍에서 살펴본 여러 방법을 시도해 보고, 어떤 것이 본인에게 가장 잘 맞는지 확인해 보시길 권합니다. 무엇이 잘 됐는지(또는 잘 안 됐는지) 제출할 때 자유롭게 공유해 주세요!

### 질문 1: 데이터셋의 시작 날짜와 종료 날짜는 언제인가요?

- 2009-01-01 to 2009-01-31
- 2009-06-01 to 2009-07-01
- 2024-01-01 to 2024-02-01
- 2024-06-01 to 2024-07-01

### 질문 2: 신용카드로 결제된 운행의 비율은 얼마인가요?

- 16.66%
- 26.66%
- 36.66%
- 46.66%

### 질문 3: 팁으로 발생한 총 금액은 얼마인가요?

- $4,063.41
- $6,063.41
- $8,063.41
- $10,063.41


### 참고 자료

| 자료 | 링크 |
|----------|------|
| dlt Dashboard 문서 | [dlthub.com/docs/general-usage/dashboard](https://dlthub.com/docs/general-usage/dashboard) |
| marimo + dlt 가이드 | [dlthub.com/docs/general-usage/dataset-access/marimo](https://dlthub.com/docs/general-usage/dataset-access/marimo) |
| dlt 문서 | [dlthub.com/docs](https://dlthub.com/docs) |

---

## 풀이 제출하기

- 제출 폼: https://courses.datatalks.club/de-zoomcamp-2026/homework/dlt
- 마감일: 웹사이트를 참고하세요

## 팁

- 이 API는 페이지네이션된 데이터를 반환합니다. 파이프라인이 페이지네이션을 올바르게 처리하는지 확인하세요.
- 에이전트가 막히면 오류를 채팅에 붙여넣고 디버깅하도록 하세요.
- dlt MCP 서버를 사용해 파이프라인 메타데이터에 대해 질문하세요.


## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

### LinkedIn 게시물 예시

```
🚀 dlt Workshop of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished the Data Ingestion workshop with @dltHub. Learned how to:

✅ Build REST API data pipelines with dlt
✅ Use AI-assisted development with dlt MCP Server
✅ Load paginated API data into DuckDB
✅ Inspect pipeline data with dlt Dashboard and marimo notebooks

Built a full NYC taxi data pipeline from a custom API - AI-assisted data engineering is the future!

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시

```
🔄 dlt Workshop of Data Engineering Zoomcamp done!

- REST API pipelines with @dltHub
- AI-assisted pipeline building
- DuckDB as local data warehouse
- dlt Dashboard & marimo notebooks

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
