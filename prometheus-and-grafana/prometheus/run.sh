#!/usr/bin/env bash

set -e

# Go get Prometheus
wget -q https://github.com/prometheus/prometheus/releases/download/v2.16.0/prometheus-2.16.0.linux-amd64.tar.gz
tar xzf prometheus-2.16.0.linux-amd64.tar.gz
chmod +x ./prometheus-2.16.0.linux-amd64/prometheus

# Go get YQ
wget -q https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64
YQ="./yq_linux_amd64"
chmod +x $YQ

echo "${VCAP_SERVICES}" \
  | $YQ -P read - "influxdb[0].credentials.prometheus" \
  > /home/vcap/app/influx-prometheus-config.yml

# Interpolate the variables in to the config file
cat /home/vcap/app/prometheus-config.template.yml \
  | $YQ write - "scrape_configs.(job_name == govuk_paas_redis).basic_auth.username" "${PAAS_READONLY_USERNAME}" \
  | $YQ write - "scrape_configs.(job_name == govuk_paas_redis).basic_auth.password" "${PAAS_READONLY_PASSWORD}" \
  > /home/vcap/app/authed-prometheus-config.yml

$YQ -P merge \
  /home/vcap/app/influx-prometheus-config.yml \
  /home/vcap/app/authed-prometheus-config.yml \
  > /home/vcap/app/prometheus-config.yml

cat /home/vcap/app/prometheus-config.yml

# Run Promtheus with the config file
./prometheus-2.16.0.linux-amd64/prometheus \
  --config.file=prometheus-config.yml \
  --web.listen-address="0.0.0.0:${PORT}"
