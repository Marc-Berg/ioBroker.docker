#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Script checks health of running container.

health_status=$(cat /opt/.docker_config/.healthcheck 2>/dev/null || true)

if [ "$health_status" == "starting" ]; then
  echo "Health status: OK - Startup script is still running."
  exit 0
elif [ "$health_status" == "maintenance" ]; then
  echo "Health status: OK - Container is running in maintenance mode."
  exit 0
fi

if pgrep -u iobroker -f 'iobroker.js-controller' > /dev/null; then
  echo "Health status: OK - Main process (js-controller) is running."
  exit 0
fi

echo "Health status: !!! NOT OK !!! - Something went wrong. Please see container logs for more details and/or try restarting the container."
exit 1
