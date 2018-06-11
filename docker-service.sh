#!/bin/bash

function __echo_exec() {
  echo "$@" >&2
  eval "$@"
}

function __load_global_variables() {
  _BASE_DIR="$(dirname "$(readlink -f "$0")")"
  _CONTAINER_NAME="$(cat "${_BASE_DIR}/info/CONTAINER_NAME")"
  _VERSION="$(cat "${_BASE_DIR}/info/VERSION")"
  _IMAGE_REPO="$(cat "${_BASE_DIR}/info/IMAGE_REPO")"
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
    "${_DOCKER_BUILD_OPTS}" \
    .
}

function __container_run() {
  local readonly _env_proxy
  _env_proxy="$( \
    printenv \
      | grep -i "_proxy=" \
      | while read -r x; do
      echo -n " -e $x"
    done \
  )"

  local readonly _args1 _args2 _docker_args _exec_cmd
  eval "$( \
    echo "$@" \
      | awk -F "--exec" '{print "_args1=\""$1"\"\n_args2=\""$2"\""}' \
      | sed -e '/^$/d' \
  )"

  if [ ! -z "${_args2}" ]; then
    _docker_args="${_args1}"
    _exec_cmd="${_args2}"
  else
    echo "${_args1}" | grep '\--exec' > /dev/null 2>&1
    local _status="$?"

    if [ "${_status}" -eq "0" ]; then
      _exec_cmd="$(echo "${_args1}" | sed -e 's/--exec //g')"
    else
      _docker_args="${_args1}"
    fi
  fi

  __echo_exec docker container run \
    -it --name "${_CONTAINER_NAME}" \
    --env-file "${_BASE_DIR}/etc/docker-container.conf" \
    "${_env_proxy}" "${_BOOT_STATE:-"-d=false"}" "${_ONCE}" \
    "${_docker_args}" "${_IMAGE_NAME}" "${_exec_cmd}"
}

function __container_start() {
  __echo_exec docker container start "${_CONTAINER_NAME}"
}

function __container_stop() {
  __echo_exec docker container stop "${_CONTAINER_NAME}"
}

function __container_restart() {
  __echo_exec docker container restart "${_CONTAINER_NAME}"
}

function __container_enable() {
  __echo_exec docker container update --restart=always "${_CONTAINER_NAME}"
}

function __container_disable() {
  __echo_exec docker container update --restart=no "${_CONTAINER_NAME}"
}

function __container_remove() {
  __echo_exec docker container rm "${_CONTAINER_NAME}"
}

function __image_remove() {
  __echo_exec docker image rm "${_IMAGE_NAME}"
}

function __container_exec() {
  __echo_exec docker container exec -it "${_CONTAINER_NAME}" "$@"
}

function __main() {
  __load_global_variables

  if [ "$#" -ge 1 ]; then
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
        __container_run "$@"
      ;;
      build )
        shift 1
        _DOCKER_BUILD_OPTS="$@"
        __container_build  
      ;;
      rebuild )
        local readonly _before_image _after_image
        _before_image="$( \
          docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" \
            | grep "${_IMAGE_NAME}" \
            | awk '{print $1}' \
        )"
        shift 1
        _DOCKER_BUILD_OPTS="$@"
        __container_build

        _after_image="$( \
          docker image ls --format "{{.ID}} {{.Repository}}:{{.Tag}}" \
            | grep "${_IMAGE_NAME}" \
            | awk '{print $1}' \
        )"
        if [ "${_before_image}" != "${_after_image}" ]; then
          if [ ! -z "${_before_image}" ]; then
            __echo_exec docker image rm "${_before_image}"
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
        local _login_user _login_shell
        _login_user="$( \
          docker container inspect -f "{{.Config.User}}" "${_CONTAINER_NAME}" \
        )"
        _login_shell="$( \
          __container_exec "cat /etc/passwd \
            | grep "${_login_user}" \
            | awk -F ':' '{print \$NF}' \
            | tr -d \"\\r\"" 2> /dev/null \
          )"
        __container_exec "${_login_shell}"
      ;;
      exec )
        shift 1
        __container_exec "$@"
      ;;
      * )
        echo "missing operand" >&2
      ;;
    esac
  fi
}

__main "$@"
