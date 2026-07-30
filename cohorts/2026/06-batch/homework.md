# Module 6 숙제

이번 숙제에서는 Spark에 대해 배운 것을 실제로 적용해 봅니다.

이번 숙제에서는 공식 웹사이트의 Yellow 2025-11 데이터를 사용합니다:

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-11.parquet
```


## 질문 1: Spark와 PySpark 설치하기

- Spark 설치하기
- PySpark 실행하기
- 로컬 spark 세션 생성하기
- spark.version 실행하기

출력 결과는 무엇인가요?

> [!NOTE]
> PySpark 설치는 이 [가이드](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/06-batch/setup/)를 따르세요


## 질문 2: 2025년 11월 Yellow 데이터

2025년 11월 Yellow 데이터를 Spark Dataframe으로 읽어들이세요.

Dataframe을 4개의 partition으로 repartition한 뒤 parquet으로 저장하세요.

생성된 Parquet 파일(.parquet 확장자로 끝나는 파일)의 평균 크기는 몇 MB인가요? 가장 가까운 답을 고르세요.

- 6MB
- 25MB
- 75MB
- 100MB


## 질문 3: 레코드 개수 세기

11월 15일에 있었던 taxi 운행은 몇 건인가요?

11월 15일에 시작된 운행만 고려하세요.

- 62,610
- 102,340
- 162,604
- 225,768


## 질문 4: 가장 긴 운행

이 데이터셋에서 가장 긴 운행의 소요 시간은 몇 시간인가요?

- 22.7
- 58.2
- 90.6
- 134.5


## 질문 5: User Interface

애플리케이션 대시보드를 보여주는 Spark의 User Interface는 로컬의 어떤 포트에서 실행되나요?

- 80
- 443
- 4040
- 8080



## 질문 6: 가장 빈도가 낮은 승차 위치 zone

zone lookup 데이터를 Spark의 temp view로 불러오세요:

```bash
wget https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv
```

zone lookup 데이터와 2025년 11월 Yellow 데이터를 사용할 때, 빈도가 가장 낮은 승차 위치 Zone의 이름은 무엇인가요?

- Governor's Island/Ellis Island/Liberty Island
- Arden Heights
- Rikers Island
- Jamaica Bay

정답이 여러 개라면 아무거나 선택하세요.

## 풀이 제출하기

- 제출 폼: https://courses.datatalks.club/de-zoomcamp-2026/homework/hw6
- 마감일: 웹사이트를 참고하세요


## 공개적으로 학습하기 (Learning in Public)

배운 것을 공유하는 것을 권장합니다. 이를 "learning in public"이라고 합니다.

이점에 대해서는 [여기](https://alexeyondata.substack.com/p/benefits-of-learning-in-public-and)에서 더 읽어보세요.

### LinkedIn 게시물 예시

```
🚀 Week 6 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 6 - Batch Processing with Spark. Learned how to:

✅ Set up PySpark and create Spark sessions
✅ Read and process Parquet files at scale
✅ Repartition data for optimal performance
✅ Analyze millions of taxi trips with DataFrames
✅ Use Spark UI for monitoring jobs

Processing 4M+ taxi trips with Spark - distributed computing is powerful! 💪

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### Twitter/X 게시물 예시

```
⚡ Module 6 of Data Engineering Zoomcamp done!

- Batch processing with Spark 🔥
- PySpark & DataFrames
- Parquet file optimization
- Spark UI on port 4040

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```
