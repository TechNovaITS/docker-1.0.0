# MySQL HA local con ProxySQL, Apache PHP y Grafana

## Arranque

```bash
docker compose up -d --build
```

Servicios publicados:

- Apache/PHP: http://localhost:8080
- Grafana: http://localhost:3000
- ProxySQL MySQL: localhost:6033
- ProxySQL admin: localhost:6032

Grafana también recibe los logs de todos los contenedores mediante Loki y Promtail. En Grafana abre `Explore`, selecciona `Loki - Docker logs` y usa `{compose_project="docker"}` para ver toda la pila. Para filtrar un servicio concreto, usa por ejemplo `{compose_service="mysql-primary"}`.

Los datos persistentes de Loki se guardan en `Registros/loki/`. Además, Vector crea copias de texto legibles directamente en `texto/`, organizadas por servicio y fecha, por ejemplo `texto/apache-php/2026-09-13.log`. Vector no copia sus propios logs para evitar un bucle; sus logs siguen disponibles en Loki mediante Promtail.

La aplicación y Grafana se conectan a `proxysql:6033`. ProxySQL envía lecturas al lector y escrituras al hostgroup del primario. La réplica se inicializa sola usando GTID. El watcher promueve la réplica si el primario deja de responder.

ProxySQL usa el monitoreo `read_only` para detectar el primario y la réplica. El monitor antiguo de lag se dejó prácticamente desactivado porque MySQL 8.4 eliminó la sintaxis `SHOW SLAVE STATUS` que generaba errores.

Los valores iniciales están en `.env`; cambia las contraseñas antes de usarlo fuera de un entorno local. Para reinicializar desde cero:

```bash
docker compose down -v
docker compose up -d --build
```

Comprueba la replicación con:

```bash
docker compose exec mysql-replica mysql -uroot -proot_change_me -e "SHOW REPLICA STATUS\\G"
```
