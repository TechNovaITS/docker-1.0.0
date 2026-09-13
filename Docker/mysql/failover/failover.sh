#!/bin/sh
set -eu

echo "mysql-failover activo; vigilando mysql-primary"

while true; do
  if mysqladmin ping -h mysql-primary -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; then
    sleep 5
    continue
  fi

  echo "mysql-primary no responde; promoviendo mysql-replica"
  mysql -h mysql-replica -uroot -p"$MYSQL_ROOT_PASSWORD" -e "STOP REPLICA; SET GLOBAL read_only=OFF; SET GLOBAL super_read_only=OFF;" || true
  exit 0
done
