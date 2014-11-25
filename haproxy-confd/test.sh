#!/bin/bash

set -e

#docker build -t discoverer .
docker rm -f etcd || true &>/dev/null
docker rm -f discoverer || true &>/dev/null

docker run -d -p 4001:4001 --name etcd quay.io/coreos/etcd:v0.4.6

sleep 3 # Yeah

etcdctl() {
	docker run --net=host --entrypoint /etcdctl quay.io/coreos/etcd:v0.5.0_alpha.0 "$@"
}

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

docker run -d \
	-p 3000:3000 -p 80:80 -p 443:443 \
	--net=host --name discoverer \
	-v `pwd`/haproxy.cfg:/etc/confd/templates/haproxy.cfg \
	-v `pwd`/keys:/keys \
	--entrypoint bash \
	haproxy-confd \
	-c 'confd -interval 1 -verbose -debug'

sleep 3 # yeah

docker cp discoverer:/etc/haproxy/haproxy.cfg from_container
cat from_container/haproxy.cfg

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

expected=$(curl -s "curlmyip.com:80")
error_503="$(curl -s 'localhost/bogusogusogus')"

actual=$(curl -s localhost:3000)
check "$actual" "$expected"

actual=$(curl -s localhost/srv1)
check "$actual" "$expected"

actual=$(curl -s localhost/srv2)
check "$actual" "$error_503"
