# Prometheus Operator Node Exporter Collector 관련 설정(EKS)
  - 참조 관련 공식 문서 : https://github.com/prometheus/node_exporter/tree/master?tab=readme-ov-file#collectors

--

## 1. 목적
  - Helm 배포 Prometheus Operator Node Exporter 메트릭 수집기(Collector) 미사용 메트릭 부분 제외 설정으로 경량화/최적화 목적(저장 메트릭 데이터 경량화, 모니터링 프로세스 간 메모리 등 자원 사용량 최적화, PromQL 관련 메트릭 조회 대상 경량화, 최적화 목적)

--

## 2. 개요 
  - 1차 설정 Node Exporter Collector 관련 물리 서버 관련 하드웨어 관련 메트릭 제외
  - Enabled by default 인 Collector 중에서 비활성화 설정

--

## 3. 설정 사항
  - Prometheus Operator Helm Chart Values.yaml 파일에 설정
```yaml
prometheus-node-exporter:
  extraArgs:
    - --no-collector.arp
    - --no-collector.bcache
    - --no-collector.cpufreq
    - --no-collector.dmi
    - --no-collector.entropy
    - --no-collector.hwmon
    - --no-collector.infiniband
    - --no-collector.powersupplyclass
    - --no-collector.rapl
    - --no-collector.tapestats
    - --no-collector.thermal_zone
    - --collector.netclass.ignored-devices=^veth.*
```

### 3.1 제외 수집기 관련 사항
    - arp : mac주소 arp 프로토콜 관련
    - bcache : 리눅스 블록 캐시(bcache) 장치의 성능 및 상태 메트릭을 수집
    - cpufreq : 리눅스 시스템의 CPU 주파수(클럭 속도) 메트릭을 수집
    - dmi : 서버의 하드웨어 BIOS, 보드, 섀시 정보를 수집
    - entropy : 리눅스 커널의 난수 생성기(Random Number Generator)에서 사용 가능한 엔트로피 크기를 모니터링
    - hwmon : 하드웨어센서
    - infiniband : 리눅스 커널의 InfiniBand 서브시스템에서 제공하는 하드웨어 메트릭을 수집
    - powersupplyclass : 리눅스 시스템의 전원 공급 장치(배터리, UPS 등) 상태를 모니터링
    - rapl : Intel/AMD CPU의 실제 전력 소비량 및 에너지 사용량을 메트릭으로 수집
    - tapestats : 리눅스 테이프 드라이브(SCSI tape devices)의 I/O 통계(읽기/쓰기 바이트, 시간 등)를 수집
    - thermal_zone : 리눅스 시스템의 /sys/class/thermal 경로에서 온도 및 냉각 장치 관련 데이터를 수집
    - netclass.ignored-devices=^veth.* : 리눅스 /sys/class/net/을 통해 네트워크 인터페이스의 성능 지표(속도, 에러, 처리량 등)를 수집  // 불필요한 가상 인터페이스를 제외해 성능을 개선


### 3.2 설정 전후 수집 데이터 용량 비교 
  - EKS 클러스터 환경 별도 어플리케이션 미 설치 클러스터 상 Prometheus만 구성


#### 3.2.1 일반 버전 Prometheus Operator Helm 배포
  - 2시간 경과 후 수집 용량 - 212.5MB
<img width="1855" height="495" alt="Image" src="https://github.com/user-attachments/assets/8c6028b8-fa90-404d-9e18-aefa052699df" />
<img width="1464" height="66" alt="Image" src="https://github.com/user-attachments/assets/d46a115e-533f-491f-8228-5234df534a33" />

#### 3.2.2 불필요 Collector 제외 설정 Prometheus Operator Helm 배포
  - 2시간 경과 후 수집 용량 - 179.5MB (메트릭 데이터 수집 용량 기준 설정 전후 대비 약 15% 감소)
<img width="1862" height="509" alt="Image" src="https://github.com/user-attachments/assets/759cea4b-cad6-485f-ac1c-91ceb4a5d2f9" />
<img width="932" height="87" alt="Image" src="https://github.com/user-attachments/assets/f587e980-7f00-4fc9-9a4a-acf792c7ab3e" />
