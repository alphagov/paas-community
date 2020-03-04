# PgAdmin 4 on GOV.UK PaaS
This quick start/incubator project can be used to deploy [PgAdmin 4](https://www.pgadmin.org/)
on [GOV.UK PaaS](https://www.cloud.service.gov.uk/). It will detect any bound Postgres databases,
and connect to them automatically.


## Getting started
Clone this repository, and push it to your target space with the following password.
Org and space names are required in order to create a unique, predictable route
for the app.

The resulting hostname will be in the form `org-space-pgadmin.london.cloudapps.digital`.

```
cf push \
  --var org="${YOUR_ORG}"
  --var space="${YOUR_SPACE}"
  --var email=emailto_log_in_with \
  --var password=password_to_log_in_with
```

When the app has been pushed, bind any Postgres backing service instances you want access to

```
cf bind-service pgadmin mypostgres-1
cf bind-service pgadmin mypostgres-2
```

After binding, restage the app.

```
cf restage pgadmin
```
