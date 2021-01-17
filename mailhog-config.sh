#!/bin/bash
# Make sure this file is executable by running chmod +x mailhog-config.sh before building your image

# https://developer.wordpress.org/reference/hooks/phpmailer_init/
# cat >> /var/www/html/wp-content/themes/_s/functions.php <<-EOF
cat >> /var/www/html/wp-config.php <<-EOF
/* MAILHOG SMTP */
function my_phpmailer_example( $phpmailer ) {
	$phpmailer->isSMTP();     
	$phpmailer->Host = 'mailhog';
	$phpmailer->Port = 1025;
}
add_action( 'phpmailer_init', 'my_phpmailer_example' );
EOF

# Run apache2
exec "apache2-foreground"


