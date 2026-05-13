#!/usr/bin/env bash
set -euo pipefail

APP_CODE="${APP_CODE:?APP_CODE env variable is not set}"
APP="${APP:-$APP_CODE}"
SECRET_KEY="${SECRET_KEY:?SECRET_KEY env variable is not set}"
GINGER_HOST="${GINGER_HOST:-test-ginger-504.np.st1.yellowpages.com}"
GINGER_PORT="${GINGER_PORT:-9111}"
CID="${CID:?CID env variable is not set}"
GPA_VERSION="${GPA_VERSION:-v1.20}"
INCLUDE_DISTRO="${INCLUDE_DISTRO:-true}"

BASE_URL="http://${GINGER_HOST}:${GINGER_PORT}"
RID="TEST_$(python3 -c 'import time; print(int(time.time()*1000))')"

ENDPOINT="/gpa/${APP_CODE}/customers/${CID}"
QUERY="includeDistro=${INCLUDE_DISTRO}"

MSG="appCode=${APP_CODE}&requestId=${RID}&myBody="
GPA_KEY="$(printf '%s' "$MSG" | tr -d ' \t\n\r' | openssl dgst -sha256 -hmac "$SECRET_KEY" | awk '{print $2}')"

echo "BASE_URL: ${BASE_URL}"
echo "ENDPOINT: ${ENDPOINT}"
echo "QUERY: ${QUERY}"
echo "RID: ${RID}"
echo "MSG: ${MSG}"
echo "GPA_KEY: ${GPA_KEY}"

curl -v -X GET "${BASE_URL}${ENDPOINT}?${QUERY}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "app: ${APP}" \
  -H "rid: ${RID}" \
  -H "gpa-key: ${GPA_KEY}" \
  -H "gpa_version: ${GPA_VERSION}"