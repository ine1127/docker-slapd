#!/bin/bash

source ${LDAP_RUNTIME_DIR}/functions

if [ ! -z $1 ]; then
  case $1 in
    start|init )
      __slapd_load_domain
      __slapd_deploy
      __slapd_install
      __slapd_cleanup

      case $1 in
        start )
          __slapd_start
        ;;
      esac

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
