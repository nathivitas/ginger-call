#!/bin/bash

#
# GET TMC API STATUS
#
# Requires the Source Code and Source Customer id as passing arguments
# Reads SECRET KEY From an environment variable
#
# -------------------------------------------

# -----------------------------------------------
# Usage
# -----------------------------------------------
usage() {
    echo "Usage: $0 -X <METHOD> -e <endpoint> [-d <body>]"
    echo "  -X  HTTP method: GET, POST, PUT"
    echo "  -e  API endpoint (e.g. /api/v1/status)"
    echo "  -d  Request body (required for POST/PUT)"
    exit 1
}

# -----------------------------------------------
# Configuration
# -----------------------------------------------
APP_CODE="${APP_CODE:?APP_CODE env variable is not set}"
SECRET_KEY="${SECRET_KEY:?SECRET_KEY env variable is not set}"

APP="${APP_CODE}"

# ENV - TEST
ginger_url="test-ginger-504.np.st1.yellowpages.com"
BASE_URL="http://${ginger_url}:9111"
ENDPOINT="/gpa/${1}/customers/${2}"

# -----------------------------------------------
# Generate rid (matches JS: "_STATUS_" + epoch ms)
# -----------------------------------------------



RID="TEST_$(date +%s%3N)"
#echo "rid: $RID"
#echo "app: $APP"
#echo "key: $SECRET_KEY"

# -----------------------------------------------
# Build the message to sign (no body in msg per your comment)
# -----------------------------------------------
MSG="appCode=${APP}&requestId=${RID}&myBody="

# -----------------------------------------------
# HMAC function - strips whitespace then signs
# -----------------------------------------------
hmac_string() {
    local privateKey="$1"
    local msg="$2"

    # Strip spaces, tabs, newlines (mirrors JS .replace() calls)
    local cleaned
    cleaned=$(echo -n "$msg" | tr -d ' \t\n\r')

    # Generate HMAC-SHA256 as hex
    local hmac
    hmac=$(echo -n "$cleaned" | openssl dgst -sha256 -hmac "$privateKey" | awk '{print $2}')

    echo "$hmac"
}

#echo "msg: ${MSG}"
GPA_KEY=$(hmac_string "$SECRET_KEY" "$MSG")
#echo "collection gpa_key: $GPA_KEY"

# -----------------------------------------------
# Make the curl request with all headers
# -----------------------------------------------
RESPONSE=`curl -s GET "${BASE_URL}${ENDPOINT}" \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "rid: ${RID}" \
   -H "app: ${APP}" \
   -H "gpa-key: ${GPA_KEY}"`

echo "$RESPONSE"