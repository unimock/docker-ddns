FROM golang:1.10-alpine3.7 as builder

RUN apk update && apk upgrade && \
apk add --no-cache git

RUN mkdir -p /go/src
COPY rest-api /go/src/dyndns
RUN cd /go/src/dyndns && go get && go test -v

############################################################
FROM alpine:3.7

RUN apk update && apk upgrade && \
apk add --no-cache bind bind-tools bash supervisor

COPY named.conf.options /etc/bind/named.conf.options
COPY --from=builder /go/bin/dyndns /root/dyndns
RUN mkdir -p /var/cache/bind && chmod 770 /var/cache/bind
COPY setup.sh /root/setup.sh
RUN chmod +x /root/setup.sh

EXPOSE 53 8080
#                                                  -g
# supervisord
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor/
# startup script
COPY start.sh /root/start.sh
RUN chmod 755 /root/start.sh
CMD ["/root/start.sh"]
