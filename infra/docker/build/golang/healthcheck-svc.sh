#!/usr/bin/env sh
set -eo pipefail

#host="$(hostname -i || echo '127.0.0.1' | awk '{print $1}')"
#... hostname may be space-delimited list 
#... hostname may take 5+ seconds 
#host=$(ip route | awk '/default/ { print $3 }')
#... fast

# --max-time 1
# -f to include HTTP errors; 
# -Is for transport-layer errors only; HTTP 404 is no error (0) 
#curl -fs ${host}${APP_SERVICE_BASE_API}/liveness || exit 1
curl -fs localhost${1} || exit 1

#curl -fs localhost:3000${APP_SERVICE_BASE_API}/liveness && exit 0 || exit 1

# @ docker service ... swarm @ host node (single node mode)
# {"name":"API",...,"host":"393565de50b9","ip":"172.18.0.3"}
#... ip (172.18.0.3) is that of $host per `ip route |...` (above).
