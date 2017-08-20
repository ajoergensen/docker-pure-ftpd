pure-ftpd container
===================

pure-ftpd with virtual users. Based on [stilliard/docker-pure-ftpd](https://github.com/stilliard/docker-pure-ftpd)

### Usage

`docker run -d --name ftpd_server -p 21:21 -p 30000-30009:30000-30009 -e "PUBLICHOST=localhost" ajoergensen/pure-ftpd`

### Environment

 - **ADDED_FLAGS**: Any command line options to be added to the default
 - **PUBLIC_HOST**: Host/IP used for PASV

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
