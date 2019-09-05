# Sentry

[Sentry](https://www.sentry.io) is an open-source error tracking tool.

## Requirements

- A Postgres instance
- A Redis instance

## Setup

The plans chosen here are to minimise costs, rather than provide a highly
available setup.


Create Postgres instance

```
$ cf create-service postgres tiny-unencrypted-10 sentry-postgres
```

Create Redis instance

```
$ cf create-service redis tiny-3.2 sentry-redis`
```

## Push the app

```
# Using the CF CLI version 7
$ cf push --var deployment=my-deployment-name \
          --var sentry-secret=pick-a-random-string \
          --var github-app-id=github-oauth-client-id \
          --var github-api-secret=github-oauth-client-secret
```

## Configure Sentry

```
export deployment='my-deployment-name'

$ cf ssh ${deployment}-sentry -t -c -/tmp/lifecycle/launcher /home/vcap/app bash

# Ensure Sentry is setup
vcap@... $ sentry init

...

# We need to create the internal Sentry project
vcap@... $ sentry shell
python> from sentry.models import Project
...
python> from sentry.receivers.core import create_default_projects
...
python> create_default_projects([Project])
...
python> exit()

vcap@... $ exit

# Log in to Sentry
$ open "https://${deployment}-sentry.london.cloudapps.digital"
```

## Configure Sentry via the Web UI

After you've created the initial project, you need to set up an administrative
user, then configure GitHub OAuth (both via the Web UI).
