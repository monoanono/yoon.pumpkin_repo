#!/bin/bash

# 고객사 프로파일 목록
profiles=("고객사1" "고객사2")

echo "====== 고객사 선택 ======"
select PROFILE in "${profiles[@]}"; do
  if [[ -n "$PROFILE" ]]; then
    echo "선택된 프로파일: $PROFILE"
    break
  fi
done

REGION_NO=1  # Classic 리전 번호

echo ""
echo "========== 전체 서버 상태 =========="
./ncloud server getServerInstanceList --regionNo $REGION_NO --profile "$PROFILE" --output json \
| jq -r '.getServerInstanceListResponse.serverInstanceList[]
        | "\(.serverName) 서버 상태: \(.serverInstanceStatusName)"'

echo ""
echo "========== 전체 LB 상태 =========="
./ncloud loadbalancer getLoadBalancerInstanceList --regionNo $REGION_NO --profile "$PROFILE" --output json \
| jq -r '.getLoadBalancerInstanceListResponse.loadBalancerInstanceList[]
        | "\(.loadBalancerName)\tLB 상태: \(.loadBalancerInstanceStatusName)"'

echo ""
echo "====== ⚠️ 비정상 서버 또는 LB 현황 ======"

# 비정상 서버 (StatusName != "running")
bad_servers=$(./ncloud server getServerInstanceList --regionNo $REGION_NO --profile "$PROFILE" --output json \
| jq -r '.getServerInstanceListResponse.serverInstanceList[]
        | select(.serverInstanceStatusName != "running")
        | "\(.serverName) 서버 상태: \(.serverInstanceStatusName)"')

# 비정상 LB (StatusName != "Running")
bad_lbs=$(./ncloud loadbalancer getLoadBalancerInstanceList --regionNo $REGION_NO --profile "$PROFILE" --output json \
| jq -r '.getLoadBalancerInstanceListResponse.loadBalancerInstanceList[]
        | select(.loadBalancerInstanceStatusName != "used")
        | "\(.loadBalancerName)\tLB 상태: \(.loadBalancerInstanceStatusName)"')

if [[ -n "$bad_servers" ]]; then
  echo "-- RUNNING이 아닌 서버 --"
  echo "$bad_servers"
else
  echo "-- RUNNING이 아닌 서버 없음 --"
fi

echo ""

if [[ -n "$bad_lbs" ]]; then
  echo "-- Used 아닌 LB --"
  echo "$bad_lbs"
else
  echo "-- Used 아닌 LB 없음 --"
fi

