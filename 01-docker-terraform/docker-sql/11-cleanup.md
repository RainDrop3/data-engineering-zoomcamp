# 정리하기

**[↑ 위로](README.md)** | **[← 이전](10-sql-refresher.md)** | **[다음 →](../README.md)**

워크숍을 마쳤다면 디스크 공간 확보를 위해 Docker 리소스를 정리하세요.

## 실행 중인 모든 컨테이너 중지하기

```bash
docker-compose down
```

## 특정 컨테이너 삭제하기

```bash
# 모든 컨테이너 목록 보기
docker ps -a

# 특정 컨테이너 삭제
docker rm <container_id>

# 중지된 모든 컨테이너 삭제
docker container prune
```

## Docker 이미지 삭제하기

```bash
# 모든 이미지 목록 보기
docker images

# 특정 이미지 삭제
docker rmi taxi_ingest:v001

# 사용하지 않는 모든 이미지 삭제
docker image prune -a
```

## Docker 볼륨 삭제하기

```bash
# 볼륨 목록 보기
docker volume ls

# 특정 볼륨 삭제
docker volume rm ny_taxi_postgres_data
docker volume rm pgadmin_data

# 사용하지 않는 모든 볼륨 삭제
docker volume prune
```

## Docker 네트워크 삭제하기

```bash
# 네트워크 목록 보기
docker network ls

# 특정 네트워크 삭제
docker network rm pg-network

# 사용하지 않는 모든 네트워크 삭제
docker network prune
```

## 전체 정리

모든 Docker 리소스를 삭제합니다 - 주의해서 사용하세요!

```bash
# ⚠️ 경고: 모든 Docker 리소스가 삭제됩니다!
docker system prune -a --volumes
```

## 로컬 파일 정리하기

```bash
# parquet 파일 삭제
rm *.parquet

# Python 캐시 삭제
rm -rf __pycache__ .pytest_cache

# 가상환경 삭제 (venv를 사용하는 경우)
rm -rf .venv
```

---

오늘은 여기까지입니다. 즐거운 학습 되세요! 🐳📊

**[↑ 위로](README.md)** | **[← 이전](10-sql-refresher.md)** | **[다음 →](../README.md)**
