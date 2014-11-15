FROM debian:stable

ADD https://github.com/coreos/fleet/releases/download/v0.8.3/fleet-v0.8.3-linux-amd64.tar.gz fleet.tar.gz

RUN tar -xvf fleet.tar.gz

RUN cp fleet-v0.8.3-linux-amd64/fleet* /usr/bin
