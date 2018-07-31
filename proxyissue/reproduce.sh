#!/bin/bash


function ctrl_c() {
  echo "Killing the Proxy and Backend jobs..."
  jobs -p | xargs kill
  exit
}

trap ctrl_c INT

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout tls.key -out tls.crt -subj '/CN=localhost.invalid/O=foo/C=XX'

echo "Building the Backend..."
go build -o backend ../examples/helloworld/greeter_server/main.go
echo "Building the Pwoxy..."
go build -o revproxy revproxy.go
echo "Building the Client..."
go build -o client ../examples/helloworld/greeter_client/main.go

./backend &
./revproxy &

echo
echo "With Go client everything works, In separate terminal run:"
echo "  ./client :50051"
echo "  ./client :9009"
echo "But with grpc_cli it does not. To reproduce:"
echo "1. add '127.0.0.2 localhost.invalid' to /etc/hosts"
echo "2. Clone https://github.com/grpc/grpc.git"
echo "3. bazel build test/cpp/util/grpc_cli"
echo "GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=tls.crt (path-to-grpc-git-client)/bazel-bin/test/cpp/util/grpc_cli --enable_ssl ls dns:///localhost.invalid:9009"
echo "However, if you point it directly at the backend, everything works:"
echo "GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=tls.crt (path-to-grpc-git-client)/bazel-bin/test/cpp/util/grpc_cli --enable_ssl ls dns:///localhost.invalid:50051"
echo
echo "Press ^C here when done."
echo

while true; do read; done
