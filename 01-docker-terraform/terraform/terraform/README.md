### 개념
* [Terraform 개요](../1_terraform_overview.md)
* 조직 정책 때문에 서비스 계정 키 파일을 생성할 수 없다면 [아래](#fallback) 안내를 참고하세요

### 실행

```shell
# 이 세션에서 서비스 계정 인증 토큰 갱신
gcloud auth application-default login

# 상태 파일(.tfstate) 초기화
terraform init

# 새 인프라 계획의 변경 사항 확인
terraform plan -var="project=<your-gcp-project-id>"
```

```shell
# 새 인프라 생성
terraform apply -var="project=<your-gcp-project-id>"
```

```shell
# 작업이 끝나면 실행 중인 서비스로 인한 비용이 발생하지 않도록 인프라 삭제
terraform destroy
```

### 경고
GitHub에 코드를 공개하기 전에 [적절한 gitignore](https://github.com/github/gitignore/blob/main/Terraform.gitignore) 파일을 사용하는 것을 잊지 마세요

### Fallback
1. 해당 서비스 계정에 대해 자신에게 토큰 생성자(token creator) 역할을 부여하세요
    ```bash
    gcloud iam service-accounts add-iam-policy-binding \
        <SERVICE_ACCOUNT_EMAIL> \
        --member="user:YOUR_EMAIL@gmail.com" \
        --role="roles/iam.serviceAccountTokenCreator"
    ```
2. 메인 terraform 설정에서 첫 번째 블록 아래에 다음 섹션들을 추가하세요
   ```terraform
    # ADC(신원 확인)를 사용해 gcp에 연결
    provider "google" {
      project = var.project
      region  = var.region
      zone    = var.zone
    }

    /* 아래 data 블록들을 추가하세요 */

    # 이 data 소스는 서비스 계정용 임시 토큰을 가져옵니다
    data "google_service_account_access_token" "default" {
      provider               = google
      target_service_account = "<SERVICE_ACCOUNT_EMAIL>"
      scopes                 = ["https://www.googleapis.com/auth/cloud-platform"]
      lifetime               = "3600s"
    }

    # 이 두 번째 provider 블록이 임시 토큰을 사용해 실제 작업을 수행합니다
    provider "google" {
      alias        = "impersonated"
      access_token = data.google_service_account_access_token.default.access_token
      project      = var.project
      region       = var.region
      zone         = var.zone
    }
   ```

3. 이제 [위](#실행)의 안내를 따라 진행하면 됩니다
