FROM centos:6.9
LABEL maintainer "ine1127"

ENV LDAP_HOME_DIR="/home/ldap"
ENV LDAP_RUNTIME_DIR="${LDAP_HOME_DIR}/runtime" \
    LDAP_WORK_DIR="${LDAP_HOME_DIR}/work" \
    LDAP_CERTS_DIR="/etc/openldap/certs" \
    LDAP_DBDATA_DIR="/var/lib/ldap"

ENV LDAP_NSSDB_KEY="${LDAP_CERTS_DIR}/key3.db" \
    LDAP_NSSDB_CERT="${LDAP_CERTS_DIR}/cert8.db" \
    LDAP_NSSDB_SECMOD="${LDAP_CERTS_DIR}/secmod.db" \
    LDAP_NSSDB_NOISE="${LDAP_CERTS_DIR}/noise" \
    LDAP_NSSDB_PASS="${LDAP_CERTS_DIR}/password"

COPY entrypoint.sh /sbin/entrypoint.sh

RUN yum -y update && \
    yum -y install \
           openldap-servers \
           expect \
           epel-release && \
    yum -y install lmdb && \
    rm -rf /var/lib/yum/* && \
    rm -rf /var/cache/yum/* && \
    rm -rf /etc/openldap/slapd.d/* && \
    rm -rf ${LDAP_CERTS_DIR}/* && \
    rm -rf ${LDAP_CERTS_DIR}/.??* && \
    cp -p  /usr/share/openldap-servers/DB_CONFIG.example \
           /var/lib/ldap/DB_CONFIG && \
    mkdir  ${LDAP_HOME_DIR} ${LDAP_WORK_DIR} && \
    chown -R ldap:ldap /var/lib/ldap && \
    chown -R ldap:ldap ${LDAP_HOME_DIR} && \
    chmod 755 /sbin/entrypoint.sh

COPY runtime/ ${LDAP_RUNTIME_DIR}

EXPOSE 389/tcp 636/tcp

WORKDIR ${LDAP_HOME_DIR}

VOLUME ["${LDAP_CERTS_DIR}", "${LDAP_DBDATA_DIR}"]

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start"]
