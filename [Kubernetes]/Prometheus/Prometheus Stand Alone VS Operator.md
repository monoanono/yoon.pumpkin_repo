# Prometheus Stand Alone VS Operator

  - Prometheus Stand Alone VS Operator 비교

---

## 1. Standalone Prometheus vs Prometheus Operator 기반 비교표

| 항목 | Standalone Prometheus | Prometheus Operator 기반 |
|------|----------------------|--------------------------|
| 설치 난이도 | 단순 (Deployment + ConfigMap) | 복잡 (CRD, Helm chart 필요) |
| 초기 러닝커브 | 낮음 | 높음 |
| 구조 이해도 | 직관적 | 내부 리소스 많아 복잡 |
| K8s Service Discovery | 가능 (kubernetes_sd_configs 사용) | 기본 제공 |
| Pod/Service 모니터링 | 가능 (annotation + relabel 직접 작성) | ServiceMonitor / PodMonitor 사용 |
| 멀티 네임스페이스 수집 | 가능 (설정 필요) | 기본적으로 자동 처리 |
| 설정 변경 방식 | prometheus.yml 직접 수정 | CRD 리소스 선언형 관리 |
| 재시작 필요 여부 | 설정 변경 시 reload 필요 | 재시작 불필요 |
| 확장성 (HA 구성) | 수동 구성 필요 | 비교적 간단 |
| Alertmanager 클러스터링 | 수동 구성 | 기본 지원 |
| GitOps 친화성 | 보통 | 매우 높음 |
| 대규모 클러스터 적합성 | 관리 어려움 | 적합 |
| 디버깅 난이도 | 단순 | 상대적으로 복잡 |
| 소규모 테스트 환경 | 매우 적합 | 다소 과함 |
| 엔터프라이즈 환경 | 제한적 | 일반적으로 채택 |
| 멀티 클러스터 확장 (Thanos 등) | 직접 구성 | 연동 용이 |


---

## 2. Standalone Prometheus
### 2.1. 장점
  - 구조가 단순함 (최소 구성 기준 Deployment + ConfigMap 만으로 구성 가능)
  - prometheus.yml 직접 관리 (디버깅 쉬움)
  - 소규모 환경, 테스트환경에 유리 (특정 환경에 종속적이지 않음)

### 2.2. 단점
  - 새 서비스 추가 등 설정 변경 시 마다 prometheus 재시작 필수
  - 감시대상이 늘어 날수록 관리포인트 증가 (매번 수동 설정 및 재시작 필수)
  - 운영 자동화에 불리

### 2.3. 매트릭 수집 흐름
  - Application -> Exporter -> Prometheus

---

## 3.  Prometheus Operator
### 3.1.  장점
  - K8s 친화적 (K8s Custom Resource Definition CRD로 모니터링 대상 자동 감지)
  - Helm 배포 가능 (내부적으로 배포 해야 할 리소스가 많으나, Helm chart로 한번에 배포)
  - 운영 자동화에 유리, 대규모 운영환경에 적합 (선언형 설정으로 GitOps 친화적)

### 3.2. 단점
  - Standalone Prometheus 대비 리소스 구조가 복잡 (Helm Chart 의존성 높음)
  - Standalone Prometheus 대비 디버깅 난이도 높음 (구조가 복잡하여 확인해야 할 지점이 많다.)
  - K8s 환경에서만 사용 할 수 있다.

### 3.3. 매트릭 수집 흐름
  - Application -> Exporter -> Servicemonitor(K8s CRD) -> Prometheus
