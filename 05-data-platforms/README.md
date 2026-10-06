# Module 5: Data Platforms

## 개요

이 모듈에서는 데이터 플랫폼에 대해 배웁니다. 데이터 플랫폼은 수집(ingestion)부터 분석까지 데이터 라이프사이클 전체를 관리하도록 도와주는 도구입니다.

데이터 플랫폼의 예시로 [Bruin](https://getbruin.com/)을 사용합니다. Bruin은 여러 도구를 하나의 플랫폼 아래에 모아 둡니다:

- 데이터 수집 (소스에서 추출해 웨어하우스로 적재)
- 데이터 변환 (정제, 모델링, 집계)
- 데이터 오케스트레이션 (스케줄링과 의존성 관리)
- 데이터 품질 (내장 체크와 검증)
- 메타데이터 관리 (lineage, 문서화)

## 튜토리얼

전체 실습 튜토리얼은 여기서 따라 하세요:

[Bruin Data Engineering Zoomcamp 템플릿](https://github.com/bruin-data/bruin/tree/main/templates/zoomcamp)

이 템플릿은 TODO 기반 학습 과제입니다 — `bruin init zoomcamp my-taxi-pipeline`을 실행한 뒤 인라인 주석의 안내에 따라 설정과 코드를 채워 넣으세요. [노트](notes/)에는 완성된 참고 구현이 들어 있습니다.

## 영상

### :movie_camera: 5.1 - Bruin 소개

[![](images/thumbnail-f6vg7lGqZx0.jpg)](https://youtu.be/f6vg7lGqZx0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=1)

Bruin 데이터 플랫폼 소개: Bruin이 무엇인지, 모던 데이터 스택(ETL/ELT, 오케스트레이션, 데이터 품질)은 어떤 모습인지, 그리고 Bruin이 이 모든 것을 어떻게 하나의 프로젝트로 묶는지.

- [노트](notes/01-introduction.md)


### :movie_camera: 5.2 - Bruin 시작하기

[![](images/thumbnail-JJwHKSidX_c.jpg)](https://youtu.be/JJwHKSidX_c&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=2)

Bruin을 설치하고, VS Code/Cursor 확장과 Bruin MCP를 설정하고, `bruin init`으로 첫 프로젝트를 만듭니다. environment, connection(DuckDB, Chess.com), pipeline YAML 설정을 살펴보고 Python, YAML ingestor, SQL asset을 실행합니다.

- [노트](notes/02-getting-started.md)


### :movie_camera: 5.3 - NYC Taxi 데이터로 End-to-End 파이프라인 구축하기

[![](images/thumbnail-q0k_iz9kWsI.jpg)](https://youtu.be/q0k_iz9kWsI&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=3)

NYC taxi 데이터와 DuckDB를 사용해 3계층 아키텍처(ingestion, staging, reports)로 전체 파이프라인을 구축합니다.

- [노트](notes/03-nyc-taxi-pipeline.md)


### :movie_camera: 5.4 - AI 에이전트와 함께 Bruin MCP 사용하기

[![](images/thumbnail-224xH7h8OaQ.jpg)](https://youtu.be/224xH7h8OaQ&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=4)

Cursor/VS Code에 Bruin MCP를 설치하고 AI 에이전트로 NYC taxi 파이프라인 전체를 처음부터 끝까지 구축합니다. 대화하듯 데이터를 조회하고, 파이프라인 로직에 대해 질문하고, 문제를 해결합니다 — 모두 자연어로.

- [노트](notes/04-bruin-mcp.md)


### :movie_camera: 5.5 - Bruin Cloud에 배포하기

[![](images/thumbnail-uBqjLEwF8rc.jpg)](https://youtu.be/uBqjLEwF8rc&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=5)

Bruin Cloud에 가입하고, GitHub 저장소를 연결하고, 데이터 웨어하우스 connection을 설정한 뒤, 완전 관리형 인프라에서 파이프라인을 배포하고 모니터링합니다.

- [노트](notes/05-bruin-cloud.md)


## Bruin 핵심 개념

Bruin의 기본 개념인 project, pipeline, asset, variable, command를 다루는 짧은 영상들입니다.

### :movie_camera: Projects

[![](images/thumbnail-YWDjnSxbBtY.jpg)](https://www.youtube.com/watch?v=YWDjnSxbBtY)

Bruin 데이터 파이프라인을 만드는 루트 디렉토리. 프로젝트 초기화, `.bruin.yml` 설정 파일, environment, connection에 대해 배웁니다.

- [노트](notes/06-core-01-projects.md)


### :movie_camera: Pipelines

[![](images/thumbnail-uzp_DiR4Sok.jpg)](https://www.youtube.com/watch?v=uzp_DiR4Sok)

실행 스케줄을 기준으로 asset을 정리하는 그룹화 메커니즘. 각 pipeline은 하나의 스케줄과 자체 설정 파일을 가집니다.

- [노트](notes/06-core-02-pipelines.md)


### :movie_camera: Assets

[![](images/thumbnail-ZElY5SoqrwI.jpg)](https://www.youtube.com/watch?v=ZElY5SoqrwI)

데이터베이스의 테이블/뷰를 생성하거나 갱신하는 등 특정 작업을 수행하는 단일 파일. SQL, Python, YAML asset 유형을 예시와 함께 다룹니다.

- [노트](notes/06-core-03-assets.md)


### :movie_camera: Variables

[![](images/thumbnail-XCx0nDmhhxA.jpg)](https://www.youtube.com/watch?v=XCx0nDmhhxA)

pipeline이 실행될 때마다 초기화되는 동적 값. 내장 변수(start_date, end_date)와 pipeline을 파라미터화하는 커스텀 변수에 대해 배웁니다.

- [노트](notes/06-core-04-variables.md)


### :movie_camera: Commands

[![](images/thumbnail-3nykPEs_V7E.jpg)](https://www.youtube.com/watch?v=3nykPEs_V7E)

Bruin 프로젝트를 다루는 CLI 명령어: `bruin run`, `bruin validate`, `bruin lineage` 등을 실전 예시와 함께 다룹니다.

- [노트](notes/06-core-05-commands.md)


## 자료

- [Bruin 문서](https://getbruin.com/docs)
- [Bruin GitHub 저장소](https://github.com/bruin-data/bruin)
- [Bruin MCP (AI 통합)](https://getbruin.com/docs/bruin/getting-started/bruin-mcp)
- [Bruin Cloud](https://getbruin.com/) — 관리형 배포와 모니터링

# 숙제

* [2026 숙제](../cohorts/2026/05-data-platforms/homework.md)

# 커뮤니티 노트

<details>
<summary>직접 정리한 노트가 있나요? 여기에 공유할 수 있습니다</summary>

* 여기에 노트를 추가하세요 (이 줄 위에)

</details>
