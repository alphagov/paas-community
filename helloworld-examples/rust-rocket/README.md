# Hello world app in rust and rocket 

A minimal [rust] app using the [rocket] framework that is deployed to [GOV.UK PaaS] using the [command line interface] and the [rust buildpack]

- [`Procfile`](Procfile) tells the runtime how to start the application 
- [`main.rs`](src/main.rs) is the sample [rust] application
  - emits logs using [rust logging] in line with the [12 factor app logging guidance](https://12factor.net/logs)
- [`manifest.yml`](manifest.yml) provides runtime settings such as the application name, memory size 
- [`Cargo.toml`](Cargo.toml) contains the dependencies that are installed using [cargo] and indicates that the [rust buildpack] should be used


## Demo

[![](rust-rocket.gif)](https://asciinema.org/a/XXXXXXXX?speed=4&size=medium&autoplay=1)

## Commands

install rust using [rustup]
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

switch to nightly 
```
rustup default nightly
```

compile and run the app locally
```
cargo run &
```

test the app
```
curl -v http://localhost:8000
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
cf push hello-rust-rocket
```

check the app is running
```
cf a
```

test the app
```
curl https://<APP NAME>.cloudapps.digital
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

[cargo]: https://doc.rust-lang.org/cargo/getting-started/installation.html
[command line interface]: https://docs.cloud.service.gov.uk/get_started.html#set-up-the-cloud-foundry-command-line
[gettingstarted]: https://www.cloud.service.gov.uk/get-started/
[GOV.UK PaaS]: https://docs.cloud.service.gov.uk
[homebrew]: https://brew.sh
[rocket]: https://rocket.rs/
[rust buildpack]: https://github.com/alphagov/cf-buildpack-rust
[rust logging]: https://docs.rs/log/0.4.11/log/
[rust]: https://www.rust-lang.org/
[rustup]: https://rustup.rs/
