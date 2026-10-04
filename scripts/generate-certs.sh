#!/usr/bin/env sh
set -eu

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cert_dir="$repo_dir/certs"
mkdir -p "$cert_dir"

openssl req -x509 -newkey rsa:3072 -sha256 -nodes -days 3650 \
  -keyout "$cert_dir/ca.key" -out "$cert_dir/ca.crt" \
  -subj "/CN=Portfolio Demo Root CA/O=Portfolio Security"

openssl req -newkey rsa:2048 -sha256 -nodes \
  -keyout "$cert_dir/server.key" -out "$cert_dir/server.csr" \
  -subj "/CN=localhost/O=Portfolio Edge"
openssl x509 -req -sha256 -days 365 \
  -in "$cert_dir/server.csr" -CA "$cert_dir/ca.crt" -CAkey "$cert_dir/ca.key" \
  -CAcreateserial -out "$cert_dir/server.crt" \
  -extfile "$repo_dir/scripts/server.ext"

openssl req -newkey rsa:2048 -sha256 -nodes \
  -keyout "$cert_dir/client.key" -out "$cert_dir/client.csr" \
  -subj "/CN=portfolio-client/O=Portfolio Consumer"
openssl x509 -req -sha256 -days 365 \
  -in "$cert_dir/client.csr" -CA "$cert_dir/ca.crt" -CAkey "$cert_dir/ca.key" \
  -CAcreateserial -out "$cert_dir/client.crt" \
  -extfile "$repo_dir/scripts/client.ext"

rm -f "$cert_dir/server.csr" "$cert_dir/client.csr" "$cert_dir/ca.srl"
chmod 600 "$cert_dir"/*.key
echo "Generated a local CA plus server and client certificates in $cert_dir"

