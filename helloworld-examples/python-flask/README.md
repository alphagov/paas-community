# Hello world app in flask/gunicorn/paas


A minimal flask app that is deployed to GOV.UK PaaS to run in gunicorn

install python
```
brew install python3
```

create virtual environment
```
python3 -m venv venv
. venv/bin/activate
```

install dependencies
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

install the CF7 CLI with homebrew

```
brew install cloudfoundry/tap/cf7-cli
```

log into paas

```
cf7 login -a https://api.cloud.service.gov.uk --sso
```

deploy the app
```
cf7 t -o <YOUR_ORG> -s <YOUR_SPACE>
cf7 push
```

check the app is running
```
cf7 a
```

test
```
curl https://<APP NAME>.cloudapps.digital/hello
```

look at the logs
```
cf7 logs <APP NAME>
```

jump into the container

```
cf7 ssh <APP NAME>
```

scale the app
```
cf7 scale -i 3 <APP NAME>
```

stop the app
```
cf7 stop <APP NAME>
```

delete the app
```
cf7 delete <APP NAME>
```