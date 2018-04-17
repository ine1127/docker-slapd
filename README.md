# docker-slapd

![TravisCI Status](https://travis-ci.org/ine1127/docker-slapd.svg?branch=master)

Dockernized OpenLDAP Server

# Download

```shell-session
user@linux:~$ git clone https://github.com/ine1127/docker-slapd.git
```

# Build

```shell-session
user@linux:~$ ./docker-service.sh build
```

or

```shell-session
docker build --tag=ine1127/docker-slapd:0.4.5 \
             --build-arg http_proxy=${http_proxy} \
             --build-arg HTTP_PROXY=${HTTP_PROXY} \
             --build-arg https_proxy=${https_proxy} \
             --build-arg HTTPS_PROXY=${HTTPS_PROXY} \
             --build-arg ftp_proxy=${ftp_proxy} \
             --build-arg FTP_PROXY=${FTP_PROXY} \
             --build-arg no_proxy=${no_proxy} \
             --build-arg NO_PROXY=${NO_PROXY} \
             .
```

# Quick Start

```shell-session
user@linux:~$ ./docker-service.sh onceboot
```

or

```shell-session
user@linux:~$ docker run --name docker-slapd --rm ine1127/docker-slapd:0.4.5
```

# Data Store

Mount volume

- /home/ldap/openldap

Create mount directory

```
user@linux$ sudo mkdir -p /srv/docker-slapd/openldap
user@linux$ sudo chown 55:55 /srv/docker-slapd/openldap
```

Volumes can be mounted in docker by specifying the `-v` option in the docker run command.

```shell-session
user@linux:~$ docker run --name docker-slapd --rm \
                --volume /srv/docker-slapd/openldap:/home/ldap/openldap \
                ine1127/docker-slapd:0.4.5
```

# OpenLDAP Parameters

```shell-session
user@linux:~$ vi etc/docker-container.conf
```

|Variable|Default|Description|
|:--|:--|:--|
| `LDAP_DOMAIN` | `example.com` | OpenLDAP Top Level Domain. Convert from domain to ldif format. `example.com` => `dc=example,dc=com` |
| `LDAP_ORGNAME` | `Example Inc.` | OpenLDAP Organization Name |
| `LDAP_ORGNAME_DESC` | `${LDAP_ORGNAME}` | OpenLDAP Organization Description |
| `LDAP_PEOPLE` | `People` | OpenLDAP Users `ou` Name |
| `LDAP_PEOPLE_DESC` | `${LDAP_PEOPLE}` | OpenLDAP Users `ou` Description |
| `LDAP_GROUP` | `Group` | OpenLDAP Groups `ou` Name |
| `LDAP_GROUP_DESC` | `${LDAP_GROUP}` | OpenLDAP Groups `ou` Description  |
| `LDAP_MANAGER_NAME` | `Manager` | OpenLDAP Manager Name |
| `LDAP_MANAGER_PASS` | `secret `| OpenLDAP Manager Password |
| `LDAP_DATABASE` | `mdb` | OpenLDAP use Database |
| `LDAP_LOGLEVEL` | `512` | Specify `olcLogLevel` in `slapd.d/cn=config.ldif` |
| `SLAPD_DEBUGLEVEL` | `512` | Specify Debugging Level when `slapd` runtime |
| `SLAPD_LDAP` | `yes` | Specify `-h ldap:///` option when you `slapd` runtime (`yes` or `no`) |
| `SLAPD_LDAPI` | `yes` | Specify `-h ldapi:///` option when you `slapd` runtime (`yes` or `no`) |
| `SLAPD_LDAPS` | `no` | Specify `-h ldaps:///` option when you `slapd` runtime (`yes` or `no`) |
| `CA_PEM_FILE` | `ca.pem` | Output CA Certificate PEM file name when you specified `yes` in `${GENERATE_SELFSIGNED_CACERT}` and not exist `${CA_PEM_FILE}` |
| `SERVER_PEM_FILE` | `server.pem` | Output OpenLDAP Server PEM file name when you specified `yes` in `${GENERATE_SELFSIGNED_CACERT}` and not exist `${SERVER_PEM_FILE}` |
| `SSL_HOSTNAME` | `${HOSTNAME}` | Self Signed Certificate subject |
| `CERT_CA_CN` | `Private CA` | CA Certificate Common Name |
| `CERT_CA_O` | `Example Inc.` | CA Certificate Organization |
| `CERT_CA_C` | `JP` | CA Certificate Country |
| `CERT_SV_CN` | `ldap.example.com` | Server Certificate Common Name |
| `NSSDB_PASSWORD` | `secretpw` | Mozilla NSS Database Password |
| `NSSDB_CACERT_NAME` | `CA Certificate` | Mozilla NSS CA Certificate Name|
| `NSSDB_CERT_NAMe` | `OpenLDAP Server` | Mozilla NSS Certificate Name|
