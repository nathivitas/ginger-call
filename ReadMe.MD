How to run it
set -a         
source .env
set +a

GET
./gpa_request.sh GET
POST
./gpa_request.sh POST body2.json
PUT
./gpa_request.sh PUT b352071d236146dd body2.json
DELETE
./gpa_request.sh DELETE b352071d236146dd body2.json