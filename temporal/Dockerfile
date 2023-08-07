FROM temporalio/auto-setup:1.21.3

ARG DB DB_PORT POSTGRES_USER POSTGRES_PWD POSTGRES_SEEDS

COPY sql.yaml /etc/temporal/config/dynamicconfig/sql.yaml

ENV DYNAMIC_CONFIG_FILE_PATH="config/dynamicconfig/sql.yaml"
# :: doesnt work due to some docker mapping things, might need to look into if 0.0.0.0 doesnt listen on ipv6 for private networking
ENV BIND_ON_IP="0.0.0.0"
ENV TEMPORAL_BROADCAST_ADDRESS="127.0.0.1"