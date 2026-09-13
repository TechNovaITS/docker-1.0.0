# MySQL HA local con ProxySQL, Apache PHP y Grafana

## Requisitos

- Docker Engine con Compose.
- Usuario con acceso al socket Docker o ejecución mediante `sudo docker compose`.

## Arranque

```bash
docker compose up -d --build
```

Para detener los servicios sin borrar datos:

```bash
docker compose down
```

Para reinicializar también los volúmenes de Docker:

```bash
docker compose down -v
docker compose up -d --build
```

## Servicios

| Servicio | Función | Acceso |
| --- | --- | --- |
| `mysql-primary` | MySQL 8.0 primario | Solo red interna |
| `mysql-replica` | MySQL 8.0 réplica GTID, inicialmente de solo lectura | Solo red interna |
| `mysql-failover` | Watcher que promueve la réplica si falla el primario | Solo red interna |
| `proxysql` | Punto único de acceso MySQL y balanceo por hostgroups | MySQL `localhost:6033`, admin `localhost:6032` |
| `apache-php` | Apache con PHP 8.3 y PDO MySQL | http://localhost:8080 |
| `grafana` | Panel y consulta de logs | http://localhost:3000 |
| `loki` | Almacenamiento de logs para Grafana | Solo red interna |
| `promtail` | Recolección de logs Docker y consultas lentas | Solo red interna |
| `vector` | Copia legible de logs de contenedores | Solo red interna |

Todos los servicios se comunican por la red Docker `docker_backend`.

## Credenciales

Los valores están en `.env`. Cambia las contraseñas antes de usar este entorno fuera de una máquina local.

Grafana usa `GRAFANA_ADMIN_USER` y `GRAFANA_ADMIN_PASSWORD`.

La aplicación y Grafana acceden a MySQL a través de `proxysql:6033`; no necesitan conectarse directamente a los servidores MySQL.

## MySQL y ProxySQL

El primario y la réplica usan GTID. ProxySQL envía las escrituras al hostgroup 10 y las lecturas al hostgroup 20. El estado de `read_only` determina cuál servidor actúa como escritor. El failover promueve la réplica si el primario deja de responder.

Comprobar la replicación:

```bash
docker compose exec mysql-replica mysql -uroot -proot_change_me -e "SHOW REPLICA STATUS\\G"
```

Los valores esperados son:

```text
Replica_IO_Running: Yes
Replica_SQL_Running: Yes
Seconds_Behind_Source: 0
```

## Logs

Loki guarda su almacenamiento interno en:

```text
Registros/loki/
```

Vector crea copias legibles de los logs de los contenedores de este proyecto en:

```text
texto/apache-php/
texto/grafana/
texto/loki/
texto/mysql-principal/
texto/mysql-replica/
texto/mysql-respaldo/
texto/proxy-sql/
texto/recolector-promtail/
```

Vector ignora contenedores externos al proyecto Compose `docker`, por lo que no aparecen nombres automáticos como `wizardly_lewin` o `vigorous_cohen`.

MySQL no registra todas las consultas. Solo mantiene el `slow query log`, con consultas que tardan más de un segundo:

```text
texto/mysql-principal/consultas-lentas.log
texto/mysql-replica/consultas-lentas.log
```

El `general_log` permanece desactivado para evitar ruido y crecimiento excesivo.

En Grafana abre **Explore** y selecciona `Loki - Docker logs`.

Todos los logs de contenedores:

```logql
{compose_project="docker"}
```

Logs de un servicio:

```logql
{compose_service="mysql-primary"}
```

Consultas lentas de MySQL:

```logql
{job="mysql-consultas-lentas"}
```

Consultas lentas del primario:

```logql
{job="mysql-consultas-lentas", servicio="mysql-principal"}
```

## Validación rápida

```bash
docker compose config --quiet
docker compose ps
curl -f http://localhost:8080
curl -f http://localhost:3000/login
```
