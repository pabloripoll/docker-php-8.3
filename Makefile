# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include .env

DOCKER_TITLE=$(PROJECT_TITLE)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

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
	echo $(ip addr show | grep "\binet\b.*\bdocker0\b" | awk '{print $2}' | cut -d '/' -f 1)

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

host-check: ## shows this project ports availability on local machine
	cd docker/nginx-php && $(MAKE) port-check

# -------------------------------------------------------------------------------------------------
#  PHP App Service
# -------------------------------------------------------------------------------------------------
.PHONY: project-ssh project-set project-create project-start project-stop project-destroy project-install project-update

project-ssh: ## enters the project container shell
	cd docker/nginx-php && $(MAKE) ssh

project-set: ## sets the project enviroment file to build the container
	cd docker/nginx-php && $(MAKE) env-set

project-create: ## creates the project container from Docker image
	cd docker/nginx-php && $(MAKE) env-set build up

project-start: ## starts the project container running
	cd docker/nginx-php && $(MAKE) start

project-stop: ## stops the project container but data won't be destroyed
	cd docker/nginx-php && $(MAKE) stop

project-destroy: ## removes the project from Docker network destroying its data and Docker image
	cd docker/nginx-php && $(MAKE) clear destroy

project-install: ## installs set version of project into container
	cd docker/nginx-php && $(MAKE) app-install

project-update: ## updates set version of project into container
	cd docker/nginx-php && $(MAKE) app-update

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"

repo-commit: ## echoes commit helper commands
	echo "git add . && git commit -m \"maint: ... \" && git push -u origin main"