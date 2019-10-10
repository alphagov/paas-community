# TheHive

[TheHive project](https://thehive-project.org/) is an open-source incident management platform.

## Requirements

  - TheHive docker image (we used version 3.4.0)
  - Elasticsearch backing service (small-ha-6.x)

## Setup

We failed to use Elasticsearch directly with TheHive as colons in Elasticsearch URI made TheHive think we are trying to push IPv6 address to it and it returned error.

Instead, we deployed Elasticsearch as a private app on the apps.internal domain and deployed HAproxy as a proxy for Elasticsearch to communicate with TheHive using basic authentication.

### Create Elasticsearch instance:
```
cf create-service elasticsearch small-ha-6.x elastic-for-hive
```

Wait for the service to provision before continuing. The status of the provisioning can be checked with:
```
$ cf services
```

We specify the route from HAproxy to the internal app and the command to pass to TheHive on startup in the manifest.yml file.

### Push both the private and public apps:
```
cf push
```

### Bind TheHive to internal applications:
```
cf add-network-policy thehive --destination-app elasticsearch-proxy-for-hive --protocol tcp --port 9300
```

## Configuration
After the initial setup, when The Hive first loads you need to click on "update database". This prompts you to create admin password and then login.
