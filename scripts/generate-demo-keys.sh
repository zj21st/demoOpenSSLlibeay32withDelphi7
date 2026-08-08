#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
key_dir=${1:-"$repo_root/build/test-keys"}
private_key="$key_dir/private-key.pem"
public_key="$key_dir/public-key.pem"

command -v openssl >/dev/null 2>&1 || {
  echo "OpenSSL CLI was not found in PATH." >&2
  exit 1
}

umask 077
mkdir -p "$key_dir"

if [ -e "$private_key" ] || [ -e "$public_key" ]; then
  echo "Refusing to overwrite an existing demo key in: $key_dir" >&2
  exit 1
fi

if openssl genrsa -help 2>&1 | grep -q -- '-traditional'; then
  openssl genrsa -traditional -out "$private_key" 2048
else
  openssl genrsa -out "$private_key" 2048
fi

openssl rsa \
  -in "$private_key" \
  -pubout \
  -out "$public_key"

chmod 600 "$private_key"
echo "Generated disposable demo keys in: $key_dir"
echo "Never commit or reuse these keys in a real system."
