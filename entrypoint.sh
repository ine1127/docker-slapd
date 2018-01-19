#!/bin/bash

source ${CONST_LDAP_RUNTIME_DIR}/functions

function __usage() {
  cat <<EOL
$(basename ${0}) is a script for starting slapd service in Docker container

Usage:
    $(basename ${0}) [[command] [arguments]]

Command:
    init            initialize settings
    start           init and start slapd
    stop            stop slapd
    status          check status
    backup_config   OpenLDAP config backup (using slapcat)
    backup_dbdata   OpenLDAP Database backup
    exec            execute linux command on Docker container
                    required [arguments]

    ex)
        $ $(basename ${0}) exec ls -la
EOL
}

if [ ! -z $1 ]; then
  case $1 in
    --help|-h|help|--usage|usage )
      __usage
    ;;
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
    backup_config )
      __slapd_backup config
    ;;
    backup_dbdata )
      __slapd_backup dbdata
    ;;
    * )
      exec $@
    ;;
  esac
else
  __usage
  exit 1
fi
