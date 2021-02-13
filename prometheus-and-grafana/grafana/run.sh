#!/usr/bin/env bash

set -e

# Go get Grafana
wget https://dl.grafana.com/oss/release/grafana-7.2.0.linux-amd64.tar.gz
tar -zxvf grafana-7.2.0.linux-amd64.tar.gz

# Go get YQ
wget -q https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64
YQ="./yq_linux_amd64"
chmod +x $YQ

# All options in the configuration file can be overridden using environment variables using the syntax:
# GF_<SectionName>_<KeyName>
# Where the section name is the text within the brackets. Everything should be uppercase, . and - should be replaced by _.
# https://grafana.com/docs/grafana/latest/administration/configuration/?plcmt=footer
export GF_SERVER_HTTP_PORT="${PORT}"
export GF_DATABASE_TYPE=postgres
export GF_DATABASE_URL=$(echo "${VCAP_SERVICES}" | $YQ read - "postgres[0].credentials.uri")
export GF_DATABASE_SSL_MODE=require

cd grafana-7.2.0
./bin/grafana-server
