FROM centos:6.9
LABEL maintainer "ine1127"

ENV LDAP_HOME_DIR="/home/ldap-exec"
ENV LDAP_RUNTIME_DIR="${LDAP_HOME_DIR}/runtime" \
    LDAP_WORK_DIR="${LDAP_HOME_DIR}/init-work"

COPY entrypoint.sh /sbin/entrypoint.sh

RUN yum -y update && \
    yum -y install openldap-servers openldap-clients && \
    rm -rf /var/lib/yum/* && \
    cp -p /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG && \
    chown -R ldap:ldap /var/lib/ldap && \
    mkdir ${LDAP_HOME_DIR} ${LDAP_WORK_DIR} && \
    chown -R ldap:ldap ${LDAP_HOME_DIR} && \
    chmod 755 /sbin/entrypoint.sh

COPY runtime/ ${LDAP_RUNTIME_DIR}

EXPOSE 389

WORKDIR ${LDAP_HOME_DIR}

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start"]
