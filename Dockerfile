FROM alpine
RUN sed -i "s|/v[0-9]*.[0-9]*/|/edge/|g" /etc/apk/repositories\
 && apk add --no-cache openssl

COPY run.sh /run.sh
CMD sh /run.sh
