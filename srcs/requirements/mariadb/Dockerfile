FROM debian:12

#ENV TERM=xterm

RUN apt update && apt install -y mariadb-server
#RUN apt install -y procps

RUN mkdir /run/mysqld && chown mysql:mysql /run/mysqld

RUN sed -i "s|bind-address            = 127.0.0.1|bind-address            = 0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

COPY ./requirements/mariadb/tools/* .

RUN chmod +x create_db.sh && ./create_db.sh && rm create_db.sh

EXPOSE 3306

USER mysql

CMD ["mariadbd"]
#CMD ["/usr/bin/watch", "-n", "1", "echo aaa"]
