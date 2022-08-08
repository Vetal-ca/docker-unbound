FROM alpine:3.16 as build
MAINTAINER "Vitali Khlebko vitali.khlebko@vetal.ca"

ARG UNBOUND_TAG=release-1.16.2

RUN apk update && apk add git g++ openssl-dev expat-dev libevent-dev make byacc


RUN cd /tmp &&\
    git clone https://github.com/NLnetLabs/unbound.git &&\
    cd unbound &&\
    git checkout ${UNBOUND_TAG} &&\
	./configure --sysconfdir /etc --localstatedir /var --with-libevent &&\
	make && make install

FROM alpine:3.16

COPY --from=build /usr/local/lib/pkgconfig/libunbound.pc /usr/local/lib/pkgconfig/libunbound.pc
COPY --from=build /usr/local/lib/libunbound.* /usr/local/lib/
COPY --from=build /usr/local/sbin/unbound* /usr/local/sbin/
COPY --from=build /usr/local/share/man/man3/ub_* /usr/local/share/man/man3/
COPY --from=build /usr/local/share/man/man3/libunbound.3 /usr/local/share/man/man3/libunbound.3
COPY --from=build /usr/local/share/man/man5/unbound.conf.5 /usr/local/share/man/man5/unbound.conf.5
COPY --from=build /usr/local/share/man/man8/unbound* /usr/local/share/man/man8/
COPY --from=build /usr/local/share/man/man1/unbound-host.1 /usr/local/share/man/man1/unbound-host.1

ENV PATH $PATH:/usr/local/lib
ADD assets/unbound.conf /etc/unbound/unbound.conf

RUN apk update && apk add openssl libevent expat &&\
	adduser -S unbound -h /home/unbound &&\
	mkdir /etc/unbound/conf.d &&\
	chown -R unbound: /etc/unbound/

#RUN ldconfig


USER unbound
RUN unbound-anchor -a /etc/unbound/root.key ; true
RUN unbound-control-setup \
	&& wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints

USER root


