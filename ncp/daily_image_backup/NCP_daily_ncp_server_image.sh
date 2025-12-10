#!/bin/bash

PROFILE="고객사프로파일명"
REGION="KR"
TODAY=$(date +"%y%m%d")
DAY_OF_WEEK=$(date +%u)

TARGET_SERVERS=("서버01" "서버02")
SLACK_WEBHOOK_URL="슬랙웹훅URL"

CREATE_REQUEST_RESULT=""
DELETE_RESULT=""
CREATE_VERIFY_RESULT=""

# 삭제 대상 날짜 계산
if [ "$DAY_OF_WEEK" -eq 1 ]; then
    DELETE_DATE=$(date -d "-5 days" +"%y%m%d")
elif [ "$DAY_OF_WEEK" -eq 2 ]; then
    DELETE_DATE=$(date -d "-5 days" +"%y%m%d")
elif [ "$DAY_OF_WEEK" -eq 3 ]; then
    DELETE_DATE=$(date -d "-5 days" +"%y%m%d")
else
    DELETE_DATE=$(date -d "-3 days" +"%y%m%d")
fi

echo "오늘 날짜: $TODAY"
echo "삭제 대상 이미지 날짜: $DELETE_DATE"

# 1. 삭제 대상 이미지 제거
IMAGE_LIST=$(./ncloud vserver getServerImageList --regionCode "$REGION" --profile "$PROFILE")

DELETE_CANDIDATES=$(echo "$IMAGE_LIST" | jq -r --arg date "$DELETE_DATE" '
  .getServerImageListResponse.serverImageList[]
  | select(.serverImageType.code == "SELF" and (.serverImageName | endswith("-" + $date)))
  | "\(.serverImageName) \(.serverImageNo)"')

if [ -z "$DELETE_CANDIDATES" ]; then
    DELETE_RESULT="삭제 대상 이미지 없음 (기준일: $DELETE_DATE)"
else
    while read -r IMAGE_NAME IMAGE_NO; do
        SERVER_NAME=$(echo "$IMAGE_NAME" | cut -d '-' -f1)
        DELETE_OUTPUT=$(./ncloud vserver deleteServerImage \
            --regionCode "$REGION" \
            --profile "$PROFILE" \
            --serverImageNoList "$IMAGE_NO" 2>&1)

        if echo "$DELETE_OUTPUT" | grep -q '"returnCode": "0"'; then
            DELETE_RESULT+="$SERVER_NAME → 삭제 성공: $IMAGE_NAME ($IMAGE_NO)\n"
        else
            DELETE_RESULT+="$SERVER_NAME → 삭제 실패: $IMAGE_NAME ($IMAGE_NO)\n에러: $DELETE_OUTPUT\n"
        fi
    done <<< "$DELETE_CANDIDATES"
fi

# 슬랙 알림 (삭제 결과)
if [ -n "$DELETE_RESULT" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "$(cat <<EOF
{
  "text": "NCP 고객사 서버 이미지 삭제 결과\n\n$DELETE_RESULT"
}
EOF
)" "$SLACK_WEBHOOK_URL"
fi

# 2. 이미지 생성 요청
INSTANCE_LIST=$(./ncloud vserver getServerInstanceList --regionCode "$REGION" --profile "$PROFILE")

while read -r SERVER_NAME INSTANCE_NO; do
    for TARGET_NAME in "${TARGET_SERVERS[@]}"; do
        if [ "$SERVER_NAME" == "$TARGET_NAME" ]; then
            IMAGE_NAME="${SERVER_NAME}-${TODAY}"
            CREATE_OUTPUT=$(./ncloud vserver createServerImage \
                --regionCode "$REGION" \
                --profile "$PROFILE" \
                --serverInstanceNo "$INSTANCE_NO" \
                --serverImageName "$IMAGE_NAME" 2>&1)

            if echo "$CREATE_OUTPUT" | grep -q '"returnCode": "0"'; then
                CREATE_REQUEST_RESULT+="$SERVER_NAME → 생성 요청 성공: $IMAGE_NAME\n"
            else
                CREATE_REQUEST_RESULT+="$SERVER_NAME → 생성 요청 실패: $IMAGE_NAME\n에러: $CREATE_OUTPUT\n"
            fi
        fi
    done
done <<< "$(echo "$INSTANCE_LIST" | jq -r '.getServerInstanceListResponse.serverInstanceList[] | "\(.serverName) \(.serverInstanceNo)"')"

# 슬랙 알림 (생성 요청 결과)
if [ -n "$CREATE_REQUEST_RESULT" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "$(cat <<EOF
{
  "text": "NCP 고객사 서버 이미지 생성 요청 결과\n\n$CREATE_REQUEST_RESULT"
}
EOF
)" "$SLACK_WEBHOOK_URL"
fi

# 3. 생성 확인 (6분 대기 후)
sleep 360

LATEST_IMAGE_LIST=$(./ncloud vserver getServerImageList --regionCode "$REGION" --profile "$PROFILE")

for SERVER_NAME in "${TARGET_SERVERS[@]}"; do
    EXPECTED_IMAGE_NAME="${SERVER_NAME}-${TODAY}"
    IMAGE_FOUND=$(echo "$LATEST_IMAGE_LIST" | jq -r --arg name "$EXPECTED_IMAGE_NAME" '
        .getServerImageListResponse.serverImageList[]
        | select(.serverImageName == $name)
        | "\(.serverImageName) \(.serverImageNo)"')

    if [ -z "$IMAGE_FOUND" ]; then
        CREATE_VERIFY_RESULT+="$SERVER_NAME → 생성 확인 실패: $EXPECTED_IMAGE_NAME\n"
    else
        IMAGE_NO=$(echo "$IMAGE_FOUND" | awk '{print $2}')
        CREATE_VERIFY_RESULT+="$SERVER_NAME → 이미지 생성 완료: $EXPECTED_IMAGE_NAME ($IMAGE_NO)\n"
    fi
done

# 슬랙 알림 (생성 확인 결과)
if [ -n "$CREATE_VERIFY_RESULT" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "$(cat <<EOF
{
  "text": "NCP 고객사 서버 이미지 생성 완료 확인 결과\n\n$CREATE_VERIFY_RESULT"
}
EOF
)" "$SLACK_WEBHOOK_URL"
fi

echo "스크립트 완료"
