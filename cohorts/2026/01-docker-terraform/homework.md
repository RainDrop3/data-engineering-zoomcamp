# Module 1 숙제: Docker & SQL

이번 숙제에서는 환경을 준비하고 Docker와 SQL을 연습합니다.

숙제를 제출할 때는 여러분의 GitHub 저장소 또는 다른 공개 코드 호스팅
사이트의 링크도 함께 포함해야 합니다.

이 저장소에는 숙제를 푸는 코드가 들어있어야 합니다.

풀이가 코드 파일(예: python 파일)이 아니라 SQL이나 셸 명령어라면,
저장소의 README 파일에 직접 포함시키세요.


## 질문 1. Docker 이미지 이해하기

`python:3.13` 이미지로 docker를 실행하세요. 컨테이너와 상호작용하기 위해 entrypoint로 `bash`를 사용하세요.

이 이미지의 `pip` 버전은 무엇인가요?

- 25.3
- 24.3.1
- 24.2.1
- 23.3.1

> 참고: cohort가 끝난 뒤에 실행한다면 실제 버전이 위 선택지와 다를 수 있습니다. 그럴 때는 여러분이 얻은 값을 사용하세요. 선택지는 라이브 cohort 기간에 사용 가능했던 버전을 반영합니다.


## 질문 2. Docker 네트워킹과 docker-compose 이해하기

다음 `docker-compose.yaml`이 주어졌을 때, pgadmin이 postgres 데이터베이스에 연결하기 위해 사용해야 할 `hostname`과 `port`는 무엇인가요?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

- postgres:5433
- localhost:5432
- db:5433
- postgres:5432
- db:5432

정답이 여러 개라면 아무거나 선택하세요.


## 데이터 준비하기

2025년 11월 green taxi 운행 데이터를 다운로드하세요:

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet
```

zone 데이터셋도 필요합니다:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

## 질문 3. 짧은 운행 횟수 세기

2025년 11월 운행 데이터(lpep_pickup_datetime이 '2025-11-01' 이상 '2025-12-01' 미만) 중에서, `trip_distance`가 1마일 이하인 운행은 몇 건인가요?

- 7,853
- 8,007
- 8,254
- 8,421


## 질문 4. 날짜별 최장 운행

운행 거리가 가장 길었던 승차 날짜는 언제인가요? 데이터 오류를 제외하기 위해 `trip_distance`가 100마일 미만인 운행만 고려하세요.

계산에는 승차 시각을 사용하세요.

- 2025-11-14
- 2025-11-20
- 2025-11-23
- 2025-11-25


## 질문 5. 최대 승차 zone

2025년 11월 18일에 `total_amount`(모든 운행의 합계)가 가장 컸던 승차 zone은 어디인가요?

- East Harlem North
- East Harlem South
- Morningside Heights
- Forest Hills


## 질문 6. 최대 팁

2025년 11월에 "East Harlem North" zone에서 승차한 승객들 중, 팁이 가장 컸던 하차 zone은 어디인가요?

참고: `trip`이 아니라 `tip`입니다. ID가 아니라 zone의 이름이 필요합니다.

- JFK Airport
- Yorkville West
- East Harlem North
- LaGuardia Airport


## Terraform

이 섹션의 숙제에서는 Terraform으로 GCP에 리소스를 생성하여 환경을 준비합니다.

GCP의 VM이나 노트북, 또는 GitHub Codespace에 Terraform을 설치하세요.
강의 저장소의 [이 파일들](../../../01-docker-terraform/terraform/terraform)을
VM/노트북/GitHub Codespace로 복사하세요.

GCP Bucket과 Big Query Dataset을 생성하도록 파일을 필요에 맞게 수정하세요.


## 질문 7. Terraform 워크플로우

다음 중 각각 아래 작업을 수행하는 순서를 올바르게 나타낸 것은 무엇인가요?
1. provider 플러그인을 다운로드하고 backend를 설정하기
2. 제안된 변경 사항을 생성하고 plan을 자동으로 실행하기
3. terraform이 관리하는 모든 리소스를 제거하기

선택지:
- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm


## 풀이 제출하기

* 제출 폼: https://courses.datatalks.club/de-zoomcamp-2026/homework/hw1


## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

### 왜 공개적으로 학습해야 할까요?

- 책임감: 진행 상황을 공유하면 계속하겠다는 다짐과 동기가 생깁니다
- 피드백: 커뮤니티에서 유용한 제안과 교정을 받을 수 있습니다
- 네트워킹: 비슷한 관심사를 가진 사람들, 잠재적인 협업자들과 연결됩니다
- 기록: 여러분의 게시물이 나중에 참고할 수 있는 학습 일지가 됩니다
- 기회: 고용주와 클라이언트는 종종 공개적인 학습을 통해 인재를 발견합니다

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어볼 수 있습니다.

완벽하지 않아도 괜찮습니다. 누구나 어딘가에서 시작하며, 사람들은 진솔한 학습 여정을 지켜보는 걸 좋아합니다!

### LinkedIn 게시물 예시

```
🚀 Week 1 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 1 - Docker & Terraform. Learned how to:

✅ Containerize applications with Docker and Docker Compose
✅ Set up PostgreSQL databases and write SQL queries
✅ Build data pipelines to ingest NYC taxi data
✅ Provision cloud infrastructure with Terraform

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시


```
🐳 Module 1 of Data Engineering Zoomcamp done!

- Docker containers
- Postgres & SQL
- Terraform & GCP
- NYC taxi data pipeline

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
