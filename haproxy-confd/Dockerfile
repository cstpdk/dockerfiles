FROM dockerfile/haproxy

ADD https://github.com/kelseyhightower/confd/releases/download/v0.6.0-beta1/confd-0.6.0-beta1-linux-amd64 /usr/local/bin/confd
RUN chmod u+x /usr/local/bin/confd

ADD configuration.toml /etc/confd/conf.d/configuration.toml
ADD haproxy.cfg /etc/confd/templates/haproxy.cfg

ADD start /start

ENTRYPOINT ["/start"]
