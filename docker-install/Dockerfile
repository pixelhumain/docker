FROM debian

# Install repos lists
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.2 main" | \
    tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# Add key and install packages
# TODO Key problem for mongodb
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
    apt-get update && \
    apt-get install --force-yes -y \
      mongodb-org-shell \
      mongodb-org-tools && \
    apt-get install -my \
      git \
      php5-cli \
      zip \ 
      supervisor \
      wget && \
    rm /etc/supervisor/supervisord.conf

COPY install-conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY install.sh /usr/bin/install

# No entry point, could be used as a scratch machine
