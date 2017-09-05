#!/usr/bin/with-contenv bash
set -eo pipefail

: ${MONITOR_CERTIFICATE:="FALSE"}
: ${CERTIFICATE_KEY_PATH:="/certs/ftpd.key"}
: ${CERTIFICATE_FULLCHAIN_PATH:="/certs/ftpd.pem"}
: ${CERTIFICATE_DHPARAMS_PATH:="/certs/dhparams.pem"}

shopt -s nocasematch
if [[ $MONITOR_CERTIFICATE == "TRUE" ]]
 then
        if [[ ! -f $CERTIFICATE_KEY_PATH ]]
         then
                echo "Error: $CERTIFICATE_KEY_PATH not found"
                exit 1
        fi

        if [[ ! -f $CERTIFICATE_FULLCHAIN_PATH ]]
         then
                echo "Error: $CERTIFICATE_FULLCHAIN_PATH not found"
                exit 1
        fi

        if [[ ! -f /etc/ssl/private/pure-ftpd.pem ]]
         then
                cat  $CERTIFICATE_KEY_PATH $CERTIFICATE_FULLCHAIN_PATH > /etc/ssl/private/pure-ftpd.pem
        fi

	if [[ ! -f /etc/ssl/private/pure-ftpd-dhparams.pem && ! -f $CERTIFICATE_DHPARAMS_PATH ]]
	 then
		echo "dhparams.pem not found - Remember to mount it from the host"
       	elif [[ -f $CERTIFICATE_DHPARAMS_PATH  && ! -f /etc/ssl/private/pure-ftpd-dhparams.pem ]]
	 then
		cp $CERTIFICATE_DHPARAMS_PATH /etc/ssl/private/pure-ftpd-dhparams.pem
		
	fi

        mkdir /etc/services.d/cert-mon
        dockerize -template /app/cert-mon.tmpl > /etc/services.d/cert-mon/run
	chmod +x /etc/services.d/cert-mon/run
fi
