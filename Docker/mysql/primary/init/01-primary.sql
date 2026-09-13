CREATE DATABASE IF NOT EXISTS app;

CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'replication_change_me';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';

CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'app_change_me';
GRANT ALL PRIVILEGES ON app.* TO 'app'@'%';

CREATE USER IF NOT EXISTS 'grafana'@'%' IDENTIFIED BY 'grafana_change_me';
GRANT SELECT ON app.* TO 'grafana'@'%';

CREATE USER IF NOT EXISTS 'proxysql_monitor'@'%' IDENTIFIED BY 'monitor_change_me';
GRANT USAGE, REPLICATION CLIENT ON *.* TO 'proxysql_monitor'@'%';
FLUSH PRIVILEGES;
