# NKS 클러스터 구성 하기


## 1. 테스트 환경 구성도
<img width="834" height="792" alt="Image" src="https://github.com/user-attachments/assets/f7491c6e-1aed-4d25-b057-4bd453a43d37" />

---

## 2. 인프라 구성


### 2.1 VPC
<img width="1633" height="525" alt="Image" src="https://github.com/user-attachments/assets/92133603-f847-40dc-aabd-4a9062091479" />

### 2.2 Subnet
<img width="1626" height="453" alt="Image" src="https://github.com/user-attachments/assets/29a30ea6-3e30-4471-968c-0558ffc2a6a8" />

### 2.3 VPC Routing Table
<img width="1622" height="530" alt="Image" src="https://github.com/user-attachments/assets/58a1c0a2-7a1f-498e-858a-b2a19cbb93d1" />

<img width="1620" height="508" alt="Image" src="https://github.com/user-attachments/assets/588dabd2-b147-4c56-a605-da60ca810ab0" />

<img width="1626" height="546" alt="Image" src="https://github.com/user-attachments/assets/a5e97297-8360-47bf-a2fe-17f61d02cfdd" />

<img width="1624" height="481" alt="Image" src="https://github.com/user-attachments/assets/59968a54-5695-41dd-86ab-de12877e26a8" />

<img width="1622" height="485" alt="Image" src="https://github.com/user-attachments/assets/2a96d5e0-9c6b-430e-9990-7a9f9cec3f07" />

<img width="1633" height="516" alt="Image" src="https://github.com/user-attachments/assets/76f57252-92c9-4f71-a178-c21823f4b7dd" />

### 2.3 NAT GateWay
<img width="1633" height="630" alt="Image" src="https://github.com/user-attachments/assets/6f1c3317-e1be-4ff8-88c9-8b77e3f91a4a" />

<img width="1629" height="481" alt="Image" src="https://github.com/user-attachments/assets/703110a0-dd8c-486a-84ee-5d47a45866b5" />

---

## 3. NKS Cluster
<img width="1693" height="943" alt="Image" src="https://github.com/user-attachments/assets/f3ae819c-a9ae-4093-bf70-9feec8df6d4d" />

<img width="1711" height="953" alt="Image" src="https://github.com/user-attachments/assets/ee5d9b41-cf5e-4fc1-857a-59bf1b095e69" />
 
	• NKS Cluster를 프라이빗 환경에서 구성 하는 경우 노드가 프라이빗 VM으로 생성 되므로 노드 내 파드 들이 외부 통신이 필요한 경우 NAT 구성이 필수(Private VM NAT 설정 과 동일)

### 3.1 NKS 클러스터 노드 풀(≒EKS 노드그룹) 설정
<img width="1615" height="817" alt="Image" src="https://github.com/user-attachments/assets/c66ac1bf-0485-47b8-b675-cbc593d02840" />

    생성할 노드 수를 지정 하고 +추가 눌러서 노드풀에 설정한다.

<img width="1640" height="945" alt="Image" src="https://github.com/user-attachments/assets/993af437-5263-4269-b3f7-a4186e94e943" />

	• 클러스터 정보에서 확인 가능한 사항은 노드 스펙의 총합으로 표기된다. (-> vCPU 2EA, Mem 8GB *2 = vCPU 4EA, Mem 16GB)
	• 주의사항 내용 확인
		○ Subnet IP 생성 수를 초과 할수 없습니다. ==> 클러스터 생성시 지정 한 Subnet CIDR에 종속적 (vpc-nks-uwsmsp-test-private 10.0.40.0/24 범위를 벗어날수 없다.)
		○ VM 생성 수를 초과 할수 없습니다. ==> NKS 클러스터 생성시 설정한 최대 노드 수를 초과 할 수 없다. 

<img width="589" height="566" alt="Image" src="https://github.com/user-attachments/assets/805f50a3-309f-4c48-83ea-1b3635c2495e" />

<img width="975" height="582" alt="Image" src="https://github.com/user-attachments/assets/e5802e54-f273-4f4f-9d94-6bb864965513" />

<img width="1909" height="721" alt="Image" src="https://github.com/user-attachments/assets/89070790-6fca-4313-bfbe-d147d5d0d58e" />

	• Node IAM Role 확인

<img width="1629" height="479" alt="Image" src="https://github.com/user-attachments/assets/089c694a-008c-4099-8648-6c69d6e57973" />

	• 인증키 설정 (일반 VPC VM 생성과 동일)

<img width="1630" height="919" alt="Image" src="https://github.com/user-attachments/assets/057ffe54-ff2d-473e-a790-3c3f967ab750" />

	• 최종 생성 전 설정 확인

<img width="1909" height="954" alt="Image" src="https://github.com/user-attachments/assets/61eb3c55-e25f-4236-9329-4a55fbc8dcb5" />

<img width="1625" height="657" alt="Image" src="https://github.com/user-attachments/assets/24d70cf4-81e1-4af7-8c91-4d2e862cab7b" />

<img width="1628" height="752" alt="Image" src="https://github.com/user-attachments/assets/f6297994-a1c3-471c-9ed3-0cb7c3bb9836" />

<img width="1638" height="459" alt="Image" src="https://github.com/user-attachments/assets/23b0e749-1207-4d33-a4f6-fb531dcafe01" />

	• 노드 네이밍은 NCP에서 임의 지정 되며 설정한 노드풀네임-임의설정으로 VM생성 된다.
		○ nks-test-node-pool-w-6i3q / nks-test-node-pool-w-6i3r 으로 생성 됨


<img width="1637" height="942" alt="Image" src="https://github.com/user-attachments/assets/c312840b-1913-4e73-99ad-b4ef36d01c6b" />

	• 최종 노드 생성까지 약 10분에서 15분정도 소요 된다.

### 3.2 대시보드 확인

	•  그라파나
<img width="1917" height="1026" alt="Image" src="https://github.com/user-attachments/assets/3ffc1a9e-0ad7-41a2-aa49-6c3fbac2beae" />

<img width="1918" height="1030" alt="Image" src="https://github.com/user-attachments/assets/9533fd61-e663-4f72-b5af-28e666edd50d" />


	•  Kubernetes 웹 대시보드
<img width="1917" height="1029" alt="Image" src="https://github.com/user-attachments/assets/fffbf3cd-936f-4442-aa98-a5c528884461" />

---

## 4. Kubectl Server 설정

	• kubectl 서버 설정
		○ kubectl 서버 NKS 클러스터 내 노드 파드 관리 를 위한 서버로 프라이빗 환경의 노드가 존재 하여 퍼블릭 환경에 구성한 kubectl 서버는 Bastion 서버 처럼 인식 될 수 있으나 역할의 구분이 다르다.
		○ Bastion 서버는 Privte 서버의 SSH 접근을 위한 host 서버이나 kubectl 서버는 kubectl 명령어 툴을 사용하여 K8s 노드 파드 클러스터 관리를 위한 관리용 툴 서버로 NKS 환경에서 NCP가 관리하는 K8s Control plane 노드 내 API server 와 ETCD 등 관리 구성 요소 접근을 위한 용도로 구성된다. (구성도 참조) 즉 kubectl 서버는 클러스터 내 노드에 직업 연결하는 방식이 아닌 NCP가 관리하는 K8s Control plane과 통신 하기 위한 서버이다. 
		○ kubectl 서버(kubectl) > NCP가 관리하는 K8s Control plane(API server) > NKS WorkerNode의 순서로 명령어 통신 및 수행

	• kubectl 서버의 지정
		○ 현 구성도 상 NCP 환경 내의 동일 VPC내 Public Subnet에 kubectl 서버를 설정 하였으나 클라우드 환경이 아닌 로컬 PC나 서버 NKS VPC와 통신 가능한 환경이라면 kubectl설치 후 NKS 가이드에 따라 API 연결 방식으로 kubectl 사용이 가능 하다.
		○ NCP NKS의 경우 IAM Sub Account의 API 인증키를 직접 config파일에 정보를 기입 하여 호출 하는 방식을 사용한다.

<img width="1361" height="906" alt="Image" src="https://github.com/user-attachments/assets/4053f2e3-9283-409c-9480-2fc61e7805d2" />

		○ 참조 :
			§ https://guide.ncloud-docs.com/docs/k8s-k8suse-cluster
			§ https://guide.ncloud-docs.com/docs/k8s-iam-auth-kubeconfig
			


### 4.1 test-nks-kubectl-server 설정
	• 필요 요소 설치
		1. ncp-iam-authenticator 설치
		- Ncloud Kubernetes Service는 ncp-iam-authenticator를 통해 IAM 인증을 제공합니다. IAM 인증을 통해 kubectl 명령을 사용하려면 ncp-iam-authenticator를 설치하고 이를 인증에 사용하도록 kubectl 설정 파일을 수정해야 합니다.
		- 참조 : https://guide.ncloud-docs.com/docs/k8s-iam-auth-ncp-iam-authenticator
		2. kubectl 설치
		- K8s클러스 관리를 위한 kubect 설치 클러스터 설치된 버전에 맞는 kubectl  툴 설치 진행 (1.29)
		- 참조 : https://kubernetes.io/docs/tasks/tools/
		3. (+a) alias 설정 
		- alias k = "kubectl" 설정

#### 4.1.1 server 내 설정 사항
  1. NCP API 액세스 키 OS 환경 변수 설정
<img width="903" height="78" alt="Image" src="https://github.com/user-attachments/assets/020fccbd-3033-44a3-a667-b8a7bcef5060" />

  2. ncp-iam-authenticator 로 kubconfig 파일 설정
<img width="1139" height="73" alt="Image" src="https://github.com/user-attachments/assets/e517aa47-1f05-45e2-a0da-a194f477360e" />

    참조 : https://guide.ncloud-docs.com/docs/k8s-iam-auth-kubeconfig
    초기 설정 시 : ncp-iam-authenticator create-kubeconfig --region <region-code> --clusterUuid <cluster-uuid> --output kubeconfig.yaml

    초기 설정 이후 신규 클러스터 연결 시 : ncp-iam-authenticator update-kubeconfig --region <region-code> --clusterUuid <cluster-uuid>

    리전은 KR, 클러스터 UUID는 콘솔에서 확인 가능함
<img width="1647" height="864" alt="Image" src="https://github.com/user-attachments/assets/54f2b812-8a80-4d4c-ac21-60f6b1a30dc2" />

	• kubectl server 내 K8S 클러스터 정보 확인
<img width="657" height="152" alt="Image" src="https://github.com/user-attachments/assets/7996b3ea-4c73-4781-b49a-b633dd933dae" />

	• Pod 배포 테스트
<img width="582" height="82" alt="Image" src="https://github.com/user-attachments/assets/343902ef-794f-4310-b3b7-6e3b6d89ca0c" />

<img width="477" height="511" alt="Image" src="https://github.com/user-attachments/assets/9969e914-6f84-4c3b-9ba0-e694ab8599d0" />

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mario
  labels:
    app: mario
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mario
  template:
    metadata:
      labels:
        app: mario
    spec:
      containers:
      - name: mario
        image: pengbai/docker-supermario
---
apiVersion: v1
kind: Service
metadata:
   name: mario
spec:
  selector:
    app: mario
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  type: LoadBalancer

```

	• LB 생성 확인
<img width="1664" height="671" alt="Image" src="https://github.com/user-attachments/assets/13df832d-61cd-4a22-8066-07e21491295b" />

	• pod 배포 현황 확인
<img width="485" height="67" alt="Image" src="https://github.com/user-attachments/assets/c4a608a9-d262-40c7-99e5-47710b63b4a8" />

<img width="1915" height="1030" alt="Image" src="https://github.com/user-attachments/assets/9e020fd0-d660-4c9c-b70e-feeb039ade02" />

	• Pod 서비스 접속 하기
<img width="1650" height="663" alt="Image" src="https://github.com/user-attachments/assets/760254f9-e3ff-4598-91b4-4990a6e85a34" />

<img width="1917" height="1029" alt="Image" src="https://github.com/user-attachments/assets/f25a9661-04cc-4fa7-bc32-d8b10246bb04" />

<img width="1912" height="1029" alt="Image" src="https://github.com/user-attachments/assets/45ef98e6-68cb-4396-978c-52cca5afa68e" />

	• Pod 삭제
<img width="685" height="187" alt="Image" src="https://github.com/user-attachments/assets/5b6d8502-ea87-4533-b493-4f871c22ecb2" />

<img width="1683" height="956" alt="Image" src="https://github.com/user-attachments/assets/b910a084-c669-4c48-8975-a79dbfbdcbb9" />

<img width="1918" height="1025" alt="Image" src="https://github.com/user-attachments/assets/9d2f7023-d6cb-43b0-b7a8-a740a7d523ac" />

<img width="1917" height="1029" alt="Image" src="https://github.com/user-attachments/assets/c4984241-044b-4c51-98b2-d4606e9820f1" />

<img width="1914" height="1027" alt="Image" src="https://github.com/user-attachments/assets/4db10adb-cb35-4fd7-bb02-ca1ab92d888d" />