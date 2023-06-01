FROM php:8-apache

RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nano \
    iputils-ping

RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copiar los archivos de la aplicación desde el stage anterior
COPY . /var/www/html

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Establecer el documento raíz del servidor web
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Habilitar el módulo de Apache para reescribir URLs
RUN a2enmod rewrite

# Establecer los permisos adecuados para los archivos de Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer self-update

RUN composer install

# Expone el puerto 80 del contenedor
EXPOSE 80

RUN php artisan key:generate

# Comando predeterminado para iniciar el servidor web de Apache
CMD ["apache2-foreground"]
