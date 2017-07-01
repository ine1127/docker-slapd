FROM centos:6.9
LABEL maintainer "ine1127"

ENV LDAP_ROOT_DIR="/home/ldap"
ENV LDAP_RUNTIME_DIR="${LDAP_ROOT_DIR}/runtime" \
    LDAP_WORK_DIR="${LDAP_ROOT_DIR}/work" \
    LDAP_CERTS_DIR="${LDAP_ROOT_DIR}/certs" \
    LDAP_DBDATA_DIR="${LDAP_ROOT_DIR}/dbdata" \
    LDAP_CONFIG_DIR="${LDAP_ROOT_DIR}/slapd.d"

ENV LDAP_NSSDB_KEY="${LDAP_CERTS_DIR}/key3.db" \
    LDAP_NSSDB_CERT="${LDAP_CERTS_DIR}/cert8.db" \
    LDAP_NSSDB_SECMOD="${LDAP_CERTS_DIR}/secmod.db" \
    LDAP_NSSDB_NOISE="${LDAP_CERTS_DIR}/noise" \
    LDAP_NSSDB_PASS="${LDAP_CERTS_DIR}/password"

COPY entrypoint.sh /sbin/entrypoint.sh

RUN yum -y update && \
    yum -y install \
           openldap-servers \
           epel-release && \
    yum -y install lmdb && \
    rm -rf /var/lib/yum/* && \
    rm -rf /var/cache/yum/* && \
    rm -rf /etc/openldap/slapd.d/* && \
    mkdir  ${LDAP_ROOT_DIR} ${LDAP_WORK_DIR} \
           ${LDAP_CERTS_DIR} ${LDAP_DBDATA_DIR} && \
    mkdir  -m 0750 ${LDAP_CONFIG_DIR} && \
    chown  -R ldap:ldap ${LDAP_ROOT_DIR} && \
    chmod  755 /sbin/entrypoint.sh

COPY runtime/ ${LDAP_RUNTIME_DIR}

EXPOSE 389/tcp 636/tcp

WORKDIR ${LDAP_ROOT_DIR}

VOLUME ["${LDAP_CERTS_DIR}", "${LDAP_DBDATA_DIR}", "${LDAP_CONFIG_DIR}"]

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start"]
