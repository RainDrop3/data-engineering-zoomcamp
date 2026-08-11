# DE Zoomcamp 4.2.1 — dbt Core vs dbt Cloud

> 📄 공식 기능 비교: [dbt Core vs dbt Cloud](https://www.getdbt.com/product/dbt-core-vs-dbt-cloud)

## dbt Core
- **2016년**에 완전한 **오픈소스 커맨드라인 도구**로 시작
- 100% 무료, 자기 머신에서 로컬로 실행
- 모든 코드가 GitHub에 공개 (fork, 수정 등 가능)

## dbt Cloud
- dbt Core보다 **2년 뒤(~2018)** dbt Labs(당시 이름 Fishtown Analytics)가 출시
- **유료 SaaS 플랫폼**으로 판매 — 인프라를 직접 관리할 필요가 없음
- 무거운 일들을 대신 처리:
  - dbt 문서 호스팅
  - 오케스트레이션
  - 환경 설정
  - dbt 아티팩트 백업 (예: Slim CI용)
- 팀/회사에 유용한 **협업 및 보안 기능** 포함

## 둘을 함께 쓰던 방식 (하이브리드 접근)
- 흔한 패턴: 기술적인 사용자는 dbt Core로, 덜 기술적인 사용자는 dbt Cloud로 작업
- 둘은 **호환되도록** 설계됨 — 예를 들어 개발자는 로컬에서 dbt Core로 작업하고 프로덕션 실행은 dbt Cloud를 통해 수행
- dbt Labs가 **2024년 10월**에 두 제품이 어떻게 나란히 공존하도록 의도되었는지 설명하는 글을 발행 → [How we think about dbt Core and dbt Cloud](https://www.getdbt.com/blog/how-we-think-about-dbt-core-and-dbt-cloud)

## dbt Fusion — 미래
- **2025년 5월**, dbt Labs가 **Fusion**이라는 새 엔진을 사용한 **코드베이스 전면 재작성**을 발표
- 주요 개선점:
  - dbt 코드의 **더 빠른 컴파일** (경우에 따라 최대 30배)
  - **더 나은 개발자 경험** — 실행/빌드 *전에* 많은 에러를 잡아내어 시간과 비용을 절약

- dbt Core는 계속 유지보수되지만, **Fusion이 Core와 Cloud 양쪽의 미래 방향**

### Fusion의 한계
- **모든 adapter를 지원하지는 않음** — 2026년 초 기준 Fusion은 Snowflake, Databricks, Postgres(및 파생), BigQuery, Redshift 같은 주요 adapter를 지원
- 특히 **DuckDB를 (아직) 지원하지 않으며**, 커뮤니티가 유지보수하는 다수의 adapter도 마찬가지
- 덜 일반적인 adapter를 쓴다면 dbt Fusion과 최신 버전의 dbt Cloud가 동작하지 않을 수 있음
- adapter 지원은 활발히 확대되는 중 — 현재 목록은 공식 문서를 확인할 것

> 📄 Fusion 업그레이드 가이드: [Upgrading to the dbt Fusion engine](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-fusion)  
> 📄 전체 adapter 지원 목록: [Supported features](https://docs.getdbt.com/docs/fusion/supported-features)

## 새로운 비전: 통합 라이선스
- 사용자를 Core와 Cloud로 나누는 대신, Fusion은 **모두가 dbt 라이선스를 갖는** 그림을 구상
- 사용자는 다음 중에서 선택해 작업 가능:
  - **dbt Cloud IDE**, 또는
  - dbt Labs 공식 확장을 사용한 **VS Code**
- 두 선택지 모두 동일한 Fusion 엔진이 뒷받침

## 강의의 선택과 권장 사항
- 이 강의는 **DuckDB + dbt Core** (로컬, VS Code 경유)를 사용합니다. 이유는:
  - 학습자가 내부에서 실제로 무슨 일이 일어나는지 이해하게 만들기 때문
  - dbt Cloud는 많은 것을 추상화합니다 — Core를 먼저 이해하면 나중에 Cloud를 익히기가 더 쉬워집니다
- dbt Cloud + BigQuery로 따라가더라도 개념은 잘 전이됩니다
- dbt Cloud 자체를 배우는 데는 dbt Labs의 문서와 강의가 훌륭한 자료입니다 → [dbt Developer Hub](https://docs.getdbt.com)
- **결론:** 어느 쪽을 먼저 배우는지는 크게 중요하지 않습니다 — 특히 컨설턴트라면 둘 다 쓰게 될 가능성이 높습니다. 공통된 기본기에 집중하세요.

---

*참고: 이 문서는 2026년 2월에 마지막으로 갱신되었습니다. dbt Fusion과 adapter 지원에 대한 최신 정보는 항상 공식 dbt 문서를 확인하세요.*
