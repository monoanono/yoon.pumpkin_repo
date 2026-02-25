# Prometheus 스터디

  - 참고 : 
    - https://prometheus.io/docs/introduction/overview/
    - https://willseungh0.tistory.com/193

---

## 1. Prometeus 아키텍처
<img width="771" height="529" alt="Image" src="https://github.com/user-attachments/assets/c20a27be-f72a-4b30-bbdb-1be50c4f609b" />

---

## 2. Prometeus 구성 요소


  ### 2.1. Exporter / Job
  - 모니터링 대상의 Metric 데이터를 수집하고 중앙 집중 서버인 Prometheus Server가 Metrics 데이터를 가져 갈 수 있도록 API Endpoint 을 제공
    - node-exporter: 노드의 CPU, Memory, Network bandwidth 등 metrics 정보를 수집
    - jmx-exporter: JVM metrics 수집 (tomcat, kafka, cassandra …)
    - kafka-exporter, mysql-exporter, redis-exporter 등 다양한 exporter가 이미 제공되며, 커스텀도 가능
    - 공식적으로 제공하는 Exporters →https://prometheus.io/docs/instrumenting/exporters/


  ### 2.2. Prometheus Server
  - Retrieveal가 Exporter에서 제공하는 API를 통해서, Metrics를 Pull 해와서 -> Prometheus Server 내의 TSDB에 저장.
    - 특이점은, 대다수의 모니터링 시스템과 같은 Push 방식이 아닌 Pull 방식으로 Metrics 데이터를 수집
      - 대부분의 모니터링 도구가 Push 방식으로, 각 대상 서버에 Agent를 설치하고, Agent가 데이터를 수집해서 중앙 서버로 전송하는 방식을 사용.
      - 반면, Prometheus의 경우에는 Pull 방식으로, 중앙 집중 서버에서 각 target 서버로 부터 (Exporter를 통해) 메트릭 데이터를 수집해가는 방식
    - 모든 메트릭 지표를 전송하지 않아도 되므로, 트래픽 및 오버헤드 감소 및 Prometheus Server의 장애가 애플리케이션에 영향을 미치지 않는 장점.
    - 단점으로는 중앙 집중 서버인 Prometheus Server에서 각 대상 서버에 대한 정보를 알고 있어야 하는데, Service Discovery를 두어서 해결


  ### 2.3. PushGateway
  - pull 할 수 없는 상황에서 pull 방식이 아닌 Push 방식으로 metrics를 전송하기 위한 컴포넌트
    - Exporter와 동일한 역할을 하지만, pull 방식이 아닌 Push 방식으로 동작하는 컴포넌트
      - 예를 들어, 배치 잡 등 prometheus server가 exporter로부터 pull 하기도 전에 파드가 종료되어서, Prometheus Server(Retrieval 모듈)이 메트릭 정보를 읽어가기 전에 종료되는 경우
      - Prometheus Server에서 메트릭 정보를 읽어갈 Exporter가 Prometheus Server에서 접근할 수 없는 곳에 있는 경우


  ### 2.4. AlertManager
  - 설정된 Rule에 따른 알림 Notification 담당
  - Slack 등에 연동해서 알림 시스템 구축 가능
  - ex) 임계치를 넘어서면 알림 발송 등
      - Cpu usage 70% 이상이 되면 알림을 발송하는 등


---

## 3. prometheus 메트릭 알람 발생 흐름
  - 각 구성요소가 수집해 둔 데이터를 HTTP로 노출하고 Prometheus가 긁어간다 (Pull)
  - [ Application ] (→ Exporter) → [ Prometheus ] (→ Rule Evaluation → Firing Alert) → [ Alertmanager ] → [ Notification ]

---

## 4. prometheus 가 확인 하는 매트릭 데이터의 실체

  - 컨테이너 리소스 메트릭 (CPU, Memory 등) -> 출처: cAdvisor
    - Kubernetes에서는 kubelet 내부에 cAdvisor가 포함
    - top 명령어가 보는 데이터와 근본적으로 같은 커널 레벨 데이터 => Prometheus용으로 정규화된 형태로 노출
      - 리눅스의 /proc
      - /sys/fs/cgroup
      - 컨테이너 런타임 (containerd, CRI-O)

  - Node 전체 메트릭 -> 출처: Node Exporter
    - Node Exporter 는 리눅스 OS 정보를 수집
    - top, vmstat, iostat가 보는 것과 동일한 원천 데이터
      - /proc/stat
      -  /proc/meminfo
      - /proc/diskstats
      - /sys

  - Pod / Deployment / Kubernetes 오브젝트 메트릭 -> 출처: kube-state-metrics
    - 리소스 사용량이 아니라 Kubernetes API 정보를 가져온다.
      - Pod 상태
      - 설정된 replicas 수

  - 애플리케이션 메트릭 -> 애플리케이션 내부 instrumentation / Application Exporter (NGINX Exporter, MySQL Exporter, 등등)
    - 애플리케이션 코드 내부 변수값
      - API 호출 값 - NGINX Exporter
      - DB 데이터 쿼리값 - MySQL Exporter

---

## 5. 기타 내용 정리
<img width="2048" height="1952" alt="Image" src="https://github.com/user-attachments/assets/7035bf4e-c248-403b-a9d3-845a62141c6e" />
<img width="2048" height="1498" alt="Image" src="https://github.com/user-attachments/assets/48d85bc3-57be-441a-9fc7-d0ed6cd211f9" />
<img width="1744" height="1722" alt="Image" src="https://github.com/user-attachments/assets/751fd5ed-21bd-4861-a11a-5aa0d372c86e" />
<img width="2048" height="904" alt="Image" src="https://github.com/user-attachments/assets/96150690-9d3b-4e61-b2a4-204d1f289f0f" />
<img width="2320" height="1586" alt="Image" src="https://github.com/user-attachments/assets/f3f8f458-a220-4504-bc7e-c5cadd1ef8dc" />
<img width="1952" height="1239" alt="Image" src="https://github.com/user-attachments/assets/454d5b80-68af-44fa-9187-86eca4726f13" />
<img width="1382" height="1536" alt="Image" src="https://github.com/user-attachments/assets/38479a69-a787-4c7e-b0b9-db20082a1771" />
<img width="1600" height="1441" alt="Image" src="https://github.com/user-attachments/assets/50d31872-b9fd-44a3-a6f8-25cd78efe290" />
<img width="1816" height="1516" alt="Image" src="https://github.com/user-attachments/assets/366ff9f0-fffb-468b-9738-fc7be2330423" />
<img width="1489" height="1309" alt="Image" src="https://github.com/user-attachments/assets/8a4b97d6-f61c-4ef1-bae0-e5790caa3bcf" />
