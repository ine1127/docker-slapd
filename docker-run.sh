#!/bin/bash

function __load_global_variables() {
_CONTAINER_NAME=$(cat ./info/CONTAINER_NAME)
_VERSION=$(cat ./info/VERSION)
_IMAGE_REPO=$(cat ./info/IMAGE_REPO)

_IMAGE_NAME="${_IMAGE_REPO}/${_CONTAINER_NAME}:${_VERSION}"
}

function __load_configure() {
if [ ! -z $1 ]; then
  local _config_file=$1
  if [ -s $1 ]; then
    source ${_config_file}
  fi
fi
}

__load_global_variables
__load_configure ./etc/docker-container.conf

if [ $# -ge 1 ]; then
  for _OPT in $@
  do
    case $_OPT in
      fg )
        if [ -z ${_BOOT_STATE} ]; then
          _BOOT_STATE="-d=false"
        else
          echo "duplicate option [fg/bg]"
        fi
        shift 1
      ;;
      bg )
        if [ -z ${_BOOT_STATE} ]; then
          _BOOT_STATE="-d=true"
        else
          echo "duplicate option [fg/bg]"
        fi
        shift 1
      ;;
      once )
        _ONCE="--rm"
        shift 1
      ;;
      "${_IMAGE_NAME}" )
        shift 1
      ;;
      * )
        _EXEC_CMD+=(${_OPT})
        shift 1
      ;;
    esac
  done
else
  echo "missing operand" >&2
  echo "$0 -- [image:tag] [fg,bg] {once}" >&2
  exit 1
fi

if [ ! -z ${_EXEC_CMD} ]; then
  _EXEC_CMD=(/bin/sh -c "${_EXEC_CMD[@]}")
fi

_BOOT_STATE=${_BOOT_STATE:-"-d=false"}

docker container run -it ${_ONCE} ${_BOOT_STATE} --name ${_CONTAINER_NAME}\
  -e LDAP_DOMAIN=${LDAP_DOMAIN} \
  -e LDAP_ORGNAME=${LDAP_ORGNAME} \
  -e LDAP_ORGNAME_DESC=${LDAP_ORGNAME} \
  -e LDAP_PEOPLE=${LDAP_PEOPLE} \
  -e LDAP_PEOPLE_DESC=${LDAP_PEOPLE_DESC} \
  -e LDAP_GROUP=${LDAP_GROUP} \
  -e LDAP_GROUP_DESC=${LDAP_GROUP_DESC} \
  -e LDAP_MANAGER_NAME=${LDAP_MANAGER_NAME} \
  -e LDAP_MANAGER_PASS=${LDAP_MANAGER_PASS} \
  -e LDAP_MANAGER_DOMAIN=${LDAP_MANAGER_DOMAIN} \
  ${_IMAGE_NAME} ${_EXEC_CMD[@]}
