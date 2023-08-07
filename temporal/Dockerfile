FROM temporalio/auto-setup:1.21.3

ARG DB DB_PORT POSTGRES_USER POSTGRES_PWD POSTGRES_SEEDS

COPY docker.yaml /etc/temporal/config/dynamicconfig/docker.yaml

ENV DYNAMIC_CONFIG_FILE_PATH="config/dynamicconfig/docker.yaml"
