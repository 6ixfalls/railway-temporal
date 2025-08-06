ARG TEMPORAL_VERSION=1.28.1
FROM temporalio/auto-setup:$TEMPORAL_VERSION

USER root
RUN apk add --update --no-cache ack
USER temporal

COPY --chmod=777 ./railway.sh /etc/temporal/railway.sh

ENTRYPOINT ["/etc/temporal/railway.sh"]
CMD ["autosetup"]
