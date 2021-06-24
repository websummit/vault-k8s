FROM alpine:latest as builder

RUN apk add go build-base

ARG GOOS=linux

COPY . .

RUN apkArch="$(apk --print-arch)" && \
    case "${apkArch}" in \
        aarch64) ARCH='arm64' ;; \
        armhf) ARCH='arm' ;; \
        x86) ARCH='386' ;; \
        x86_64) ARCH='amd64' ;; \
        *) echo >&2 "error: unsupported architecture: ${apkArch} (see ${LOCATION}/${NAME}/${VERSION}/)" && exit 1 ;; \
    esac && \
    GO111MODULE=on CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -a -o vault-k8s .

FROM alpine:latest

RUN addgroup vault && \
    adduser -S -G vault vault

COPY --from=builder vault-k8s /vault-k8s

USER vault

ENTRYPOINT ["/vault-k8s"]
