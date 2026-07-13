# Docker와 PostgreSQL: 데이터 엔지니어링 워크숍

* 영상: [링크](https://www.youtube.com/watch?v=lP8xXebHmuE)
* 슬라이드: [링크](https://docs.google.com/presentation/d/19pXcInDwBnlvKWCukP5sDoCAb69SPqgIoxJ_0Bikr00/edit?usp=sharing)
* 코드: [pipeline/](pipeline/)

이 워크숍에서는 Docker의 기초와 Docker 컨테이너를 활용한 데이터 엔지니어링 워크플로우를 살펴봅니다. 이 워크숍은 [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)의 Module 1에 해당합니다.

**데이터 엔지니어링(Data Engineering)** 이란 대규모 데이터를 수집, 저장, 분석하기 위한 시스템을 설계하고 개발하는 일입니다.

## 사전 준비 사항

- Python에 대한 기본적인 이해
- 기본적인 SQL 지식 (있으면 좋지만 필수는 아님)
- Docker와 Python이 설치된 컴퓨터
- Git (선택)

## 워크숍 목차

1. [Docker 소개](01-introduction.md) - Docker란 무엇인지, 왜 사용하는지, 기본 명령어
2. [가상환경과 데이터 파이프라인](02-virtual-environment.md) - uv로 Python 환경 구성하기
3. [파이프라인 도커라이징](03-dockerizing-pipeline.md) - 간단한 파이프라인을 위한 Dockerfile 작성하기
4. [Docker로 PostgreSQL 실행하기](04-postgres-docker.md) - PostgreSQL 데이터베이스 도커라이징
5. [NY Taxi 데이터셋과 데이터 수집](05-data-ingestion.md) - 실제 데이터 다루기, pandas, SQLAlchemy
6. [데이터 수집 스크립트 만들기](06-ingestion-script.md) - 노트북을 Python 스크립트로 변환하기
7. [pgAdmin - 데이터베이스 관리 도구](07-pgadmin.md) - 웹 기반 데이터베이스 관리
8. [수집 스크립트 도커라이징](08-dockerizing-ingestion.md) - 파이프라인 컨테이너화
9. [Docker Compose](09-docker-compose.md) - 다중 컨테이너 오케스트레이션
10. [SQL 복습](10-sql-refresher.md) - SQL 조인, 집계, 쿼리
11. [정리하기](11-cleanup.md) - Docker 리소스 정리
