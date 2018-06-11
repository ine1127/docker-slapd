FROM centos:6.9
LABEL maintainer "ine1127"

ARG LDAP_HOME_DIR="/home/ldap"
ARG LDAP_USR="ldap"
ARG LDAP_GRP="ldap"
ARG LDAP_UID="55"
ARG LDAP_GID="55"

ENV CONST_LDAP_USR="${LDAP_USR}" \
    CONST_LDAP_DATA_DIR="${LDAP_HOME_DIR}/openldap" \
    CONST_LDAP_RUNTIME_DIR="${LDAP_HOME_DIR}/runtime" \
    CONST_LDAP_WORK_DIR="${LDAP_HOME_DIR}/work"
ENV CONST_LDAP_BACKUP_DIR="${CONST_LDAP_DATA_DIR}/backup" \
    CONST_LDAP_CERTS_DIR="${CONST_LDAP_DATA_DIR}/certs" \
    CONST_LDAP_CONFIG_DIR="${CONST_LDAP_DATA_DIR}/slapd.d" \
    CONST_LDAP_DBDATA_DIR="${CONST_LDAP_DATA_DIR}/dbdata"

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh

RUN groupadd \
      -g "${LDAP_GID}" "${LDAP_GRP}" && \
    useradd \
      -g "${LDAP_GRP}" \
      -u "${LDAP_UID}" \
      -d "${LDAP_HOME_DIR}" \
      -s "/bin/bash" \
      -c "LDAP User" \
         "${LDAP_USR}" && \
    yum -y update && \
    yum -y install \
      openldap-clients \
      openldap-servers \
      epel-release && \
    yum -y install lmdb && \
    yum clean all && \
    rm -rf /etc/openldap/slapd.d/* && \
    runuser -m -s /bin/mkdir -- "${LDAP_USR}" \
      "${CONST_LDAP_WORK_DIR}" "${CONST_LDAP_DATA_DIR}" && \
    chmod 755 /usr/local/sbin/entrypoint.sh

COPY runtime/ "${CONST_LDAP_RUNTIME_DIR}"

EXPOSE 10389/tcp 10636/tcp

USER "${LDAP_USR}"

WORKDIR "${LDAP_HOME_DIR}"

VOLUME ["${CONST_LDAP_DATA_DIR}"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["start"]
