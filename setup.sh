#!/bin/sh
set -eu

# Validate required environment variables
: "${ES_SCHEME:?ERROR: ES_SCHEME environment variable is required}"
: "${ES_HOST:?ERROR: ES_HOST environment variable is required}"
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
temporal-elasticsearch-tool --ep "$ES_SCHEME://$ES_HOST:$ES_PORT" setup-schema
temporal-elasticsearch-tool --ep "$ES_SCHEME://$ES_HOST:$ES_PORT" create-index --index $ES_VISIBILITY_INDEX

echo 'PostgreSQL and Elasticsearch setup complete'