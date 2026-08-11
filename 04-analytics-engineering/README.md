# Module 4: Analytics Engineering

목표: DWH에 적재된 데이터를 [dbt 프로젝트](taxi_rides_ny/README.md)를 만들어가며 분석용 뷰(Analytical View)로 변환하기.

### 사전 준비

어떤 셋업 경로를 고르느냐에 따라 사전 준비가 달라집니다.

**Cloud Setup (BigQuery)의 경우:**

- [Module 3: Data Warehouse](../03-data-warehouse/) 완료. 다음이 갖춰져 있어야 합니다:
  - BigQuery가 활성화된 GCP 프로젝트
  - BigQuery 권한을 가진 service account
  - BigQuery에 적재된 NYC taxi 데이터 (2019~2020년 yellow, green taxi 데이터)

**Local Setup (DuckDB)의 경우:**

- 사전 준비 없음! local setup 가이드가 데이터 다운로드와 적재까지 안내합니다.

> [!NOTE]
> 이 모듈은 **yellow와 green taxi 데이터** (2019~2020)를 다룹니다. Module 3에서 FHV 데이터를 포함했을 수 있지만, 이 dbt 프로젝트에서는 사용하지 않습니다.

## 환경 설정하기

셋업 경로를 선택하세요:

### 🏠 [Local Setup](setup/local_setup.md)

- **스택**: DuckDB + dbt Core
- **비용**: 무료
- [→ 시작하기](setup/local_setup.md)

### ☁️ [Cloud Setup](setup/cloud_setup.md)

- **스택**: BigQuery + dbt Cloud
- **비용**: 무료 티어 사용 가능 (dbt Cloud Developer), BigQuery 비용은 사용량에 따라 다름
- **필요 조건**: BigQuery 데이터가 준비된 Module 3 완료
- [→ 시작하기](setup/cloud_setup.md)

## 콘텐츠

### Analytics Engineering 소개

[![](images/thumbnail-HxMIsPrIyGQ.jpg)](https://www.youtube.com/watch?v=HxMIsPrIyGQ)

### 데이터 모델링 소개

[![](images/thumbnail-uF76d5EmdtU.jpg)](https://www.youtube.com/watch?v=uF76d5EmdtU&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=40)

### dbt란 무엇인가?

[![](images/thumbnail-gsKuETFJr54.jpg)](https://www.youtube.com/watch?v=gsKuETFJr54&list=PLaNLNpjZpzwgneiI-Gl8df8GCsPYp_6Bs&index=5)

### dbt Core와 dbt Cloud의 차이

[![](images/thumbnail-auzcdLRyEIk.jpg)](https://www.youtube.com/watch?v=auzcdLRyEIk)

### 프로젝트 셋업

| 대안 A  | 대안 B   |
|-----------------------------|--------------------------------|
| BigQuery + dbt Platform | DuckDB + dbt core |
| [![](images/thumbnail-GFbwlrt6f54.jpg)](https://www.youtube.com/watch?v=GFbwlrt6f54) | [![](images/thumbnail-GoFAbJYfvlw.jpg)](https://www.youtube.com/watch?v=GoFAbJYfvlw) |

### dbt 강의

| dbt 프로젝트 구조 | dbt sources | dbt models | Seeds와 Macros |
|-----------------------|-------------|------------|------------------|
| [![](images/thumbnail-2dYDS4OQbT0.jpg)](https://www.youtube.com/watch?v=2dYDS4OQbT0) | [![](images/thumbnail-7CrrXazV_8k.jpg)](https://www.youtube.com/watch?v=7CrrXazV_8k) | [![](images/thumbnail-JQYz-8sl1aQ.jpg)](https://www.youtube.com/watch?v=JQYz-8sl1aQ) | [![](images/thumbnail-lT4fmTDEqVk.jpg)](https://www.youtube.com/watch?v=lT4fmTDEqVk) |

| dbt tests | 문서화 | dbt packages | dbt 명령어 |
|-----------|---------------|----------------------|---------------|
| [![](images/thumbnail-bvZ-rJm7uMU.jpg)](https://www.youtube.com/watch?v=bvZ-rJm7uMU) | [![](images/thumbnail-UqoWyMjcqrA.jpg)](https://www.youtube.com/watch?v=UqoWyMjcqrA) | [![](images/thumbnail-KfhUA9Kfp8Y.jpg)](https://www.youtube.com/watch?v=KfhUA9Kfp8Y) | [![](images/thumbnail-t4OeWHW3SsA.jpg)](https://www.youtube.com/watch?v=t4OeWHW3SsA) |

## 문제 해결

- [DuckDB 문제 해결 가이드](setup/duckdb_troubleshooting.md) — DuckDB로 `dbt build` 실행 중 OOM 에러가 난다면

## 추가 자료

> [!NOTE]
> 위 영상들이 버겁게 느껴진다면, [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) 과정을 먼저 수강한 뒤 이 모듈을 다시 보는 것을 권합니다. 이 모듈에 필요한 핵심 개념의 탄탄한 기초를 제공합니다.

## SQL 복습

이 모듈의 숙제는 window function과 CTE를 집중적으로 다룹니다. 이 주제를 복습할 필요가 있다면 아래 노트를 참고하세요.

* [SQL 복습](refreshers/SQL.md)

## 숙제

* [2026 숙제](../cohorts/2026/04-analytics-engineering/homework.md)

# 커뮤니티 노트

<details>
<summary>직접 정리한 노트가 있나요? 여기에 공유할 수 있습니다</summary>

* [Slides used in previous years](https://docs.google.com/presentation/d/1xSll_jv0T8JF4rYZvLHfkJXYqUjPtThA/edit?usp=sharing&ouid=114544032874539580154&rtpof=true&sd=true)
* [Notes by Alvaro Navas](https://github.com/ziritrion/dataeng-zoomcamp/blob/main/notes/4_analytics.md)
* [Sandy's DE learning blog](https://learningdataengineering540969211.wordpress.com/2022/02/17/week-4-setting-up-dbt-cloud-with-bigquery/)
* [Notes by Victor Padilha](https://github.com/padilha/de-zoomcamp/tree/master/week4)
* [Marcos Torregrosa's blog (spanish)](https://www.n4gash.com/2023/data-engineering-zoomcamp-semana-4/)
* [Notes by froukje](https://github.com/froukje/de-zoomcamp/blob/main/week_4_analytics_engineering/notes/notes_week_04.md)
* [Notes by Alain Boisvert](https://github.com/boisalai/de-zoomcamp-2023/blob/main/week4.md)
* [Setting up Prefect with dbt by Vera](https://medium.com/@verazabeida/zoomcamp-week-5-5b6a9d53a3a0)
* [Blog by Xia He-Bleinagel](https://xiahe-bleinagel.com/2023/02/week-4-data-engineering-zoomcamp-notes-analytics-engineering-and-dbt/)
* [Setting up DBT with BigQuery by Tofag](https://medium.com/@fagbuyit/setting-up-your-dbt-cloud-dej-9-d18e5b7c96ba)
* [Blog post by Dewi Oktaviani](https://medium.com/@oktavianidewi/de-zoomcamp-2023-learning-week-4-analytics-engineering-with-dbt-53f781803d3e)
* [Notes from Vincenzo Galante](https://binchentso.notion.site/Data-Talks-Club-Data-Engineering-Zoomcamp-8699af8e7ff94ec49e6f9bdec8eb69fd)
* [Notes from Balaji](https://github.com/Balajirvp/DE-Zoomcamp/blob/main/Week%204/Data%20Engineering%20Zoomcamp%20Week%204.ipynb)
* [Notes by Linda](https://github.com/inner-outer-space/de-zoomcamp-2024/blob/main/4-analytics-engineering/readme.md)
* [2024 - Videos transcript week4](https://drive.google.com/drive/folders/1V2sHWOotPEMQTdMT4IMki1fbMPTn3jOP?usp=drive)
* [Blog Post](https://www.jonahboliver.com/blog/de-zc-w4) by Jonah Oliver
* [2025 Notes by Manuel Guerra](https://github.com/ManuelGuerra1987/data-engineering-zoomcamp-notes/blob/main/4_Analytics-Engineering/README.md)
* [2025 Notes by Horeb SEIDOU](https://spotted-hardhat-eea.notion.site/Week-4-Analytics-Engineering-18929780dc4a808692e4e0ee488bf49c?pvs=74)
* [2025 Notes by Daniel Lachner](https://github.com/mossdet/dlp_data_eng/blob/main/Notes/04_01_Analytics_Engineering.pdf)
* [2026 Notes by Sharad K. Gupta](https://github.com/sharadgupta27/data-engineering/blob/main/Notes/dbt_commands.md)
* [Analytical Engineering overview](https://github.com/khanhnguyen7802/DataEngineer101/tree/main/week4-analytics-engineering#readme) 
* [2026 Notes about dbt](https://github.com/khanhnguyen7802/DataEngineer101/blob/main/week4-analytics-engineering/dbt_installation.md) | [dbt + Duckdb setup using Docker](https://github.com/khanhnguyen7802/DataEngineer101/blob/main/week4-analytics-engineering/dbt_installation.md) by Khanh Nguyen
* 이 줄 위에 여러분의 노트를 추가하세요

</details>
