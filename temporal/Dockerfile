FROM temporalio/auto-setup:1.21.3

ARG DB DB_PORT POSTGRES_USER POSTGRES_PWD POSTGRES_SEEDS

COPY sql.yaml /etc/temporal/config/dynamicconfig/sql.yaml

ENV DYNAMIC_CONFIG_FILE_PATH="config/dynamicconfig/sql.yaml"
