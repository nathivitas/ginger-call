---

# Ginger Call

Created by Naty Caraballo

---

## Overview

This repository provides a lightweight shell-based test harness for validating and troubleshooting Ginger GPA API integrations.

The goal of this project is to simplify testing and debugging of Ginger customer endpoints by dynamically generating:

- GPA request signatures
- Request IDs
- Authentication headers
- Endpoint URLs

This allows quick validation of Ginger API behavior without requiring Postman collections, application deployments, or additional tooling.

---

## Current Capabilities

The harness currently supports testing of:

- GET requests
- POST requests
- PUT requests
- DELETE requests

against Ginger GPA customer endpoints.

---

## Requirements

Required tools:

- bash
- curl
- openssl
- python3

Recommended environment:

- macOS
- Linux

---

## Project Structure

```text
GINGER CALL/
├── README.md
├── .gitignore
├── .env
├── .env.sample
├── scripts
│   ├── gpa_request.sh
│   └── script.sh
├── payloads
│   ├── body.json
│   ├── body2.json
│   └── samplecall
└── examples
    ├── get.example
    └── post.example
```

---

## Environment Configuration

Copy the sample environment file:

```bash
cp .env.sample .env
```

Update the values:

```bash
APP_CODE=tmc
APP=tmc
SECRET_KEY=replace_me
GINGER_HOST=
GINGER_PORT=
CID=
GPA_VERSION=v1.20
INCLUDE_DISTRO=true
```

---

## Load Environment Variables

Before running requests:

```bash
set -a
source .env
set +a
```

---

## Running Requests

### GET Request

```bash
./scripts/gpa_request.sh GET
```

---

### POST Request

```bash
./scripts/gpa_request.sh POST payloads/body2.json
```

---

### PUT Request

```bash
./scripts/gpa_request.sh PUT b352071d236146dd payloads/body2.json
```

---

### DELETE Request

```bash
./scripts/gpa_request.sh DELETE b352071d236146dd
```

---

## What the Script Does

The script dynamically:

- Generates a request ID
- Computes GPA HMAC SHA256 signatures
- Builds Ginger request headers
- Constructs endpoint URLs
- Executes curl requests against Ginger

Example generated headers:

```http
app: tmc
rid: TEST_1747143191923
gpa-key: <generated_hmac>
gpa_version: v1.20
```

---

## Example Endpoint

```text
http://test-ginger-504.np.st1.yellowpages.com:9111/gpa/tmc/customers/<customer_id>
```

---

## Common Troubleshooting

### Invalid GPA Key

Example response:

```json
{
  "message": "unauthorized_user",
  "details": [
    {
      "field": "gpa-key",
      "issue": "Invalid Key"
    }
  ]
}
```

Verify:

- SECRET_KEY is correct
- APP_CODE matches the environment
- Environment variables are loaded
- Payload formatting is correct
- No whitespace issues exist

---

### Connectivity Issues

Verify:

- VPN access is active
- Ginger host is reachable
- Port is correct
- DNS resolves properly

---

## Security Notes

This repository intentionally excludes:

- `.env`
- secrets
- credentials
- local MDM folders

Never commit production secrets to GitHub.

---

## Ownership

Created and maintained by Naty Caraballo.