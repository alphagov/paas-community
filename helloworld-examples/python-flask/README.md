# Hello world app in python3 using flask and gunicorn 

A minimal [python] app using the [flask] [wsgi] framework that is deployed to [GOV.UK PaaS] to run in [gunicorn] using the [command line interface] and the [python buildpack]

- [`Procfile`](Procfile) tells the runtime how to start the application 
- [`hello.py`](hello.py) is the sample [python] application
  - emits logs using [Flask logging](https://flask.palletsprojects.com/en/1.1.x/logging/) in line with the [12 factor app logging guidance](https://12factor.net/logs)
- [`manifest.yml`](manifest.yml) provides runtime settings such as the application name, memory size 
- [`requirements.txt`](requirements.txt) contains the dependencies that are installed using [pip] and indicates that the [python buildpack] should be used
- [`runtime.txt`](runtime.txt) sets the specific [python] version to use

## Demo

[![](python-flask.gif)](https://asciinema.org/a/383080?speed=4&size=medium&autoplay=1)

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

[command line interface]: https://docs.cloud.service.gov.uk/get_started.html#set-up-the-cloud-foundry-command-line
[flask]:https://palletsprojects.com/p/flask/
[gettingstarted]: https://www.cloud.service.gov.uk/get-started/
[gunicorn]: https://gunicorn.org/
[homebrew]: https://brew.sh
[pip]: https://pip.pypa.io/en/stable/
[python]: https://docs.python.org/3/
[python buildpack]: https://docs.cloudfoundry.org/buildpacks/python/index.html
[wsgi]: https://wsgi.readthedocs.io/en/latest/
[GOV.UK PaaS]: https://docs.cloud.service.gov.uk
