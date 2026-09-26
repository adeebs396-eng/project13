#!/usr/bin/env bash
# Add your current public IP to allowed_source_ips, then apply.
#
#   bash infra/allow-my-ip.sh 1.2.3.4
#
# Get the address from https://ipv4.icanhazip.com in your BROWSER.
# Do not curl it in Cloud Shell, that returns Azure's address, not yours.
set -euo pipefail

IP="${1:-}"
if [ -z "$IP" ]; then
  echo "usage: bash infra/allow-my-ip.sh 1.2.3.4"
  echo "get it from https://ipv4.icanhazip.com in your browser"
  exit 1
fi

if ! printf '%s' "$IP" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
  echo "not an IPv4 address: $IP"
  echo "the VM has no IPv6 address, so an IPv6 client cannot reach it"
  exit 1
fi

cd "$(dirname "$0")"
[ -f terraform.tfvars ] || { echo "terraform.tfvars not found"; exit 1; }

if grep -q "\"$IP\"" terraform.tfvars; then
  echo "$IP is already allowed, nothing to do"
  exit 0
fi

cp terraform.tfvars terraform.tfvars.bak
python3 - "$IP" <<'PY'
import re, sys
ip = sys.argv[1]
s = open("terraform.tfvars").read()
m = re.search(r'(allowed_source_ips\s*=\s*\[)(.*?)(\])', s, re.S)
if not m:
    sys.exit("allowed_source_ips not found in terraform.tfvars")
inner = m.group(2).strip().rstrip(',')
inner = (inner + ', ' if inner else '') + '"%s"' % ip
open("terraform.tfvars", "w").write(s[:m.start(2)] + inner + s[m.end(2):])
print("added " + ip)
PY

grep allowed_source_ips terraform.tfvars
echo
echo "Review the plan. It should say 3 to change, 0 to add, 0 to destroy."
terraform apply
