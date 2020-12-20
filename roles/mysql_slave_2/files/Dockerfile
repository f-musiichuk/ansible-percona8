# https://github.com/docker-library/percona
# vim:set ft=dockerfile:
FROM debian:jessie

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
#RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN groupadd -g 1001 mysql; \
	useradd -u 1001 -r -g 1001 -s /sbin/nologin \
	-c "Default Application User" mysql

# install "pwgen" for randomizing passwords
RUN apt-get update && apt-get install -y pwgen gnupg2 wget lsb-release curl && rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint-initdb.d

RUN wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

RUN percona-release setup ps80

ENV PERCONA_MAJOR 8.0
ENV DEBIAN_FRONTEND noninteractive

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN  \
	echo "percona-server-server-${PERCONA_MAJOR} percona-server-server/root_password password unused" | debconf-set-selections \
	&& echo "percona-server-server-${PERCONA_MAJOR} percona-server-server/root_password_again password unused" | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y percona-server-server \
	&& apt-get install -y percona-xtrabackup \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql

RUN set -ex; \
	/usr/bin/install -m 0775 -o mysql -g root -d /var/lib/mysql /var/run/mysqld /docker-entrypoint-initdb.d

# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
	&& echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
	&& mv /tmp/my.cnf /etc/mysql/my.cnf
RUN \
	chown -R mysql:root /etc/mysql/my.cnf; \
	chmod -R ug+rwX /etc/mysql/my.cnf



# set date/time
RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER mysql
EXPOSE 3306
CMD ["mysqld"]
