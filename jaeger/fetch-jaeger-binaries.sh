#!/usr/bin/env bash
set -eu

echo "-----> Downloading jaeger binaries"
if ! [ -f jaeger-binaries.tgz ]; then
  curl --progress-bar -Lo jaeger-binaries.tgz https://github.com/jaegertracing/jaeger/releases/download/v1.17.1/jaeger-1.17.1-linux-amd64.tar.gz
else
  echo "=====> Already downloaded, skipping"
fi

echo "-----> Extracting binaries to subdirectories"
tar -xf jaeger-binaries.tgz --strip 1 --directory jaeger-all-in-one 'jaeger-*/jaeger-all-in-one'
tar -xf jaeger-binaries.tgz --strip 1 --directory example-app 'jaeger-*/example-hotrod'
