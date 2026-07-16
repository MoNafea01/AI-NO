#!/bin/bash
set -e 

echo "Waiting for PostgreSQL to be ready..."
MAX_RETRIES=3
RETRY_COUNT=0
while ! PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USERNAME} -d postgres -c '\q' 2>/dev/null; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "PostgreSQL connection failed after $MAX_RETRIES attempts. Continuing anyway..."
    break
  fi
  echo "PostgreSQL is unavailable - attempt $RETRY_COUNT/$MAX_RETRIES - sleeping"
  sleep 2
done
if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
  echo "PostgreSQL is ready!"
fi

echo "Creating database if not exists..."
PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USERNAME} -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_MAIN_DB}'" | grep -q 1 || \
PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USERNAME} -d postgres -c "CREATE DATABASE ${POSTGRES_MAIN_DB};"

echo "Running Database Migrations..."
export PYTHONPATH=/app/db/sql:/app:$PYTHONPATH
cd /app/db/sql/
alembic upgrade head
cd /app
echo "Database Migrations Completed."

exec "$@"
