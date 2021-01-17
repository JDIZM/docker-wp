# this is to pull from the latest wordpress and run additional commands after the image is pulled
FROM wordpress:latest

# install wp cli
# https://make.wordpress.org/cli/handbook/guides/installing/
RUN cd /var/www/html; \ 
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \ 
    chmod +x wp-cli.phar; \ 
    mv wp-cli.phar /usr/local/bin/wp

# install composer https://getcomposer.org/download/
RUN curl -s https://getcomposer.org/installer | php; \
    chmod +x composer.phar; \
    mv composer.phar /usr/local/bin/composer

# install phpmailer https://github.com/PHPMailer/PHPMailer
RUN composer require phpmailer/phpmailer
