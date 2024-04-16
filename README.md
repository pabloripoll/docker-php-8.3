<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="https://github.com/pabloripoll?tab=repositories">
        <img style="width:150px;float:left;" src="https://pabloripoll.com/files/logo-light-100x300.png"/>
    </a>
</div>

# PHP 8+ Service

The objective of this repository is having a CaaS [Containers as a Service](https://www.ibm.com/topics/containers-as-a-service) to provide a "ready to use" container with the basic enviroment features to deploy any application service under a lightweight Linux Alpine image with Nginx server platform and [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) for development stage requirements.

The container configuration is as [Host Network](https://docs.docker.com/network/drivers/host/) on `eth0` as [Bridge network](https://docs.docker.com/network/drivers/bridge/), thus it can be accessed through `localhost:${PORT}` by browsers but to connect with it or this with other services `${HOSTNAME}:${PORT}` will be required.

## Container Service

- [PHP-FPM 8.3](https://www.php.net/releases/8.3/en.php)

- [Nginx 1.24](https://nginx.org/)

- [Alpine Linux 3.19](https://www.alpinelinux.org/)

### Database Service

This project does not include a database service for it is intended to connect to a database instance like in a cloud database environment or similar.

To emulate a SQL database service it can be used the following [MariaDB 10.11](https://mariadb.com/kb/en/changes-improvements-in-mariadb-1011/) repository:
- [https://github.com/pabloripoll/docker-mariadb-10.11](https://github.com/pabloripoll/docker-mariadb-10.11)

### Project objetives with Docker

* Built on the lightweight and secure Alpine 3.19 [2024 release](https://www.alpinelinux.org/posts/Alpine-3.19.1-released.html) Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-40MB)
* Uses PHP 8.3 as default for the best performance, low CPU usage & memory footprint, but also can be downgraded till PHP 8.0
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's `on-demand` process manager)
* The services Nginx, PHP-FPM and supervisord run under a project-privileged user to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs
* Services independency to connect the application to other database allocation

#### PHP config

To use a different PHP 8 version the following [Dockerfile](docker/nginx-php/docker/Dockerfile) arguments and variable has to be modified:
```Dockerfile
ARG PHP_VERSION=8.3
ARG PHP_ALPINE=83
...
ENV PHP_V="php83"
```

Also, it has to be informed to [Supervisor Config](docker/nginx-php/docker/config/supervisord.conf) the PHP-FPM version to run.
```bash
...
[program:php-fpm]
command=php-fpm83 -F
...
```

## Dockerfile insight
```
# Install main packages and remove default server definition
RUN apk add --no-cache \
  curl \
  wget \
  nginx \
  curl \
  zip \
  bash \
  vim \
  git \
  supervisor

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        libzip-dev \
        freetype-dev \
        icu-dev \
        libmcrypt-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxslt-dev \
        patch \
        openssh-client

# Install PHP and its extensions packages and remove default server definition
ENV PHP_V="php83"

RUN apk add --no-cache \
  ${PHP_V} \
  ${PHP_V}-cli \
  ${PHP_V}-ctype \
  ${PHP_V}-curl \
  ${PHP_V}-dom \
  ${PHP_V}-fileinfo \
  ${PHP_V}-fpm \
  ${PHP_V}-gd \
  ${PHP_V}-intl \
  ${PHP_V}-mbstring \
  ${PHP_V}-opcache \
  ${PHP_V}-openssl \
  ${PHP_V}-phar \
  ${PHP_V}-session \
  ${PHP_V}-tokenizer \
  ${PHP_V}-soap \
  ${PHP_V}-xml \
  ${PHP_V}-xmlreader \
  ${PHP_V}-xmlwriter \
  ${PHP_V}-simplexml \
  ${PHP_V}-zip \
  # Databases
  ${PHP_V}-pdo \
  ${PHP_V}-pdo_sqlite \
  ${PHP_V}-sqlite3 \
  ${PHP_V}-pdo_mysql \
  ${PHP_V}-mysqlnd \
  ${PHP_V}-mysqli \
  ${PHP_V}-pdo_pgsql \
  ${PHP_V}-pgsql \
  ${PHP_V}-mongodb \
  ${PHP_V}-redis

# PHP Docker
RUN docker-php-ext-install pdo pdo_mysql gd

# PHP PECL extensions
RUN apk add \
  ${PHP_V}-pecl-amqp \
  ${PHP_V}-pecl-xdebug
```

#### Containers on Windows systems

This project has not been tested on Windows OS neither I can use it to test it. So, I cannot bring much support on it.

Anyway, using this repository you will needed to find out your PC IP by login as an `administrator user` to set connection between containers.

```bash
C:\WINDOWS\system32>ipconfig /all

Windows IP Configuration

 Host Name . . . . . . . . . . . . : 191.128.1.41
 Primary Dns Suffix. . . . . . . . : paul.ad.cmu.edu
 Node Type . . . . . . . . . . . . : Peer-Peer
 IP Routing Enabled. . . . . . . . : No
 WINS Proxy Enabled. . . . . . . . : No
 DNS Suffix Search List. . . . . . : scs.ad.cs.cmu.edu
```

Take the first ip listed. Wordpress container will connect with database container using that IP.

#### Containers on Unix based systems

Find out your IP on UNIX systems and take the first IP listed
```bash
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```

## Structure

Directories and main files on a tree architecture description. Main `/docker` directory has `/nginx-php` directory separated in case of needing to be included other container service directory with its specific contents
```
.
│
├── docker
│   ├── nginx-php
│   │   ├── docker
│   │   │   ├── config
│   │   │   ├── .env
│   │   │   ├── docker-compose.yml
│   │   │   └── Dockerfile
│   │   │
│   │   └── Makefile
│   │
│   └── (other...)
│
├── resources
│   ├── doc
│   │   └── (any documentary file...)
│   │
│   └── project
│       └── (any file or directory required for re-building the app...)
│
├── project
│   └── (application...)
│
├── .env
├── .env.example
└── Makefile
```

## Automation with Makefile

Makefiles are often used to automate the process of building and compiling software on Unix-based systems as Linux and macOS.

*On Windows - I recommend to use Makefile: \
https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows*

Makefile recipies
```bash
$ make help
usage: make [target]

targets:
Makefile  help                    shows this Makefile help message
Makefile  hostname                shows local machine ip
Makefile  fix-permission          sets project directory permission
Makefile  host-check              shows this project ports availability on local machine
Makefile  project-ssh             enters the project container shell
Makefile  project-set             sets the project enviroment file to build the container
Makefile  project-create          creates the project container from Docker image
Makefile  project-start           starts the project container running
Makefile  project-stop            stops the project container but data will not be destroyed
Makefile  project-destroy         removes the project from Docker network destroying its data and Docker image
Makefile  project-install         installs set version of project into container
Makefile  project-update          updates set version of project into container
Makefile  repo-flush              clears local git repository cache specially to update .gitignore
Makefile  repo-commit             echoes commit helper commands
```

## Service Configuration

Create a [DOTENV](.env) file from [.env.example](.env.example) and setup according to your project requirement the following variables
```
# REMOVE COMMENTS WHEN COPY THIS FILE

# Leave it empty if no need for sudo user to execute docker commands
DOCKER_USER=sudo

# Container data for docker-compose.yml
PROJECT_TITLE="PHP PROJECT"     # <- this name will be prompt for automation commands
PROJECT_ABBR="proj-php"         # <- part of the service image tag - useful if similar services are running
PROJECT_HOST="127.0.0.1"        # <- for this project is not necessary
PROJECT_PORT="8888"             # <- port access container service on local machine
PROJECT_CAAS="proj-php"         # <- container as a service name to build the service
PROJECT_PATH="../project"       # <- path where application is binded from container to local
```

Exacute the following command to create the [docker/.env](docker/.env) file, required for building the container
```bash
$ make project-set
PROJECT docker-compose.yml .env file has been set.
```

Checkout port availability from the set enviroment
```bash
$ make host-check

Checking configuration for PROJECT container:
PROJECT > port:8888 is free to use.
```

Checkout local machine IP to set connection between container services using the following makefile recipe if required
```bash
$ make hostname

192.168.1.41
```

## Project Service

If the container is built with the pre-installed application content, by browsing to localhost with the selected port configured [http://localhost:8888/](http://localhost:8888/) will display the successfully installation welcome page.

The pre-installed application could require to update its dependencies. The following Makefile recipe will update dependencies set on `composer.json` file
```bash
$ make project-update
```

If it is needed to build the container with other type of application *(like a PHP framework)*, there is a Makefile recipe to set at [docker/Makefile](docker/Makefile) all the commands needed for its installation.
```bash
$ make project-install
```

## Create the application container service

```bash
$ make project-create

SYMFONY docker-compose.yml .env file has been set.

[+] Building 67.8s (28/28) FINISHED                                       docker:default
=> [nginx-php internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 2.88kB                                              0.0s
 => [nginx-php internal] load metadata for docker.io/library/composer:latest        1.5s
 => [nginx-php internal] load metadata for docker.io/library/php:8.3-fpm-alpine     1.5s
 => [nginx-php internal] load .dockerignore                                         0.0s

...

[+] Running 2/2
 ⠴ Network proj-php_default  Created                                                0.4s
 ✔ Container proj-php        Started                                                0.3s
[+] Running 1/0
 ✔ Container proj-php        Running
```

## Container Information

Docker image size
```bash
$ sudo docker images
REPOSITORY   TAG           IMAGE ID       CREATED         SIZE
project-app  proj...       373f6967199b   5 minutes ago   261MB
```

Stats regarding the amount of disk space used by the container
```bash
$ sudo docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         1         260.7MB   0B (0%)
Containers      1         1         4B        0B (0%)
Local Volumes   1         0         473.2MB   473.2MB (100%)
Build Cache     39        0         15.06kB   15.06kB
```

## Stopping the Container Service

Using the following Makefile recipe stops application from running, keeping database persistance and application files binded without any loss
```bash
$ make project-stop
[+] Stopping 1/1
 ✔ Container project-app  Stopped                                                    0.5s
```

## Removing the Container Image

To remove application container from Docker network use the following Makefile recipe *(Docker prune commands still needed to be applied manually)*
```bash
$ make project-destroy

[+] Removing 1/0
 ✔ Container project-app  Removed                                                     0.0s
[+] Running 1/1
 ✔ Network project-app_default  Removed                                               0.4s
Untagged: project-app:project-nginx-php
Deleted: sha256:3c99f91a63edd857a0eaa13503c00d500fad57cf5e29ce1da3210765259c35b1
```

Pruning Docker system cache
```bash
$ sudo docker system prune
...
Total reclaimed space: 171.5MB
```

Pruning Docker volume cache
```bash
$ sudo docker volume prune
...
Total reclaimed space: 0MB
```
