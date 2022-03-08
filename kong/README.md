# [Kong](https://getkong.org/) on Cloud Foundry


## How to deploy on [GOV.UK Platform-as-a-Service](https://www.cloud.service.gov.uk)

```
cf create-service postgres small-ha-13 kong-db
cf push your-kong
```

port `8080` is used for incoming HTTP traffic from your clients. You can access this endpoint via `https://your-kong.cloudapps.digital`.
port `8001` is used for the Admin API. You can access this endpoint with the following command.

```
cf ssh -N -T  -L localhost:8001:127.0.0.1:8001 your-kong
```

> If you use a database name which is different to `kong-db`, you need to change `services` in `manifest.yml`.


## Add a service

```
$ cf map-route your-kong cloudapps.digital -n example-api-kong
$ curl -i -X POST \
  -url http://localhost:8001/services/ \
  --data 'name=example-service' \
  --data 'url=http://httpbin.org'
  
HTTP/1.1 201 Created
Date: Fri, 14 Feb 2020 11:39:52 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.0.1
Content-Length: 296
X-Kong-Admin-Latency: 16

{"host":"httpbin.org","created_at":1581680392,"connect_timeout":60000,"id":"3ea10061-6651-459c-bb80-39d1b48e5b35","protocol":"http","name":"example-service","read_timeout":60000,"port":80,"path":null,"updated_at":1581680392,"retries":5,"write_timeout":60000,"tags":null,"client_certificate":null}
```

## Add a route to your service

```
curl -i -X POST -url http://localhost:8001/services/example-service/routes \
 --data 'hosts[]=example-api-kong.cloudapps.digital'

Enter host password for user 'rl':
HTTP/1.1 201 Created
Date: Fri, 14 Feb 2020 11:40:41 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.0.1
Content-Length: 473
X-Kong-Admin-Latency: 11

{"id":"3361cbba-d4da-4dca-95a4-0d6774c3bcfe","path_handling":"v0","paths":null,"destinations":null,"headers":null,"protocols":["http","https"],"methods":null,"snis":null,"service":{"id":"3ea10061-6651-459c-bb80-39d1b48e5b35"},"name":null,"strip_path":true,"preserve_host":false,"regex_priority":0,"updated_at":1581680441,"sources":null,"hosts":["example-api-kong.cloudapps.digital"],"https_redirect_status_code":426,"tags":null,"created_at":1581680441}

```

## verify your requests are going through Kong

Visit https://example-api-kong.cloudapps.digital in your browser or 

```
$ curl --head -X GET --url https://example-api-kong.cloudapps.digital
```

## Use Basic Authentication Plugin

### Enable plugin

```
curl -X POST http://localhost:8001/services/example-service/plugins/ --data 'name=key-auth'
```

### Verify that the plugin is installed

```
$ curl --head -X GET --url https://example-api-kong.cloudapps.digital

HTTP/2 401 
date: Fri, 14 Feb 2020 11:56:39 GMT
content-type: application/json; charset=utf-8
content-length: 41
server: kong/2.0.1
strict-transport-security: max-age=31536000; includeSubDomains; preload
www-authenticate: Key realm="kong"
x-kong-response-latency: 3
x-vcap-request-id: 5d84a2ee-b8e4-4c58-64fc-9705d59bbe65
```

### Add consumer

#### Add the user
```
$ curl -i -X POST \
  --url http://localhost:8001/consumers/ \
  --data "username=Kevin"

HTTP/1.1 201 Created
Date: Fri, 14 Feb 2020 11:57:54 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.0.1
Content-Length: 117
X-Kong-Admin-Latency: 7

{"custom_id":null,"created_at":1581681474,"id":"8a277ed3-f122-4638-a193-e23773a4838c","tags":null,"username":"Kevin"}
```

#### Provision key credentials

```
curl -i -X POST \
  --url http://localhost:8001/consumers/Kevin/key-auth/ \
  --data 'key=KEVIN_SECRET_KEY'

HTTP/1.1 201 Created
Date: Fri, 14 Feb 2020 11:59:52 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/2.0.1
Content-Length: 174
X-Kong-Admin-Latency: 6

{"created_at":1581681592,"consumer":{"id":"8a277ed3-f122-4638-a193-e23773a4838c"},"id":"ec5f288a-0cda-448a-9d8e-697a5de4588a","tags":null,"ttl":null,"key":"KEVIN_SECRET_KEY"}
```

### Verify that the auth works

```
$ curl --head -X GET --url https://example-api-kong.cloudapps.digital --header "apikey: KEVIN_SECRET_KEY"

HTTP/2 200 
date: Fri, 14 Feb 2020 12:01:43 GMT
content-type: text/html; charset=utf-8
content-length: 9593
access-control-allow-credentials: true
access-control-allow-origin: *
server: gunicorn/19.9.0
strict-transport-security: max-age=31536000; includeSubDomains; preload
via: kong/2.0.1
x-kong-proxy-latency: 25
x-kong-upstream-latency: 151
x-vcap-request-id: 18e98dad-ad35-4255-4e90-e113205e1279
```


[Full Kong Admin API reference](https://docs.konghq.com/2.0.x/admin-api/)
