#!/usr/bin/env bash
# Execute only inside a disposable test container; all external commands are mocked.
set -euo pipefail
[[ ${NEXORA_RECOVERY_TEST:-} == 1 && -f /.dockerenv ]] || { echo 'Disposable test container required.' >&2; exit 64; }
mkdir -p /mock-bin /run/lock /etc/nginx/sites-available /etc/nexora /var/lib/nexora/secrets /app
cp /src/update.sh /app/update.sh
printf 'original nginx\n' > /etc/nginx/sites-available/nexora
export PATH="/mock-bin:$PATH"
cat > /mock-bin/docker <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> /calls
case "$*" in
  'image inspect '*nexora-api*) echo 'ghcr.io/torogoz-tech/nexora-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';;
  'image inspect '*nexora-web*) echo 'ghcr.io/torogoz-tech/nexora-web@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';;
  'run --rm '*--help) echo 'Nexora self-hosted platform API';;
  *psql*) echo 116;;
  *pg_dump*) echo 'database dump fixture';;
  'compose up '*)
    if [[ ! -e /failed-up ]]; then touch /failed-up; exit 1; fi;;
esac
MOCK
cat > /mock-bin/systemctl <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf 'systemctl %s\n' "$*" >> /calls
case "$1" in
  is-active) [[ $TEST_MODE == native ]];;
  stop) printf 'key-at-stop\n' > /var/lib/nexora/secrets/master-key;;
esac
MOCK
cat > /mock-bin/id <<'MOCK'
#!/usr/bin/env bash
if [[ $1 == -u ]]; then echo 999; else echo 987; fi
MOCK
printf '#!/bin/sh\nexit 0\n' > /mock-bin/nginx
printf '#!/bin/sh\nexit 0\n' > /mock-bin/flock
chmod +x /mock-bin/*
for scenario in native-first native-stale-env containers; do
  rm -f /app/.env /app/.env.next /failed-up /calls
  rm -rf /var/backups/nexora
  printf 'key-before-stop\n' > /var/lib/nexora/secrets/master-key
  export TEST_MODE=native
  if [[ $scenario != native-first ]]; then
    printf 'previous images\n' > /app/.env
  fi
  if [[ $scenario == containers ]]; then export TEST_MODE=containers; fi
  if bash /app/update.sh 0.2.1 0.2.0 >/test-output 2>&1; then
    cat /test-output; echo 'Expected activation failure.' >&2; exit 1
  fi
  backup=(/var/backups/nexora/images-*)
  test -s "${backup[0]}/database.dump"
  if [[ $scenario == native-first ]]; then test ! -e /app/.env
  else grep -qx 'previous images' /app/.env
  fi
  if [[ $TEST_MODE == native ]]; then
    grep -qx 'systemctl start nexora-api.service nexora-worker.service' /calls
    test "$(grep -c '^compose up ' /calls)" -eq 1
    grep -qx 'key-at-stop' "${backup[0]}/secrets/master-key"
  else
    test "$(grep -c '^compose up ' /calls)" -eq 2
    if grep -q '^systemctl start nexora-api' /calls; then exit 1; fi
  fi
  test ! -e /app/.env.next
  echo "Recovery passed: $scenario"
done
