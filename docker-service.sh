#!/bin/bash

function __load_global_variables() {
  _CONTAINER_NAME=$(cat ./info/CONTAINER_NAME)
  _VERSION=$(cat ./info/VERSION)
  _IMAGE_REPO=$(cat ./info/IMAGE_REPO)

  _IMAGE_NAME="${_IMAGE_REPO}/${_CONTAINER_NAME}:${_VERSION}"

  _BASE_DIR=$(dirname $(readlink -f $0))
}

function __load_container_configure(){
  cat ${_BASE_DIR}/etc/docker-container.conf \
  | grep -v "^#" \
  | sed '/^$/d' \
  | awk '{print "-e",$0}'
}

function __container_build() {
  docker build \
    --tag="${_IMAGE_NAME}" \
    --build-arg http_proxy="${http_proxy}" \
    --build-arg HTTP_PROXY="${HTTP_PROXY}" \
    --build-arg https_proxy="${https_proxy}" \
    --build-arg HTTPS_PROXY="${HTTP_PROXY}" \
    --build-arg ftp_proxy="${ftp_proxy}" \
    --build-arg FTP_PROXY="${FTP_PROXY}" \
    --build-arg no_proxy="${no_PROXY}" \
    --build-arg NO_PROXY="${NO_PROXY}" \
    $@ \
    .
}

function __container_run() {
  docker container run \
    -it --name ${_CONTAINER_NAME} \
    $(__load_container_configure) \
    ${_BOOT_STATE:-"-d=false"} ${_ONCE} \
    ${_IMAGE_NAME} ${_EXEC_CMD[@]}
}

function __container_start() {
  docker container start ${_CONTAINER_NAME}
}

function __container_stop() {
  docker container stop ${_CONTAINER_NAME}
}

function __container_remove() {
  docker container rm ${_CONTAINER_NAME}
}

function __image_remove() {
  docker image rm ${_IMAGE_NAME}
}

function __container_login() {
  docker container exec -it ${_CONTAINER_NAME} /bin/bash
}

__load_global_variables

if [ $# -ge 1 ]; then
  case $1 in
    boot|boot-[bf]g|onceboot|onceboot-[bf]g )
      case $1 in 
        boot|boot-fg )
          _BOOT_STATE=
          _ONCE=
        ;;
        boot-bg )
          _BOOT_STATE="-d=true"
          _ONCE=
        ;;
        onceboot|onceboot-fg )
          _BOOT_STATE=
          _ONCE="--rm"
        ;;
        onceboot-bg )
          _BOOT_STATE="-d=true"
          _ONCE="--rm"
        ;;
      esac

      shift 1
      _EXEC_CMD=($@)
      __container_run
    ;;
    build )
      __container_build  
    ;;
    start )
      __container_start
    ;;
    stop )
      __container_stop
    ;;
    container-rm )
      __container_remove
    ;;
    image-rm )
      __image_remove
    ;;
    purge )
      __container_remove
      __image_remove
    ;;
    login )
      __container_login
    ;;
    * )
      echo "missing operand" >&2
    ;;
  esac
fi
