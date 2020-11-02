# DOCKER-WP

using docker compose to build a container with

* wordpress
* mysql
* underscores starter theme
* wp-cli

`/wordpress/` will be mapped to the container

start: `docker-compose up -d`
stop: `docker-compose down`
remove all volumes: `docker-compose down -v`

you can use `docker stack deploy` command instead of `docker-compose` to deploy to docker swarm (https://docs.docker.com/engine/swarm/stack-deploy/)

deploying to swarm: `docker stack deploy -c docker-compose.yml docker-wp`

load up the browser `http://127.0.0.1:8080`

install wordpress it will use the db settings in the .env so you won't have to enter them. The installation will persist on db_data volume until its removed.

## CONNECTING TO THE DB

1. connect to db with sequel pro
```
host: 127.0.0.1
port: 6603
```
2. use wp-sync-db plugin within wordpress
3. setup wp cli

## SMTP / EMAIL

* wp-mail-smtp plugin

Setup the plugin and configure smtp settings to handle mail.

I am using mailgun but you can use any other smtp config easily.

