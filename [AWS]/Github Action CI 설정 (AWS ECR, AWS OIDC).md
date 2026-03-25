# Github Action CI 설정 (AWS ECR, AWS OIDC)



## 1. 구성도
<img width="769" height="336" alt="Image" src="https://github.com/user-attachments/assets/36969b1d-fcd8-45d1-b476-ce12410639c1" />

## 2. 목적
- AWS EKS 내 서비스 배포를 위한 **CI/CD 파이프라인** 구성

---

## 3. Continuous Integration (CI)
  CI - Github Action (Github Private Repository 컨테이너 이미지 빌드 하여 AWS ECR에 푸시 ECR 로그인 관련 OIDC 토큰 발행 하여 로그인)
  Github main 브랜치 내 frontend / backend 워크플로우 단위 구분

- Github → **Github Action** → AWS ECR

#### 3.1 Github Action WorkFlow yaml
```yaml
name: Frontend Request Workflow                                   # name: 워크플로우 이름(Actions 목록/실행 화면에 표기)

on:
  push:                                                           # push: 지정 브랜치/경로 변경 시 트리거
    branches: [ "main" ]                                          # ← 트리거 대상 브랜치
    paths:                                                        # 신청 페이지 관련 파일 변경에만 반응 (불필요 실행 방지)
      - 'frontend/request/*'                                      # ← 이 경로 하위 "한 단계" 파일만 감지(*)
                                                                  # (선택) 하위 폴더까지 포함하려면 '**' 사용 가능: frontend/request/**
  workflow_dispatch:                                              # 수동 실행 허용(액션 탭에서 Run workflow 버튼)

# env: 이 워크플로우 전체 스코프의 셸 환경변수(편의상 매핑)
#  - ${{ vars.* }} 는 Environment → Repository → Organization 우선순위로 값을 가져옴
#  - 이 파일은 잡에서 environment: request 를 사용하므로, request 환경의 변수 우선
env:
  AWS_REGION: ${{ vars.AWS_REGION }}
  # Repository > Settings > Secrests and variables > Action > Variables > Repository variables
  AWS_OIDC_ROLE_ARN: ${{ vars.AWS_OIDC_ROLE_ARN }}
  ECR_REPOSITORY: ${{ vars.ECR_REPO_REQUEST }}

permissions:
  id-token: write                                                 # OIDC 토큰 발급(AssumeRoleWithWebIdentity에 필요)
  contents: read                                                  # 코드 체크아웃 등 읽기 권한

jobs:
  build-and-ecr-push:                                             # jobs.<id>: 잡 식별자
    name: DockerImageECRPush                                      # name: 잡 표시 이름
    runs-on: ubuntu-latest                                        # runs-on: 실행 러너(ubuntu-latest 권장)
    environment: request                                          # environment: 이 잡이 사용할 GitHub Environment 이름
#- 이 환경에 등록한 Variables/Secrets를 ${{ vars.* }}, ${{ secrets.* }} 로 참조

# 코드 체크아웃
    steps:
    - name: Checkout
      uses: actions/checkout@v4
# AWS 자격증명 구성: GitHub OIDC로 IAM Role
    - name: Configure AWS credentials (OIDC)
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-region: ${{ env.AWS_REGION }}                          # 위 env에서 매핑한 리전 사용 (Repository variables 사용)
        role-to-assume: ${{ env.AWS_OIDC_ROLE_ARN }}               # 위 env에서 매핑한 Role ARN 사용 (Repository variables 사용)
        role-session-name: gha-ecr-fe-request                      # 세션 이름(CloudTrail 등에서 식별용)
# Amazon ECR 로그인(도커 레지스트리 로그인)
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
# Docker 이미지 빌드 & ECR 푸시
    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}    # ECR 레지스트리 도메인(로그인 스텝 출력값) AWS ECR URI
        # 이미지 태그: Environment 변수 REQUEST_VERSION 사용 
        #  - (주의) 동일 태그 재푸시 시 기존 이미지가 덮어쓰기 됨
        #  - (선택) ECR 태그 불변(immutability)을 켠 경우 동일 태그 재푸시는 실패
        #  - (선택) 커밋 SHA를 쓰고 싶다면 ${{ github.sha }} 로 교체 가능 -> 워크플로우 트리거 한 git commit 해시 값
        IMAGE_TAG: ${{ vars.REQUEST_VERSION }}
      run: |
        #  - 빌드 컨텍스트: ${{ vars.DOCKER_CONTEXT_REQUEST }} (예: ./frontend/request)
        #  - Dockerfile 경로는 기본값(Dockerfile)로 가정
        #    (선택) 별도 경로/파일명일 경우 -f 옵션 사용 필요(여기서는 원본 유지)
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ${{ vars.DOCKER_CONTEXT_REQUEST }}

        # docker push: 위에서 빌드한 태그를 ECR로 푸시
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

        # 출력 변수 기록(다른 스텝에서 outputs로 활용 가능)
        echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

```

#### 3.2 변수 설정
  * 변수 설정 (${{ vars.* }} 는 Environment → Repository → Organization 우선순위로 값을 가져옴)
    * Repository 단위 변수 - AWS 계정명, OIDC Role ARN, AWS 리전 설정
      - AWS_ACCOUNT_ID / 123456789
      - AWS_OIDC_ROLE_ARN / arn:aws:iam::123456789:role/ECR_Github_OIDC_Role
      - AWS_REGION / ap-northeast-2
	
  * Environment 단위(jobs: environment: request ) 변수(워크플로우 yaml 단위에서 사용할 변수 설정) 
    * 도커 파일 위치(repo 상 경로), 도커 빌드용 컨텍스트 위치, AWS ECR repo명, 이미지 태그 명시용 변수
      - DOCKERFILEPATH_SVC_REQUEST / ./frontend/request/Dockerfile
      - DOCKER_CONTEXT_REQUEST / ./frontend/request
      - ECR_REPO_REQUEST / frontend/vpnrequest
      - REQUEST_VERSION / v.0.9.0

#### 3.3 AWS OIDC 연동 (Github <-> AWS ECR)
  - AWS ECR 연동
  - AWS ECR에 푸시 ECR 로그인 관련 OIDC 토큰 발행 하여 로그인 
	(참조 : https://jennifersoft.com/ko/blog/kubernetes/2024-02-22-jennifer-kubernetes-20/)
	(참조 : https://docs.github.com/ko/enterprise-cloud@latest/actions/concepts/security/openid-connect)
<img width="763" height="308" alt="Image" src="https://github.com/user-attachments/assets/5ce344a8-de3f-4fe2-9e9a-26d544f052a9" />

  * CI - GitHub Action - AWS OIDC 사용 이유?
    - OIDC 미사용으로 구성 시 
    - AWS Access Key, Secret 을 GitHub Secret에 저장 하고 사용
    - Key 관련 관리 중 유출 위험성, Key 정보 망실 시 재발행 등 관리 소요 존재
    - OIDC 구성 시 -> 토큰 방식  AWS OIDC 사용 하여 관리 소요 해소(AWS 내부에서만 관리, Access Key, Secret 등 외부 환경 노출 X)

##### 3.3.1 AWS IAM ID 제공업체 공급자 추가
<img width="1912" height="937" alt="Image" src="https://github.com/user-attachments/assets/85edcde9-cd41-48de-91d9-a3445fd3d631" />

  * OpenID Connect 선택
  * 공급자 URL : https://token.actions.githubusercontent.com
  * 대상 : sts.amazonaws.com
<img width="1910" height="947" alt="Image" src="https://github.com/user-attachments/assets/a5119fc2-5235-421d-90f3-be2e89eeb7b9" />
<img width="1630" height="628" alt="Image" src="https://github.com/user-attachments/assets/57f5d7ce-e2b5-4869-a6ff-3cc1b1f7dbc2" />

##### 3.3.2 IAM Role 설정
  * 웹 자격 증명
    - 생성한 OIDC 토큰 선택 :  token.actions.githubusercontent.com 
    - Adience : sts.amazonaws.com
    - GitHub organization(CI Github Action 연동할 레포지토리 ) :  Github ORG 이름 / Github Repository 이름
<img width="1904" height="936" alt="Image" src="https://github.com/user-attachments/assets/a8b325bc-fb93-4db3-85ed-139728977596" />

  * 권한 추가 : EC2InstanceProfileForImageBuilderECRContainerBuilds
<img width="1914" height="935" alt="Image" src="https://github.com/user-attachments/assets/25b6587c-51cf-469c-8866-2659a8dedecb" />
<img width="1902" height="939" alt="Image" src="https://github.com/user-attachments/assets/1e1ab63e-7930-4497-ac17-81e1cbada0b5" />
<img width="1589" height="530" alt="Image" src="https://github.com/user-attachments/assets/9109a111-22b1-484f-931e-17224e98ab7a" />

---
