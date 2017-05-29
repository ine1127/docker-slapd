# Makefile
# docker container build, run, etc...

_CONTAINER_NAME = $(shell cat ./info/CONTAINER_NAME)
_VERSION        = $(shell cat ./info/VERSION)
_IMAGE_REPO     = $(shell cat ./info/IMAGE_REPO)
_IMAGE_NAME     = ${_IMAGE_REPO}/${_CONTAINER_NAME}:${_VERSION}
_CONF_FILE      = ./etc/docker-container.conf

all: build

help:
	@echo "- Help Menu"
	@echo "  image name:     ${_IMAGE_NAME}"
	@echo "  container name: ${_CONTAINER_NAME}"
	@echo "--"
	@echo "  make build        - build ${_IMAGE_NAME}"
	@echo "  make boot         - run ${_CONTAINER_NAME} (same as 'make boot-fg')"
	@echo "  make boot-fg      - run ${_CONTAINER_NAME} (fg)"
	@echo "  make boot-bg      - run ${_CONTAINER_NAME} (bg)"
	@echo "  make onceboot     - run --rm ${_CONTAINER_NAME} (same as 'onceboot-fg')"
	@echo "  make onceboot-fg  - run --rm ${_CONTAINER_NAME} (fg)"
	@echo "  make onceboot-bg  - run --rm ${_CONTAINER_NAME} (bg)"
	@echo "  make start        - start ${_CONTAINER_NAME}"
	@echo "  make login        - login bash on ${_CONTAINER_NAME}"

build:
	@docker build -t ${_IMAGE_NAME} . \
		--build-arg HTTP_PROXY=${HTTP_PROXY} \
		--build-arg http_proxy=${http_proxy} \
		--build-arg HTTPS_PROXY=${HTTPS_PROXY} \
		--build-arg https_proxy=${https_proxy} \
		--build-arg FTP_PROXY=${FTP_PROXY} \
		--build-arg ftp_proxy=${ftp_proxy} \
		--build-arg NO_PROXY=${NO_PROXY} \
		--build-arg no_proxy=${no_proxy}

start:
	@docker container start ${_CONTAINER_NAME}

stop:
	@docker container stop ${_CONTAINER_NAME}

restart:
	@docker container restart ${_CONTAINER_NAME}

enable:
	@docker container update --restart=always ${_CONTAINER_NAME}

disable:
	@docker container update --restart=no ${_CONTAINER_NAME}

container-rm:
	@docker container rm ${_CONTAINER_NAME}

image-rm:
	@docker image rm ${_IMAGE_NAME}

purge:
	@docker container rm ${_CONTAINER_NAME}
	@docker image rm ${_IMAGE_NAME}

boot: boot-fg

onceboot: onceboot-fg

boot-fg:
	@docker container run \
		-it --name ${_CONTAINER_NAME} \
		--env-file ${_CONF_FILE} \
		${_IMAGE_NAME}

boot-bg:
	@docker container run \
		-itd --name ${_CONTAINER_NAME} \
		--env-file ${_CONF_FILE} \
		${_IMAGE_NAME}

onceboot-fg:
	@docker container run \
		-it --rm --name ${_CONTAINER_NAME} \
		--env-file ${_CONF_FILE} \
		${_IMAGE_NAME}

onceboot-bg:
	@docker container run \
		-itd --rm --name ${_CONTAINER_NAME} \
		--env-file ${_CONF_FILE} \
		${_IMAGE_NAME}

login:
	@-docker container exec -it ${_CONTAINER_NAME} /bin/bash
