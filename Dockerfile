FROM alpine:3.10 as build
MAINTAINER "Vitali Khlebko vitali.khlebko@vetal.ca"

ARG UNBOUND_TAG=release-1.9.5

RUN apk update && apk add git
 automake libtool texinfo gawk g++ autoconf pkgconfig readline-dev \
	make linux-headers

RUN cd /tmp &&\
    git clone https://github.com/NLnetLabs/unbound.git &&\
    cd unbound &&\
    git checkout ${UNBOUND_TAG}
	