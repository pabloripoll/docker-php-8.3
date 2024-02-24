# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include .env

DOCKER_ABBR=$(PROJECT_ABBR)
DOCKER_HOST=$(PROJECT_HOST)
DOCKER_PORT=$(PROJECT_PORT)
DOCKER_NAME=$(PROJECT_NAME)
DOCKER_PATH=$(PROJECT_PATH)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)
DOCKER_COMPOSE?=$(DOCKER_USER) docker compose
DOCKER_COMPOSE_RUN=$(DOCKER_COMPOSE) run --rm
DOCKER_EXEC_TOOLS_APP=$(DOCKER_USER) docker exec -it $(DOCKER_NAME) sh

COMPOSER_INSTALL="composer update"

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission host-check

hostname: ## shows local machine ip
	echo $(word 1,$(shell hostname -I))

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

host-check: ## shows this project ports availability on local machine
	echo "Checking configuration for "${C_YEL}"$(DOCKER_ABBR)"${C_END}" container:";
	if [ -z "$$($(DOCKER_USER) lsof -i :$(DOCKER_PORT))" ]; then \
		echo ${C_BLU}"$(DOCKER_ABBR)"${C_END}" > port:"${C_GRN}"$(DOCKER_PORT) is free to use."${C_END}; \
    else \
		echo ${C_BLU}"$(DOCKER_ABBR)"${C_END}" > port:"${C_RED}"$(DOCKER_PORT) is busy. Update ./.env file."${C_END}; \
	fi

# -------------------------------------------------------------------------------------------------
#  Enviroment
# -------------------------------------------------------------------------------------------------
.PHONY: env env-set

env: ## checks if docker .env file exists
	if [ -f ./docker/.env ]; then \
		echo ${C_BLU}$(DOCKER_ABBR)${C_END}" docker-compose.yml .env file "${C_GRN}"is set."${C_END}; \
    else \
		echo ${C_BLU}$(DOCKER_ABBR)${C_END}" docker-compose.yml .env file "${C_RED}"is not set."${C_END}" \
	Create it by executing "${C_YEL}"$$ make env-set"${C_END}; \
	fi

env-set: ## sets docker .env file
	echo "COMPOSE_PROJECT_NAME=\"$(DOCKER_NAME)\"\
	\nCOMPOSE_PROJECT_HOST=$(DOCKER_HOST)\
	\nCOMPOSE_PROJECT_PORT=$(DOCKER_PORT)\
	\nCOMPOSE_PROJECT_PATH=\"$(DOCKER_PATH)\"" > ./docker/.env; \
	echo ${C_BLU}"$(DOCKER_ABBR)"${C_END}" docker-compose.yml .env file "${C_GRN}"has been set."${C_END};

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: ssh build install dev up start first stop restart clear

ssh:
	$(DOCKER_EXEC_TOOLS_APP)

build:
	cd docker && $(DOCKER_COMPOSE) up --build --no-recreate -d

install:
	cd docker && $(DOCKER_EXEC_TOOLS_APP) -c $(COMPOSER_INSTALL)

dev:
	cd docker && $(DOCKER_EXEC_TOOLS_APP) -c $(SERVER_RUN)

up:
	cd docker && $(DOCKER_COMPOSE) up -d
	echo Container Host:; \
	$(DOCKER_USER) docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(DOCKER_NAME)
	echo Local Host:; \
	echo localhost:$(DOCKER_PORT); \
	echo 127.0.0.1:$(DOCKER_PORT); \
	echo $(DOCKER_HOST):$(DOCKER_PORT); \

container-ip:
	$(DOCKER_USER) docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(DOCKER_NAME)
	echo $(DOCKER_PORT)

start:
	$(MAKE) up dev

first:
	$(MAKE) build install dev

stop:
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true

restart:
	$(MAKE) stop start dev

clear:
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true