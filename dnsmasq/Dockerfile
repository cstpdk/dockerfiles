FROM debian:latest

RUN apt-get update -y
RUN apt-get install -y dnsmasq

ADD dnsmasq.conf /etc/dnsmasq.conf
ADD extra.conf /etc/dnsmasq.d/extra.conf

EXPOSE 53

CMD ["dnsmasq","-d"]
