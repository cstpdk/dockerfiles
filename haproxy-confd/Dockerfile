FROM dockerfile/haproxy

ADD confd-0.6.0-linux-amd64 /usr/local/bin/confd
RUN chmod u+x /usr/local/bin/confd

ADD configuration.toml /etc/confd/conf.d/configuration.toml
ADD haproxy.cfg /etc/confd/templates/haproxy.cfg

ENTRYPOINT ["confd"]
