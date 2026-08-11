# Cloud Setup 가이드

이 가이드는 Module 3에서 만든 BigQuery 데이터 웨어하우스와 함께 동작하도록 dbt를 셋업하는 과정을 안내합니다.

<div align="center">

[![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/bigquery)

</div>

> [!NOTE]
> 이 가이드는 [Module 3: Data Warehouse](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/03-data-warehouse)를 완료했다고 가정합니다. 거기서 다음을 했습니다:
> - GCP 프로젝트를 만들고 BigQuery API를 활성화
> - BigQuery 권한을 가진 service account 생성
> - BigQuery에 데이터를 적재하는 법 학습 (`nytaxi` dataset에)
>
> Module 4는 Module 3과 **다른 데이터**를 씁니다 (2024년 yellow만이 아니라 2019~2020년 green과 yellow taxi 데이터). 새 데이터는 아래 [Step 1](#load-the-taxi-data)에서 적재합니다.

## Step 1: BigQuery 셋업 확인

dbt Cloud를 셋업하기 전에 Module 3에서 만든 데이터와 자격 증명이 있는지 확인하세요.

### Service Account 확인

Module 3에서 만든 service account JSON 키 파일이 이미 있어야 합니다. 다음 권한이 있는지 확인하세요:

- **BigQuery Data Editor**
- **BigQuery Job User**
- **BigQuery User**

새 service account를 만들거나 새 키를 받아야 한다면 아래 안내를 따르세요.

### Service Account JSON 키 다운로드 방법

JSON 키 파일이 없거나 새로 받아야 한다면:

1. [Google Cloud Console](https://console.cloud.google.com/)로 이동합니다

2. **IAM & Admin** > **Service Accounts**로 이동합니다
   - 또는 검색창에 "Service Accounts"를 입력합니다

3. 목록에서 service account를 찾습니다
   - `service-account-name@project-id.iam.gserviceaccount.com` 형태여야 합니다
   - 아직 service account가 없다면 **+ CREATE SERVICE ACCOUNT**를 클릭하고:
     - 이름을 입력합니다 (예: `dbt-bigquery-service-account`)
     - **CREATE AND CONTINUE**를 클릭합니다
     - 다음 역할을 추가합니다:
       - **BigQuery Admin** (또는 최소한: BigQuery Data Editor, BigQuery Job User, BigQuery User)
     - **CONTINUE** > **DONE**을 클릭합니다

4. service account 이름을 클릭해 상세 정보를 엽니다

5. **KEYS** 탭으로 이동합니다

6. **ADD KEY** > **Create new key**를 클릭합니다

7. 키 타입으로 **JSON**을 선택합니다

8. **CREATE**를 클릭합니다

9. JSON 키 파일이 컴퓨터에 자동으로 다운로드됩니다
   - 안전한 위치에 보관하세요
   - **이 파일을 절대 Git에 커밋하거나 공개적으로 공유하지 마세요** — GCP 리소스에 접근할 수 있는 자격 증명이 들어 있습니다

다운로드된 JSON 파일은 대략 이런 모습입니다:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account-name@project-id.iam.gserviceaccount.com",
  ...
}
```

이 JSON 파일은 Step 4에서 dbt Cloud를 BigQuery에 연결할 때 사용합니다.

### Taxi 데이터 적재하기

이 모듈은 **2019~2020년 yellow와 green taxi 데이터**를 사용합니다. Module 3에서 적재한 데이터와는 다릅니다. Module 3에서 배운 것과 같은 방식으로 다음 데이터를 BigQuery `nytaxi` dataset에 적재하세요:

- 2019년과 2020년 전체 월의 **Yellow taxi trip 레코드**
- 2019년과 2020년 전체 월의 **Green taxi trip 레코드**

> [!IMPORTANT]
> 데이터는 공식 NYC TLC 웹사이트가 **아니라** [DataTalksClub NYC TLC Data 저장소](https://github.com/DataTalksClub/nyc-tlc-data/releases)에서 받으세요. 공식 사이트는 수년에 걸쳐 소급 갱신되어 왔기 때문에, 숙제 정답의 기준이 된 데이터와 다릅니다.

적재 후 데이터를 확인하세요:

1. [BigQuery Console](https://console.cloud.google.com/bigquery)로 이동합니다
2. 왼쪽 Explorer 패널에서 프로젝트를 펼칩니다
3. `nytaxi` dataset이 보여야 합니다
4. `nytaxi` dataset을 펼치면 다음 테이블이 보여야 합니다:
   - `green_tripdata`
   - `yellow_tripdata`

### Dataset 위치 확인해두기

Module 3에서 BigQuery dataset을 만들 때 위치를 골랐습니다 (예: `US`, `EU`, `us-central1`). dbt를 설정할 때 같은 위치를 써야 합니다.

**dataset 위치 확인 방법:**
1. BigQuery Console에서 `nytaxi` dataset을 클릭합니다
2. dataset 상세 정보에서 **Data location**을 확인합니다

## Step 2: dbt Platform 가입

dbt Platform은 웹 IDE, 스케줄러, 협업 기능을 갖춘 dbt의 클라우드 기반 개발 환경입니다. dbt는 **무료 Developer 플랜**을 제공합니다. dbt를 배우고 강의를 따라가기에는 차고 넘칩니다.

## Step 3: 새 dbt 프로젝트 만들기

이제 dbt Cloud에서 새 dbt 프로젝트를 처음부터 만듭니다.

1. **Account settings**(오른쪽 위 톱니바퀴 아이콘)로 이동해 **+ New Project**를 클릭합니다

2. 프로젝트 이름을 입력합니다:
   - 프로젝트 이름: `taxi_rides_ny`

3. **Continue**를 클릭합니다

## Step 4: BigQuery 연결 설정

이전 단계에서 **Continue**를 클릭하면 dbt Cloud가 데이터 웨어하우스 연결을 설정하라고 안내합니다.

> [!TIP]
> 연결 설정 화면으로 자동으로 넘어가지 않는다면 **Account settings** > **Projects** > **taxi_rides_ny** > **Connection**에서도 설정할 수 있습니다.

### Service Account JSON 업로드

1. 연결 타입으로 **BigQuery**를 선택합니다

2. **Upload a Service Account JSON file**을 클릭합니다

3. Module 3의 service account JSON 키 파일을 선택합니다

4. dbt가 자동으로 다음을 추출합니다:
   - GCP 프로젝트 ID
   - 인증 자격 증명

### 연결 설정 구성

1. **Dataset**: `dbt_prod`를 입력합니다
   - dbt가 dataset을 만들 기준 schema 이름입니다
   - dbt가 model을 다음과 같은 schema로 정리합니다:
     - `dbt_prod_staging` — staging model용
     - `dbt_prod_intermediate` — intermediate model용
     - `dbt_prod_marts` — 최종 분석 테이블용

2. **Location**: Module 3의 `nytaxi` dataset과 같은 위치를 선택합니다
   - 예: `US`, `EU`, 또는 `us-central1`
   - **반드시 nytaxi dataset 위치와 일치해야 합니다**
   - UI 버전에 따라 **Optional Settings** 또는 **Advanced Settings** 아래에서 찾을 수 있습니다

3. **Timeout**: `300`초

4. **Maximum Bytes Billed**: (선택)
   - 무제한으로 두려면 비워두거나,
   - 폭주하는 쿼리를 막기 위해 `1000000000`(1 GB) 같은 한도를 설정합니다

### 연결 테스트

1. **Test Connection**을 클릭합니다

2. 성공 메시지가 보여야 합니다: "Connection test succeeded"

3. **Continue**를 클릭합니다

## Step 5: 저장소 설정

dbt Cloud는 프로젝트 코드를 저장할 Git 저장소가 필요합니다. 두 가지 선택지가 있습니다:

- dbt가 저장소를 관리하게 하기 (초보자에게 권장)
- 자신의 GitHub 저장소 연결하기 (프로덕션에 권장)

이 강의에서는 어느 쪽을 선호하든 상관없습니다.

## Step 6: 개발 환경 확인

### dbt에서 환경(Environment)이란?

dbt에서 **환경**은 데이터 변환이 실행되는 서로 다른 맥락을 정의합니다:

- **Development 환경**: model을 만들고 테스트하는 개인 작업 공간
  - 개인 자격 증명을 사용합니다
  - 이름이 붙은 임시 schema를 만듭니다 (예: `dbt_<your_name>`)
  - 변경 사항이 프로덕션이 아니라 본인 작업에만 영향을 줍니다
  - dbt Cloud IDE에서 작업할 때 사용됩니다

- **Deployment 환경**: 최종 model이 스케줄에 따라 실행되는 프로덕션 작업 공간
  - service account 자격 증명을 사용합니다
  - 프로덕션 schema를 만듭니다 (예: `dbt_prod_staging`, `dbt_prod_marts`)
  - 데이터 웨어하우스를 최신으로 유지하는 예약 작업이 사용합니다

분석 코드를 위한 초안 폴더(development)와 발행 폴더(deployment)를 갖는 것이라고 생각하면 됩니다.

### 개발 환경 확인하기

dbt Cloud는 프로젝트를 셋업할 때 **개발 환경을 자동으로 만듭니다.** 수동으로 만들 필요가 없습니다.

만들어졌는지 확인하려면:

1. 상단 내비게이션 바에서 **Deploy** > **Environments**로 이동합니다
2. **Development** 환경이 이미 목록에 있어야 합니다

### 개발 자격 증명 커스터마이즈 (선택)

개발 중 dbt가 BigQuery에 연결하는 방식을 바꾸거나 개발 schema를 조정해야 한다면:

1. 프로필 아이콘(왼쪽 아래 모서리) > **Your Profile** > **Credentials**를 클릭합니다
2. 프로젝트에 연결된 자격 증명을 선택합니다
3. 여기서 다음을 갱신할 수 있습니다:
   - **Development Schema**: 개인 개발 model이 생성될 위치
     - dbt가 자동으로 제안합니다: `dbt_<your_name>` (예: `dbt_john_smith`)
     - 이 schema는 프로덕션(`dbt_prod`)과 분리되어 있습니다
   - **Target Name**: `dev`(기본값)로 두세요

## Step 7: 개발 시작하기

프로젝트, 연결, 저장소 설정이 끝나면 dbt model을 만들 준비가 된 것입니다.

1. **Start developing in the Studio IDE**를 클릭합니다
   - 이 옵션이 보이지 않으면 상단 내비게이션 바의 **Develop**로 이동합니다

2. dbt Cloud가 작업 공간을 초기화합니다 (1분 정도 걸릴 수 있습니다)

3. IDE가 로드되면 개발 준비가 된 새 프로젝트가 준비되어 있습니다!

## 추가 자료

* [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
* [dbt Documentation](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features)
* [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices)
* [NYC Taxi Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)
