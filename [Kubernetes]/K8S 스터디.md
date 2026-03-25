# K8S 스터디

  - 참고 :  Minikube 활용 K8s 스터디
    - https://subicura.com/k8s/prepare/
    - https://subicura.com/k8s/guide/#%E1%84%80%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%83%E1%85%B3


### 내용 정리

![Image](https://github.com/user-attachments/assets/09d891dc-7f62-4ac9-b63a-6328c2ed7d5b)

![Image](https://github.com/user-attachments/assets/8aade5ae-3c11-4c24-85c3-787a76c621aa)

![Image](https://github.com/user-attachments/assets/d86fd417-52a9-4d06-ac5b-60e1905216eb)

<img width="2048" height="2732" alt="Image" src="https://github.com/user-attachments/assets/4561fb31-2a80-4331-b625-2e72372bdc6a" />

<img width="2048" height="2732" alt="Image" src="https://github.com/user-attachments/assets/25e7baf3-6c17-476f-8ab1-c9c3be7e95e7" />

<img width="1469" height="1207" alt="Image" src="https://github.com/user-attachments/assets/5b4f7046-f01c-408a-a0e4-919407dbca99" />

<img width="1410" height="1401" alt="Image" src="https://github.com/user-attachments/assets/3f46b6f8-5ba6-4dfc-a42e-c6e067b4ef90" />


  - kubectl 과 minikube 실행 주체 및 동작 원리
    1. kubectl 명령어:
      - 실행 주체: kubectl은 사용자의 로컬 컴퓨터(여기서는 Windows 환경)에서 실행됩니다.
      - 동작 원리:
        - kubectl은 Kubernetes 클러스터의 API 서버와 통신하는 CLI 도구입니다.
        - 사용자가 kubectl 명령어를 실행하면, 이 명령어는 API 서버로 HTTP 요청을 보내 클러스터 리소스를 관리합니다.
        - API 서버는 요청을 받아 처리하고, 필요한 경우 클러스터의 상태 데이터를 저장하는 etcd에 접근합니다.
        - kubectl은 클러스터 내부의 Pod, Service, Deployments 등과 같은 리소스를 제어할 수 있습니다.

    2. minikube 명령어:
      - 실행 주체: minikube도 사용자의 로컬 컴퓨터에서 실행됩니다.
      - 동작 원리:
        - minikube는 로컬 컴퓨터에서 단일 노드 Kubernetes 클러스터를 실행할 수 있게 해주는 도구입니다.
        -  minikube start 명령어를 실행하면, Hyper-V, VirtualBox 등과 같은 가상화 기술을 이용해 가상 머신을 생성하고, 그 안에 Kubernetes 클러스터를 띄웁니다.
        - 이 가상 머신은 마스터 노드와 워커 노드를 포함한 단일 노드 클러스터로 동작합니다.
        - minikube 명령어는 이 가상 머신에서 실행 중인 Kubernetes 클러스터를 제어하거나 상태를 조회하는 데 사용됩니다.


  - 구동 흐름 및 동작 원리 요약:
    1. minikube 구동:
      - minikube start 명령어를 통해 Hyper-V와 같은 가상화 환경에서 Kubernetes 클러스터가 생성됩니다.
      -  이 가상 머신은 Kubernetes의 마스터 노드와 워커 노드를 모두 포함한 단일 노드로 동작합니다.
    2. kubectl 사용:
      - 클러스터가 구동되면, kubectl을 사용하여 클러스터 내부의 리소스(Pod, Service 등)를 제어합니다.
      -  kubectl은 사용자의 로컬 컴퓨터에서 실행되어 Hyper-V에서 구동 중인 가상 머신 내의 Kubernetes API 서버와 통신합니다.
      - API 서버는 명령을 처리하고, 클러스터의 상태를 반영하도록 etcd를 업데이트합니다.	
      -Windows 환경: 사용자는 kubectl과 minikube 명령어를 로컬 컴퓨터에서 실행합니다.
      -Hyper-V 가상 머신: minikube가 생성한 가상 머신에서 Kubernetes 클러스터가 동작하며, kubectl 명령어는 이 클러스터의 API 서버와 통신합니다.
	요약
      -kubectl과 minikube 모두 로컬 컴퓨터에서 실행되며, 각기 다른 역할을 합니다.
        - kubectl: Kubernetes 클러스터의 API 서버와 통신하여 클러스터 리소스를 관리.
        - minikube: 로컬에서 Kubernetes 클러스터를 실행하고 관리하기 위한 도구.
      -minikube는 Hyper-V를 통해 가상 머신을 생성하고, 그 안에서 Kubernetes 클러스터를 구동합니다. kubectl은 이 클러스터를 제어하는 데 사용됩니다.

