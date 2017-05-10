#!/bin/bash

source ${LDAP_RUNTIME_DIR}/functions

if [ ! -z $1 ]; then
  case $1 in
    start|stop )
      __slapd_call_pid
      __slapd_start_bg
      bash ${LDAP_RUNTIME_DIR}/init-setup.sh
      if [ ! -z ${_PID} ]; then
        case $1 in
          start )
            __slapd_call_pid
            __slapd_stop_proc
            __slapd_call_pid
            __slapd_start_proc
          ;;
          stop )
            __slapd_stop_proc
          ;;
          status )
            __slapd_status_proc
          ;;
        esac
      fi
    ;;
    * )
      exec $@
    ;;
  esac
fi
