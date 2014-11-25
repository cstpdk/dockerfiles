.PHONY: build run

default: build run

build: .built

.built: .
	docker build -t cstpdk/heka .
	touch .built

run:
	./run
