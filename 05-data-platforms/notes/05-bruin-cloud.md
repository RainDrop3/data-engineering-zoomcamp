# 5.5 - Bruin Cloud에 배포하기

## Bruin Cloud란?

Bruin Cloud는 데이터 pipeline을 위한 완전 관리형 인프라입니다. 로컬 개발에 쓰는 것과 같은 오픈소스 CLI 도구로 동작합니다. 모든 것이 한곳에 있습니다:

- 수집과 변환
- 품질 체크와 모니터링
- lineage와 메타데이터
- 데이터 거버넌스
- AI 기반 기능 (메타데이터 자동 생성, 대화형 데이터 분석)

## 가입

1. [Bruin Cloud](https://getbruin.com/)에 가서 가입
2. 이름, 이메일을 입력하고 비밀번호 설정
3. 인증 메일의 링크를 눌러 이메일 인증
4. 기존 팀에 합류할지 새 organization을 만들지 선택
5. organization 이름 정하기

## GitHub 저장소 연결하기

두 가지 방법이 있습니다:

1. **GitHub 직접 연결** (권장) — GitHub 계정을 직접 연결하고 드롭다운에서 저장소 선택
2. **Personal Access Token** — GitHub personal access token과 저장소 링크를 직접 입력

## Connection 설정하기

저장소를 연결한 다음에는 데이터 웨어하우스 connection을 설정합니다. 로컬의 `.bruin.yml`에서 설정하는 것과 같은 connection이지만, 클라우드에 안전하게 저장됩니다.

1. connections 페이지로 이동
2. connection 유형 선택 (MotherDuck, BigQuery, Redshift 등)
3. 로컬에서 쓰는 것과 같은 connection 이름 지정
4. 필요한 자격 증명 입력 (예: service token, 데이터베이스 이름)
5. connection이 자동으로 검증되고 테스트됨

secret이 어떻게 안전하게 저장되는지는 Bruin 문서를 참고하세요.

## Pipeline 배포하기

1. **Pipelines** 페이지로 가서 저장소의 pipeline 목록 확인
2. Bruin이 모든 asset을 검증하고 lineage와 connection이 동작하는지 확인 (잠시 걸림)
3. 준비되면 pipeline을 **enable**

스케줄이 있는 pipeline을 enable하면 Bruin이 직전 interval에 대한 run을 자동으로 만듭니다. 예를 들어 monthly pipeline은 지난달 데이터를 바로 처리합니다.

## 모니터링

pipeline이 실행된 뒤:

- 각 asset의 상태 확인 (성공/실패)
- 품질 체크 결과 검토
- 모든 asset에 걸친 lineage 보기
- AI 기반 기능으로 데이터를 분석하거나 pipeline에 대해 질문

## 도움 받기

- 질문이나 기능 요청은 [Bruin Slack 커뮤니티](https://getbruin.com/)에 참여하세요
- 이슈는 [GitHub](https://github.com/bruin-data/bruin)에 제출하세요
