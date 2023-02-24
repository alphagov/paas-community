# Nginx 301

[Nginx](https://nginx.org/en/) is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server

The configuration within this repo is designed to enable [301 redirects](https://http.cat/301) for services that have moved domains permanently from GOV.UK PaaS.

To deploy this app

```
cf unmap-route OLD_APP_NAME cloudapps.digital --hostname HOSTNAME-TO-BE-REDIRECTED
```
Where OLD_APP_NAME is the name of the application that now exists on a new host

```
cf push --var new-domain=MY-NEW-DOMAIN -d cloudapps.digital --hostname HOSTNAME-TO-BE-REDIRECTED
```

Verify your redirect with

```
curl -L -I HOSTNAME-TO-BE-REDIRECTED.cloudapps.digital
```
