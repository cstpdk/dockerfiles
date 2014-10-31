#docker build -t discoverer .
docker rm -f etcd || true &>/dev/null
docker rm -f discoverer || true &>/dev/null

docker run -d -p 4001:4001 -p 7001:7001 --name etcd \
	coreos/etcd \
	-discovery `curl -s https://discovery.etcd.io/new` -addr etcd:4001

sleep 3 # Yeah

curl="docker run --link etcd:etcd speg03/curl -s -L -w '\n'"
etcd="etcd"

$curl -XPUT "http://$etcd:4001/v2/keys/services" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv1" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv1/hosts" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv1/scheme" -d value=http

$curl -XPUT "http://$etcd:4001/v2/keys/services/srv1/host_port" -d value=3000
$curl -XPOST "http://$etcd:4001/v2/keys/services/srv1/hosts" -d value="curlmyip.com:80"

$curl -XPUT "http://$etcd:4001/v2/keys/services/srv2" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv2/hosts" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv2/scheme" -d value=http

$curl -XPUT "http://$etcd:4001/v2/keys/services/srv2/host_port" -d value=3001
$curl -XPOST "http://$etcd:4001/v2/keys/services/srv2/hosts" -d value="curlmyip.com:80"

$curl -XPUT "http://$etcd:4001/v2/keys/services/srv3" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv3/hosts" -d dir=true
$curl -XPUT "http://$etcd:4001/v2/keys/services/srv3/scheme" -d value=tcp

$curl -XPOST "http://$etcd:4001/v2/keys/services/srv3/hosts" -d value="curlmyip.com:80"


docker run --link etcd:etcd -d \
	-p 3000:3000 -p 80:80 -p 443:443 \
	--name discoverer \
        --entrypoint bash \
        -v `pwd`/haproxy.cfg:/etc/confd/templates/haproxy.cfg \
	-v `pwd`/keys:/keys \
	discoverer \
	-c '/start -interval 2 -verbose -debug -node=$ETCD_PORT_4001_TCP_ADDR:$ETCD_PORT_4001_TCP_PORT'

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

actual=$(curl -s localhost)
check "$actual" "$expected"

actual=$(curl -s localhost/srv1)
check "$actual" "$expected"
