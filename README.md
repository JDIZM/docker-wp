# DOCKER-WP

using docker compose to build a container with

* nginx
* wordpress
* mysql
* mailhog
* underscores starter theme
* wp-cli
* letsencrypt 
* certbot

`/wp-content/` will be mapped to the container for easy access to the theme files and content.

Read the official docs for the respective docker images
- [Wordpress](https://hub.docker.com/_/wordpress)
- [MySQL](https://hub.docker.com/_/mysql)
- [nginx](https://hub.docker.com/_/nginx)
- [mailhog](https://hub.docker.com/r/mailhog/mailhog/)
- [certbot](https://hub.docker.com/r/certbot/certbot/)

Setting up SSL is optional and can be configured after setting up standard http.

For development Mailhog will catch all email sent from wordpress and serve as an inbox to test.

In the `docker-compose` file comment out mailhog and uncomment certbot for production and SSL setup.
## COMMANDS

- start: `docker-compose up -d`
- stop: `docker-compose down`
- remove all volumes: `docker-compose down -v`
- build images on start: `docker-compose up --build`

You can use `docker stack deploy` command instead of `docker-compose` to deploy to docker swarm <https://docs.docker.com/engine/swarm/stack-deploy/> but this will require the images to be hosted on a registry like Docker Hub.

deploying to swarm: `docker stack deploy -c docker-compose.yml docker-wp`

load up the browser `http://127.0.0.1`

install wordpress it will use the db settings in the .env so you won't have to enter them. The installation will persist on `db_data` volume until its removed.
## FILE PERMISSIONS

Set the file permissions of the `wp-content` folder, since they are mounted from the host. Otherwise you will notice issues updating plugins.
```
chown -R www-data:www-data /var/www/html/wp-content
```

## EXPORTING MYSQL DATABASE

The wordpress user created with this build won't have permissions to export the database you will need to use root.

From the official mysql docker image https://hub.docker.com/_/mysql when `MYSQL_RANDOM_ROOT_PASSWORD` is set to true "The generated root password will be printed to stdout (GENERATED ROOT PASSWORD: .....)." You can view your docker container log when the db image first boots up to get the root password.

Uncomment this line in the docker-compose file if you want to set a custom root password:
```
MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT}
```
set the .env var `MYSQL_ROOT` with your desired root password. You can also save the randomly generated root password in .env for safe keeping.

Steps to export and import the mysql database:
```
# get the container id
docker ps

# gain a shell to the db container
docker exec -it containerid /bin/bash

# export the wp database
mysqldump -u root -p wordpress > backup.sql

# then enter your root password on prompt
# check the backup.sql file has been created
ls

# copy from docker container
docker cp container:./backup.sql ./backup.sql 

# copy to docker container
docker cp ./import.sql container:./import.sql

# import existing database dump
mysql -u root -p < import.sql
```
## SMTP & EMAIL

* wp-mail-smtp plugin

Setup the plugin and configure smtp settings to handle mail.

### MAILHOG & PHPMAILER FOR LOCAL EMAIL TESTING

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
1. Send a test mail from the plugin dashboard `http://localhost/wp-admin/admin.php?page=wp-mail-smtp&tab=test`
1. check mailhog caught it! `http://localhost:8025/`

### MAILGUN FOR PRODUCTION

configure the wp-mail-smtp plugin with your mailgun settings

* private API key
* domain

## WP REST API

* enable permalinks
* `http://localhost/wp-json/wp/v2`

## SSL config

### 1. make sure your domain has a DNS A record pointing to the server ip.

### 2. uncomment certbot in the docker compose file.

### 3. Edit the command line in the docker compose file to include your domain and email
```
command: certonly --webroot --webroot-path=/var/www/certbot --email your-email@domain.com --agree-tos --no-eff-email -d domain.com -d www.domain.com
```
### 4. start the containers as normal

```
docker-compose up -d
```

### 5. certbot should get a certificate for your domain

### 6. edit the location of your keychain in the `ssl.conf`
```
# ssl_certificate /etc/letsencrypt/live/mysite.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/mysite.com/privkey.pem;
```

### 7. make a copy of the default.conf and replace it with the ssl.conf
```
cd nginx
cp default.conf backup.conf
cat ssl.conf > default.conf 
```

Now we can start the containers again using the ssl certificates certbot just created for the domain name and email we specified in the compose file.