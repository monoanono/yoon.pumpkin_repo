# NCP CLI 활용 일일 서버이미지 백업 설정

---

## 1. 개요
  - Ncloud 자체 데일리 스케줄 백업 서비스를 지원하지 않음
  - NCP CLI 명령어를 사용하여 서버 이미지를 생성
    - NCP CLI 명령어 기반 백업 이미지 생성 스크립트 구성 
    - Crontab 설정 하여  데일리 백업 진행, 3일 경과 이미지 삭제
    - 설치 필요 - NCP CLI, JSON processor jq
  - 명령어 구동용 Batch 서버하나에서 다중 NCP Account 내의 서버 이미지 생성 가능
    - 서버 이미지 생성을 위해 각 NCP Account 별로 권한있는 Sub Account의 API Key를 기반으로 NCP CLI Profile 설정하여 명령어 사용

---

## 2. 설정

### 2.1 NCP CLI Profile 설정
  - 참고 : https://cli.ncloud-docs.com/docs/guide-userguide#api-인증키-설정

```
Naver@AL01221192:/mnt/c/Users/Naver/Desktop/cli_linux$ ./ncloud configure --profile example_profile
set [example_profile]'s configuration.
Ncloud Access Key Id [] :***js9sk$K)DA!#***
Ncloud Secret Access Key [] :***kdofFIik9D$Kdk2***
Ncloud API URL (default:https://ncloud.apigw.ntruss.com) []: 

```

### 2.2 백업 이미지 생성 스크립트

```bash
#!/bin/bash

PROFILE="NCP CLI 프로파일 이름"                                                             # NCP CLI 프로파일 명
REGION="KR"
TODAY=$(date +"%y%m%d")
DAY_OF_WEEK=$(date +%u)

TARGET_SERVERS=("image-test01" "image-test02")    # 일일 서버 이미지 생성 대상 서버 콘솔상 이름 기입
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/슬랙 웹훅 URL"    #  slack  웹훅 URL

CREATE_REQUEST_RESULT=""
DELETE_RESULT=""
CREATE_VERIFY_RESULT=""

# 삭제 대상 날짜 계산
if [ "$DAY_OF_WEEK" -eq 1 ]; then
    DELETE_DATE=$(date -d "-5 days" +"%y%m%d")     # 월요일이면 지난주 수요일 생성 자원 삭제
elif [ "$DAY_OF_WEEK" -eq 2 ]; then
    DELETE_DATE=$(date -d "-5 days" +"%y%m%d")     #  화요일이면 지난주 목요일 생성 자원 삭제
elif [ "$DAY_OF_WEEK" -eq 3 ]; then
    DELETE_DATE=$(date -d "-5 days" +"%y%m%d")     #  수요일이면 지난주 금요일 생성 자원 삭제
else
    DELETE_DATE=$(date -d "-3 days" +"%y%m%d")     #  목/금 이면 같은 주 월/화 생성 자원 삭제
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
  "text": "서버 이미지 삭제 결과\n\n$DELETE_RESULT"
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
  "text": "서버 이미지 생성 요청 결과\n\n$CREATE_REQUEST_RESULT"
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
  "text": "서버 이미지 생성 완료 확인 결과\n\n$CREATE_VERIFY_RESULT"
}
EOF
)" "$SLACK_WEBHOOK_URL"
fi

echo "스크립트 완료"

```

### 2.2 Crotab 설정 
<img width="833" height="238" alt="Image" src="https://github.com/user-attachments/assets/81f1df86-6ab4-4b0e-9c64-7bc48f7cced3" />

```
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
#
0 9 * * 1-5 yhpark cd /home/yhpark/CLI_1.1.26_20250918/cli_linux && ./daily_ncp_server_image.sh

```
---

## 3. 결과
<img width="1917" height="743" alt="Image" src="https://github.com/user-attachments/assets/9898dae9-6d10-473c-980a-bbad3582af27" />

<img width="597" height="959" alt="Image" src="https://github.com/user-attachments/assets/7dc227ea-8d7d-4bbd-8736-54fe0c142cf2" />

---