FROM php:8.3-fpm

# Install Nginx and utilities
RUN apt-get update && apt-get install -y nginx supervisor

# Copy custom config files
COPY ../../docker/nginx_php/default /etc/nginx/sites-available/
COPY ../../docker/nginx_php/supervisord.conf /etc/supervisor/conf.d/

COPY . /var/www/html

RUN mkdir -p /var/www/html/var/cache/dev && \
    chown -R www-data:www-data /var/www/html/var/cache

EXPOSE 80

WORKDIR /var/www/html

# Start both Nginx and PHP-FPM via supervisord
CMD ["/usr/bin/supervisord", "-n"]
