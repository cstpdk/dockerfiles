.PHONY: build run

default: build run

build: .built

.built: .
	docker build -t `basename $(shell pwd)` .
	touch .built

run:
	docker run -it -p 9200:9200 -p 9300:9300 -p 9292:9292 \
		-v `pwd`/elasticsearch.yml:/elasticsearch/config/elasticsearch.yml \
		`basename $(shell pwd)`
