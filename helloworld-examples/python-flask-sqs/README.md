# Hello world app in python3 using flask, gunicorn and SQS

A minimal [python] app using the [flask] [wsgi] framework and the [SQS backing service] that is deployed to [GOV.UK PaaS] to run in [gunicorn] using the [command line interface] and the [python buildpack]

- [`Procfile`](Procfile) tells the runtime how to start the application 
- [`hello.py`](hello.py) is the sample [python] application
  - emits logs using [Flask logging](https://flask.palletsprojects.com/en/1.1.x/logging/) in line with the [12 factor app logging guidance](https://12factor.net/logs)
- [`manifest.yml`](manifest.yml) provides runtime settings such as the application name, memory size 
- [`requirements.txt`](requirements.txt) contains the dependencies that are installed using [pip] and indicates that the [python buildpack] should be used
  - [boto3] - AWS SDK for python
  - [flask] - lightweight web framework for python
  - [gunicorn] - python wsgi http server
  - [pypopenssl] - openssl library 
- [`runtime.txt`](runtime.txt) sets the specific [python] version to use

## Demo

[![](python-flask-sqs.gif)](https://asciinema.org/a/XXXX?speed=4&size=medium&autoplay=1)

## Commands

install python3
```
brew install python3
```

create virtual environment and activate
```
python3 -m venv venv
. venv/bin/activate
```

install dependencies into virtual environment 
```
pip3 install -r requirements.txt
```

run the app locally using http
```
FLASK_APP=hello.py flask run --debugger --reload --host localhost --port 8080
```

run the app locally using https
```
FLASK_APP=hello.py flask run --debugger --reload --host localhost --port 8080 --cert=adhoc
```

run the app locally using gunicorn
```
gunicorn hello:app
```

install the Cloud Foundry CLI with [homebrew]

```
brew install cloudfoundry/tap/cf-cli
```

log into GOV.UK PaaS (assumes you have an account, see [gettingstarted])

```
cf login -a https://api.cloud.service.gov.uk --sso
```

deploy the app
```
cf t -o <YOUR_ORG> -s <YOUR_SPACE>
cf push
```

check the app is running
```
cf a
```

test the app
```
curl https://<APP NAME>.cloudapps.digital/hello
```

look at the logs
```
cf logs <APP NAME>
```

jump into the container

```
cf ssh <APP NAME>
```

scale the app
```
cf scale -i 3 <APP NAME>
```

stop the app
```
cf stop <APP NAME>
```

delete the app
```
cf delete <APP NAME>
```

[boto3]: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
[amazon_sqs_examples]: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/sqs-examples.html
[flask]: https://flask.palletsprojects.com/en/1.1.x/
[gunicorn]: https://docs.gunicorn.org/en/stable/
[pyopenssl]: https://www.pyopenssl.org/en/stable/
[GOV.UK PaaS]: https://docs.cloud.service.gov.uk
[SQS backing service](https://docs.cloud.service.gov.uk/deploying_services/sqs/)
[command line interface]: https://docs.cloud.service.gov.uk/get_started.html#set-up-the-cloud-foundry-command-line
[flask]:https://palletsprojects.com/p/flask/
[gettingstarted]: https://www.cloud.service.gov.uk/get-started/
[gunicorn]: https://gunicorn.org/
[homebrew]: https://brew.sh
[pip]: https://pip.pypa.io/en/stable/
[python buildpack]: https://docs.cloudfoundry.org/buildpacks/python/index.html
[python]: https://docs.python.org/3/
[wsgi]: https://wsgi.readthedocs.io/en/latest/
