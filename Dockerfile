FROM golang:alpine AS runc

# install packages, and build runc and img from source
RUN apk add --no-cache git make bash build-base linux-headers libseccomp-dev && \
    mkdir -p $GOPATH/src/github.com/opencontainers && \
    cd $GOPATH/src/github.com/opencontainers && \
    git clone --depth 1 --single-branch --branch v1.0.0-rc5 https://github.com/opencontainers/runc && \
    cd runc && \
    make static && \
    mkdir -p $GOPATH/src/github.com/genuinetools && \
    cd $GOPATH/src/github.com/genuinetools && \
    git clone https://github.com/genuinetools/img img && \
    cd img && \
    make BUILDTAGS="seccomp noembed" && \
    make static

FROM quay.io/10thmagnitude/aks-vsts-agent:0.1

COPY --from=runc /go/src/github.com/opencontainers/runc/runc /usr/bin/runc
COPY --from=runc /go/src/github.com/genuinetools/img/img /usr/bin/img
