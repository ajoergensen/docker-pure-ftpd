#!/usr/bin/with-contenv bash

# Load in any existing db from volume store
if [ -e /etc/pure-ftpd/passwd/pureftpd.passwd ]
 then
	pure-pw mkdb /etc/pure-ftpd/pureftpd.pdb -f /etc/pure-ftpd/passwd/pureftpd.passwd
fi
