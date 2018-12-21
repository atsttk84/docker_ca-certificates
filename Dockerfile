FROM alpine:latest
RUN apk add --no-cache openssl perl

VOLUME /mnt
WORKDIR /mnt
CMD sh /mnt/run.sh
