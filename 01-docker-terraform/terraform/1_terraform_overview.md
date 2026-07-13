## Terraform 개요

[영상](https://www.youtube.com/watch?v=18jIzE41fJ4&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=2)

### 개념

#### 소개

1. [Terraform](https://www.terraform.io)이란?
   * [HashiCorp](https://www.hashicorp.com)에서 만든 오픈소스 도구로, 인프라 리소스를 프로비저닝하는 데 사용
   * 변경 관리를 위한 DevOps 모범 사례 지원
   * 설정 파일을 소스 컨트롤로 관리하여 테스트/프로덕션 환경에 대한
     이상적인 프로비저닝 상태를 유지
2. IaC란?
   * Infrastructure-as-Code (코드형 인프라)
   * 버전 관리, 재사용, 공유가 가능한 리소스 설정을 정의함으로써
     안전하고 일관되며 반복 가능한 방식으로 인프라를 구축, 변경, 관리
3. 주요 장점
   * 인프라 생명주기(lifecycle) 관리
   * 버전 관리 커밋
   * 스택 기반 배포와 AWS, GCP, Azure, K8S 같은 클라우드 제공업체와 함께 사용할 때 매우 유용
   * 상태(state) 기반 접근으로 배포 전반에 걸쳐 리소스 변경 사항 추적


#### 파일

* `main.tf`
* `variables.tf`
* 선택: `resources.tf`, `output.tf`
* `.tfstate`

#### 선언(Declarations)
* `terraform`: 인프라 프로비저닝을 위한 기본 Terraform 설정 구성
   * `required_version`: 이 설정에 적용할 최소 Terraform 버전
   * `backend`: 실제 리소스를 설정과 매핑하기 위한 Terraform "상태" 스냅샷 저장소
      * `local`: 상태 파일을 로컬에 `terraform.tfstate`로 저장
   * `required_providers`: 현재 모듈에 필요한 프로바이더 지정
* `provider`:
   * Terraform이 관리할 수 있는 리소스 타입 및/또는 데이터 소스 집합을 추가
   * Terraform Registry는 대부분의 주요 인프라 플랫폼에서 공개적으로 제공하는 프로바이더의 메인 디렉터리입니다.
* `resource`
  * 인프라의 구성 요소를 정의하는 블록
  * 이 프로젝트의 모듈/리소스: google_storage_bucket, google_bigquery_dataset, google_bigquery_table
* `variable` & `locals`
  * 런타임 인자와 상수


#### 실행 단계
1. `terraform init`:
    * 백엔드 초기화 및 설정, 플러그인/프로바이더 설치, 버전 관리에서 기존 설정 체크아웃
2. `terraform plan`:
    * 로컬 변경 사항을 원격 상태와 비교/미리보기하여 실행 계획(Execution Plan)을 제안
3. `terraform apply`:
    * 제안된 계획에 대한 승인을 요청하고, 클라우드에 변경 사항을 적용
4. `terraform destroy`
    * 클라우드에서 스택을 제거


### GCP 인프라 생성을 위한 Terraform 워크숍
[여기](./terraform)에서 계속하세요: `week_1_basics_n_setup/1_terraform_gcp/terraform`


### 참고 자료
https://learn.hashicorp.com/collections/terraform/gcp-get-started
