# Alpine 3.19 / Nginx 1.24 / PHP 8.3 - Service

PHP-FPM 8.3 & Nginx 1.24 container image for Docker, built on [Alpine Linux 3.19](https://www.alpinelinux.org/).

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

## [![Personal Page](https://pabloripoll.com/files/logo-light-100x300.png)](https://github.com/pabloripoll?tab=repositories)

## Project as Service

The goal of this container image is to provide a start up application with the basic enviroment to deploy a php service running with Nginx and PHP-FPM in a container which follows the best practices and is easy to understand and modify to your needs.

Thus not includes a database neither other services like message broker or mailing, etc.

## Usage on Windows systems

You can use the makefile that comes with this repository or manually update the [./docker/.env](./docker/.env) file to feed the `docker-compose.yml` file.

## Usage on Unix based systems

Makefiles are often used to automate the process of building and compiling software on Unix-based systems, including Linux and macOS.

Checkout the Mkaefile recepies:
```
$ make help
```

Example:
```
$ make host-check

Checking configuration for MY PHP APP container:
MY PHP APP > port:8888 is free to use.
```

Build container
```bash
$ make build
[+] Building 33.0s (25/25) FINISHED                                                                               docker:default
 => [slight83 internal] load build definition from Dockerfile                                                     0.0s
 => => transferring dockerfile: 2.43kB
...
 => => exporting layers                                                                                           0.7s
 => => writing image sha256:05b7369d7c730f1571dbbd4b46137a67c9f87c5ef9fa686225cb55a46277aca1                      0.0s
 => => naming to docker.io/library/slight83:php-8.3-alpine-3.19                                                   0.0s
[+] Running 1/2
 ⠦ Network myphp_default  Created                                                                                 0.6s
 ✔ Container myphp        Started
```

Up container
```bash
$ make up
[+] Running 1/1
 ✔ Container myphp  Started                                                                                                                                                   0.4s
Container Host:
172.19.0.2
Local Host:
localhost:8888
127.0.0.1:8888
191.128.1.41:8888
```

Build & Up container
```bash
$ make build up
[+] Building 32.4s (25/25) FINISHED
...
```
TOTAL TIME: 32.4s

Stop container
```bash
$ make stop
[+] Killing 1/1
 ✔ Container myphp  Killed                                                                                        0.4s
Going to remove myphp
[+] Removing 1/0
 ✔ Container myphp  Removed
```

Clear container
```bash
$ make clear
[+] Running 1/1
 ✔ Network myphp_default  Removed
```

## Docker Info

Docker container
```bash
$ sudo docker ps -a
CONTAINER ID   IMAGE      COMMAND    CREATED         STATUS                     PORTS                                             NAMES
0f94fe4739a6   php-8...   "doc…"     2 minutes ago   Up 2 minutes (unhealthy)   9000/tcp, 0.0.0.0:8888->80/tcp, :::8888->80/tcp   myphp
```

Docker image
```bash
$ sudo docker images
REPOSITORY   TAG           IMAGE ID       CREATED         SIZE
php-8.3      alpine-3.19   8f7db0dfcde1   3 minutes ago   199MB
```

Docker stats
```bash
$ sudo docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         1         199.5MB   0B (0%)
Containers      1         1         4B        0B (0%)
Local Volumes   1         0         117.9MB   117.9MB (100%)
Build Cache     39        0         10.2kB    10.2kB
```

Removing container and image generated
```bash
$ sudo docker system prune
...
Total reclaimed space: 116.4MB
```
*(no need for pruning volume)*

## Reset configurations on the run
In [docker/config/](docker/config/) you'll find the default configuration files for Nginx, PHP and PHP-FPM.

If you want to extend or customize that you can do so by mounting a configuration file in the correct folder;

Nginx configuration:
```
$ docker run -v "`pwd`/nginx-server.conf:/etc/nginx/conf.d/server.conf" ${COMPOSE_PROJECT_NAME}
```

PHP configuration:
```
$ docker run -v "`pwd`/php-setting.ini:/etc/php83/conf.d/settings.ini" ${COMPOSE_PROJECT_NAME}
```

PHP-FPM configuration:
```
$ docker run -v "`pwd`/php-fpm-settings.conf:/etc/php83/php-fpm.d/server.conf" ${COMPOSE_PROJECT_NAME}
```

_Note; Because `-v` requires an absolute path I've added `pwd` in the example to return the absolute path to the current directory_


## Troubleshoots

If you want to connect to another container running your local machine *(for e.g.: database, bucket)* use your ip to do so *(not localhost or 127.0.0.1)*.

Find out your IP on UNIX systems and take the first ip listed
```
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```

Find out your IP on Windows as `administrator user` and take the first ip listed
```
C:\WINDOWS\system32>ipconfig /all

Windows IP Configuration

 Host Name . . . . . . . . . . . . : 191.128.1.41
 Primary Dns Suffix . . . . . . . : andrew.ad.cmu.edu
 Node Type . . . . . . . . . . . . : Peer-Peer
 IP Routing Enabled. . . . . . . . : No
 WINS Proxy Enabled. . . . . . . . : No
 DNS Suffix Search List. . . . . . : scs.ad.cs.cmu.edu
```