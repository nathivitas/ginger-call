#!/usr/bin/env bash
set -euo pipefail

APP_CODE="${APP_CODE:?APP_CODE env variable is not set}"
APP="${APP:-$APP_CODE}"
SECRET_KEY="${SECRET_KEY:?SECRET_KEY env variable is not set}"
CID="${CID:?CID env variable is not set}"

GINGER_HOST="${GINGER_HOST:-test-ginger-504.np.st1.yellowpages.com}"
GINGER_PORT="${GINGER_PORT:-9111}"
GPA_VERSION="${GPA_VERSION:-v1.20}"
INCLUDE_DISTRO="${INCLUDE_DISTRO:-true}"

# Optional headers shown in POST docs
CALLBACK_URL="${CALLBACK_URL:-}"
USER_ID="${USER_ID:-}"

METHOD="${1:-GET}"          # GET | POST | PUT | DELETE
CPID="${2:-}"              # used by PUT / DELETE
BODY_FILE="${3:-}"         # used by POST / PUT / DELETE

BASE_URL="http://${GINGER_HOST}:${GINGER_PORT}"
RID="TEST_$(python3 -c 'import time; print(int(time.time()*1000))')"

BODY_CONTENT=""
QUERY=""
ENDPOINT=""

case "$METHOD" in
  GET)
    ENDPOINT="/gpa/${APP_CODE}/customers/${CID}"
    QUERY="includeDistro=${INCLUDE_DISTRO}"
    ;;

  POST)
    BODY_FILE="${2:-}"
    BODY_FILE="${BODY_FILE:?BODY_FILE is required for POST}"
    ENDPOINT="/gpa/${APP_CODE}/customers/${CID}"
    BODY_CONTENT="$(jq -c . "$BODY_FILE")"
    ;;

  PUT)
    CPID="${2:-}"
    BODY_FILE="${3:-}"
    CPID="${CPID:?CPID is required for PUT}"
    BODY_FILE="${BODY_FILE:?BODY_FILE is required for PUT}"
    ENDPOINT="/gpa/${APP_CODE}/customers/${CID}/products/${CPID}"
    BODY_CONTENT="$(jq -c . "$BODY_FILE")"
    ;;

  DELETE)
    CPID="${2:-}"
    BODY_FILE="${3:-}"
    CPID="${CPID:?CPID is required for DELETE}"
    BODY_FILE="${BODY_FILE:?BODY_FILE is required for DELETE per Ginger cancel docs}"
    ENDPOINT="/gpa/${APP_CODE}/customers/${CID}/products/${CPID}"
    BODY_CONTENT="$(jq -c . "$BODY_FILE")"
    ;;

  *)
    echo "❌ Unsupported method: $METHOD"
    echo "Usage:"
    echo "  $0 GET"
    echo "  $0 POST body.json"
    echo "  $0 PUT <cpid> body.json"
    echo "  $0 DELETE <cpid> body.json"
    exit 1
    ;;
esac

MSG="appCode=${APP_CODE}&requestId=${RID}&myBody=${BODY_CONTENT}"
GPA_KEY="$(printf '%s' "$MSG" | tr -d ' \t\n\r' | openssl dgst -sha256 -hmac "$SECRET_KEY" | awk '{print $2}')"

URL="${BASE_URL}${ENDPOINT}"
if [[ -n "$QUERY" ]]; then
  URL="${URL}?${QUERY}"
fi

echo "METHOD: $METHOD"
echo "URL: $URL"
echo "RID: $RID"
echo "BODY_CONTENT: $BODY_CONTENT"
echo "MSG: $MSG"
echo "GPA_KEY: $GPA_KEY"

CURL_ARGS=(
  -v
  -X "$METHOD" "$URL"
  -H "Accept: application/json"
  -H "Content-Type: application/json"
  -H "app: ${APP}"
  -H "rid: ${RID}"
  -H "gpa-key: ${GPA_KEY}"
  -H "gpa_version: ${GPA_VERSION}"
)

# Add optional headers only when present
if [[ -n "$CALLBACK_URL" ]]; then
  CURL_ARGS+=(-H "callback_url: ${CALLBACK_URL}")
fi

if [[ -n "$USER_ID" ]]; then
  CURL_ARGS+=(-H "user_id: ${USER_ID}")
fi

if [[ "$METHOD" == "POST" || "$METHOD" == "PUT" || "$METHOD" == "DELETE" ]]; then
  CURL_ARGS+=(--data "$BODY_CONTENT")
fi

curl "${CURL_ARGS[@]}"