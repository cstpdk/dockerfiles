# elasticsearch-kibana

Instance of elasticsearch and kibana in one container.

Example run:

```bash
docker run -it -p 9200:9200 -p 9300:9300 -p 9292:9292 \
	-v `pwd`/elasticsearch.yml:/elasticsearch/config/elasticsearch.yml \
	cstpdk/elasticsearch-kibana
