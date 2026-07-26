#!/bin/sh
# @@@SNIPSTART compose-postgres-setup
set -eu

# Validate required environment variables
: "${POSTGRES_SEEDS:?ERROR: POSTGRES_SEEDS environment variable is required}"
: "${POSTGRES_USER:?ERROR: POSTGRES_USER environment variable is required}"

echo 'Starting PostgreSQL schema setup...'
echo 'Waiting for PostgreSQL port to be available...'
nc -z -w 10 ${POSTGRES_SEEDS} 5432
echo 'PostgreSQL port is available'

export SQL_PASSWORD="${POSTGRES_PWD:-}"
export SQL_TLS="${SQL_TLS_ENABLED:-false}"
# Create and setup temporal database
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p 5432 --db "${DBNAME}" create
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p 5432 --db "${DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p 5432 --db "${DBNAME}" update-schema -d /etc/temporal/schema/postgresql/v12/temporal/versioned

# Create and setup visibility database
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p 5432 --db "${VISIBILITY_DBNAME}" create
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p 5432 --db "${VISIBILITY_DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin "$DB" --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p 5432 --db "${VISIBILITY_DBNAME}" update-schema -d /etc/temporal/schema/postgresql/v12/visibility/versioned

echo 'PostgreSQL schema setup complete'
# @@@SNIPEND