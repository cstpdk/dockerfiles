.PHONY: build

default: build test

build: .built

.built: .
	docker build -t `basename $(shell pwd)` .
	touch .built

test:
	./test.sh
