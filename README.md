# Slight 83

*(project in development but working)*

Custom and light PHP framework built from base to develop simply PHP start up projects. In other words, all this framework functionalities are accesible to improve or modify its content.

*If you're looking for something more accuracy or robust I personally recomend to use [Laravel](https://laravel.com/) or [Symfony](https://symfony.com/).*

## Requirements

- [PHP](https://www.php.net/) version 8.3
- Composer
- Docker *(latest)* optionally

## Installation
Just clone this repository and configure

### Local
If you have PHP alredady installed in your machine (preferably version 8.3)

### Docker
Create an `.env` file from `.env.example` to define on which port the container will be running.

The Dockerfile comes with Alpine 3.19, Nginx 1.24, Supervisor, PHP 8.3 and Composer.

So, if you want to connect to another container running for instance a database, use your ip to do so *(not localhost or 127.0.0.1)*

Find out your IP on Linux and take the first ip listed
```
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```