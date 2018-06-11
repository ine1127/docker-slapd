#!/bin/bash

source "${CONST_LDAP_RUNTIME_DIR}/functions"

##########################################################
# Output script usage
# Environments:
#   None
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##########################################################
function __usage() {
  local _script_name="$0"
  cat <<EOL
${_script_name} is a script for starting slapd service on Docker container

Usage:
    ${_script_name} [[command] [arguments]]

Command:
    init            initialize settings
    start           init and start slapd
    stop            stop slapd
    status          check status
    backup_config   OpenLDAP config backup (using slapcat)
    backup_dbdata   OpenLDAP Database backup
    exec            execute linux command on Docker container
                    required [arguments]

    exec e.g)
        $ ${_script_name} exec ls -la
EOL
}

function __main() {
  local readonly _argument="$1"

  if [ ! -z "${_argument}" ]; then
    case "${_argument}" in
      --help|-h|help|--usage|usage )
        __usage
      ;;
      start|init )
        __slapd_load_domain
        __slapd_deploy
        __slapd_install
        __slapd_test
        __slapd_cleanup

        case "${_argument}" in
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
        exec "$@"
      ;;
    esac

  else
    __usage
    exit 1
  fi
}

__main "$@"
