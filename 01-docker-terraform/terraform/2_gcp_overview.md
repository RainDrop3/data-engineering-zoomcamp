## GCP 개요

[영상](https://www.youtube.com/watch?v=18jIzE41fJ4&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=2)


### 이 프로젝트에서 사용하는 GCP 인프라 모듈:
* Google Cloud Storage (GCS): Data Lake
* BigQuery: Data Warehouse

(개념은 Week 2 - Data Ingestion에서 설명합니다)

### 초기 설정 (Initial Setup)

이 강의에서는 무료 버전(최대 300유로 크레딧)을 사용합니다.

1. Google 이메일 계정으로 가입하기
2. 아직 없다면 첫 [프로젝트](https://console.cloud.google.com/) 만들기
    * 예: "DTC DE Course". 그리고 "Project ID"를 적어 두세요 (나중에 Terraform으로 인프라를 배포할 때 사용합니다)
3. 이 프로젝트에 대한 [서비스 계정(service account) 및 인증](https://cloud.google.com/docs/authentication/getting-started) 설정하기
    * 우선 `Viewer` 역할(role)을 부여하세요.
    * 인증용 서비스 계정 키(.json)를 다운로드하세요.
4. 로컬 설정을 위한 [SDK](https://cloud.google.com/sdk/docs/quickstart) 다운로드
5. 다운로드한 GCP 키를 가리키는 환경 변수 설정:
   ```shell
   export GOOGLE_APPLICATION_CREDENTIALS="<path/to/your/service-account-authkeys>.json"

   # 토큰/세션 갱신 및 인증 확인
   gcloud auth application-default login
   ```

### 접근 권한 설정 (Setup for Access)

1. 서비스 계정을 위한 [IAM 역할](https://cloud.google.com/storage/docs/access-control/iam-roles):
   * *IAM & Admin*의 *IAM* 섹션으로 이동 https://console.cloud.google.com/iam-admin/iam
   * 서비스 계정의 *Edit principal* 아이콘 클릭
   * *Viewer*에 더해 다음 역할들을 추가: **Storage Admin** + **Storage Object Admin** + **BigQuery Admin**

2. 프로젝트에서 다음 API들을 활성화:
   * https://console.cloud.google.com/apis/library/iam.googleapis.com
   * https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com

3. `GOOGLE_APPLICATION_CREDENTIALS` 환경 변수가 설정되어 있는지 확인하세요.
   ```shell
   export GOOGLE_APPLICATION_CREDENTIALS="<path/to/your/service-account-authkeys>.json"
   ```

### GCP 인프라 생성을 위한 Terraform 워크숍
[여기](./terraform)에서 계속하세요: `week_1_basics_n_setup/1_terraform_gcp/terraform`
