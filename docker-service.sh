#!/bin/bash

function __echo_exec() {
  echo $@
  eval $@
}

function __load_global_variables() {
  _BASE_DIR=$(dirname $(readlink -f $0))

  _CONTAINER_NAME=$(cat ${_BASE_DIR}/info/CONTAINER_NAME)
  _VERSION=$(cat ${_BASE_DIR}/info/VERSION)
  _IMAGE_REPO=$(cat ${_BASE_DIR}/info/IMAGE_REPO)

  _IMAGE_NAME="${_IMAGE_REPO}/${_CONTAINER_NAME}:${_VERSION}"
  _HOSTNAME="$(hostname -f)"
}

function __container_build() {
  __echo_exec docker image build \
    --tag="${_IMAGE_NAME}" \
    --build-arg http_proxy="${http_proxy}" \
    --build-arg HTTP_PROXY="${HTTP_PROXY}" \
    --build-arg https_proxy="${https_proxy}" \
    --build-arg HTTPS_PROXY="${HTTP_PROXY}" \
    --build-arg ftp_proxy="${ftp_proxy}" \
    --build-arg FTP_PROXY="${FTP_PROXY}" \
    --build-arg no_proxy="${no_PROXY}" \
    --build-arg NO_PROXY="${NO_PROXY}" \
    ${_ADD_DOCKER_OPTS[@]} \
    .
}

function __container_run() {
  local _env_proxy=$( \
    printenv \
    | grep -i "_proxy=" \
    | while read -r x
    do
      echo -n " -e $x"
    done \
  )
  __echo_exec docker container run \
    -it --name ${_CONTAINER_NAME} \
    --env-file ${_BASE_DIR}/etc/docker-container.conf \
    ${_env_proxy} ${_BOOT_STATE:-"-d=false"} ${_ONCE} \
    ${_ADD_DOCKER_OPTS[@]} ${_IMAGE_NAME}
}

function __container_start() {
  __echo_exec docker container start ${_CONTAINER_NAME}
}

function __container_stop() {
  __echo_exec docker container stop ${_CONTAINER_NAME}
}

function __container_restart() {
  __echo_exec docker container restart ${_CONTAINER_NAME}
}

function __container_enable() {
  __echo_exec docker container update --restart=always ${_CONTAINER_NAME}
}

function __container_disable() {
  __echo_exec docker container update --restart=no ${_CONTAINER_NAME}
}

function __container_remove() {
  __echo_exec docker container rm ${_CONTAINER_NAME}
}

function __image_remove() {
  __echo_exec docker image rm ${_IMAGE_NAME}
}

function __container_exec() {
  __echo_exec docker container exec -it ${_CONTAINER_NAME} ${_EXEC_CMD[@]}
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
      _ADD_DOCKER_OPTS=($@)
      __container_run
    ;;
    build )
      shift 1
      _ADD_DOCKER_OPTS=($@)
      __container_build  
    ;;
    rebuild )
      _IMAGE_ID_BEFORE=$( \
        docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" \
          | grep ${_IMAGE_NAME} \
          | awk '{print $1}'
      )
      shift 1
      _ADD_DOCKER_OPTS=($@)
      __container_build

      _IMAGE_ID_AFTER=$( \
        docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" \
          | grep ${_IMAGE_NAME} \
          | awk '{print $1}'
      )
      if [ "${_IMAGE_ID_BEFORE}" != "${_IMAGE_ID_AFTER}" ]; then
        if [ ! -z "${_IMAGE_ID_BEFORE}" ]; then
          __echo_exec docker image rm ${_IMAGE_ID_BEFORE}
        fi
      fi
    ;;
    start )
      __container_start
    ;;
    stop )
      __container_stop
    ;;
    restart )
      __container_restart
    ;;
    enable )
      __container_enable
    ;;
    disable )
      __container_disable
    ;;
    container-rm )
      __container_remove
    ;;
    image-rm )
      __image_remove
    ;;
    purge )
      __container_remove && \
      __image_remove
    ;;
    login )
      _EXEC_CMD=("/bin/bash")
      __container_exec 
    ;;
    exec )
      shift 1
      _EXEC_CMD=($@)
      __container_exec 
    ;;
    * )
      echo "missing operand" >&2
    ;;
  esac
fi
