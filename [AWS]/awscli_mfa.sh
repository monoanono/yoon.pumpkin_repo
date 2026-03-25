#!/bin/bash

# 기존 AWS 인증 환경변수 해제
unset AWS_SESSION_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# MFA 토큰코드 입력받기
read -p "MFA 토큰 코드를 입력하세요: " TOKEN_CODE

# AWS CLI로 세션 토큰 요청 (JSON 응답)
RESPONSE=$(aws sts get-session-token \
  --serial-number #AWS 계정 내 MFA 장치 ARN \
  --token-code "$TOKEN_CODE")

# 각 값 추출 (jq 사용)
export AWS_ACCESS_KEY_ID=$(echo "$RESPONSE" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$RESPONSE" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$RESPONSE" | jq -r '.Credentials.SessionToken')

echo "AWS 세션 토큰이 환경변수에 등록되었습니다."
