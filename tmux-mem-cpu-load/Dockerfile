FROM debian:testing

ENV VERSION 2.2.2

RUN apt-get update
RUN apt-get -y install cmake build-essential

ADD https://github.com/thewtex/tmux-mem-cpu-load/archive/v${VERSION}.tar.gz \
	tmux-mem-cpu-load-${VERSION}.tar.gz

RUN tar xvf tmux-mem-cpu-load-${VERSION}.tar.gz

WORKDIR /tmux-mem-cpu-load-${VERSION}

RUN cmake .
RUN make
RUN make install

ENTRYPOINT ["tmux-mem-cpu-load"]
