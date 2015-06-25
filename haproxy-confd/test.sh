#!/bin/bash

#set -e

#docker build -t discoverer .
docker rm -f etcd || true &>/dev/null
docker rm -f discoverer || true &>/dev/null
docker rm -f echoserver || true &>/dev/null

docker run -d -p 4001:4001 --name etcd quay.io/coreos/etcd:v0.4.6

sleep 3 # Yeah

etcdctl() {
	docker run --net=host --entrypoint /etcdctl quay.io/coreos/etcd:v0.5.0_alpha.0 "$@"
}

check(){
	echo "Checking ""$3"
	if [[ "$1" != "$2" ]] ; then
		echo -e "Wrong test output\n"
		echo -e "Was:\n$1"
		echo -e "Wanted:\n$2"
		exit 1
	else
		echo -e "\nOk\n"
	fi
}

docker run -d --name echoserver -p 1234:1234 -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf nginx

docker run -d \
	--net=host --name discoverer \
	-v `pwd`/haproxy.cfg:/etc/confd/templates/haproxy.cfg \
	-v `pwd`/keys:/keys \
	haproxy-confd \
	-interval 1

sleep 2 # yeah

# Setup
etcdctl mkdir /services
etcdctl mkdir /config

# Happy path
etcdctl set services/srv1/scheme http
etcdctl set services/srv1/host_port 3000
etcdctl set services/srv1/hosts/1 localhost:1234

# Missing hosts
etcdctl set services/srv2/scheme http

# Missing hosts and scheme!!!
etcdctl mkdir services/srv3

# Missing scheme
etcdctl set services/srv4/hosts/1 localhost:1234

sleep 2

expected=$(curl -s "localhost:1234")
error_503="$(curl -s 'localhost/bogusogusogus')"

todo="curl -s localhost:3000"
actual=$($todo)
check "$actual" "$expected" "$todo"

todo="curl -s localhost/srv1"
actual=$($todo)
check "$actual" "$expected" "$(curl localhost:1234/srv1)"

check "$(curl -s --resolve 'srv1.local:80:127.0.0.1' http://srv1.local)" "$expected"

todo="curl -s localhost/srv2"
actual=$($todo)
check "$actual" "$error_503" "$todo"

# SSL
etcdctl set /config/services/ssl_support true

etcdctl set /services/srv5/scheme https
etcdctl set /services/srv5/hosts/1 localhost:1234

sleep 2

# Happy path
check "$(curl --resolve 'srv5.local:443:127.0.0.1' --insecure -s https://srv5.local)" "$expected"

# Redirect non-https to https ... Btw curl is magic <3
check "$(curl --resolve 'srv5.local:80:127.0.0.1' -s -L -w "%{http_code} %{url_effective}\\n" http://srv5.local)" "301 https://srv5.local/"

# Private service
etcdctl set /services/srv6/scheme http
etcdctl set /services/srv6/private true
etcdctl set /services/srv6/hosts/1 localhost:1234
etcdctl set /services/srv6/host_port 1338

sleep 2

todo="curl -s localhost/srv6"
actual=$($todo)
check "$actual" "$error_503" "$todo"

check "$(curl -s localhost:1338)" "$expected"

# Hybrid http/https

etcdctl set services/srv7/scheme http-and-https
etcdctl set services/srv7/hosts/1 localhost:1234

sleep 2

check "$(curl --resolve 'srv7.local:80:127.0.0.1' http://srv7.local)" \
	"$expected" "srv7.local:80"
check "$(curl --resolve 'srv7.local:443:127.0.0.1' --insecure \
	-s https://srv7.local)" "$expected" "srv7.local:443"
