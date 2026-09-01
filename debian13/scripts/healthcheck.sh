#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Script checks that ioBroker is ready to serve requests.

health_status=$(cat /opt/.docker_config/.healthcheck 2>/dev/null || true)

if [ "$health_status" != "running" ]; then
  echo "Health status: NOT READY - Startup script has not completed."
  exit 1
fi

if pgrep -u iobroker -f 'iobroker.js-controller/controller.js' > /dev/null; then
  echo "Health status: OK - Main process (js-controller) is running."
  exit 0
fi

echo "Health status: !!! NOT OK !!! - Something went wrong. Please see container logs for more details and/or try restarting the container."
exit 1
