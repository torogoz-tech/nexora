#!/usr/bin/env bash
# Exercise Compose wait with the real worker health contract, without DB/network access.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
temporary="$(mktemp -d)"
project="nexora-worker-health-test-$$"
cleanup() {
  docker compose -p "$project" -f "$temporary/compose.json" down --timeout 1 >/dev/null 2>&1 || true
  rm -rf "$temporary"
}
trap cleanup EXIT
docker compose -f "$root/compose.yaml" --env-file "$root/images.env.example" config --format json > "$temporary/source.json"
python3 - "$temporary/source.json" "$temporary/compose.json" <<'PY'
import json,sys
worker=json.load(open(sys.argv[1]))['services']['worker']
for field in ['volumes','depends_on','command','restart']:
    worker.pop(field,None)
worker['network_mode']='none'
worker['entrypoint']=['/bin/bash','-ec','exec -a /usr/local/bin/nexora-api sleep 60']
worker['healthcheck'].update(interval='1s',start_period='1s')
json.dump({'services':{'worker':worker}},open(sys.argv[2],'w'))
PY
docker compose -p "$project" -f "$temporary/compose.json" up -d --wait --wait-timeout 30
