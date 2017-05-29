#!/bin/bash

source ${LDAP_RUNTIME_DIR}/functions

if [ ! -z $1 ]; then
  case $1 in
    start )
      __slapd_load_domain
      __slapd_install
      __slapd_configure
      __slapd_start
    ;;
    stop )
      __slapd_stop
    ;;
    status )
      __slapd_status
    ;;
    * )
      exec $@
    ;;
  esac
fi
