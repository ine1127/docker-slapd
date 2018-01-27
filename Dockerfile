FROM centos:6.9
LABEL maintainer "ine1127"

ENV CONST_LDAP_ROOT_DIR="/home/ldap"
ENV CONST_LDAP_RUNTIME_DIR="${CONST_LDAP_ROOT_DIR}/runtime" \
    CONST_LDAP_WORK_DIR="${CONST_LDAP_ROOT_DIR}/work" \
    CONST_LDAP_CERTS_DIR="${CONST_LDAP_ROOT_DIR}/certs" \
    CONST_LDAP_DBDATA_DIR="${CONST_LDAP_ROOT_DIR}/dbdata" \
    CONST_LDAP_CONFIG_DIR="${CONST_LDAP_ROOT_DIR}/slapd.d"

ENV CONST_LDAP_NSSDB_SECMOD="${CONST_LDAP_CERTS_DIR}/secmod.db" \
    CONST_LDAP_NSSDB_NOISE="${CONST_LDAP_CERTS_DIR}/noise" \
    CONST_LDAP_NSSDB_PASS="${CONST_LDAP_CERTS_DIR}/password"

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh

RUN yum -y update && \
    yum -y install \
           openldap-servers \
           epel-release && \
    yum -y install lmdb && \
    rm -rf /var/lib/yum/* && \
    rm -rf /var/cache/yum/* && \
    rm -rf /etc/openldap/slapd.d/* && \
    mkdir  ${CONST_LDAP_ROOT_DIR} ${CONST_LDAP_WORK_DIR} \
           ${CONST_LDAP_CERTS_DIR} ${CONST_LDAP_DBDATA_DIR} && \
    mkdir  -m 0750 ${CONST_LDAP_CONFIG_DIR} && \
    chown  -R ldap:ldap ${CONST_LDAP_ROOT_DIR} && \
    chmod  755 /usr/local/sbin/entrypoint.sh

COPY runtime/ ${CONST_LDAP_RUNTIME_DIR}

EXPOSE 389/tcp 636/tcp

WORKDIR ${CONST_LDAP_ROOT_DIR}

VOLUME ["${CONST_LDAP_CERTS_DIR}", "${CONST_LDAP_DBDATA_DIR}", "${CONST_LDAP_CONFIG_DIR}"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["start"]
