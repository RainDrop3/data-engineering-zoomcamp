## KSQL DB 예제
### stream 생성
```sql
CREATE STREAM ride_streams (
    VendorId varchar, 
    trip_distance double,
    payment_type varchar
)  WITH (KAFKA_TOPIC='rides',
        VALUE_FORMAT='JSON');
```

### stream 조회
```sql
select * from RIDE_STREAMS 
EMIT CHANGES;
```

### stream count 조회
```sql
SELECT VENDORID, count(*) FROM RIDE_STREAMS 
GROUP BY VENDORID
EMIT CHANGES;
```

### 필터를 사용한 stream 조회
```sql
SELECT payment_type, count(*) FROM RIDE_STREAMS 
WHERE payment_type IN ('1', '2')
GROUP BY payment_type
EMIT CHANGES;
```

### window 함수를 사용한 stream 조회
```sql
CREATE TABLE payment_type_sessions AS
  SELECT payment_type,
         count(*)
  FROM  RIDE_STREAMS 
  WINDOW SESSION (60 SECONDS)
  GROUP BY payment_type
  EMIT CHANGES;
```

## 자세한 내용은 KSQL 문서 참고
[KSQL DB Documentation](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/quick-reference/)

[KSQL DB Java client](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-clients/java-client/)