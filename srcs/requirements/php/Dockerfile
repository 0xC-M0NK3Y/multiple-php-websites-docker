FROM debian:12

#ENV TERM=xterm

RUN apt update && apt install -y php8.2-fpm php8.2-mysqli
#RUN apt install -y procps

RUN mkdir -p /var/www/websites

COPY ./requirements/php/conf/confs/* /etc/php/8.2/fpm/pool.d

EXPOSE 9000
EXPOSE 9001
EXPOSE 9002
EXPOSE 9003
EXPOSE 9004
EXPOSE 9005
EXPOSE 9006
EXPOSE 9007
EXPOSE 9008
EXPOSE 9009
EXPOSE 9010
EXPOSE 9011
EXPOSE 9012
EXPOSE 9013
EXPOSE 9014
EXPOSE 9015
EXPOSE 9016
EXPOSE 9017
EXPOSE 9018
EXPOSE 9019
EXPOSE 9020

CMD [ "php-fpm8.2", "-F" ]
#CMD ["/usr/bin/watch", "-n", "1", "echo aaa"]
