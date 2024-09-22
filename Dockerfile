FROM temporalio/auto-setup:1.25.0

USER root
RUN apk add --update --no-cache ack
USER temporal

COPY --chmod=777 ./railway.sh /etc/temporal/railway.sh

ENTRYPOINT ["/etc/temporal/railway.sh"]
CMD ["autosetup"]