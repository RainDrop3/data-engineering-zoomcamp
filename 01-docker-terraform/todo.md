# Module 1 학습 TODO

> 목표: Docker로 데이터 파이프라인을 만들고, PostgreSQL에 NY Taxi 데이터를 적재한 뒤, Terraform으로 GCP 인프라를 코드로 관리해 본다.
> 진행하면서 체크박스(`- [x]`)를 채워 나가세요.

---

## 0. 사전 준비 (환경 세팅)

- [ ] [Docker Desktop](https://www.docker.com/products/docker-desktop/) 설치 후 `docker --version`으로 확인
- [ ] Python 설치 확인 (`python -V`)
- [ ] `pip install uv`로 uv 설치
- [ ] 모듈 소개 영상 시청: [Introduction](https://www.youtube.com/watch?v=JgspdlKXS-w)

## 1. Docker + Postgres 워크숍 (`docker-sql/`)

영상과 병행: [Docker + Postgres 워크숍 영상](https://www.youtube.com/watch?v=lP8xXebHmuE)

- [ ] [01 - Docker 소개](docker-sql/01-introduction.md) — 컨테이너 개념, 기본 명령어, 볼륨
- [ ] [02 - 가상환경과 데이터 파이프라인](docker-sql/02-virtual-environment.md) — uv로 프로젝트 초기화, pandas 설치
- [ ] [03 - 파이프라인 도커라이징](docker-sql/03-dockerizing-pipeline.md) — 첫 Dockerfile 작성과 빌드
- [ ] [04 - Docker로 PostgreSQL 실행](docker-sql/04-postgres-docker.md) — Postgres 컨테이너 실행, pgcli 접속
- [ ] [05 - NY Taxi 데이터 수집](docker-sql/05-data-ingestion.md) — Jupyter에서 CSV를 청크 단위로 Postgres에 적재
- [ ] [06 - 수집 스크립트 만들기](docker-sql/06-ingestion-script.md) — 노트북을 `ingest_data.py` 스크립트로 변환
- [ ] [07 - pgAdmin](docker-sql/07-pgadmin.md) — Docker 네트워크 만들고 pgAdmin으로 DB 관리
- [ ] [08 - 수집 스크립트 도커라이징](docker-sql/08-dockerizing-ingestion.md) — 수집 파이프라인 전체를 컨테이너로 실행
- [ ] [09 - Docker Compose](docker-sql/09-docker-compose.md) — Postgres + pgAdmin을 파일 하나로 실행
- [ ] [10 - SQL 복습](docker-sql/10-sql-refresher.md) — JOIN, GROUP BY, 집계 쿼리 연습 ([영상](https://www.youtube.com/watch?v=QEcps_iskgg))
- [ ] [11 - 정리하기](docker-sql/11-cleanup.md) — 컨테이너/이미지/볼륨 정리

## 2. GCP 준비

- [ ] GCP 소개 영상 시청: [Introduction to GCP](https://youtu.be/18jIzE41fJ4)
- [ ] Google 계정으로 GCP 가입 (무료 크레딧 $300)
- [ ] 프로젝트 생성 후 Project ID 기록해 두기
- [ ] 서비스 계정 생성 + 키(.json) 다운로드 → [2_gcp_overview.md](terraform/2_gcp_overview.md)
- [ ] IAM 역할 추가: Storage Admin, Storage Object Admin, BigQuery Admin
- [ ] Google Cloud SDK 설치 — Windows 사용자는 [windows.md](terraform/windows.md) 참고
- [ ] `GOOGLE_APPLICATION_CREDENTIALS` 환경 변수 설정 및 `gcloud auth` 인증

## 3. Terraform (`terraform/`)

- [ ] Terraform 개념 영상 시청: [Concepts and Overview](https://youtu.be/s2bOYDCKl_M)
- [ ] [1_terraform_overview.md](terraform/1_terraform_overview.md) 읽기 — IaC 개념, 파일 구조, 실행 단계
- [ ] Terraform 설치 후 `terraform -version` 확인
- [ ] 실습 영상 시청: [Terraform Basics](https://youtu.be/Y2ux7gq3Z0o), [Deployment with Variables](https://youtu.be/PBi0hHjLftk)
- [ ] `terraform/terraform/` 디렉터리에서 실습: `init` → `plan` → `apply` (GCS 버킷 + BigQuery 데이터셋 생성)
- [ ] 실습 후 `terraform destroy`로 리소스 삭제 (비용 방지!)

## 4. 숙제

- [ ] [Homework](../cohorts/2026/01-docker-terraform/homework.md) 풀기

---

## 다음 단계

Module 1을 마치면 → `02-workflow-orchestration/` (워크플로우 오케스트레이션)으로 진행

## 팁

- 문서 순서대로 직접 명령어를 쳐보면서 진행하는 것이 가장 효과적입니다.
- 막히면 각 모듈 README 하단의 커뮤니티 노트를 참고하세요.
- GCP 리소스는 쓰지 않을 때 꼭 삭제해서 크레딧을 아끼세요.
