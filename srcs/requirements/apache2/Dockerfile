FROM debian:12

#ENV TERM=xterm

RUN apt update && apt install -y apache2 libapache2-mod-fcgid software-properties-common python3-launchpadlib
RUN add-apt-repository -y ppa:certbot/certbot
RUN apt install -y certbot python3-certbot-apache

RUN rm /etc/apache2/sites-enabled/*
RUN mkdir -p /etc/apache2/certificate

COPY ./requirements/apache2/conf/confs/* /etc/apache2/sites-enabled
COPY ./requirements/apache2/conf/certs/* /etc/apache2/certificate

RUN a2enmod proxy
RUN a2enmod proxy_fcgi
RUN a2enmod ssl
RUN a2enmod rewrite

CMD ["apache2ctl", "-DFOREGROUND"]
# CMD ["/usr/bin/watch", "-n", "1", "echo aaa"]
