# TheHive

[TheHive project](https://thehive-project.org/) is an open-source incident management platform.
[Cortex](https://github.com/TheHive-Project/Cortex) is an engine for analysis of indicators of compromise that can work independently or from within TheHive.

This creates both apps that are able to communicate with each other over REST API.

## Requirements

  - TheHive docker image (we used version 3.4.0)
  - Elasticsearch backing service (small-ha-6.x)
  - Cortex docker image (we tested 3.0.0)

## Setup

We failed to use Elasticsearch directly with TheHive as colons in Elasticsearch URI made TheHive think we are trying to push IPv6 address to it and it returned error.

Instead, we deployed Elasticsearch as a private app on the apps.internal domain and deployed HAproxy as a proxy for Elasticsearch to communicate with TheHive using basic authentication.

### Create Elasticsearch instance:
```
$ cf create-service elasticsearch small-ha-6.x elastic-for-hive
```

Wait for the service to provision before continuing. The status of the provisioning can be checked with:
```
$ cf services
```

We specify the route from HAproxy to the internal app and the command to pass to TheHive on startup in the manifest.yml file.

The first time you run this you will not have created API key for the Cortex as this needs to be done in the web interface once the app is running. Push the manifest file without the `--cortex-key ((cortex-key))` command first.

### Push both the private and public apps:

```
$ cf push --vars-file /PATH/vars.yml
```

Where vars.yml is your own environmental variables file as needed. Cortex default REST API port is 9001.

### Bind TheHive and Cortex to internal applications:
```
$ cf add-network-policy <<thehive-instance-name>> --destination-app <<es-instance-name>> --protocol tcp --port 9300
```

```
$ cf add-network-policy <<cortex-instance-name>> --destination-app <<es-instance-name>> --protocol tcp --port 9400
```

## Configuration
After the initial setup, when TheHive first loads you need to click on "update database". This prompts you to create admin password and then login.

The same needs to be done for Cortex. After you've logged on for the first time as superadmin, you can create a user for integration with TheHive (needs read and analyze roles) and a corresponding API key. Add the API key to your vars.yml and `--cortex-key ((cortex-key))` back to the manifest.yml file and run this again:

```
$ cf push --vars-file /PATH/vars.yml
```

After logging into TheHive again you should be able to see a little brain icon in the bottom right corner light up green and say "Cortex integration enabled".
