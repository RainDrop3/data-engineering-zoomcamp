# AWS Terraform Data Lake (GCP 대응 버전)

## 📌 개요

이 저장소에는 데이터 엔지니어링 강의에서 사용하는 **Google Cloud Platform (GCP)** 인프라(예: GCS + BigQuery)를 **AWS 서비스**로 동일하게 구현한 **AWS 기반 Terraform 구성**이 담겨 있습니다.

다음과 같은 학습자를 돕는 것이 목표입니다:
- **GCP 중심의 데이터 엔지니어링 강의**를 수강 중인 분
- **AWS**를 선호하거나 사용해야 하는 분
- **클라우드에 종속되지 않는 데이터 엔지니어링 개념**을 이해하고 싶은 분

이 구성은 다음을 사용해 **기본적인 data lake 기반**을 구축하는 데 집중합니다:
- **Amazon S3** (GCS에 해당)
- **AWS Glue Data Catalog** (BigQuery 데이터셋 / 메타데이터 계층에 해당)
- Infrastructure as Code (IaC) 도구로서의 **Terraform**

---

## 🏗️ 아키텍처 매핑 (GCP → AWS)

| GCP 서비스 | AWS 대응 서비스 | 용도 |
|------------|---------------|---------|
| Google Cloud Storage (GCS) | Amazon S3 | Data Lake 저장소 |
| Uniform Bucket Level Access | S3 Public Access Block | 안전한 버킷 접근 |
| Object Lifecycle Rules | S3 Lifecycle Configuration | 데이터 자동 만료 |
| BigQuery Dataset | AWS Glue Catalog Database | 메타데이터 및 쿼리 계층 |
| Terraform (GCP provider) | Terraform (AWS provider) | Infrastructure as Code |

---

## 📁 프로젝트 구조

```text
.
├── main.tf            # 핵심 인프라 리소스
├── variables.tf       # 입력 변수 정의
├── terraform.tfvars   # 환경별 값
└── README.md          # 프로젝트 문서
