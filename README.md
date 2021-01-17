# DOCKER-WP

using docker compose to build a container with

* wordpress
* mysql
* underscores starter theme
* wp-cli
* mailhog

`/wp-content/` will be mapped to the container

## COMMANDS

start: `docker-compose up -d`
stop: `docker-compose down`
remove all volumes: `docker-compose down -v`
rebuild the image: `docker-compose build`

you can use `docker stack deploy` command instead of `docker-compose` to deploy to docker swarm <https://docs.docker.com/engine/swarm/stack-deploy/>

deploying to swarm: `docker stack deploy -c docker-compose.yml docker-wp`

load up the browser `http://127.0.0.1:8080`

install wordpress it will use the db settings in the .env so you won't have to enter them. The installation will persist on db_data volume until its removed.

## CONNECTING TO THE DB

Multiple ways of connecting to the database

* connect to db with sequel pro

```config
host: 127.0.0.1
port: 6603
username: wordpress
password: wordpress
```

* use wp-sync-db plugin within wordpress
* use wp cli

Note: having issues with wp cli, it can't access the db but everything else works.

## SMTP & EMAIL

* wp-mail-smtp plugin

Setup the plugin and configure smtp settings to handle mail.

### MAILHOG & PHPMAILER FOR LOCAL

* composer is installed
* phpmailer is installed
* mailhog is running on `http://localhost:8025` and catches mail on port 1025

We need to configure wordpress to route the mail to mailhog. I've found the solution between these two sources:

* https://gist.github.com/eduwass/039864b7dca85f06c3883b6fab0f7f2e
* https://developer.wordpress.org/reference/hooks/phpmailer_init/
  
#### STEPS TO CONFIGURE MAILHOG

1. edit the theme functions file to configure the local smtp settings at `/var/www/html/wp-content/themes/_s/functions.php`

add the following code to the theme functions.php file

```php
/* MAILHOG SMTP */
function my_phpmailer_example( $phpmailer ) {
  $phpmailer->isSMTP();     
  $phpmailer->Host = 'mailhog';
  $phpmailer->Port = 1025;
}
add_action( 'phpmailer_init', 'my_phpmailer_example' );
```

This will configure phpmailer to use mailhog with port 1025

Note: I've tried automating this on the build of the dockerfile see **mailhog-config.sh** but this causes issues on build.

1. get a shell to the container
1. `cd /var/www/html`
1. activate the theme (with modified functions.php) `wp theme activate _s --allow-root`
1. activate the wp-mail-smtp plugin  `wp plugin activate wp-mail-smtp --allow-root`
1. Send a test mail from the plugin dashboard `http://localhost:8080/wp-admin/admin.php?page=wp-mail-smtp&tab=test`
1. check mailhog caught it! `http://localhost:8025/`

### MAILGUN FOR PRODUCTION

configure the wp-mail-smtp plugin with your mailgun settings

* private API key
* domain

## WP REST API

* enable permalinks
* `http://localhost:8080/wp-json/wp/v2`
