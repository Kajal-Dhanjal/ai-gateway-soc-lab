#!/usr/bin/env bash
# Untested. Run line by line the first time.
# Steps from docs/02-wazuh.md. Assumes Docker is already installed.
set -euo pipefail

WAZUH_TAG="v4.14.10"

sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-wazuh-max-map-count.conf
sudo sysctl --system

git clone https://github.com/wazuh/wazuh-docker.git -b "$WAZUH_TAG"
cd wazuh-docker/single-node/

docker compose -f generate-indexer-certs.yml run --rm generator
docker compose up -d

echo "Started. Wait about a minute for the indexer, then change the default password."
