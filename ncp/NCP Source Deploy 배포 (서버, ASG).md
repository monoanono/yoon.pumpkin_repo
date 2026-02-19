# NCP Source Deploy 배포 (서버, ASG)
================================


## 1. 목적

- NCP 서비스 배포를 위한 **CI/CD 파이프라인** 구성
- NCP Auto Scaling Group 기반 환경, **Kubernetes / 컨테이너 환경이 아님**
- NCP Container Registry 대신 **Object Storage**에 빌드 결과물 저장
- NCP Auto Scaling Group 배포 자동화를 위해 **Source Deploy 필수 사용**
- Source Deploy 빌드 참조 대상은 **Object Storage / Source Build만 가능**

---

## 2. 전체 구성 개요
- Github → Github Action → NCP Object Storage → NCP SourceDeploy → NCP Server(ASG)

### NCP 측 설정
- GitHub Actions WorkFlow Bot 용 **Sub Account** 생성 및 API 키 발급
- Sub Account에 **Object Storage 업로드 최소 권한만** 가지는 사용자 정의 정책 부여
- NCP SourceDeploy 배포 시나리오 구성
- NCP SourceDeploy 배포 Agent 설치용 Init Script 구성
<img width="1917" height="911" alt="Image" src="https://github.com/user-attachments/assets/83f383e6-13f2-4342-914a-93092d86cc25" />
<img width="1914" height="912" alt="Image" src="https://github.com/user-attachments/assets/b08ec533-11a4-4c3d-80e1-366059307294" />
  ```
  #!/bin/bash
  echo $'NCP_ACCESS_KEY=서브 어카운트 엑세스 키\nNCP_SECRET_KEY=서브 어카운트 시크릿 키' > /opt/NCP_AUTH_KEY
  chmod 400 /opt/NCP_AUTH_KEY
  wget --header="에이전트 사용리전 헤더 정보" "Agent 다운로드 주소"
  chmod 755 install
  ./install
  rm -rf install

  ```


### GitHub / GitHub Actions
- GitHub 에서 소스코드 관리
- GitHub Actions에서 .NET 기반 빌드 수행
- 빌드 결과물을 **NCP Object Storage**에 업로드
<img width="1912" height="909" alt="Image" src="https://github.com/user-attachments/assets/b022ac3e-66d4-4460-897a-241a6d7bec87" />

- GitHub Secrets 에 저장된 **NCP Sub Account API Access Key / Secret Key**를 사용하여 업로드

---

## 3. NCP 설정 상세

### 3.1 Sub Account 생성

- Sub Account 이름: `s3_bot`
- 용도: GitHub Actions 워크플로에서 Object Storage 업로드, SourceDeploy  실행 권한 전용 Bot 계정


### 3.2 사용자 정의 정책 (최소 권한)

다음 API 권한만 허용하는 사용자 정의 정책을 생성하여 `s3_bot` 에 부여한다.
<img width="1915" height="807" alt="Image" src="https://github.com/user-attachments/assets/49a3c8ea-312c-4d96-94a6-c0478d9d7857" />

- `doDeploy` : 프로젝트의 배포 시나리오 실행 권한
- `requestDeploy` : 프로젝트 배포 시나리오 실행 요청 권한

<img width="1913" height="915" alt="Image" src="https://github.com/user-attachments/assets/12740f4a-9dcb-4d64-b811-914fcc547431" />
<img width="1916" height="910" alt="Image" src="https://github.com/user-attachments/assets/2428e4d9-8cfb-49fb-9b2d-a3ef111c2185" />

---

## 4. 서비스 배포

### 4.1 단일 서버 배포
- NCP SourceDeploy 배포 Agent 설치 필요

<img width="1917" height="909" alt="Image" src="https://github.com/user-attachments/assets/3bf7d60f-6441-403f-bbd6-356c08880fa0" />
<img width="1915" height="909" alt="Image" src="https://github.com/user-attachments/assets/696b3886-6883-49a1-be4b-e73691a3876c" />
<img width="1915" height="906" alt="Image" src="https://github.com/user-attachments/assets/e13751c2-926c-421a-adea-f43f9c21c8aa" />
<img width="1919" height="908" alt="Image" src="https://github.com/user-attachments/assets/47bc9e59-736c-4169-82de-c2a00da0b267" />
<img width="1916" height="908" alt="Image" src="https://github.com/user-attachments/assets/64d5c333-76a9-4dc0-8901-1fce3a5c2b73" />
<img width="1917" height="907" alt="Image" src="https://github.com/user-attachments/assets/68564dfb-7768-4d8f-b7bd-171b1f917b35" />
<img width="1917" height="908" alt="Image" src="https://github.com/user-attachments/assets/2656222a-31e4-4824-b65d-3170f2b709f9" />
<img width="1916" height="910" alt="Image" src="https://github.com/user-attachments/assets/fbb136f2-1a54-4caa-b249-32b4147d5f96" />



### 4.2 Auto Scaling Group 배포
- NCP SourceDeploy 배포 Agent 설치용 Init Script 구성 필요

<img width="1918" height="909" alt="Image" src="https://github.com/user-attachments/assets/c5ffa613-29e5-4eca-875c-f02e2c74d064" />
<img width="1911" height="908" alt="Image" src="https://github.com/user-attachments/assets/62365316-2fd4-4dc9-bb82-66da8cf2fee2" />
<img width="1904" height="910" alt="Image" src="https://github.com/user-attachments/assets/7364e3a6-09ed-4a1b-bcd9-2bf9093899ef" />
<img width="1910" height="910" alt="Image" src="https://github.com/user-attachments/assets/682a3180-232f-4aac-879c-caa3b1dac906" />
<img width="1917" height="913" alt="Image" src="https://github.com/user-attachments/assets/ef9762cf-5217-473a-96f6-bcd57b0f3bcd" />
<img width="1918" height="906" alt="Image" src="https://github.com/user-attachments/assets/f7967998-fe45-4e79-8bf2-c171a1e9b620" />
<img width="1919" height="913" alt="Image" src="https://github.com/user-attachments/assets/2881b228-ca61-4e2c-831a-e6e81d82a2de" />
- 배포 과정간 오류 사항 로그 확인 가능
  --> 해당 오류는 ASG 타겟 그룹 변경으로 신규 ASG 생성 하여 배포 대상 ASG 변경 되어 오류 발생

<img width="1917" height="906" alt="Image" src="https://github.com/user-attachments/assets/32a3fb78-606e-411d-97bd-72a7577165b4" />
- 정상 배포 시 < HTTP/1.1 200 OK 내용 확인 가능
---

## 5. ASP .NET 8.0 API 빌드 배포 테스트 설정 정리

### 5.1 단일 서버 배포 관련 설정 사항
  - OS : ubuntu-22.04-base (NCP 제공 이미지)
  - OS Account : appadmin 생성 및 sudo 권한 설정 
  - ASP .NET 8.0 설치
  - testapi.service 파일 생성 ( sudo vi /etc/systemd/system/testapi.service )

```
[Unit]
Description=TestAPI (.NET 8)
After=network.target

[Service]
WorkingDirectory=/opt/testapi/current
ExecStart=/usr/bin/dotnet /opt/testapi/current/TestAPI.dll
Restart=always
RestartSec=5
User=www-data
Environment=ASPNETCORE_URLS=http://0.0.0.0:5000
Environment=ASPNETCORE_ENVIRONMENT=Production
#Environment=ASPNETCORE_ENVIRONMENT=Development


[Install]
WantedBy=multi-user.target

```

  웹 브라우저 접근
  http:// 대상 IP:5000/swagger/index.html
  ==> 빌드 배포 간 서버 내 서비스 확인 및 NCP 콘솔 LB 타겟 그룹 헬스 체크 경로 설정
  curl -v http://127.0.0.1:5000/swagger/index.html

  Health Check Port : 5000
  Health Check URL Path : /swagger/index.html

  웹 브라우저 접근
  http:// 대상 IP:5000/WeatherForecast
  ==> api호출 URL로 접근 확인


---
