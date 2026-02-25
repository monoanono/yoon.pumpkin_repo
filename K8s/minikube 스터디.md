# minikube 스터디

- 다운로드 링크 : https://github.com/kubernetes/minikube/releases/latest/download/minikube-installer.exe


## 1. minikube 설치

  - Hyper-V 활성화
    - 관리자 권한으로 CMD 에서 명령어 실행

```
DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V

```
<img width="643" height="181" alt="Image" src="https://github.com/user-attachments/assets/0a92f25f-8003-49fe-8f2c-524b40fa0215" />

---

  - minikube  버전 확인
```
minikube version

```
<img width="406" height="67" alt="Image" src="https://github.com/user-attachments/assets/3ee25b2e-a392-4667-af86-666f202e5952" />

---

  - minikube 시작 (Hyper-V)

```
minikube start --driver=hyperv

```
<img width="838" height="188" alt="Image" src="https://github.com/user-attachments/assets/04ee04fb-fe66-4279-ada7-408d20c2ab77" />
<img width="960" height="515" alt="Image" src="https://github.com/user-attachments/assets/70f62f1e-dde9-45bc-903b-b1a9d696c198" />
<img width="950" height="354" alt="Image" src="https://github.com/user-attachments/assets/7ccbe3a3-4d18-4471-867f-60494e351a0e" />

---

  - minikube 상태 확인
```
minikube status

```
<img width="221" height="127" alt="Image" src="https://github.com/user-attachments/assets/9361f6aa-7635-4ae5-823a-10a61b11dd9c" />
<img width="203" height="52" alt="Image" src="https://github.com/user-attachments/assets/0f06496a-d221-43b0-bcd9-5c61d206e9af" />

---

  - minikube 접속하기
    - 로컬(윈도우) -> minikube 접속

```
minikube ssh

```
<img width="452" height="157" alt="Image" src="https://github.com/user-attachments/assets/b178016b-c971-4df4-aef5-20a23b8385c7" />

    - Hyper-V 콘솔에서 접속하기
      - 가상컴퓨터 -> 우클릭 -> 연결
      - OS 계정 : root (초기 설정 패스워드 미입력, 계정명 입력하고 엔터 시 접속 가능)
<img width="959" height="516" alt="Image" src="https://github.com/user-attachments/assets/56281db3-72da-4af0-8bc2-033f6224e658" />
<img width="638" height="505" alt="Image" src="https://github.com/user-attachments/assets/4c002352-41f3-400e-8585-90128b91a722" />

---


## 2. kubectl 설치
  - 로컬(윈도우) 에 kubectl 설치 (26.02.25 부 최신 버전 : kubectl 1.35.0 )
  - 참고 : https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-windows/
<img width="781" height="759" alt="Image" src="https://github.com/user-attachments/assets/2f684349-7cc9-4bdd-a0c2-160a65be844e" />

```
curl.exe -LO "https://dl.k8s.io/release/v1.35.0/bin/windows/amd64/kubectl.exe"

```
<img width="733" height="83" alt="Image" src="https://github.com/user-attachments/assets/c988a388-b210-457f-b090-baf4a1db9794" />

  - minikube 설치 시 함께 포함된 kubectl.exe 를 CMD에서 구동 해도 된다.
<img width="959" height="514" alt="Image" src="https://github.com/user-attachments/assets/6246f57b-8d55-448f-82c0-021c267d1c41" />

---

  - kubectl 버전 확인

```
kubectl version --client

```
<img width="312" height="66" alt="Image" src="https://github.com/user-attachments/assets/ee580512-80c4-4af9-9bf5-902467bcac23" />

---

  - kubectl 명령어로 minikube cluster ip 확인

```
kubectl describe service

```
<img width="377" height="300" alt="Image" src="https://github.com/user-attachments/assets/da8b6e86-508d-41cc-a9f5-07f285b4cc67" />
<img width="639" height="500" alt="Image" src="https://github.com/user-attachments/assets/50ebf65f-5a14-4e45-a2d5-70bc3915e348" />
<img width="1065" height="403" alt="Image" src="https://github.com/user-attachments/assets/b8f606aa-8f52-44ad-a466-2f5674c1d330" />
