#!/usr/bin/env sh
set -eu

base_url="https://localhost:8443"
cert_args="--cacert certs/ca.crt --cert certs/client.crt --key certs/client.key"

assert_code() {
  expected="$1"
  description="$2"
  shift 2
  actual="$(curl -sS -o /dev/null -w '%{http_code}' "$@" || true)"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: $description (expected $expected, got $actual)" >&2
    exit 1
  fi
  echo "PASS: $description ($actual)"
}

# shellcheck disable=SC2086
assert_code 200 "valid client certificate reaches the API" $cert_args "$base_url/api/"
assert_code 400 "missing client certificate is rejected before proxying" \
  --cacert certs/ca.crt "$base_url/api/"
# shellcheck disable=SC2086
assert_code 403 "encoded path traversal is rejected" $cert_args "$base_url/api/?file=%2e%2e%2fsecret"
# shellcheck disable=SC2086
assert_code 403 "SQL injection signature is rejected" $cert_args "$base_url/api/?q=UNION%20SELECT"

body="$(curl -sS $cert_args "$base_url/api/")"
echo "$body" | grep -q 'SUCCESS'
echo "PASS: upstream receives a verified client identity"
