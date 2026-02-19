# ArgoCD CD 설정 (Github, EKS)



## 1. 구성도
<img width="766" height="336" alt="Image" src="https://github.com/user-attachments/assets/5aa64a59-fc9a-4e58-901b-c3cdfc9129e1" />

## 2. 목적
- AWS EKS 내 서비스 배포를 위한 **CI/CD 파이프라인** 구성

---

## 3. Continuous Deployment, (CD)


  CD - Github를 AWS EKS 클러스터 내 ArgoCD가 감시 변경점 반영 시 AWS ECR 신규빌드이미지 기반으로 서비스 배포
  Github main 브랜치 내 frontend / backend 워크플로우 단위 구분

- Github → ** ArgoCD(AWS EKS Cluster) ** → AWS ECR → AWS EKS Cluster
<img width="1916" height="2992" alt="Image" src="https://github.com/user-attachments/assets/df42d232-3abf-4c8a-9482-df538a0250c6" />

---

## 4. ArgoCD 설치


```helm
helm upgrade --install argo레포이름 . -f values.yaml --namespace argocd \
--set server.GKEbackendConfig.enabled=false \
--set controller.service.annotations={} \
--set controller.service.port=8082 \
--set controller.service.targetPort=8082 \
--skip-crds
```
  - 특정 버전 ArgoCD helm Chart 수정 하지 않고 옵션 명령어로 특정 기능 활성/비활성 설치
    GKE 관련 Config 기능 비활성화
    ArgoCD K8s(EKS) 서비스 포트, 타겟 포트 지정
    CRD 생성 스킵

<img width="1909" height="623" alt="Image" src="https://github.com/user-attachments/assets/a8d55d1e-4aef-45d2-a5fe-8e390a237c6a" />
<img width="1208" height="804" alt="Image" src="https://github.com/user-attachments/assets/9bf799b0-3664-4d97-9083-9e506cb3b6f2" />
<img width="681" height="102" alt="Image" src="https://github.com/user-attachments/assets/ed222847-b4c4-4c91-afe1-fc00d879c704" />

  - kubectl patch svc argo-uws-argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    argocd-server 설정 "type": "LoadBalancer" 로 변경
<img width="1253" height="38" alt="Image" src="https://github.com/user-attachments/assets/8b1b5e33-058b-4b6a-ac8a-b31081a99b94" />

  - kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d> argocd_pw.txt
    ArgoCD admin 초기 Default 설정 계정 암호 확인

  - kubectl get svc -n argocd
    ArgoCD 웹 접속 LB 정보 확인
    (/ 혹은 AWS 콘솔 상 Classic LB 접속 정보 확인 시 동일 내용 확인 가능)
<img width="1891" height="166" alt="Image" src="https://github.com/user-attachments/assets/423378f6-44ed-475a-a186-9298050f2339" />

---

## 5. ArgoCD 설정


### 5.1 ArgoCD 콘솔 웹 접속
  - ArgoCD 웹 접근 , admin, 확인 한 PW 로 로그인
<img width="1190" height="1821" alt="Image" src="https://github.com/user-attachments/assets/cbf042a7-43a7-44fa-ad6e-ca8eb9d8739c" />

### 5.2 ArgoCD - Github 연동
<img width="1185" height="1866" alt="Image" src="https://github.com/user-attachments/assets/b433b139-a137-41dd-8481-ba084f1b75c6" />

### 5.3 ArgoCD Application 생성
<img width="1189" height="1814" alt="Image" src="https://github.com/user-attachments/assets/44705291-f564-40ab-b5cd-e81982b66c1f" />
<img width="1187" height="1814" alt="Image" src="https://github.com/user-attachments/assets/b40d4e86-5013-40b8-9d17-fd6a9200bd47" />
<img width="1190" height="1211" alt="Image" src="https://github.com/user-attachments/assets/e7904bdd-fb76-46ee-93a8-1136f0bc884f" />
<img width="1911" height="979" alt="Image" src="https://github.com/user-attachments/assets/f8be47f7-7b90-4903-a032-8d21509eba71" />

---
