# Prometheus Operator 설치

  - 참조 : https://wanbaep.tistory.com/21

---

## 1. helm 설치
```CMD
choco install kubernetes-helm
```
<img width="592" height="237" alt="Image" src="https://github.com/user-attachments/assets/9b4ff311-6ee5-44e7-ab51-26f9e6379ae2" />

---

## 2. Prometheus helm repo 추가
  -  Prometheus helm repo 추가
```CMD
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
<img width="787" height="51" alt="Image" src="https://github.com/user-attachments/assets/f93a8861-9bc0-4342-b8ef-0c1d50a76a09" />

  - helm repo 업데이트
```CMD
helm repo update
```
<img width="640" height="144" alt="Image" src="https://github.com/user-attachments/assets/47d956a3-a84d-481d-a3dd-1387d19bc086" />

---

## 3. K8s Cluster 설정
  - 본 테스트 는 minikube 에서 진행함

### 3.1 namespace 생성
```CMD
kubectl create ns monitoring
```
<img width="329" height="43" alt="Image" src="https://github.com/user-attachments/assets/bf0a99da-d8f8-4876-9649-8bb6e2f071ae" />


### 3.2 Prometheus 설치
```CMD
helm install wb-prometheus prometheus-community/kube-prometheus-stack -f prometheus-value.yaml -nmonitoring
```
```
helm install [설치 될 릴리스 네임] prometheus-community/kube-prometheus-stack -f [helm 설치 시 반영할 설정 파일] -nmonitoring
```
<img width="954" height="509" alt="Image" src="https://github.com/user-attachments/assets/7b69d843-ac11-4d9c-9778-8096d59ea258" />

#### 3.2.1 이슈 조치
  - 이슈 사항 : 기존 기본 형태로 배포 하였으나 그라파나 접속 시 default 로그인 정보 admin / admin 으로 로그인 불가 현상 발생
  - 조치 사항 : garafana env 환경 변수 설정을 통해 default 로그인 정보 admin / admin 명시적으로 지정 후 재배포, 재 배포 후 default 로그인 정보 admin / admin 로 정상 로그인 확인
```
helm upgrade wb-prometheus prometheus-community/kube-prometheus-stack -f prometheus-value.yml -n monitoring
```

  - prometheus-value.yaml
```yaml
prometheus:
  service:
    type: NodePort
grafana:
  service:
    type: NodePort
  env:
    GF_SECURITY_ADMIN_USER: "admin"
    GF_SECURITY_ADMIN_PASSWORD: "admin"
alertmanager:
  service:
   type: NodePort
```

### 3.3 Cluster 배포 현황 확인
```CMD
kubectl get all -n monitoring
```
<img width="947" height="750" alt="Image" src="https://github.com/user-attachments/assets/cc2ddf12-39ef-447d-aaee-c1a7e2bddbcc" />

---

## 4. prometheus & grafana 접속

### 4.1 접속 ip 확인
```CMD
minikube ip
```
<img width="195" height="50" alt="Image" src="https://github.com/user-attachments/assets/17602ef6-6798-4a9f-a948-a330c37a6184" />


### 4.2 접속 Port 확인
```CMD
minikube service -n monitoring --all
```
<img width="944" height="947" alt="Image" src="https://github.com/user-attachments/assets/f2b51fb3-4f50-4906-bec2-4f14350dd366" />

### 4.3 웹 서비스 접속

#### 4.3.1 Prometheus Web  UI
  - 172.25.207.124:30090
<img width="1915" height="575" alt="Image" src="https://github.com/user-attachments/assets/1ae7bdda-9a4d-4309-ab87-af8055b218e1" />

#### 4.3.2 Grafana Web  UI
  - 172.25.207.124:30357
  - ID : admin / PW : admin 으로 로그인
<img width="1917" height="1030" alt="Image" src="https://github.com/user-attachments/assets/2ca7b963-82e2-4fac-ac8e-f92185b708e2" />

  - Node Exporter 관련 대시보드 확인
<img width="1917" height="674" alt="Image" src="https://github.com/user-attachments/assets/5f4feee8-bccb-4a85-bb51-8ecd35585d9c" />
<img width="1916" height="1028" alt="Image" src="https://github.com/user-attachments/assets/98216465-0ee1-4515-ab96-6695800775f2" />
<img width="1913" height="1026" alt="Image" src="https://github.com/user-attachments/assets/73473ea4-848f-4cdc-b5af-f86a6f9bbd6e" />