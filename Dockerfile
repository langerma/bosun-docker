FROM golang:1.8-alpine
MAINTAINER "Markus Langer <langer.markus@gmail.com>"

RUN adduser -S bosun
# net.Dial doesn't respect /etc/hosts by default
ENV GODEBUG netdns=cgo
RUN mkdir -p /var/cache/bosun && chown bosun /var/cache/bosun


ENV BOSUN_REPO https://github.com/bosun-monitor/bosun.git
ENV BOSUN_TAG master

RUN apk update && apk add git
RUN go get -d bosun.org/cmd/bosun && \
    cd /go/src/bosun.org && \
    git remote set-url origin ${BOSUN_REPO} && \
    git fetch && \
    git checkout ${BOSUN_TAG}
RUN cd /go/src/bosun.org/cmd/bosun && \
    go build && \
    go install

USER bosun
WORKDIR /var/cache/bosun/
VOLUME /var/cache/bosun/
EXPOSE 8070
ENTRYPOINT ["/go/bin/bosun", "-c", "/etc/bosun.conf"]

ADD bosun.toml /etc/bosun.toml
ADD rules.conf /etc/rules.conf
