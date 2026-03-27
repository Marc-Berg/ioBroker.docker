#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Reading ENV
set +u
packages=$PACKAGES
debug=$DEBUG
set -u

export DEBIAN_FRONTEND=noninteractive

check_package_preq() {
  local pkg="$1"
  # check for influx packages — adds external repo, no apt-get update here (done once before install)
  if [[ "$pkg" == "influxdb" || "$pkg" == "influxdb2-cli" ]]; then
    wget -qO- https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor | tee /usr/share/keyrings/influxdata-archive.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main" | tee /etc/apt/sources.list.d/influxdata.list
  fi
}

check_package_validity() {
  # normalize whitespace
  packages=$(echo "$packages" | tr -s ' ' | xargs)
  # remove packages when "influxdb" AND "influxdb2-cli"
  if echo "$packages" | grep -qw "influxdb" && echo "$packages" | grep -qw "influxdb2-cli"; then
    echo "PACKAGES includes influxdb AND influxdb2-cli."
    echo "As installing both packages together is not possible, they will be skipped."
    packages=$(echo "$packages" | sed 's/\binfluxdb2-cli\b//g;s/\binfluxdb\b//g' | tr -s ' ' | xargs)
    if [[ $debug == "true" ]]; then echo "[DEBUG] New list of packages: $packages"; fi
    echo " "
  fi
}

if [[ "$1" == "-install" ]]; then
  echo " "
  check_package_validity
  # Run pre-reqs (e.g. adding external repos) and collect package list
  for i in $packages; do
    check_package_preq "$i" >> /opt/scripts/setup_packages.log 2>&1
  done
  # Install all packages in a single call
  echo -n "Installing packages ($packages)... "
  apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  if ! apt-get -q -y --no-install-recommends install $packages >> /opt/scripts/setup_packages.log 2>&1; then
    echo "Failed."
    echo "For more details see \"/opt/scripts/setup_packages.log\"."
  else
    echo "Done."
  fi
elif [[ "$1" == "-update" ]]; then
  echo -n "PACKAGES_UPDATE is set. Updating Linux packages on first run... "
  apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  return1=$?
  apt-get -q -y upgrade >> /opt/scripts/setup_packages.log 2>&1
  return2=$?
  if [[ "$return1" -ne 0 || "$return2" -ne 0 ]]; then
    echo "Failed."
    echo "For more details see \"/opt/scripts/setup_packages.log\"."
    echo "Make sure the container has internet access to get the latest package updates."
    echo "This has no impact to the setup process. The script will continue."
  else
    echo "Done."
  fi
else
  echo "No parameter found!"
  exit 1
fi

# Silent Cleanup
apt-get -qq autoclean -y && apt-get -qq autoremove && apt-get -qq clean
rm -rf /tmp/* /var/tmp/* /root/.cache/* /var/lib/apt/lists/* || true

exit 0
