dirs := $(shell find -maxdepth 1 -type d -not -path "." -and -not -path "./.*" -printf '%P\n')

.PHONY: $(dirs) all

$(dirs):
	docker build -t cstpdk/$@ $@

all: $(dirs)
