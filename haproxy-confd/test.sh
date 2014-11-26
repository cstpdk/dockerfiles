#!/bin/bash

#set -e

#docker build -t discoverer .
docker rm -f etcd || true &>/dev/null
docker rm -f discoverer || true &>/dev/null

docker run -d -p 4001:4001 --name etcd quay.io/coreos/etcd:v0.4.6

sleep 3 # Yeah

etcdctl() {
	docker run --net=host --entrypoint /etcdctl quay.io/coreos/etcd:v0.5.0_alpha.0 "$@"
}

check(){
	if [[ "$1" != "$2" ]] ; then
		echo -e "Wrong test output\n"
		echo -e "Was:\n$1"
		echo -e "Wanted:\n$2"
		exit 1
	else
		echo -e "\nOk\n"
	fi
}

docker run -d \
	--net=host --name discoverer \
	-v `pwd`/haproxy.cfg:/etc/confd/templates/haproxy.cfg \
	-v `pwd`/keys:/keys \
	haproxy-confd \
	-interval 5

sleep 3 # yeah

# Setup
etcdctl mkdir /services
etcdctl mkdir /config

# Happy path
etcdctl set services/srv1/scheme http
etcdctl set services/srv1/host_port 3000
etcdctl set services/srv1/hosts/1 curlmyip.com:80

# Missing hosts
etcdctl set services/srv2/scheme http

# Missing hosts and scheme!!!
etcdctl mkdir services/srv3

# Missing scheme
etcdctl set services/srv4/hosts/1 curlmyip.com:80

expected=$(curl -s "curlmyip.com:80")
error_503="$(curl -s 'localhost/bogusogusogus')"

actual=$(curl -s localhost:3000)
check "$actual" "$expected"

actual=$(curl -s localhost/srv1)
check "$actual" "$expected"

actual=$(curl -s --resolve 'srv1.local:80:127.0.0.1' http://srv1.local)
check "$actual" "$expected"

actual=$(curl -s localhost/srv2)
check "$actual" "$error_503"

# SSL
etcdctl set /config/services/ssl_support true

etcdctl set /services/srv5/scheme https
etcdctl set /services/srv5/hosts/1 curlmyip.com:80

sleep 3

# Happy path
actual=$(curl --resolve 'srv5.local:443:127.0.0.1' --insecure -s https://srv5.local)
check "$actual" "$expected"

# Redirect non-https to https ... Btw curl is magic <3
actual=$(curl --resolve 'srv5.local:80:127.0.0.1' \
	-s -L -w "%{http_code} %{url_effective}\\n" http://srv5.local)

check "$actual" "301 https://srv5.local/"
