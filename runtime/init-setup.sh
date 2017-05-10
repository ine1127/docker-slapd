#!/bin/bash

source ${LDAP_RUNTIME_DIR}/functions

__ldap_load_domain
__ldap_add_manager_pass
__ldap_mod_manager_domain
__ldap_add_base_domain
__ldap_add_unit_user
__ldap_add_unit_group
__ldap_add_base_in_config

ldapadd -Y EXTERNAL -H ldapi:// -f ${LDAP_WORK_DIR}/add_manager_pass.ldif
ldapmodify -x -D cn=config -w ${LDAP_MANAGER_PASS} -f ${LDAP_WORK_DIR}/mod_manager_domain.ldif
ldapadd -x -D "cn=${LDAP_MANAGER_NAME},${LDAP_MANAGER_DOMAIN}" -w ${LDAP_MANAGER_PASS} -f ${LDAP_WORK_DIR}/add_base_domain.ldif
ldapadd -x -D "cn=${LDAP_MANAGER_NAME},${LDAP_MANAGER_DOMAIN}" -w ${LDAP_MANAGER_PASS} -f ${LDAP_WORK_DIR}/add_unit_user.ldif
ldapadd -x -D "cn=${LDAP_MANAGER_NAME},${LDAP_MANAGER_DOMAIN}" -w ${LDAP_MANAGER_PASS} -f ${LDAP_WORK_DIR}/add_unit_group.ldif
