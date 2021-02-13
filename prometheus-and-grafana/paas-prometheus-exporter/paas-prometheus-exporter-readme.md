```
cf push --no-start paas-prometheus-exporter --random-route
cf set-env paas-prometheus-exporter API_ENDPOINT https://api.london.cloud.service.gov.uk
cf set-env paas-prometheus-exporter USERNAME miki.mokrysz+prometheus-endpoint-testing@digital.cabinet-office.gov.uk
cf set-env paas-prometheus-exporter PASSWORD ",JYZrE[eFo786wW/z8At"
cf start paas-prometheus-exporter
```
