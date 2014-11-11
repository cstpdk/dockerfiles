FROM debian:stable

RUN apt-get update && apt-get -y install wget ruby

RUN wget --no-check-certificate https://s3.amazonaws.com/assets.heroku.com/heroku-client/heroku-client.tgz
RUN tar xvf heroku-client.tgz

RUN mkdir -p /usr/local/heroku
RUN mv heroku-client/* /usr/local/heroku

ENTRYPOINT ["/usr/local/heroku/bin/heroku"]
