FROM debian:12


# Set the timezone, to fix possible timezone issue
ENV TZ=Europe/London
ENV DEBIAN_FRONTEND=noninteract

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Upgrade and install ondrej PPA
RUN apt-get update && apt-get dist-upgrade -y \
    && apt-get install -y apt-transport-https ca-certificates curl git gpg

# Expose port 80 for the web requests
EXPOSE 80

# Add the repository for later versions of PHP.
RUN curl -fsSL https://packages.sury.org/php/apt.gpg \
  | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ bookworm main" \
  > /etc/apt/sources.list.d/php.list


# Install the relevant packages
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    vim apache2 curl wget libapache2-mod-php8.4 git unzip cron supervisor \
    php8.4-cli php8.4-mbstring php8.4-xml php8.4-mysql php8.4-zip php8.4-gd php8.4-xml php8.4-yaml \
    php8.4-curl php8.4-zip php8.4-bz2

# Enable the php mod we just installed
RUN a2enmod php8.4 && a2enmod rewrite && a2enmod headers


# Manually set the apache environment variables in order to get apache to work immediately.
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_RUN_DIR=/var/run/apache2

# It appears that the new apache requires these env vars as well
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid


# Set display errors to on, we can decide in the application layer whether to hide or not based on the environment.
# Also bump up limits like the maximum
# upload size and memory limits, as we want to allow admins to upload massive hoard files and download large
# generated PDFs.
RUN sed -i 's;display_errors = .*;display_errors = Off;' /etc/php/8.4/apache2/php.ini



# install composer directly rather tahn from packages
RUN apt update \
  && apt install curl -y \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/bin/composer \
  && chmod +x /usr/bin/composer

RUN mkdir -p /var/www/site \
    && chown root:www-data /var/www/site  \
    && chmod u=rwX,g=rX,o= /var/www/site  \
    && chmod g+s /var/www/site

RUN cd /var/www/site &&  \
    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.tar.gz \
    && tar --extract --gzip --file phpMyAdmin-5.2.3-all-languages.tar.gz  \
    && mv -i phpMyAdmin-5.2.3-all-languages/ phpmyadmin  \
    && rm phpMyAdmin-5.2.3-all-languages.tar.gz



# Running this manually to set sticky bit on the directory as setting
# 2750 on the previous copy does not seem to work.
RUN chmod g+s /var/www/site


# Update our apache sites available with the config we created
ADD docker/apache-config.conf /etc/apache2/sites-enabled/000-default.conf
ADD docker/apache-ssl-config.conf /etc/apache2/sites-available/apache-ssl-config.conf


# Add supervisor config
COPY --chown=root:root docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add script for generating confg yaml file
COPY docker/generate-yaml-config.php /root/generate-yaml-config.php

# add our include script that will load settings from our geenrated yaml config file.
COPY --chown=root:www-data --chmod=750 docker/config.inc.php /var/www/site/phpmyadmin/config.inc.php

# Add the startup script to the container
COPY docker/startup.sh /root/startup.sh

# Execute the containers startup script which will start many processes/services
# The startup file was already added when we added "project"
CMD ["/bin/bash", "/root/startup.sh"]

