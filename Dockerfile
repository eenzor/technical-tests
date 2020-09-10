### base image to cache apk updates and the go modules

FROM golang:alpine as base

ENV GO111MODULE=on

RUN apk update --no-cache

RUN apk add git

WORKDIR /app

COPY go.mod .

COPY go.sum .

RUN go mod download

### build image with build deps

FROM base as build

WORKDIR /app

ADD ./ /app

RUN CGO_ENABLED=0 go build -ldflags "-s -w" -a -o golang-test .

### run image with only the binary

FROM scratch

COPY --from=build /app/golang-test /app/golang-test

ENTRYPOINT ["/app/golang-test"]

EXPOSE 8000
