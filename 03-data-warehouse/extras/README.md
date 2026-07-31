Airflow 없이 파일을 GCS로 바로 적재하는 간단한 방법입니다. https://nyc-tlc.s3.amazonaws.com/trip+data/ 에서 csv 파일을 다운로드한 뒤, parquet 파일로 변환해 여러분의 Cloud Storage 계정에 업로드합니다.

1. `uv sync`로 사전 요구 패키지를 설치합니다
2. 실행: `uv run python web_to_gcs_with_progress_bar.py`
2. 또는 실행: `uv run python web_to_gcs.py` — 출력이 덜 자세한 버전입니다 (업로드 속도가 빠른 인터넷 환경이라면 이쪽)
