FROM debian:jessie

# Install repos lists
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | \
    tee /etc/apt/sources.list.d/mongodb-org-3.4.list

# Add key and install packages
# TODO Key problem for mongodb
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    apt-get update && \
    apt-get install --force-yes -y \
      mongodb-org-shell \
      mongodb-org-tools && \
    apt-get install -my \
      git \
      curl \
      php5-curl \
      php5-cli \
      zip \
      supervisor \
      wget && \
    rm /etc/supervisor/supervisord.conf

COPY install-conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY install.sh /usr/bin/install
COPY easyoptions.sh /usr/bin/easyoptions
COPY asciiart.sh /usr/bin/asciiart
COPY cotools.sh /usr/bin/cotools
COPY update.sh /usr/bin/update

# No entry point, could be used as a scratch machine
