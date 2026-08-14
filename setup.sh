#!/bin/sh
set -eu

: "${SKIP_DEFAULT_NAMESPACE_CREATION:=false}"
: "${DEFAULT_NAMESPACE:=default}"
: "${DEFAULT_NAMESPACE_RETENTION:=24h}"

: "${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES:=false}"

# Validate required environment variables
: "${ES_SCHEME:?ERROR: ES_SCHEME environment variable is required}"
: "${ES_SEEDS:?ERROR: ES_SEEDS environment variable is required}"
: "${ES_PORT:?ERROR: ES_PORT environment variable is required}"
: "${ES_VISIBILITY_INDEX:?ERROR: ES_VISIBILITY_INDEX environment variable is required}"
: "${ES_VERSION:?ERROR: ES_VERSION environment variable is required}"

: "${POSTGRES_SEEDS:?ERROR: POSTGRES_SEEDS environment variable is required}"
: "${POSTGRES_USER:?ERROR: POSTGRES_USER environment variable is required}"

echo 'Starting PostgreSQL and Elasticsearch schema setup...'
echo 'Waiting for PostgreSQL port to be available...'
export DB_PORT="${DB_PORT:-5432}"
nc -z -w 10 ${POSTGRES_SEEDS} ${DB_PORT}
echo 'PostgreSQL port is available'

export SQL_PASSWORD="${POSTGRES_PWD:-}"
export SQL_TLS="${SQL_TLS_ENABLED:-false}"
# Create and setup temporal database
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p ${DB_PORT} --db "${DBNAME}" create
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p ${DB_PORT} --db "${DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p ${DB_PORT} --db "${DBNAME}" update-schema -d /etc/temporal/schema/postgresql/v12/temporal/versioned

# Setup Elasticsearch index
echo 'Using temporal-elasticsearch-tool for Elasticsearch setup'
temporal-elasticsearch-tool --ep "$ES_SCHEME://$ES_SEEDS:$ES_PORT" setup-schema
temporal-elasticsearch-tool --ep "$ES_SCHEME://$ES_SEEDS:$ES_PORT" create-index --index $ES_VISIBILITY_INDEX

echo 'PostgreSQL and Elasticsearch setup complete'

register_default_namespace() {
    echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
    if ! temporal operator namespace describe --namespace "${DEFAULT_NAMESPACE}"; then
        echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
        temporal operator namespace create --retention "${DEFAULT_NAMESPACE_RETENTION}" --description "Default namespace for Temporal Server." --namespace "${DEFAULT_NAMESPACE}"
        echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
    else
        echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
    fi
}

add_custom_search_attributes() {
    until temporal operator search-attribute list --namespace "${DEFAULT_NAMESPACE}"; do
      echo "Waiting for namespace cache to refresh..."
      sleep 1
    done
    echo "Namespace cache refreshed."

    echo "Adding Custom*Field search attributes."
# @@@SNIPSTART add-custom-search-attributes-for-testing-command
    temporal operator search-attribute create --namespace "${DEFAULT_NAMESPACE}" \
        --name CustomKeywordField --type Keyword \
        --name CustomTextField --type Text \
        --name CustomIntField --type Int \
        --name CustomDatetimeField --type Datetime \
        --name CustomDoubleField --type Double \
        --name CustomBoolField --type Bool
# @@@SNIPEND
}

export TEMPORAL_ADDRESS="127.0.0.1:${PORT}"

setup_server(){
    echo "Temporal CLI address: ${TEMPORAL_ADDRESS}."

    until temporal operator cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    if [[ ${SKIP_DEFAULT_NAMESPACE_CREATION} != true ]]; then
        register_default_namespace
        if [[ ${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES} != true ]]; then
            add_custom_search_attributes
        fi
    fi
}

(
    unset TEMPORAL_SERVICES
    exec /etc/temporal/entrypoint.sh
) &
TEMPORAL_PID=$!

setup_server

echo "Setup complete. Sending SIGTERM to Temporal..."
kill -TERM "$TEMPORAL_PID"

echo "Waiting for Temporal to shut down..."
wait "$TEMPORAL_PID"

echo "Temporal shut down."
exit 0
