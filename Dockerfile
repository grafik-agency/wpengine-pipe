FROM alpine:3.9

RUN apk add --update --no-cache bash

COPY pipe /

ENTRYPOINT ["/pipe.sh"]
