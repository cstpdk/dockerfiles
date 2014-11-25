FROM debian:testing

RUN apt-get update &&\
        apt-get -y -q install wget &&\
        mkdir /etc/hekad &&\
        mkdir /var/cache/hekad


ENV VERSION 0.8.0

RUN wget -nv -O /tmp/heka_amd64.deb https://github.com/mozilla-services/heka/releases/download/v${VERSION}/heka_${VERSION}_amd64.deb &&\
        dpkg -i /tmp/heka_amd64.deb &&\
        rm /tmp/heka_amd64.deb

ADD https://raw.githubusercontent.com/JustinJudd/heka/dev/sandbox/lua/encoders/influxdb.lua /usr/share/heka/lua_encoders/influxdb.lua

ENTRYPOINT ["/usr/bin/hekad"]
CMD ["-config=/etc/hekad/hekad.toml"]
