FROM golang:alpine as builder

RUN apk add -U --no-cache ca-certificates git build-base make gcc musl-dev linux-headers

RUN go get github.com/TeamEGEM/go-egem
RUN cd /go/src/github.com/TeamEGEM/go-egem && make


FROM alpine:latest
MAINTAINER Zibastian <Discord: @zibastian>

COPY --from=builder /go/src/github.com/TeamEGEM/go-egem/build/bin/egem /usr/bin/

RUN apk add -U --no-cache nodejs npm git curl su-exec
RUN npm install -g pm2

RUN mkdir -p /opt/live-net/egem \
	&& curl -o /opt/live-net/egem/static-nodes.json https://raw.githubusercontent.com/TeamEGEM/EGEM-Bootnodes/master/static-nodes.json

ARG usr=egem
RUN addgroup -g 900 ${usr} && \
    adduser -D -u 900 -G ${usr} -h /home/${usr} ${usr} \
	&& mkdir -p /home/${usr} \
	&& chmod 700 /home/${usr} \
	&& chown -R ${usr}:${usr} /home/${usr}
	
RUN chown -R ${usr}:${usr} /opt

RUN su-exec ${usr} git clone https://github.com/TeamEGEM/egem-net-intelligence-api.git /opt/egem-net-intelligence-api
RUN cd /opt/egem-net-intelligence-api && su-exec ${usr} npm install

COPY ./docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]

USER ${usr}

WORKDIR /opt

#EXPOSE 8545/tcp
#EXPOSE 30661/tcp
EXPOSE 30666/tcp
