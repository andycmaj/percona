#
# Percona Server Dockerfile
#
# https://github.com/dockerfile/percona
#

# Pull base image.
FROM dockerfile/ubuntu

# Copy bootstrap scripts to container. Fuck if I can get -v host:container mounting to work correctly!
ADD bootstrap/ /data/bootstrap/

# Install Percona Server.
RUN \
  apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A && \
  echo "deb http://repo.percona.com/apt `lsb_release -cs` main" > /etc/apt/sources.list.d/percona.list && \
  apt-get update && \
  apt-get install -y percona-server-server-5.6 && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(bind-address\s*=\s*\)127\.0\.0\.1/\10.0.0.0/' /etc/mysql/my.cnf && \
  sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
  echo "mysqld_safe &" > /tmp/config && \
  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
  echo "for f in /data/bootstrap/*.sql" >> /tmp/config && \
  echo "do" >> /tmp/config && \
  echo "  mysql < \$f" >> /tmp/config && \
  echo "done" >> /tmp/config && \
  bash /tmp/config && \
  rm -f /tmp/config

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql", "/var/logs"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["mysqld_safe"]

# Expose ports.
EXPOSE 3306
