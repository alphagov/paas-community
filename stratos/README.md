Stratos
=======

[Stratos](https://github.com/cloudfoundry/stratos) is an Open Source Web-based
UI (Console) for managing Cloud Foundry. It allows users and administrators to
both manage applications running in the Cloud Foundry cluster and perform
cluster management tasks.

This example includes the stratos source as a git submodule, and a manifest
file to deploy it to cloud foundry. The code is designed to be compatible with
GOV.UK PaaS.

Initial deployment
------------------

First make sure you've downloaded the stratos submodule:

```
git submodule init && git submodule update
```

Pre-build the stratos frontend:

```
cd stratos
npm install
npm run prebuild-ui
```

GOV.UK PaaS recommend using single sign-on (SSO) to authenticate whenever
possible. To enable SSO for stratos you'll need some client credentials.

Contact GOV.UK PaaS support to request client credentials and let them know the
URL you plan on running Stratos on (e.g. `https://my-stratos.london.cloudapps.digital`).

They should create a client with configuration like the following:

```
- type: replace
  path: /instance_groups/name=uaa/jobs/name=uaa/properties/uaa/clients/some-stratos-deployment?
  value:
    scope: openid,cloud_controller.read,cloud_controller.write
    authorized-grant-types: refresh_token,authorization_code
    redirect-uri: https://some-stratos-deployment.((app_domain))/pp/v1/auth/sso_login_callback
    override: true
    secret: ((secrets_uaa_clients_stratos_secret))
```

Using at least [V7 of the CF CLI](https://docs.cloudfoundry.org/cf-cli/v7.html)
(which we assume will be aliased to `cf7` here):

```
cf7 push stratos \
  --var cf_client=my-cf-client \
  --var cf_client_secret=my-cf-client-secret \
  --var session_store_secret="$(head -c 24 /dev/urandom | base64)" \
  --var route=my-stratos.london.cloudapps.digital
```

Subesequent deployments
-----------------------

Once the application is deployed for the first time you can push changes to the
stratos submodule without downtime and without having to specify the secret variables:

```
cf7 push stratos --no-manifest --path ./stratos --strategy rolling
```

If you need to update the manifest you can omit the `--no-manifest` flag, but
you'll be asked to provide the secrets again.

Limitations
-----------

* Production stratos deployments should have a separate database for persistence, see [the Stratos documentation on associating a database service](https://github.com/cloudfoundry/stratos/blob/master/deploy/cloud-foundry/db-migration/README.md)

