FROM ajoergensen/baseimage-alpine

MAINTAINER ajoergensen

RUN \
	apk -U update && \
	apk add pure-ftpd && \
	rm /var/cache/apk/* 

ADD root/ /

RUN \
	chmod -v +x /etc/cont-init.d/*.sh /etc/services.d/*/run

# default publichost, you'll need to set this for passive support
ENV PUBLICHOST ftp.foo.com

# couple available volumes you may want to use
VOLUME ["/home/ftpusers", "/etc/pure-ftpd/passwd"]

EXPOSE 21 30000-30009

