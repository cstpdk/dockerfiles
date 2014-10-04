FROM dockerfile/haproxy

ADD https://github.com/kelseyhightower/confd/releases/download/v0.5.0/confd-0.5.0-linux-amd64 /usr/local/bin/confd
RUN chmod u+x /usr/local/bin/confd

ADD run.sh /run.sh

ENTRYPOINT ["/run.sh"]
