#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Script checks health of running container.

health_status=$(cat /opt/.docker_config/.healthcheck 2>/dev/null || true)
healthcheck_instance=${IOB_HEALTHCHECK_INSTANCE:-}

if [ "$health_status" == "starting" ]; then
  echo "Health status: OK - Startup script is still running."
  exit 0
elif [ "$health_status" == "maintenance" ]; then
  echo "Health status: OK - Container is running in maintenance mode."
  exit 0
fi

if ! pgrep -u iobroker -f 'iobroker.js-controller' > /dev/null; then
  echo "Health status: !!! NOT OK !!! - Main process (js-controller) is not running."
  exit 1
fi

if [ -n "$healthcheck_instance" ]; then
  state_id="system.adapter.${healthcheck_instance}.alive"
  if ! gosu iobroker iob state getvalue "$state_id" 2> /dev/null | grep -qx 'true'; then
    echo "Health status: !!! NOT OK !!! - Adapter instance ${healthcheck_instance} is not alive."
    exit 1
  fi
  echo "Health status: OK - Main process and adapter instance ${healthcheck_instance} are running."
  exit 0
fi

echo "Health status: OK - Main process (js-controller) is running."
exit 0
