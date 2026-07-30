## Module 2 숙제

주의: 제출 폼 마지막에 여러분의 GitHub 저장소 또는 다른 공개 코드 호스팅 사이트의 링크를 포함해야 합니다. 이 저장소에는 숙제를 푸는 코드가 들어있어야 합니다. 풀이에 파일 형태가 아닌 코드가 포함되어 있다면, 저장소의 README 파일에 직접 포함시켜 주세요.

> 선택지 중 정확히 일치하는 것이 없다면 가장 가까운 것을 고르세요.

이번 숙제에서는 여기에 있는 _green_ taxi 데이터셋을 사용합니다:

`https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green/download`

`wget`으로 받을 수 있는 링크를 얻으려면 다음 접두사를 사용하세요 (이 링크 자체는 404가 납니다):

`https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/`

### 과제

지금까지 강의에서는 2019년과 2020년 데이터를 처리했습니다. 여러분의 과제는 기존 flow를 확장해서 2021년 데이터까지 포함시키는 것입니다.

![homework datasets](../../../02-workflow-orchestration/images/homework.png)

힌트를 주자면, Kestra를 쓰면 이 과정이 정말 간단합니다:
1. [스케줄된 flow](../../../02-workflow-orchestration/flows/09_gcp_taxi_scheduled.yaml)의 backfill 기능을 활용해 2021년 데이터를 backfill할 수 있습니다. 데이터가 존재하는 기간, 즉 `2021-01-01`부터 `2021-07-31`까지를 선택하도록 주의하세요. 또한 `yellow`와 `green` taxi 데이터 모두에 대해 동일하게 진행해야 합니다(`taxi` input에서 올바른 서비스를 선택하세요).
2. 또는 2021년 7개월 각각에 대해 `yellow`와 `green` taxi 데이터를 수동으로 실행해도 됩니다. 도전 과제: `ForEach` task를 사용해 연-월과 `taxi` 타입의 조합을 순회하면서, `Subflow` task로 각 조합마다 flow를 실행하는 방법을 찾아보세요.

### 퀴즈 문제

아래 퀴즈를 완료하세요. workflow orchestration, Kestra, ETL 파이프라인에 대한 이해를 확인하는 6개의 객관식 문제입니다.

1) `2020`년 `12`월 `Yellow` Taxi 데이터에 대한 실행에서, 압축이 풀린 파일 크기(즉 `extract` task의 출력 파일 `yellow_tripdata_2020-12.csv`)는 얼마인가요?
- 128.3 MiB
- 134.5 MiB
- 364.7 MiB
- 692.6 MiB

2) 실행 중에 input `taxi`가 `green`, `year`가 `2020`, `month`가 `04`로 설정되었을 때, 변수 `file`이 렌더링된 값은 무엇인가요?
- `{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv` 
- `green_tripdata_2020-04.csv`
- `green_tripdata_04_2020.csv`
- `green_tripdata_2020.csv`

3) 2020년의 모든 CSV 파일에 대해 `Yellow` Taxi 데이터의 행은 몇 개인가요?
- 13,537.299
- 24,648,499
- 18,324,219
- 29,430,127

4) 2020년의 모든 CSV 파일에 대해 `Green` Taxi 데이터의 행은 몇 개인가요?
- 5,327,301
- 936,199
- 1,734,051
- 1,342,034

5) 2021년 3월 CSV 파일의 `Yellow` Taxi 데이터 행은 몇 개인가요?
- 1,428,092
- 706,911
- 1,925,152
- 2,561,031

6) Schedule trigger에서 타임존을 뉴욕으로 설정하려면 어떻게 해야 하나요?
- `Schedule` trigger 설정에 `timezone` 속성을 `EST`로 추가한다
- `Schedule` trigger 설정에 `timezone` 속성을 `America/New_York`로 추가한다
- `Schedule` trigger 설정에 `timezone` 속성을 `UTC-5`로 추가한다
- `Schedule` trigger 설정에 `location` 속성을 `New_York`로 추가한다

## 풀이 제출하기

* 제출 폼: https://courses.datatalks.club/de-zoomcamp-2026/homework/hw2
* 마감일은 위 링크에서 확인하세요

## 풀이

마감일 이후에 추가될 예정입니다


## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

### LinkedIn 게시물 예시

```
🚀 Week 2 of Data Engineering Zoomcamp by @DataTalksClub and @Will Russell complete!

Just finished Module 2 - Workflow Orchestration with @Kestra. Learned how to:

✅ Orchestrate data pipelines with Kestra flows
✅ Use variables and expressions for dynamic workflows
✅ Implement backfill for historical data
✅ Schedule workflows with timezone support
✅ Process NYC taxi data (Yellow & Green) for 2019-2021

Built ETL pipelines that extract, transform, and load taxi trip data automatically!

Thanks to the @Kestra team for the great orchestration tool!

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시

```
Module 2 of DE Zoomcamp by @DataTalksClub @wrussell1999 done!

- @kestra_io workflow orchestration
- ETL pipelines for taxi data
- Backfill & scheduling
- Variables & dynamic flows

My solution: <LINK>

Join me here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
