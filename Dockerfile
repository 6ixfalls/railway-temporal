FROM temporaliotest/server:sha-cab0545

RUN apk add --no-cache ack

COPY --chmod=777 ./railway.sh /etc/temporal/railway.sh

ENTRYPOINT ["/etc/temporal/railway.sh"]