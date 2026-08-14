ARG GOPROXY
ARG TEMPORAL_IMAGE=temporalio/server
ARG TEMPORAL_ADMIN_TOOLS_IMAGE=temporalio/admin-tools
# renovate: datasource=docker depName=temporalio/server
ARG TEMPORAL_VERSION=1.31.2
ARG TEMPORAL_FULL_IMAGE=${TEMPORAL_IMAGE}:${TEMPORAL_VERSION}
ARG TEMPORAL_FULL_ADMIN_TOOLS_IMAGE=${TEMPORAL_ADMIN_TOOLS_IMAGE}:${TEMPORAL_VERSION}

FROM ${TEMPORAL_FULL_ADMIN_TOOLS_IMAGE} as tools
FROM ${TEMPORAL_FULL_IMAGE} as server

COPY --from=tools --chmod=755 --chown=temporal:temporal \
    /usr/local/bin/temporal \
    /usr/local/bin/temporal-cassandra-tool \
    /usr/local/bin/temporal-sql-tool \
    /usr/local/bin/temporal-elasticsearch-tool \
    /usr/local/bin/tdbg \
    /usr/local/bin/

COPY --from=tools --chown=temporal:temporal /etc/temporal/schema /etc/temporal/schema

EXPOSE 7233

ENV BIND_ON_IP=::0
ENV DEFAULT_NAMESPACE=default

ENV DYNAMIC_CONFIG_FILE_PATH=/etc/temporal/config/dynamicconfig/docker.yaml
COPY ./dynamicconfig.yaml /etc/temporal/config/dynamicconfig/docker.yaml

COPY --chmod=755 ./setup.sh /etc/temporal/setup.sh