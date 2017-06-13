#!/bin/bash

source ${LDAP_RUNTIME_DIR}/environments

umask 0077
expect -c "
set timeout 2
spawn env LANG=C /usr/bin/openssl req -utf8 \
                 -newkey rsa \
                 -keyout ${SSL_CERT_DIR}/${SSL_KEY_FILE} \
                 -nodes -x509 -days 3650 \
                 -out ${SSL_CERT_DIR}/${SSL_PEM_FILE} \
                 -set_serial 0
expect {
  -exact \"Country Name (2 letter code) \[XX\]:\" {
    send \"${SSL_COUNTRY_NAME}\n\"
  }
}

expect {
  -exact \"State or Province Name (full name) \[\]:\" {
    send \"${SSL_STATE_NAME}\n\"
  }
}

expect {
  -exact \"Locality Name (eg, city) \[Default City\]:\" {
    send \"${SSL_CITY_NAME}\n\"
  }
}

expect {
  -exact \"Organization Name (eg, company) \[Default Company Ltd\]:\" {
    send \"${SSL_ORG_NAME}\n\"
  }
}

expect {
  -exact \"Organizational Unit Name (eg, section) \[\]:\" {
    send \"${SSL_ORG_UNIT}\n\"
  }
}

expect {
  -exact \"Common Name (eg, your name or your server\'s hostname) \[\]:\" {
    send \"${SSL_HOST_NAME}\n\"
  }
}

expect {
  -exact \"Email Address \[\]:\" {
    send \"${SSL_MAIL_ADDR}\n\"
    interact
  }
}
"

#chmod 600 /etc/openldap/certs/server.key
#chmod 600 /etc/openldap/certs/server.pem
