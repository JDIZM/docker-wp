# DOCKER-WP

using docker compose to build a container with

* wordpress
* mysql
* underscores theme

`/wp-content/` will be mapped to the container

start: `docker-compose up -d`

get a shell to wp container and set permissions for the volume.
`chown www-data:www-data wp-content -R`

load up the browser
`http://127.0.0.1:8080`

connect to db with sequel pro
```
host: 127.0.0.1
port: 6603
```

