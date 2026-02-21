#!/usr/bin/env bash

mysql --user=root --password="$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS testing_service_booking;
    CREATE DATABASE IF NOT EXISTS testing_only_client_crm;
    CREATE DATABASE IF NOT EXISTS app_crm;
EOSQL

if [ -n "$MYSQL_USER" ]; then
mysql --user=root --password="$MYSQL_ROOT_PASSWORD" <<-EOSQL
    GRANT ALL PRIVILEGES ON \`testing_service_booking%\`.* TO '$MYSQL_USER'@'%';
    GRANT ALL PRIVILEGES ON \`testing_only_client_crm%\`.* TO '$MYSQL_USER'@'%';
    GRANT ALL PRIVILEGES ON \`app_crm%\`.* TO '$MYSQL_USER'@'%';
EOSQL
fi
