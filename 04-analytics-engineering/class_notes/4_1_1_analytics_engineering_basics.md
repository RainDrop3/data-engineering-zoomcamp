# DE Zoomcamp 4.1.1 — Analytics Engineering 기초

> 📄 영상: [Analytics Engineering Basics](https://www.youtube.com/watch?v=uF76d5EmdtU)  
> 📄 더 읽어보기: [What is Analytics Engineering?](https://docs.getdbt.com/docs/introduction)  
> 📄 Kimball의 Dimensional Modeling: *The Data Warehouse Toolkit* (Ralph Kimball & Margy Ross)

Module 4의 시작 영상입니다. 직접 코딩하는 부분은 없고, 판을 까는 내용입니다. analytics engineering이 왜 생겨났는지, 실제로 무슨 일을 하는지, 그리고 이 모듈 내내 기대게 될 데이터 모델링 개념은 무엇인지를 다룹니다. dbt로 뛰어들기 전에 한번 곱씹어볼 만합니다.

---

## Analytics engineering이 존재하는 이유

데이터 업계의 몇 가지 변화가 아무도 채우지 않던 공백을 만들어냈습니다:

- **클라우드 데이터 웨어하우스** (BigQuery, Snowflake, Redshift)가 스토리지와 컴퓨트를 싸게 만들었습니다. 무엇을 적재할지 더 이상 외과수술하듯 고를 필요가 없어졌습니다.
- Fivetran, Stitch 같은 **EL 도구**가 데이터를 웨어하우스에 넣는 일을 거의 사소한 일로 만들었습니다 — extract와 load 단계는 이제 사실상 자동화되었습니다.
- Looker 같은 **SQL 우선 BI 도구**가 데이터 워크플로에 버전 관리를 들여왔습니다. 그리고 Mode 같은 도구는 비즈니스 사용자를 위한 셀프서비스 분석을 가능하게 했습니다.
- 데이터를 만지는 사람이 늘어나면서 **데이터 거버넌스**가 더 큰 화두가 되었습니다.

이 모든 변화가 데이터 팀의 일하는 방식과 이해관계자가 데이터를 소비하는 방식을 바꿨습니다. 하지만 인프라를 만드는 사람과 데이터를 쓰는 사람 사이에 공백을 남겼습니다.

### 전통적인 데이터 팀

예전 모델에서는 세 가지 역할이 꽤 깔끔하게 나뉘어 있었습니다:

- **Data Engineer** — 인프라를 구축하고 유지합니다. 훌륭한 소프트웨어 엔지니어이지만, 비즈니스가 실제로 데이터를 어떻게 쓰는지에는 반드시 가깝지는 않습니다.
- **Data Analyst** — 데이터로 질문에 답하고 비즈니스 문제를 풉니다. 비즈니스를 잘 이해하지만 소프트웨어 엔지니어로 훈련받지는 않았습니다.
- **Data Scientist** — analyst와 비슷한 이야기입니다. 요즘 점점 더 많은 코드를 쓰지만, 소프트웨어 엔지니어링 모범 사례는 훈련 과정에 없었습니다.

### 공백

analyst와 scientist는 점점 더 많은 코드를 쓰지만 그 훈련을 받지 않았습니다. engineer는 시스템 구축에는 뛰어나지만, 데이터가 하류에서 어떻게 소비되는지는 늘 알지는 못합니다. 그 공백을 잇는 사람이 아무도 없었습니다.

### Analytics Engineer

analytics engineer가 그 다리입니다. 버전 관리, 테스트, 문서화, 모듈화 같은 소프트웨어 엔지니어링 모범 사례를, analyst와 scientist가 이미 하고 있는 일에 들여옵니다. data engineer와 data analyst의 교차점에 앉아 있는 역할입니다.

도구 체인 측면에서 analytics engineer가 만질 만한 것들:

- **데이터 적재(Data loading)** — Fivetran, Stitch 같은 도구 (EL 계층)
- **데이터 저장(Data storing)** — 클라우드 데이터 웨어하우스. data engineer와 공유하는 영역입니다.
- **데이터 모델링(Data modeling)** — 이것이 핵심입니다. dbt나 Dataform 같은 도구. Module 4의 대부분이 여기에 있습니다.
- **데이터 표현(Data presentation)** — Google Looker Studio 같은 BI 도구. 비즈니스 사용자가 실제로 보는 최종 결과물입니다.

이번 주의 초점은 모델링과 표현입니다 — "데이터가 웨어하우스에 있다"와 "비즈니스 사용자가 대시보드를 본다" 사이의 모든 것.

---

## ETL vs ELT — 빠른 복습

데이터를 변환해 준비시키는 두 가지 철학:

**ETL (Extract → Transform → Load)** — 데이터가 웨어하우스에 닿기 *전에* 변환합니다. 변환 로직을 먼저 만들어야 해서 셋업이 더 오래 걸리지만, 웨어하우스 안의 데이터는 첫날부터 깨끗하고 안정적입니다.

**ELT (Extract → Load → Transform)** — raw 데이터를 먼저 적재하고, 웨어하우스 *안에서* 변환합니다. 더 빠르고 유연합니다. 클라우드 웨어하우스가 가능하게 만든 접근법입니다 — 스토리지가 싸니 일단 다 적재하고 변환은 나중에 생각하는 것이죠.

이제는 ELT가 지배적인 접근법이고, 우리가 다룰 방식이기도 합니다. dbt는 ELT의 "T"에 정확히 들어맞습니다 — SQL을 써서 웨어하우스 안에서 변환을 실행합니다.

---

## Dimensional Modeling — 핵심 개념

Kimball의 프레임워크이고, 이번 주에 데이터를 어떻게 구조화할지에 대한 주된 멘탈 모델입니다. 목표는 두 가지입니다: 데이터를 **비즈니스 사용자가 이해할 수 있게** 만들고, **쿼리를 빠르게** 만드는 것.

참고: 제3정규형(3NF)과 달리 dimensional modeling은 의도적으로 어느 정도의 데이터 중복을 허용합니다. 우선순위는 중복 제거가 아니라 사용성과 성능입니다.

### Fact table vs Dimension table (Star Schema)

두 가지 구성 요소:

- **Fact table** — 측정값, 지표, 비즈니스 이벤트. **동사**라고 생각하세요. "판매가 일어났다." "주문이 접수되었다." 비즈니스 프로세스에 대응합니다.
- **Dimension table** — 그 fact를 둘러싼 맥락. **명사**라고 생각하세요. "누가 샀는가? 어떤 제품을? 언제?" 고객이나 제품 같은 비즈니스 엔티티에 대응합니다.

이 둘이 함께 **star schema**를 이룹니다 — fact table이 중앙에 있고 dimension table들이 그 주위로 뻗어 나가는 형태입니다. 대부분의 데이터 웨어하우스에서 보게 될 고전적인 배치입니다.

### 주방 비유 (The Kitchen Analogy)

Kimball의 책은 데이터가 웨어하우스를 어떻게 흘러가는지 설명하는 데 레스토랑 비유를 씁니다. 우리가 프로젝트에서 할 일과 꽤 깔끔하게 맞아떨어집니다:

- **Staging area (식료품 저장고)** — raw 데이터가 여기에 도착합니다. 비즈니스 사용자를 위한 곳이 아닙니다. 뭘 하는지 아는 사람만 들여다봐야 합니다.
- **Processing area (주방)** — raw 데이터가 제대로 된 데이터 모델로 변환되는 곳입니다. 역시 요리하는 사람들 — data engineer와 analytics engineer — 에게 한정됩니다. 여기서의 초점은 효율성과 표준 준수입니다.
- **Presentation area (식당 홀)** — 최종적으로 다듬어진 결과물. 비즈니스 이해관계자가 실제로 보고 상호작용하는 것입니다. 깨끗하고, 구조화되어 있고, 바로 소비할 수 있습니다.

이 모듈 내내 dbt 프로젝트에서 정확히 이 계층 구조를 만들게 됩니다.
