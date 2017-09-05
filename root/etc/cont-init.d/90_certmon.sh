#!/usr/bin/with-contenv bash
set -eo pipefail

shopt -s nocasematch
if [[ $DEBUG == "TRUE" ]]
 then
	set -x
fi

: ${MONITOR_CERTIFICATE:="FALSE"}
: ${CERTIFICATE_KEY_PATH:="/certs/ftpd.key"}
: ${CERTIFICATE_FULLCHAIN_PATH:="/certs/ftpd.pem"}
: ${CERTIFICATE_DHPARAMS_PATH:="/certs/dhparams.pem"}

CERTIFICATE_DIR="/etc/ssl/private"

if [[ $MONITOR_CERTIFICATE == "TRUE" ]]
 then

	if [[ ! -d $CERTIFICATE_DIR ]]
	 then
		mkdir $CERTIFICATE_DIR
	fi

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

        if [[ ! -f $CERTIFICATE_DIR/pure-ftpd.pem ]]
         then
                cat  $CERTIFICATE_KEY_PATH > $CERTIFICATE_DIR/pure-ftpd.pem
		echo >> $CERTIFICATE_DIR/pure-ftpd.pem
		cat $CERTIFICATE_FULLCHAIN_PATH >> $CERTIFICATE_DIR/pure-ftpd.pem
        fi

	if [[ ! -f $CERTIFICATE_DIR/pure-ftpd-dhparams.pem && ! -f $CERTIFICATE_DHPARAMS_PATH ]]
	 then
		echo "dhparams.pem not found - Remember to mount it from the host"
       	elif [[ -f $CERTIFICATE_DHPARAMS_PATH  && ! -f $CERTIFICATE_DIR/pure-ftpd-dhparams.pem ]]
	 then
		cp $CERTIFICATE_DHPARAMS_PATH $CERTIFICATE_DIR/pure-ftpd-dhparams.pem
		
	fi

        mkdir /etc/services.d/cert-mon
        dockerize -template /app/cert-mon.tmpl > /etc/services.d/cert-mon/run
	chmod +x /etc/services.d/cert-mon/run
fi
