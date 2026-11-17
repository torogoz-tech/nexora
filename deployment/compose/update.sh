#!/usr/bin/env bash
# Updates official images only. Never builds images or touches database volumes.
set -euo pipefail
umask 077
[[ $EUID -eq 0 ]] || { echo 'Run as root on the Nexora server.' >&2; exit 1; }
api_version="${1:?Usage: update.sh API_VERSION WEB_VERSION}"
web_version="${2:?Usage: update.sh API_VERSION WEB_VERSION}"
[[ $api_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && $web_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 64
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
exec 9>/run/lock/nexora-images.lock
flock -n 9 || { echo 'Another image update is running.' >&2; exit 1; }
api="ghcr.io/torogoz-tech/nexora-api:$api_version"
web="ghcr.io/torogoz-tech/nexora-web:$web_version"
docker pull "$api"
docker pull "$web"
# Fail before any interruption if the published runtime is incompatible.
docker run --rm "$api" --help > /tmp/nexora-image-help-$$ 2> /tmp/nexora-image-errors-$$
trap 'rm -f /tmp/nexora-image-help-$$ /tmp/nexora-image-errors-$$' EXIT
grep -q 'Nexora self-hosted platform API' /tmp/nexora-image-help-$$
test ! -s /tmp/nexora-image-errors-$$ || { cat /tmp/nexora-image-errors-$$ >&2; exit 1; }
docker run --rm --entrypoint /bin/sh "$api" -ec 'git --version; test -x "$(git --exec-path)/git-remote-https"'
api_digest="$(docker image inspect "$api" --format '{{index .RepoDigests 0}}')"
web_digest="$(docker image inspect "$web" --format '{{index .RepoDigests 0}}')"
[[ $api_digest == ghcr.io/torogoz-tech/nexora-api@sha256:* && $web_digest == ghcr.io/torogoz-tech/nexora-web@sha256:* ]]
data=(docker compose -f /opt/nexora/deploy/data/compose.yaml)
backup="/var/backups/nexora/images-$(date -u +%Y%m%dT%H%M%SZ)-$$"
install -d -m 700 "$backup"
[[ ! -f .env ]] || cp .env "$backup/previous.env"
cp /etc/nginx/sites-available/nexora "$backup/nginx.conf"
printf 'NEXORA_API_IMAGE=%s\nNEXORA_WEB_IMAGE=%s\nNEXORA_UID=%s\nNEXORA_GID=%s\n' \
  "$api_digest" "$web_digest" "$(id -u nexora)" "$(id -g nexora)" > .env.next
docker compose --env-file .env.next config --quiet
native_active=false
if systemctl is-active --quiet nexora-api.service; then native_active=true; fi
before_schema="$("${data[@]}" exec -T postgres psql -U nexora -d nexora -Atc 'SELECT max(version) FROM nexora_platform.platform_schema_versions')"
interrupted=false
activated=false
recover() {
  code=$?
  rm -f /tmp/nexora-image-help-$$ /tmp/nexora-image-errors-$$ .env.next
  if [[ $interrupted == true && $activated == false ]]; then
    after_schema="$("${data[@]}" exec -T postgres psql -U nexora -d nexora -Atc 'SELECT max(version) FROM nexora_platform.platform_schema_versions' 2>/dev/null || true)"
    docker compose stop worker api web || true
    cp "$backup/nginx.conf" /etc/nginx/sites-available/nexora
    if nginx -t; then systemctl reload nginx || true; fi
    if [[ -n $after_schema && $after_schema == "$before_schema" ]]; then
      if [[ $native_active == true ]]; then
        if [[ -f $backup/previous.env ]]; then
          cp "$backup/previous.env" .env
        else
          rm -f .env
        fi
        systemctl start nexora-api.service nexora-worker.service || true
      elif [[ -f $backup/previous.env ]]; then
        cp "$backup/previous.env" .env
        docker compose up -d --no-build --wait --wait-timeout 180 || true
      fi
    else
      echo "Schema changed. Preserve data and recover using $backup; do not blindly downgrade." >&2
    fi
  fi
  exit "$code"
}
trap recover EXIT
# Stop writers before the consistent database backup and schema operation.
interrupted=true
if [[ $native_active == true ]]; then systemctl stop nexora-worker.service nexora-api.service; fi
if [[ -f .env ]]; then docker compose stop worker api; fi
cp -a /etc/nexora "$backup/config"
cp -a /var/lib/nexora/secrets "$backup/secrets"
"${data[@]}" exec -T postgres pg_dump -U nexora -d nexora -Fc > "$backup/database.dump"
if [[ ! -s $backup/database.dump ]]; then echo 'Database backup is empty.' >&2; exit 1; fi
mv .env.next .env
docker compose run --rm --no-deps api --connections /etc/nexora/connections.json --schema nexora_platform migrate
docker compose up -d --no-build --wait --wait-timeout 180
# Keep the existing host proxy, security headers and tunnel. Only change the static origin.
python3 - <<'PY'
from pathlib import Path
p=Path('/etc/nginx/sites-available/nexora')
s=p.read_text()
if 'location @nexora_web' not in s:
    assert 'try_files $uri =404;' in s and 'try_files $uri $uri/ /index.html;' in s
    s=s.replace('try_files $uri =404;', 'try_files $uri @nexora_web;', 1)
    s=s.replace('try_files $uri $uri/ /index.html;', 'proxy_pass http://127.0.0.1:18082;', 1)
    s=s.replace('location = /index.html {', 'location = /index.html {\n        proxy_pass http://127.0.0.1:18082;', 1)
    pos=s.rfind('}')
    s=s[:pos]+'    location @nexora_web {\n        proxy_pass http://127.0.0.1:18082;\n    }\n'+s[pos:]
    p.write_text(s)
else:
    assert s.count('proxy_pass http://127.0.0.1:18082;') == 3
PY
nginx -t
systemctl reload nginx
curl --fail --silent http://127.0.0.1:18081/ready > "$backup/readiness.json"
curl --fail --silent http://127.0.0.1:18080/login > /dev/null
curl --fail --silent http://127.0.0.1:18082/health > /dev/null
if [[ $native_active == true ]]; then systemctl disable nexora-api.service nexora-worker.service; fi
cp .env "$backup/active-images.env"
docker compose ps > "$backup/containers.txt"
activated=true
printf 'Official images active. Backup and image digests: %s\n' "$backup"
