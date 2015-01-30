FROM java:openjdk-8-jre

RUN apt-get update
RUN apt-get -y install wget mini-httpd

ENV ES_VERSION 1.4.0

RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz && \
	tar -xvf elasticsearch-${ES_VERSION}.tar.gz && \
	rm elasticsearch-${ES_VERSION}.tar.gz && \
	mv /elasticsearch-${ES_VERSION} /elasticsearch

ENV KIBANA_VERSION 3.1.2

RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}.tar.gz && \
	tar -xvf kibana-${KIBANA_VERSION}.tar.gz && \
	rm kibana-${KIBANA_VERSION}.tar.gz && \
	mv /kibana-${KIBANA_VERSION} /kibana

# HTTP
EXPOSE 9200 9292

ADD elasticsearch.yml /elasticsearch/config/elasticsearch.yml

CMD /elasticsearch/bin/elasticsearch -Des.logger.level=OFF & mini-httpd -d /kibana -h 0.0.0.0 -r -D -p 9292
