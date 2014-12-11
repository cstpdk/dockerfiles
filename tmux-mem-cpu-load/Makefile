.PHONY: build

default: build

build: .built

.built: .
	docker build -t `basename $(shell pwd)` .
	touch .built
