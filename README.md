# Alpine 3.19 / Nginx 1.24 / PHP 8.3

Example PHP-FPM 8.3 & Nginx 1.24 container image for Docker, built on [Alpine Linux](https://www.alpinelinux.org/).

Repository: https://github.com/pabloripoll/docker-php-8.3-service

* Built on the lightweight and secure Alpine Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-40MB)
* Uses PHP 8.3 for the best performance, low CPU usage & memory footprint
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's `on-demand` process manager)
* The services Nginx, PHP-FPM and supervisord run under a non-privileged user (nobody) to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs

## [![Personal Page](https://pabloripoll.com/files/logo-light-100x300.png)](https://github.com/pabloripoll)

## Goal of this project

The goal of this container image is to provide an example for running Nginx and PHP-FPM in a container which follows the best practices and is easy to understand and modify to your needs.

## Usage

You can use the makefile that comes with this repository or manually update the `.env` file to feed the `docker-compose.yml` file.

Checkout the Mkaefile recepies:
```
$ make help
```

## Configuration
In [config/](config/) you'll find the default configuration files for Nginx, PHP and PHP-FPM.
If you want to extend or customize that you can do so by mounting a configuration file in the correct folder;

Nginx configuration:

    docker run -v "`pwd`/nginx-server.conf:/etc/nginx/conf.d/server.conf" trafex/php-nginx

PHP configuration:

    docker run -v "`pwd`/php-setting.ini:/etc/php83/conf.d/settings.ini" trafex/php-nginx

PHP-FPM configuration:

    docker run -v "`pwd`/php-fpm-settings.conf:/etc/php83/php-fpm.d/server.conf" trafex/php-nginx

_Note; Because `-v` requires an absolute path I've added `pwd` in the example to return the absolute path to the current directory_


Create an `.env` file from `.env.example` to define on which port the container will be running.

The Dockerfile comes with Alpine 3.19, Nginx 1.24, Supervisor, PHP 8.3 and Composer.

So, if you want to connect to another container running for instance a database, use your ip to do so *(not localhost or 127.0.0.1)*

Find out your IP on Linux and take the first ip listed
```
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```