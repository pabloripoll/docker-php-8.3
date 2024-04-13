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
	cd docker && $(MAKE) port-check

# -------------------------------------------------------------------------------------------------
#  PHP App Service
# -------------------------------------------------------------------------------------------------
.PHONY: project-ssh project-set project-create project-start project-stop project-destroy project-install project-update

project-ssh: ## enters the project container shell
	cd docker && $(MAKE) ssh

project-set: ## sets the project enviroment file to build the container
	cd docker && $(MAKE) env-set

project-create: ## creates the project container from Docker image
	cd docker && $(MAKE) build up

project-start: ## starts the project container running
	cd docker && $(MAKE) start

project-stop: ## stops the project container but data won't be destroyed
	cd docker && $(MAKE) stop

project-destroy: ## removes the project from Docker network destroying its data and Docker image
	cd docker && $(MAKE) clear destroy

project-install: ## installs set version of project into container
	cd docker && $(MAKE) app-install

project-update: ## updates set version of project into container
	cd docker && $(MAKE) app-update

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: database-install database-replace database-backup

database-install: ## installs into container database the init sql file from resources/database
	sudo docker exec -i $(DB_CAAS) sh -c 'exec mysql $(DB_NAME) -uroot -p"$(DB_ROOT)"' < $(DB_BACKUP_PATH)/$(DB_BACKUP_NAME)-init.sql
	echo ${C_YEL}"DATABASE"${C_END}" has been installed."

database-replace: ## replaces container database with the latest sql backup file from resources/database
	sudo docker exec -i $(DB_CAAS) sh -c 'exec mysql $(DB_NAME) -uroot -p"$(DB_ROOT)"' < $(DB_BACKUP_PATH)/$(DB_BACKUP_NAME)-backup.sql
	echo ${C_YEL}"DATABASE"${C_END}" has been replaced."

database-backup: ## creates / replace a sql backup file from container database in resources/database
	sudo docker exec $(DB_CAAS) sh -c 'exec mysqldump $(DB_NAME) -uroot -p"$(DB_ROOT)"' > $(DB_BACKUP_PATH)/$(DB_BACKUP_NAME)-backup.sql
	echo ${C_YEL}"DATABASE"${C_END}" backup has been created."

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"

repo-commit: ## echoes commit helper
	echo "git add . && git commit -m \"maint: ... \" && git push -u origin main"