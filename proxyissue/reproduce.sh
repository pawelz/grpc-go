#!/bin/bash


function ctrl_c() {
  echo "Killing the Proxy and Backend jobs..."
  jobs -p | xargs kill
  exit
}

trap ctrl_c INT

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout tls.key -out tls.crt -subj '/CN=localhost.invalid/O=foo/C=XX'

go build -o backend ../examples/helloworld/greeter_server/main.go
go build -o revproxy revproxy.go

./backend &
./revproxy &

read
