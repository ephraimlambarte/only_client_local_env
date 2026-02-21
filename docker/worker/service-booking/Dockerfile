FROM php:8.4-cli-alpine

# Install system dependencies required by Laravel and common extensions
# 'git' is often needed if you install packages from source or private repos
# 'supervisor' is optional but helpful for managing the worker process in production
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    mysql-client

# Install PHP extensions required by Laravel (adjust for your specific needs)
# Example extensions: pdo, pdo_mysql, mbstring, exif, pcntl, bcmath
RUN docker-php-ext-install pdo pdo_mysql

# Copy Composer from the official image (best practice for speed and consistency)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory inside the container
WORKDIR /var/www/html/service-booking

# The app code will be mounted via a volume in docker-compose.yml during development.

# Define the default command for this container (can be overridden in docker-compose)
CMD ["php", "./artisan", "queue:work", "--tries=3", "--verbose"]