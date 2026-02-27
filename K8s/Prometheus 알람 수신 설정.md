# Prometheus 알람 수신 설정

  - 개요 : Prometheus 알람을 Slack 채널 알람 수신
  - 흐름 : Prometheus -> AlertManager -> Slack

---
## 1. AlertManager 설정 수정
  - 알람 발송 할 Slack webhook URL 추가 value 파일 적용
<img width="787" height="761" alt="Image" src="https://github.com/user-attachments/assets/b82018b1-1c3f-4ca6-b152-f9046606932d" />

  - prometheus-value.yaml 파일 수정
```yaml
prometheus:
  service:
    type: NodePort          # Prometheus UI를 NodePort로 외부 접속 가능하게 설정
                                  # (minikube IP:NodePort 로 접근 가능)

grafana:
  service:
    type: NodePort          # Grafana UI를 NodePort로 외부 접속 가능하게 설정
  env:
    GF_SECURITY_ADMIN_USER: "admin"       # Grafana 관리자 계정 아이디
    GF_SECURITY_ADMIN_PASSWORD: "admin"   # Grafana 관리자 계정 비밀번호

alertmanager:
  service:
    type: NodePort          # Alertmanager UI를 NodePort로 외부 접속 가능하게 설정

  alertmanagerSpec:
    useExistingSecret: false  # 기존 Kubernetes Secret을 사용하지 않고  Helm values에 정의된 config를 기반으로 Secret을 자동 생성함
    
  config:
    global:
      resolve_timeout: 5m   # Alert가 resolve(해소)된 후 상태를 유지하는 기본 타임아웃 , 5분 동안 추가 변경 없으면 resolve 처리

    route:
      receiver: slack-notifications  # 기본 수신자 설정 (매칭되는 route 없을 경우 이 receiver로 전달)

      group_by:
        - alertname  # 동일 alertname 기준으로 알람 묶음 (Slack 메시지 그룹핑 기준)
      group_wait: 30s    # 알람 발생 후 처음 전송 전까지 대기 시간 (여러 알람을 묶기 위해 30초 대기)
      group_interval: 5m # 같은 그룹에서 새 알람이 생겼을 때 다음 알람을 보내기 전 최소 대기 시간
      repeat_interval: 4h  # 동일한 FIRING 알람을 재전송하는 주기 (4시간마다 한 번씩 재알림)
      routes: [] # 하위 라우팅 규칙 정의 영역 현재는 비어있음 (severity별 분기 등 가능)

    receivers:
      - name: slack-notifications # route에서 지정한 receiver 이름과 동일해야 함
        slack_configs:
          - api_url: "Slack 알람 수신 웹훅 URL 주소"  # Slack Incoming Webhook URL
            channel: "#alert_test_msp" # Slack 알림이 전송될 채널 이름
            send_resolved: true  # Alert가 해소(RESOLVED) 되었을 때도 Slack 알림 전송 여부
```

---

## 2. helm 반영

  - helm 릴리즈 이름 확인
```helm
helm list -A
```
<img width="945" height="97" alt="Image" src="https://github.com/user-attachments/assets/f82e3307-f6e7-45c8-83e4-2186f9c280ff" />

  - helm 업그레이드로 설정 적용
```helm
helm upgrade wb-prometheus prometheus-community/kube-prometheus-stack -f prometheus-value.yaml -n monitoring
```
<img width="943" height="530" alt="Image" src="https://github.com/user-attachments/assets/e8cfb3e2-7dbc-4126-9bd6-a37eff7f9507" />


---

## 3. 알람 수신 확인

### 3.1 알람 발생 테스트 yaml 적용
  - cpu-test-alert.yaml
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cpu-test-alert
  namespace: monitoring
  labels:
    release: wb-prometheus
spec:
  groups:
    - name: test-alert
      rules:
        - alert: CPUHighTest
          expr: vector(1)
          for: 30s
          labels:
            severity: critical
          annotations:
            summary: "CPU Test Alert"
            description: "This is a manual Slack test alert."
```
<img width="427" height="409" alt="Image" src="https://github.com/user-attachments/assets/8bfe7e64-b0a2-4e1a-91a6-c8db6894d8bd" />


### 3.2 Alert rule 적용
```yaml
kubectl apply -f cpu-test-alert.yaml
```
<img width="486" height="47" alt="Image" src="https://github.com/user-attachments/assets/ca904ac0-0c4d-48ea-97ae-7641a8361c56" />

  - rule 적용 확인
<img width="956" height="1031" alt="Image" src="https://github.com/user-attachments/assets/70ac46ba-9069-4081-82fe-3211cec4137a" />


  - Slack 알람 수신 확인
<img width="597" height="88" alt="Image" src="https://github.com/user-attachments/assets/141933f8-4b3e-4980-98ff-b6dd2e87640f" />


  - Alert rule 삭제
<img width="726" height="48" alt="Image" src="https://github.com/user-attachments/assets/4a9c3998-2396-4b54-a57b-35b35811a780" />
<img width="579" height="93" alt="Image" src="https://github.com/user-attachments/assets/f1a28126-88c6-477e-b3d6-71b73db28139" />