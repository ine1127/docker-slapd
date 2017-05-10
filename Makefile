# Makefile
# docker container build & run 

CONTAINER_NAME = $(shell cat ./info/CONTAINER_NAME)
VERSION        = $(shell cat ./info/VERSION)
IMAGE_REPO     = $(shell cat ./info/IMAGE_REPO)
IMAGE_NAME     = ${IMAGE_REPO}/${CONTAINER_NAME}

all: build

help:
	@echo "- Help Menu"
	@echo "  image name:     ${IMAGE_NAME}:${VERSION}"
	@echo "  container name: ${CONTAINER_NAME}"
	@echo "--"
	@echo "  make build        - build ${IMAGE_NAME}:${VERSION}"
	@echo "  make boot         - run ${CONTAINER_NAME} (same as 'make boot-fg')"
	@echo "  make boot-fg      - run ${CONTAINER_NAME} (fg)"
	@echo "  make boot-bg      - run ${CONTAINER_NAME} (bg)"
	@echo "  make onceboot     - run --rm ${CONTAINER_NAME} (same as 'onceboot-fg')"
	@echo "  make onceboot-fg  - run --rm ${CONTAINER_NAME} (fg)"
	@echo "  make onceboot-bg  - run --rm ${CONTAINER_NAME} (bg)"
	@echo "  make start        - start ${CONTAINER_NAME}"
	@echo "  make login        - login bash on ${CONTAINER_NAME}"

build:
	@docker build -t ${IMAGE_NAME}:${VERSION} .

boot: boot-fg

onceboot: onceboot-fg

boot-fg:
	@/bin/bash ./docker-run.sh ${IMAGE_NAME}:${VERSION} fg

boot-bg:
	@/bin/bash ./docker-run.sh ${IMAGE_NAME}:${VERSION} bg

onceboot-fg:
	@/bin/bash ./docker-run.sh ${IMAGE_NAME}:${VERSION} fg once

onceboot-bg:
	@/bin/bash ./docker-run.sh ${IMAGE_NAME}:${VERSION} bg once

start:
	@docker container ${CONTAINER_NAME} start

login:
	@-docker container exec -it ${CONTAINER_NAME} /bin/bash
