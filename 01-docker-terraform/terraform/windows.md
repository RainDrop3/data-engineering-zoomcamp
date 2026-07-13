## Windows에서 GCP와 Terraform 사용하기

WSL을 사용한다면 이 안내는 필요 없습니다. "순수 Windows" 환경에서만 필요합니다.

### Google Cloud SDK

* 이 튜토리얼에는 Linux와 유사한 환경이 필요합니다. 예: [GitBash](https://gitforwindows.org/), [MinGW](https://www.mingw-w64.org/), [cygwin](https://www.cygwin.com/)
  * Power Shell도 가능하지만 약간의 수정이 필요합니다
* SDK를 zip으로 다운로드: https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip
  * 출처: https://cloud.google.com/sdk/docs/downloads-interactive
* 압축을 풀고 `install.sh` 스크립트를 실행하세요

설치 중에 다음과 같은 메시지가 보일 수 있습니다:

```
The installer is unable to automatically update your system PATH. Please add
  C:\tools\google-cloud-sdk\bin
```

* 이를 해결하려면 `.bashrc`에서 해당 경로를 `PATH`에 추가하세요 ([안내](https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path))
* 시스템 전역으로 설정할 수도 있습니다 ([안내](https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7))

이제 올바른 Python 설치 경로를 지정해야 합니다. [Anaconda](https://www.anaconda.com/products/individual)를 사용한다고 가정하면:

```bash
export CLOUDSDK_PYTHON=~/Anaconda3/python
```

이제 잘 동작하는지 확인해 봅시다:

```bash
$ gcloud version
Google Cloud SDK 367.0.0
bq 2.0.72
core 2021.12.10
gsutil 5.5
```

### Google Cloud SDK 인증

* 이제 영상에서 보여준 대로 서비스 계정을 만들고 키를 생성하세요
* 키를 다운로드해서 적당한 위치에 두세요. 예: `.gc/ny-rides.json`
* `GOOGLE_APPLICATION_CREDENTIALS` 환경 변수가 그 파일을 가리키도록 설정하세요

```bash
export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/ny-rides.json
```

이제 인증합니다:

```bash
gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
```

또는 영상에서 보여준 것처럼 OAuth로 인증할 수도 있습니다:

```bash
gcloud auth application-default login
```

`quota exceeded` 같은 메시지가 나온다면:

> WARNING:
> Cannot find a quota project to add to ADC. You might receive a "quota exceeded" or "API not enabled" error.
> Run `$ gcloud auth application-default set-quota-project` to add a quota project.

다음을 실행하세요:

```bash
PROJECT_NAME="ny-rides-alexey"
gcloud auth application-default set-quota-project ${PROJECT_NAME}
```


### Terraform

* [Terraform 다운로드](https://www.terraform.io/downloads)
* [PATH](https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7)에 포함된 폴더에 두세요
* Terraform 파일이 있는 위치로 이동해서 초기화하세요

```bash
terraform init
```

선택적으로 terraform 파일(`variables.tf`)에 프로젝트 id를 설정할 수 있습니다:

```bash
variable "project" {
  description = "Your GCP Project ID"
  default = "ny-rides-alexey"
  type = string
}
```

* 이제 [안내를 따라 진행하세요](1_terraform_overview.md#실행-단계)
  * `terraform plan` 실행
  * 다음으로 `terraform apply` 실행

다음과 같은 에러가 나온다면:

> Error: googleapi: Error 403: terraform@ny-rides-alexey.iam.gserviceaccount.com does not have
> storage.buckets.create access to the Google Cloud project., forbidden

서비스 계정에 필요한 모든 권한을 부여해야 합니다. 영상의 안내를 잘 따라 했는지 확인하세요.

* [이 파일](https://docs.google.com/document/d/e/2PACX-1vSZapy7gIj0TP-EFzub2OpAlAkuifGEVJ4XpkA1RvxZ45NjiQi29b6OhLuetdXXHWAn2lbbKxnbzMdd/pub)도 참고할 수 있지만, 필요한 모든 권한이 나열되어 있지는 않습니다
