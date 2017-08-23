pure-ftpd container
===================

[![](https://images.microbadger.com/badges/image/ajoergensen/pure-ftpd.svg)](https://microbadger.com/images/ajoergensen/pure-ftpd "Get your own image badge on microbadger.com") [![Build Status](https://travis-ci.org/ajoergensen/docker-pure-ftpd.svg?branch=master)](https://travis-ci.org/ajoergensen/docker-pure-ftpd)

pure-ftpd with virtual users. Based on [stilliard/docker-pure-ftpd](https://github.com/stilliard/docker-pure-ftpd)

Main differences:

- Based on Alpine Linux, not Debian
- s6 init

### Usage

#### Plain FTP

```docker run -d --name ftpd_server -p 20-21:20-21 -p 30000-30009:30000-30009 -e "PUBLICHOST=localhost" ajoergensen/pure-ftpd```

#### FTP with TLS

```docker run -d --name ftpd_server -p 20-21:20-21 -p 30000-30009:30000-30009 -e "PUBLICHOST=localhost" -v ./certs:/etc/ssl/private:ro ajoergensen/pure-ftpd```

In the default configuration only TLSv1.2 and strong ciphers are used ([testssl.sh report](https://ajoergensen.github.io/docker-pure-ftpd/testssl.sh.html))

##### Certificate

The directory/volume used for `/etc/ssl/private/` must contain the file `pure-ftpd.pem`.

`pure-ftpd.pem` must contain the private key, certificate and all intermediate certificates needed.

```bash
cat private-key.pem certificate.pem intermediate.pem > pure-ftpd.pem
```

##### dhparams

If you place a file called `pure-ftpd-dhparams.pem` in `/etc/ssl/private` it will be used by pure-ftpd

The dhparams should be at least 2048 bits:

```bash
# openssl dhparam -out pure-ftpd-dhparams.pem 4096
```

### Environment

 - `ADDED_FLAGS`: Any command line options to be added to the default
 - `PUBLICHOST`: Host/IP used for PASV
 - `CIPHER_LIST`: List of SSL ciphers to use/support if TLS is enabled, default is ```ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256``` ([Mozilla modern cipher list](https://mozilla.github.io/server-side-tls/ssl-config-generator/))

### Management

To enter the running container: `docker exec -it ftpd_server bash`

This comes in handy for managing user

`pure-pw useradd bob -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/bob`

This will add a virtual user bob chroot'ed into /home/ftpusers/bob.

For more information: https://download.pureftpd.org/pure-ftpd/doc/README.Virtual-Users

### Logs

To get verbose logs add the following to your `docker run` command:
```
-e "ADDED_FLAGS=-d -d"
```

Then follow the output with `docker logs -f ftpd_server`

Want a transfer log file? add the following to your `docker run` command:
```bash
-e "ADDED_FLAGS=-O w3c:/var/log/pure-ftpd/transfer.log"
```

### Default options

```
/usr/sbin/pure-ftpd # path to pure-ftpd executable
-c 50 # --maxclientsnumber (no more than 50 people at once)
-C 10 # --maxclientsperip (no more than 10 requests from the same ip)
-l puredb:/etc/pure-ftpd/pureftpd.pdb # --login (login file for virtual users)
-E # --noanonymous (only real users)
-j # --createhomedir (auto create home directory if it doesnt already exist)
-R # --nochmod (prevent usage of the CHMOD command)
-P $PUBLICHOST # IP/Host setting for PASV support, passed in your the PUBLICHOST env var
-p 30000:30009 # PASV port range
-tls 1 # Enables optional TLS support
```

For more information please see `man pure-ftpd`, or visit: https://www.pureftpd.org/


### Volumes

  - `/home/ftpusers/` The ftp's data volume (by convention). 
  - `/etc/pure-ftpd/passwd` A directory containing the single `pureftps.passwd`
    file which contains the user database (i.e., all virtual users, their
    passwords and their home directories). This is read on startup of the
    container and updated by the `pure-pw useradd -f /etc/pure-
    ftpd/passwd/pureftpd.passwd ...` command.
  - `/etc/ssl/private/` A directory containing a single `pure-ftpd.pem` file
    with the server's SSL certificates for TLS support. Optional TLS is
    automatically enabled when the container finds this file on startup.
