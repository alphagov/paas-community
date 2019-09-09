# Alertmanager

[Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) is an
alert management and routing tool for Prometheus.

This creates a highly available cluster of Alertmanagers, that mesh with each
other.

## Requirements

- No backing service requirements

## Setup

## Push the apps

```
# Using the CF CLI version 7
$ cf push --var deployment=my-deployment-name
```

## Allow the applications to communicate with one another

```
$ cf add-network-policy alertmanager-0 --destination-app alertmanager-1 --port 9094
$ cf add-network-policy alertmanager-0 --destination-app alertmanager-2 --port 9094

$ cf add-network-policy alertmanager-1 --destination-app alertmanager-0 --port 9094
$ cf add-network-policy alertmanager-1 --destination-app alertmanager-2 --port 9094

$ cf add-network-policy alertmanager-2 --destination-app alertmanager-0 --port 9094
$ cf add-network-policy alertmanager-2 --destination-app alertmanager-1 --port 9094
```

## Authentication

This deployment puts Alertmanager unauthenticated on the public internet, this
is probably not desirable.

You should configure Alertmanager to:

- either be behind an authentication proxy
- or only be accessible internally

## Deployment

Either `v3-zdt-push` or `cf push --strategy=rolling` using the CF CLI version 7
should be used, in order for Alertmanagers to keep their meshing and network
policies intact.

## Further configuration

The `[manifest.yml](manifest.yml)` has an environment variable
`ALERTMANAGER_CONFIG` which contains the configuration used by alertmanager.
You should update this with any configuration you need.
