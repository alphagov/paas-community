# Hello world app in python3 using flask, gunicorn and SQS

A minimal [python] app using the [flask] [wsgi] framework and the [SQS backing service] that is deployed to [GOV.UK PaaS] to run in [gunicorn] using the [command line interface] and the [python buildpack]

- [`Procfile`](Procfile) tells the runtime how to start the application 
- [`hello.py`](hello.py) is the sample [python] application
  - emits logs using [Flask logging] in line with the [12 factor app logging guidance]
- [`manifest.yml`](manifest.yml) provides runtime settings such as the application name, memory size, the queue to bind 
- [`requirements.txt`](requirements.txt) contains the dependencies that are installed using [pip] and indicates that the [python buildpack] should be used
  - [boto3] - AWS SDK for python
  - [cfenv] - utility to handle VCAP_SERVICES
  - [flake8] - python linter
  - [flask] - lightweight web framework for python
  - [gunicorn] - python wsgi http server
  - [pip] - python package installer
  - [pyopenssl] - openssl library 
- [`runtime.txt`](runtime.txt) sets the specific [python] version to use

## Demo

[![](python-flask-sqs.gif)](https://asciinema.org/a/387179?speed=2&size=medium&autoplay=1)

## Commands

install the Cloud Foundry CLI with [homebrew]

```
brew install cloudfoundry/tap/cf-cli
```

log into GOV.UK PaaS (assumes you have an account, see [gettingstarted])

```
cf login -a https://api.lomndon.cloud.service.gov.uk --sso
```

target org / space

```
cf target -o <ORG> -s <SPACE>
```

check apps
```
cf apps
```


create a queue
```
cf create-service aws-sqs-queue standard hello-standard
```

check for completion 
```
watch cf services
```

check the queue
```
cf service hello-standard
```

deploy the app
```
cf push
```

check the app is running
```
cf apps
```

check the app is bound to the queue
```
cf service hello-standard
```

test the app
```
curl -L https://<APP NAME>.cloudapps.digital/hello
```

send a message
```
curl -vL https://<APP NAME>.cloudapps.digital/send | jq .
```

receive a message
```
curl -vL https://<APP NAME>.cloudapps.digital/receive | jq .
```

look at the logs
```
cf logs hello-python-flask-sqs
```

jump into the container

```
cf ssh hello-python-flask-sqs
```

scale the app
```
cf scale -i 3 hello-python-flask-sqs
```

stop the app
```
cf stop hello-python-flask-sqs
```

unbind the service
```
cf unbind-service hello-python-flask-sqs hello-standard
```

delete the app
```
cf delete -f hello-python-flask-sqs
```

[12 factor app logging guidance]: https://12factor.net/logs
[amazon_sqs_examples]: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/sqs-examples.html
[boto3]: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
[cfenv]: https://github.com/jmcarp/py-cfenv
[command line interface]: https://docs.cloud.service.gov.uk/get_started.html#set-up-the-cloud-foundry-command-line
[flake8]: https://flake8.pycqa.org/en/latest/index.html
[Flask logging]: (https://flask.palletsprojects.com/en/1.1.x/logging/)
[flask]: https://flask.palletsprojects.com/en/1.1.x/
[flask]:https://palletsprojects.com/p/flask/
[gettingstarted]: https://www.cloud.service.gov.uk/get-started/
[GOV.UK PaaS]: https://docs.cloud.service.gov.uk
[gunicorn]: https://docs.gunicorn.org/en/stable/
[gunicorn]: https://gunicorn.org/
[homebrew]: https://brew.sh
[pip]: https://pip.pypa.io/en/stable/
[pyopenssl]: https://www.pyopenssl.org/en/stable/
[python buildpack]: https://docs.cloudfoundry.org/buildpacks/python/index.html
[python]: https://docs.python.org/3/
[SQS backing service]: https://docs.cloud.service.gov.uk/deploying_services/sqs/
[wsgi]: https://wsgi.readthedocs.io/en/latest/
