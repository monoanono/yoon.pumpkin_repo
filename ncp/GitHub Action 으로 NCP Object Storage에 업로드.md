# GitHub Action 으로 NCP Object Storage에 업로드
================================


## 1. 목적

- NCP 서비스 배포를 위한 **CI/CD 파이프라인** 구성
- NCP Auto Scaling Group 기반 환경, **Kubernetes / 컨테이너 환경이 아님**
- NCP Container Registry 대신 **Object Storage**에 빌드 결과물 저장
- NCP Auto Scaling Group 배포 자동화를 위해 **Source Deploy 필수 사용**
- Source Deploy 빌드 참조 대상은 **Object Storage / Source Build만 가능**

---

## 2. 전체 구성 개요

### NCP 측 설정

- GitHub Actions WorkFlow Bot 용 **Sub Account** 생성 및 API 키 발급
- Sub Account에 **Object Storage 업로드 최소 권한만** 가지는 사용자 정의 정책 부여
- Sub Account 콘솔 로그인은 **사무실 공인 IP만 허용**

### GitHub / GitHub Actions

- GitHub 에서 소스코드 관리
- GitHub Actions에서 .NET 기반 빌드 수행
- 빌드 결과물을 **NCP Object Storage**에 업로드
- GitHub Secrets 에 저장된 **NCP Sub Account API Access Key / Secret Key**를 사용하여 업로드

---

## 3. NCP 설정 상세

### 3.1 Sub Account 생성

- Sub Account 이름: `s3_bot`
- 용도: GitHub Actions 워크플로에서 Object Storage 업로드 전용 Bot 계정
<img width="1917" height="908" alt="Image" src="https://github.com/user-attachments/assets/81098de4-5d2c-4a23-a8eb-699ebb9b8e87" />

### 3.2 사용자 정의 정책 (최소 권한)

다음 API 권한만 허용하는 사용자 정의 정책을 생성하여 `s3_bot` 에 부여한다.
<img width="1896" height="528" alt="Image" src="https://github.com/user-attachments/assets/caa0d252-b4ab-41a5-8594-cc1e9e1b5c96" />
<img width="1916" height="910" alt="Image" src="https://github.com/user-attachments/assets/797b888a-0ee8-4c4e-8b1e-827f4acee3e4" />

- `getBucketList` : 버킷 리스트 조회
- `getObjectList` : 오브젝트 리스트 조회
- `writeObject` : 오브젝트 업로드 및 삭제

추가 설정:

- **리소스 지정**을 통해 접근 가능한 버킷을 제한 (예: `test-githubaction` 등 필요한 버킷만)
- 콘솔 로그인은 사무실 공인 IP 대역만 허용하도록 접근 제어 설정
<img width="498" height="304" alt="Image" src="https://github.com/user-attachments/assets/f0a7f896-e9ce-4a41-bbe2-2d95072cae8a" />

---

## 4. GitHub 설정

### 4.1 Repository 설정

<img width="1905" height="507" alt="Image" src="https://github.com/user-attachments/assets/3428e0da-3ea5-4154-b36d-85dca600f36c" />

- 소스 코드 관리용 GitHub Repository 사용
- `TestAPI` 프로젝트 및 `systemd` 서비스 파일 디렉터리 포함

### 4.2 Secrets 설정

<img width="1904" height="909" alt="Image" src="https://github.com/user-attachments/assets/d27ff510-fbd2-4db3-bdb0-da05c78acd0b" />

Repository 메뉴 경로:

> `Settings` → `Secrets and variables` → `Actions` → `Repository secrets`

아래 항목 등록:

- `NCLOUD_ACCESS_KEY` : NCP Sub Account(API 계정) Access Key
- `NCLOUD_SECRET_KEY` : NCP Sub Account(API 계정) Secret Key

GitHub Actions 워크플로에서 위 Secret을 참조해 NCP Object Storage로 업로드를 수행한다.

---

## 5. GitHub Actions 워크플로

### 5.1 WeatherForecast_workflow.yml (최신 버전)

경로: `.github/workflows/WeatherForecast_workflow.yml`

```yaml
name: WeatherForecast-publish

on:
  push:
    branches: [ "master" ]
    paths:
      - 'TestAPI/**'
      - 'systemd/**'
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    env:
      NCP_OBJECT_ENDPOINT: https://kr.object.ncloudstorage.com
      NCP_BUCKET_NAME: [NCP Object Storage 버킷 이름]

      AWS_DEFAULT_REGION: us-east-1
      AWS_REGION: us-east-1
      AWS_EC2_METADATA_DISABLED: "true"

      AWS_REQUEST_CHECKSUM_CALCULATION: when_required
      AWS_RESPONSE_CHECKSUM_VALIDATION: when_required

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install .NET Core
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: Set artifact name (KST)
        run: |
          echo "ARTIFACT_NAME=WeatherForecast_$(TZ=Asia/Seoul date +%Y%m%d_%H%M).zip" >> $GITHUB_ENV
          echo "Artifact: $ARTIFACT_NAME"

      - name: Restore
        run: dotnet restore TestAPI/TestAPI.csproj

      - name: Build
        run: dotnet build TestAPI/TestAPI.csproj --configuration Release --no-restore

      - name: Publish
        run: dotnet publish TestAPI/TestAPI.csproj -c Release -o ./publish

      - name: Include systemd service file
        run: |
          install -D -m 0644 systemd/api.service publish/systemd/api.service

      - name: Create zip
        run: |
          cd publish
          zip -r "../${ARTIFACT_NAME}" .

      - name: Show AWS CLI version
        run: aws --version

      - name: Upload zip to NCP Object Storage
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.NCLOUD_ACCESS_KEY }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.NCLOUD_SECRET_KEY }}
        run: |
          aws --endpoint-url="${NCP_OBJECT_ENDPOINT}" \
            s3 cp "${ARTIFACT_NAME}" "s3://${NCP_BUCKET_NAME}/${ARTIFACT_NAME}"
```
<img width="1903" height="914" alt="Image" src="https://github.com/user-attachments/assets/62ebd77d-e3c1-481d-9e4f-9404ad62da81" />

<img width="1902" height="905" alt="Image" src="https://github.com/user-attachments/assets/c763688a-1395-4cb8-bcf0-6f469ae1a9a3" />

<img width="1915" height="901" alt="Image" src="https://github.com/user-attachments/assets/03cd8867-ead8-4901-8182-5d052bbae4b6" />

<img width="1919" height="910" alt="Image" src="https://github.com/user-attachments/assets/ae0706ff-fc7b-45bc-909a-a533e35b7292" />

<img width="1919" height="912" alt="Image" src="https://github.com/user-attachments/assets/95c49012-95a1-4234-b485-f4bf83533251" />

---

## 7. 빌드 및 업로드 동작

- GitHub UI에서 Run workflow로 담당자가 수동 트리거 가능
<img width="1905" height="910" alt="Image" src="https://github.com/user-attachments/assets/6d9e019c-9c8f-4f77-a75b-add91a83c027" />

- 각 Step 별 로그를 통해 빌드/업로드 과정 및 에러를 상세 확인 가능
<img width="1907" height="494" alt="Image" src="https://github.com/user-attachments/assets/b1bc03aa-e502-4ed0-ba5d-af0d1412821e" />
<img width="1910" height="904" alt="Image" src="https://github.com/user-attachments/assets/0dd84574-9c3c-4242-bb69-ea1d0b6010cb" />
<img width="1917" height="903" alt="Image" src="https://github.com/user-attachments/assets/f26e99ac-7e5f-47a3-bc4a-0613a63a5705" />

- 빌드 결과:
  - 이름: 서비스명_날짜_시간.zip 형식 (예: WeatherForecast_20260219_0947.zip)
  - 내용: TestAPI Publish 결과물 + systemd/api.service 파일 포함

- 업로드 완료 후 NCP Object Storage 콘솔에서 신규 파일 생성 및 정상 업로드 여부 확인 가능
<img width="1916" height="910" alt="Image" src="https://github.com/user-attachments/assets/1b6f2b8f-a017-43c7-ad14-2895714b79f3" />

---

## 8. AWS CLI – NCP Object Storage 호환 이슈

### 8.1 문제 원인
 - 최신 AWS CLI 에서 S3 요청 시 체크섬 관련 헤더를 기본적으로 포함
 - NCP Object Storage 가 아직 일부 체크섬 기능을 지원하지 않아 업로드 실패 (403 등) 발생

### 8.2 해결 방안
 - GitHub Actions 워크플로 env 에 아래 옵션 추가
  ```
  env:
  AWS_REQUEST_CHECKSUM_CALCULATION: when_required
  AWS_RESPONSE_CHECKSUM_VALIDATION: when_required

  ```
<img width="1138" height="733" alt="Image" src="https://github.com/user-attachments/assets/22abd753-8eea-4d30-95af-4d767e850299" />