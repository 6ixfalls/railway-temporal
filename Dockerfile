FROM temporaliotest/server:sha-cab0545

USER root
RUN apk add --update --no-cache ack
USER temporal

COPY --chmod=777 ./railway.sh /etc/temporal/railway.sh

ENTRYPOINT ["/etc/temporal/railway.sh"]