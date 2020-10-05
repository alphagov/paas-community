
You may be better off trying https://github.com/SpringerPE/cf-grafana-buildpack.

Basic instructions for GOV.UK PaaS:

```
$ cf create-service postgres small-ha-11 grafana-db
[ wait until service create succeeded - see `cf service grafana-db` ]

$ cf push -f manifest.yml
```

Manually add Prometheus as a Data Source using Grafana's web UI.
