FROM golang:1.11

ENV GOPATH="/go"
ENV COREDNS_VERSION=v1.2.4
ENV KUBERNETAI_VERSION=c8e14a7

WORKDIR /go/src/github.com/coredns/

RUN git clone https://github.com/coredns/kubernetai.git && \
	cd kubernetai && git checkout ${KUBERNETAI_VERSION}

RUN git clone https://github.com/coredns/coredns.git && \
	cd coredns && git checkout ${COREDNS_VERSION} && \
	echo "kubernetai:github.com/coredns/kubernetai/plugin/kubernetai" >> plugin.cfg && \
	make

# https://github.com/coredns/coredns/blob/master/Dockerfile
FROM debian:stable-slim

RUN apt-get update && apt-get -uy upgrade
RUN apt-get -y install ca-certificates && update-ca-certificates

FROM scratch

COPY --from=1 /etc/ssl/certs /etc/ssl/certs
COPY --from=0 /go/src/github.com/coredns/coredns/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
