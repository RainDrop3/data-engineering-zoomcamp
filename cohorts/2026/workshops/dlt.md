# API에서 Warehouse까지: dlt로 하는 AI 기반 Data Ingestion

[영상](https://www.youtube.com/watch?v=5eMytPBgmVs)

이 실습 워크숍은 dlt(data load tool)를 사용해 data warehouse(예: Snowflake)로 향하는 안정적인 data ingestion 파이프라인을 구축하는 데 초점을 맞추며, LLM과 dlt 대시보드, dlt MCP를 활용해 이를 강화합니다.

## 배우게 될 내용

프로덕션에 쓸 수 있는 ingestion 구성의 핵심 요소들을 직접 다뤄봅니다:

- API, 파일, 데이터베이스에서 데이터 추출하기
- 데이터를 일관된 스키마로 정규화하기
- data warehouse(예: Snowflake)에 데이터 쓰기
- LLM으로 dlt 파이프라인 개발 속도 높이기
- dlt 대시보드와 dlt MCP로 데이터 및 스키마 변경 검증하기

이 세션은 전적으로 실습 중심이며 코드로 진행됩니다. 워크숍이 끝나면 유지보수 가능하고 확장성 있는 ingestion 파이프라인을 설계하는 방법과, AI 및 검증 도구를 활용해 이를 더 빠르고 확신 있게 구축하는 방법을 이해하게 됩니다.

## 자료

* [워크숍 안내](dlt/README.md)
* [dlt Pipeline Overview 노트북 (Google Colab)](https://colab.research.google.com/github/anair123/data-engineering-zoomcamp/blob/workshop/dlt_2026/cohorts/2026/workshops/dlt/dlt_Pipeline_Overview.ipynb)
* [숙제](dlt/dlt_homework.md)
* [숙제 제출 폼](https://courses.datatalks.club/de-zoomcamp-2026/homework/dlt)

## 발표자 소개

**Aashish Nair**는 dltHub의 Data Engineer이며, 프로덕션에서 dlt 파이프라인을 운영하는 모범 사례를 가르치는 유명한 _dlt deployment_ 강의의 제작자입니다.
