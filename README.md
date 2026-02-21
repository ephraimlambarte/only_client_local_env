# SETUP

## 1: Clone the 2 projects

### Clone only-client-crm
```
git clone https://github.com/ephraimlambarte/only-client-crm.git
```

### Clone service-booking
```
git clone https://github.com/ephraimlambarte/service-booking.git
```

## 2: Install composer dependencies (root folder)

### only-client-crm
```
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd)/only-client-crm:/var/www/html" \
    -w /var/www/html \
    laravelsail/php84-composer:latest \
    composer install --ignore-platform-reqs
```

### service-booking
```
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd)/service-booking:/var/www/html" \
    -w /var/www/html \
    laravelsail/php84-composer:latest \
    composer install --ignore-platform-reqs
```

## 3: Give Permission to sail file
```
chmod +x ./sail
```
## 4: Comment the queue services
### the queue services needs the migration files to run first before it runs
```
 # service_booking.test-queue:
    #     build:
    #         context: ./docker/worker/service-booking
    #         dockerfile: Dockerfile
    #     command: php artisan queue:work --verbose --tries=3 --delay=3
    #     volumes:
    #         - './service-booking:/var/www/html/service-booking'
    #     depends_on:
    #         mysql:
    #             condition: service_healthy
    #     networks:
    #         - sail
    #     environment:
    #         WAIT_HOSTS: mysql:3306
    #         APP_ENV: ${APP_ENV}
    #         QUEUE_CONNECTION: ${QUEUE_CONNECTION}
    #         DB_HOST: ${DB_HOST}
    #         REDIS_HOST: ${REDIS_HOST}
    # only_client_crm.test-queue:
    #     build:
    #         context: ./docker/worker/only-client-crm
    #         dockerfile: Dockerfile
    #     command: php artisan queue:work --verbose --tries=3 --delay=3
    #     volumes:
    #         - './only-client-crm:/var/www/html/only-client-crm'
    #     depends_on:
    #         mysql:
    #             condition: service_healthy
    #     networks:
    #         - sail
    #     environment:
    #         WAIT_HOSTS: mysql:3306
    #         APP_ENV: ${APP_ENV}
    #         QUEUE_CONNECTION: ${QUEUE_CONNECTION}
    #         DB_HOST: ${DB_HOST}
    #         REDIS_HOST: ${REDIS_HOST}
```
## 5: Start the service
`./sail up`

## 6: Run migration on the apps
### Run migration on service-booking
`./sail service-booking artisan migrate`
### Run migration on only-client-crm
`./sail only-client-crm artisan migrate`

## 7: Run npm install on the apps
### Run migration on service-booking
`./sail service-booking artisan migrate`
### Run migration on only-client-crm
`./sail only-client-crm artisan migrate`

## 8: Stop the service and uncomment the queue services
```
service_booking.test-queue:
    build:
        context: ./docker/worker/service-booking
        dockerfile: Dockerfile
    command: php artisan queue:work --verbose --tries=3 --delay=3
    volumes:
        - './service-booking:/var/www/html/service-booking'
    depends_on:
        mysql:
            condition: service_healthy
    networks:
        - sail
    environment:
        WAIT_HOSTS: mysql:3306
        APP_ENV: ${APP_ENV}
        QUEUE_CONNECTION: ${QUEUE_CONNECTION}
        DB_HOST: ${DB_HOST}
        REDIS_HOST: ${REDIS_HOST}
only_client_crm.test-queue:
    build:
        context: ./docker/worker/only-client-crm
        dockerfile: Dockerfile
    command: php artisan queue:work --verbose --tries=3 --delay=3
    volumes:
        - './only-client-crm:/var/www/html/only-client-crm'
    depends_on:
        mysql:
            condition: service_healthy
    networks:
        - sail
    environment:
        WAIT_HOSTS: mysql:3306
        APP_ENV: ${APP_ENV}
        QUEUE_CONNECTION: ${QUEUE_CONNECTION}
        DB_HOST: ${DB_HOST}
        REDIS_HOST: ${REDIS_HOST}
```
## 9 Run `./sail up` again to build the services